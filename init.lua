local GUI = require("grapes.GUI")
local term = require("term")
local config = require("config")
local utils = require("utils")
local text = require("text")
local controllers = require("controllers")
local thread = require("thread")
local screen = require("grapes.Screen")
local unicode = require("unicode")
local route = require("route")
local keyboard = require("grapes.Keyboard")

local SwitchTexts = {}
local SignalTexts = {}
local settingsWindow = nil

local routeGraph = route.buildGraph(config)
local routeModeActive = false
local pendingEntrance = nil
local cellObjects = {}
local signalGuiObjects = {}
local signalConfigByName = {}
local activeRouteCells = {}
local activeRouteSwitches = {}
local activeRouteCrossings = {}
local crossingObjectsByName = {}
local switchGuiObjects = {}

local function cellKey(x, y)
    return x .. "," .. y
end

local function highlightCells(cells, active)
    for _, c in ipairs(cells) do
        local entry = cellObjects[cellKey(c.x, c.y)]
        if entry then
            entry.obj.color = active and 0x19ED15 or entry.revertColor
        end
    end
end

local workspace = GUI.workspace()

workspace:addChild(GUI.panel(1, 1, workspace.width, workspace.height, 0x000000))

workspace:addChild(GUI.label(1, 1, workspace.width, workspace.height, 0xFFFFFF, "Open Rail Management System"):setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_TOP))
workspace:addChild(GUI.label(1, 1, workspace.width, workspace.height, 0xFFFFFF, "By Petsox and tpeterka1"):setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_BOTTOM))

-- Signal state helpers (used by both manual clicks and automatic route building)
local function startBlink(signal, signalTbl, blinkState, onColor, offColor)
    local t
    t = thread.create(function()
        while true do
            if not (controllers.Signals.getState(signalTbl[3]) == blinkState) then t:kill() end
            signal.colors.default.text = onColor
            signal.colors.pressed.text = onColor
            workspace:draw()
            if not (controllers.Signals.getState(signalTbl[3]) == blinkState) then t:kill() end
            os.sleep(0.5)
            signal.colors.default.text = offColor
            signal.colors.pressed.text = offColor
            workspace:draw()
            if not (controllers.Signals.getState(signalTbl[3]) == blinkState) then t:kill() end
            os.sleep(0.5)
        end
    end):resume()
end

local function setSignalStateGUI(signal, state, signalTbl)
    signal.colors.default.text = 0xB2B2B2
    signal.colors.pressed.text = 0xB2B2B2
    ::signal::
    if state == nil then return end
    if state == "Stuj" then
        signal.colors.default.text = 0xB2B2B2
        signal.colors.pressed.text = 0xB2B2B2
    elseif state == "Vystraha" then
        signal.colors.default.text = 0x00FF00
        signal.colors.pressed.text = 0x00FF00
    elseif state == "Volno" then
        signal.colors.default.text = 0x00FF00
        signal.colors.pressed.text = 0x00FF00
    elseif state == "PosunDov" then
        signal.colors.default.text = 0xFFFFFF
        signal.colors.pressed.text = 0xFFFFFF
    elseif state == "PosunZak" then
        signal.colors.default.text = 0xB2B2B2
        signal.colors.pressed.text = 0xB2B2B2
    elseif state == "PN" then
        startBlink(signal, signalTbl, "PN", 0xFFFFFF, 0xB2B2B2)
    elseif state == "OdNavDovJizdu" then
        -- Inserted signal: "Departure Allowed" is a flashing white light.
        startBlink(signal, signalTbl, "OdNavDovJizdu", 0xFFFFFF, 0x000000)
    elseif string.sub(state, 1, 3) == "R40" or string.sub(state, 1, 3) == "R60" or string.sub(state, 1, 3) == "R80" then
        signal.colors.default.text = 0xFFFF00
        signal.colors.pressed.text = 0xFFFF00
    elseif string.sub(state, 1, 4) == "Opak" then
        state = string.sub(state, 5)
        goto signal
    end
end

-- Function: applyMainSignalState
-- Description: Sets a Main signal's state on the controller, chains the expect signal, updates
--              its GUI color, and (when set back to Stuj) releases any route it was holding.
--              Shared by the manual state menu and automatic route building.
local function applyMainSignalState(signal, signalObj, state)
    controllers.Signals.setState(signal[3], state)
    utils.sendStateToExpectSig(signal[3], state)
    setSignalStateGUI(signalObj, state, signal)
    if state == "Stuj" then
        route.unlock(signal[3])
        if activeRouteCells[signal[3]] then
            highlightCells(activeRouteCells[signal[3]], false)
            activeRouteCells[signal[3]] = nil
        end
        if activeRouteSwitches[signal[3]] then
            for switchName in pairs(activeRouteSwitches[signal[3]]) do
                local switchEntry = switchGuiObjects[switchName]
                if switchEntry then switchEntry.obj.locked = false end
            end
            activeRouteSwitches[signal[3]] = nil
        end
        if activeRouteCrossings[signal[3]] then
            for crossingName in pairs(activeRouteCrossings[signal[3]]) do
                for _, entry in ipairs(crossingObjectsByName[crossingName] or {}) do
                    entry.obj.locked = false
                end
            end
            activeRouteCrossings[signal[3]] = nil
        end
    end
    workspace:draw()
end

-- Function: chooseProceedState
-- Description: Picks the "route is set, proceed" state for a signal by asking it what
--              states it actually supports, rather than assuming by name/kind -- Inserted
--              signals (and some shared departure signals like "S1-3") use "OdNavDovJizdu"
--              instead of Main signals' Volno/R40... vocabulary.
local function chooseProceedState(signalName, allStraight)
    local hasOdNavDovJizdu = false
    local restrictedState = nil
    for _, validState in pairs(controllers.Signals.getValidStatesForSignal(signalName)) do
        if validState == "OdNavDovJizdu" then
            hasOdNavDovJizdu = true
        elseif not restrictedState and (string.sub(validState, 1, 3) == "R40" or string.sub(validState, 1, 3) == "R60" or string.sub(validState, 1, 3) == "R80") then
            restrictedState = validState
        end
    end
    if hasOdNavDovJizdu then
        return "OdNavDovJizdu"
    end
    if not allStraight and restrictedState then
        return restrictedState
    end
    return "Volno"
end

-- Draw exit button
local exitBtn = workspace:addChild(GUI.label(155, 50, 6, 1, 0xFFFFFF, "[Exit]"))
exitBtn.eventHandler = function(workspace, object, event)
    if event == "touch" then
        utils.resetLayout()
        screen.flush()
        term.clear()
        os.exit()
    end
end

-- Draw settings
local settBtn = workspace:addChild(GUI.label(1, 50, 10, 1, 0xFFFFFF, "[Settings]"))
settBtn.eventHandler = function(workspace, object, event)
    if event == "touch" then
        if not settingsWindow then
            settingsWindow = workspace:addChild(GUI.titledWindow(workspace.width/2, workspace.height/2, 21, 20, "Settings", true))

            -- Switch number toggle
            local switchNumberStg = settingsWindow:addChild(GUI.button(3, 3, 16, 3, 0x19ED15, 0x000000, 0xED1515, 0x000000, "Switch Numbers"))
            switchNumberStg.switchMode = true
            switchNumberStg.animated = false
            if workspace.children[SwitchTexts[1]].hidden then switchNumberStg.pressed = true end
            switchNumberStg.onTouch = function()
                for _, switchText in pairs(SwitchTexts) do
                    workspace.children[switchText].hidden = not workspace.children[switchText].hidden
                end
                workspace:draw()
            end

            -- Signal description toggle
            local sigDescSetting = settingsWindow:addChild(GUI.button(3, 7, 16, 3, 0x19ED15, 0x000000, 0xED1515, 0x000000, "Signal Names"))
            sigDescSetting.switchMode = true
            sigDescSetting.animated = false
            if workspace.children[SignalTexts[1]].hidden then sigDescSetting.pressed = true end
            sigDescSetting.onTouch = function()
                for _, sigDesc in pairs(SignalTexts) do
                    workspace.children[sigDesc].hidden = not workspace.children[sigDesc].hidden
                end
                workspace:draw()
            end


            workspace:draw()
            settingsWindow.actionButtons.close.onTouch = function()
                settingsWindow:remove()
                settingsWindow = nil
            end
        end
    end
end

-- Draw route mode toggle
local routeBtn = workspace:addChild(GUI.label(12, 50, 10, 1, 0xFFFFFF, "[Route]"))
routeBtn.eventHandler = function(workspace, object, event)
    if event == "touch" then
        routeModeActive = not routeModeActive
        object.color = routeModeActive and 0x19ED15 or 0xFFFFFF
        object.text = routeModeActive and "[Route:ON]" or "[Route]"
        if pendingEntrance then
            local entranceObj = signalGuiObjects[pendingEntrance[3]]
            if entranceObj then
                setSignalStateGUI(entranceObj, controllers.Signals.getState(pendingEntrance[3]), pendingEntrance)
            end
            pendingEntrance = nil
        end
        workspace:draw()
    end
end

-- Import tracks
for _, track in pairs(config.Tracks) do
    local newTrack = workspace:addChild(GUI.text(track[1], track[2], 0xB2B2B2, text.trim(track[3]) or ""))
    local text = newTrack.text
    local revertColor = 0xB2B2B2
    if text == "⦗" or text == "⦘" or text == "︹" or text == "︺" then
        newTrack.color = 0x0000FF
        revertColor = 0x0000FF
    end
    for i = 1, unicode.len(track[3] or "") do
        cellObjects[cellKey(track[1] + i - 1, track[2])] = {obj = newTrack, revertColor = revertColor}
    end
end

-- Import switches
for _, switch in pairs(config.Switches) do
    -- Create switch button in layout
    local newSwitch = workspace:addChild(GUI.text(switch[1], switch[2], 0xB2B2B2, text.trim(switch[3]) or ""))
    newSwitch.state = false
    cellObjects[cellKey(switch[1], switch[2])] = {obj = newSwitch, revertColor = 0xB2B2B2}
    switchGuiObjects[switch[5]] = {obj = newSwitch, cfg = switch}
    newSwitch.eventHandler = function(workspace, object, event)
        if event == "touch" then
            if object.locked then return end
            -- When switch is clicked, we toggle the switch in the GUI and send the state to the controller
            object.state = not object.state
            object.text = object.state and switch[4] or switch[3]
            utils.toggleSwitch(switch, object.state)
            workspace:draw()
        end
    end

    -- Create switch description
    local newSwitchTbl = table.clone(switch)
    newSwitchTbl[5] = (string.lower(string.sub(switch[5], 1, 2)) == "vy" and string.sub(switch[5], 3, -3)) or text.trim(switch[5])
    local calculatedTextPos = utils.calcSwitchTextPos(newSwitchTbl)
    local switchName = newSwitchTbl[5]
    table.insert(SwitchTexts, workspace:addChild(GUI.text(calculatedTextPos.x, calculatedTextPos.y, 0xFFFFFF, switchName)):indexOf())
end

-- Import crossings
for _, crossing in pairs(config.Crossings) do
    -- Create crossing button in layout
    local newcrossing = workspace:addChild(GUI.text(crossing[1], crossing[2], 0xB2B2B2, text.trim(crossing[3]) or ""))
    newcrossing.state = false
    -- Multi-track crossings share one name across several (x,y) entries (one per track it
    -- protects); keep every GUI object for that name in sync so clicking any one of them
    -- updates them all, not just the one that was touched.
    crossingObjectsByName[crossing[5]] = crossingObjectsByName[crossing[5]] or {}
    table.insert(crossingObjectsByName[crossing[5]], {obj = newcrossing, cfg = crossing})
    newcrossing.eventHandler = function(workspace, object, event)
        if event == "touch" then
            if object.locked then return end
            -- When crossing is clicked, we toggle the crossing (and any sibling sharing its
            -- name) in the GUI and send the state to the controller
            local newState = not object.state
            for _, entry in ipairs(crossingObjectsByName[crossing[5]]) do
                entry.obj.state = newState
                entry.obj.color = newState and 0xFF0000 or 0xB2B2B2
                entry.obj.text = newState and entry.cfg[4] or entry.cfg[3]
            end
            utils.toggleCrossing(crossing[5], newState)
            workspace:draw()
        end
    end
end

-- Import signals
local signalMenus = {}

for _, signal in pairs(config.Signals) do
    -- Create signal button in layout
    local newSignal = workspace:addChild(GUI.button(signal[1], signal[2], 1, 1, 0x000000, 0xB2B2B2, 0x000000, 0xB2B2B2, signal[4]))
    signalMenus[signal[3]] = false
    signalGuiObjects[signal[3]] = newSignal
    signalConfigByName[signal[3]] = signal
    local signalKind = route.classifySignal(signal[3])
    -- Inserted (VS/VL) signals are valid route endpoints too -- they mark a specific track
    -- at a station where several tracks share one Main departure signal, so a route can
    -- legitimately start or end at one (e.g. S -> VS1 to arrive on track 1, then VS1 -> S1-3
    -- to depart from it). Only Shunting and Expect signals stay out of route building.
    local isRouteEligible = signalKind == "main" or signalKind == "inserted"
    newSignal.onTouch = function()
        -- Shift+click the entrance of an already-built route to cancel it (release the
        -- lock, unlock switches/crossings, clear the highlight) -- works regardless of
        -- whether Route Mode is currently on, since it targets a specific active route.
        if keyboard.isShiftDown() and activeRouteCells[signal[3]] then
            applyMainSignalState(signal, newSignal, "Stuj")
            return
        end

        -- Automatic route building: only for Main/Inserted signals, only while Route Mode is on.
        if routeModeActive and isRouteEligible then
            if not pendingEntrance then
                -- First click: remember this signal as the pending route entrance.
                pendingEntrance = signal
                newSignal.colors.default.text = 0xFFFF00
                newSignal.colors.pressed.text = 0xFFFF00
                workspace:draw()
            elseif pendingEntrance[3] == signal[3] then
                -- Clicking the pending entrance again cancels the selection.
                setSignalStateGUI(newSignal, controllers.Signals.getState(signal[3]), signal)
                pendingEntrance = nil
                workspace:draw()
            else
                -- Second click on a different Main signal: try to build the route.
                local entranceSignal = pendingEntrance
                local entranceObj = signalGuiObjects[entranceSignal[3]]
                pendingEntrance = nil

                local result = route.findPath(routeGraph, entranceSignal[3], signal[3])
                if not result then
                    GUI.alert("Mezi vybranými návěstidly nelze postavit cestu / No route exists between the selected signals")
                    setSignalStateGUI(entranceObj, controllers.Signals.getState(entranceSignal[3]), entranceSignal)
                elseif not route.tryLock(entranceSignal[3], result) then
                    GUI.alert("Cesta koliduje s již postavenou cestou / Route conflicts with one already set")
                    setSignalStateGUI(entranceObj, controllers.Signals.getState(entranceSignal[3]), entranceSignal)
                else
                    for switchName, icon in pairs(result.switches) do
                        controllers.Switches.setActive(switchName, route.isCurveGlyph(icon))
                        -- Route-thrown switches bypass their own click handler, so sync the
                        -- GUI (text + toggle state) here too, or it'll silently drift from
                        -- the physical position until someone happens to click it manually.
                        -- Locked while the route holds it, so it can't be manually toggled
                        -- out from under the route.
                        local switchEntry = switchGuiObjects[switchName]
                        if switchEntry then
                            switchEntry.obj.text = icon
                            switchEntry.obj.state = (icon == switchEntry.cfg[4])
                            switchEntry.obj.locked = true
                        end
                    end
                    activeRouteSwitches[entranceSignal[3]] = result.switches

                    for crossingName in pairs(result.crossings) do
                        controllers.Crossings.activate(crossingName, true)
                        for _, entry in ipairs(crossingObjectsByName[crossingName] or {}) do
                            entry.obj.locked = true
                        end
                    end
                    activeRouteCrossings[entranceSignal[3]] = result.crossings

                    activeRouteCells[entranceSignal[3]] = result.cells
                    highlightCells(result.cells, true)

                    -- Set the entrance's own state.
                    applyMainSignalState(entranceSignal, entranceObj, chooseProceedState(entranceSignal[3], result.allStraight))

                    -- Any OTHER Main/Inserted signal genuinely passed -- in its own facing
                    -- direction -- along the route (e.g. a shared departure signal like
                    -- S1-3, or an Inserted VL/VS marking which track is in use) also gets
                    -- cleared. The clicked exit itself is a pure location marker (it may
                    -- deliberately face "backwards" relative to the route) and never gets a
                    -- state, and neither does anything only passed against its own facing.
                    local usedInserted = {}
                    if route.classifySignal(entranceSignal[3]) == "inserted" then
                        usedInserted[entranceSignal[3]] = true
                    end
                    for _, passed in ipairs(route.signalsAlongRoute(routeGraph, result)) do
                        local passedSignal = routeGraph.signalsByName[passed.name]
                        if passed.name ~= entranceSignal[3] and passed.name ~= signal[3]
                            and passed.travelDir == passedSignal.dir
                            and (passedSignal.kind == "main" or passedSignal.kind == "inserted")
                            and signalConfigByName[passed.name] and signalGuiObjects[passed.name] then
                            applyMainSignalState(signalConfigByName[passed.name], signalGuiObjects[passed.name], chooseProceedState(passed.name, result.allStraight))
                            if passedSignal.kind == "inserted" then
                                usedInserted[passed.name] = true
                            end
                        end
                    end

                    -- Reset sibling Inserted signals (other tracks feeding the same shared
                    -- departure signal) that weren't part of this specific route, so only
                    -- one ever shows authorized at a time.
                    if next(usedInserted) then
                        for _, siblingName in ipairs(route.siblingInsertedSignals(routeGraph, entranceSignal[3], usedInserted)) do
                            if signalConfigByName[siblingName] and signalGuiObjects[siblingName] then
                                applyMainSignalState(signalConfigByName[siblingName], signalGuiObjects[siblingName], "StujPosunZak")
                            end
                        end
                    end
                end
                workspace:draw()
            end
            return
        end

        -- When signal is clicked, we first check if the menu is already open
        if signalMenus[signal[3]] == false then
            -- If not, we create the menu
            signalMenus[signal[3]] = true
            local signalMenu = workspace:addChild(GUI.titledWindow(workspace.width - 30, workspace.height - 25, 30, 25, signal[3], true))
            signalMenu.actionButtons.close.onTouch = function()
                -- When the close button is clicked, we remove the menu and set it's existence to false
                signalMenu:remove()
                signalMenus[signal[3]] = false
                setSignalStateGUI(newSignal, controllers.Signals.getState(signal[3]), signal)
            end

            -- We then add all the possible states to the menu
            for i, state in pairs(controllers.Signals.getValidStatesForSignal(signal[3])) do
                if state == "Stuj" and string.sub(signal[3], 1, 2) == "Se" then goto continue end
                local signalMenuState = signalMenu:addChild(GUI.button(5, i+1, 20, 1, 0x555555, 0x000000, 0x19ED15, 0x000000, state))
                signalMenuState.switchMode = true
                signalMenuState.animated = false
                -- PN state is highlited red (for safety reasons)
                if state == "PN" then signalMenuState.colors.default.text = 0xFC0303 end
                -- We highlight the current state that the signal is in
                local currentState = controllers.Signals.getState(signal[3])
                if currentState == state then
                    signalMenuState.pressed = true
                end
                if currentState == "Stuj" and state == "PosunZak" then signalMenuState.pressed = true end
                signalMenuState.onTouch = function()
                    -- When a state is clicked, we check if the signal is a normal signal or an expect signal
                    if not (string.sub(signal[3], 1, 2) == "Pr") then
                        -- If it's a normal signal, we set the state of the signal to the state that was clicked and we send the state to the expect signal
                        for _, signalState in pairs(signalMenu.children) do
                            signalState.pressed = false
                        end
                        signalMenuState.pressed = true
                        applyMainSignalState(signal, newSignal, state)
                    else
                        -- If it's an expect signal, we alert the user that the expect signal is controlled automatically
                        signalMenuState.pressed = false
                        if controllers.Signals.getState(signal[3]) == state then
                            signalMenuState.pressed = true
                        end
                        workspace:draw()
                        GUI.alert("Předvěsti jsou ovládány automaticky / Expect signals are controlled automatically")
                    end
                end
                ::continue::
            end
            workspace:draw()
        end
    end
    setSignalStateGUI(newSignal, controllers.Signals.getState(signal[3]), signal)

    -- Create signal description
    local newSigTbl = table.clone(signal)
    newSigTbl[3] = string.sub(signal[3], 1, -3)
    local calculatedTextPos = utils.calcSignalTextPos(newSigTbl)
    local sigName = newSigTbl[3]
    table.insert(SignalTexts, workspace:addChild(GUI.text(calculatedTextPos.x, calculatedTextPos.y, 0xFFFFFF, sigName)):indexOf())
end

-- Import labels
for _, label in pairs(config.Labels) do
    workspace:addChild(GUI.button(math.ceil(label[1] - (string.len(label[3]) / 2)), label[2], string.len(label[3]) + 2, 1, 0x0000FF, 0xFFFFFF, 0x0000FF, 0xFFFFFF, label[3]))
end

-- Reset layout
utils.resetLayout()

screen.flush()
workspace:draw()
workspace:start()
