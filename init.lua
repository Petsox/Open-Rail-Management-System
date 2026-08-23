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
local activeRouteSignals = {}
local crossingObjectsByName = {}
local switchGuiObjects = {}

-- signalName -> the direction of travel of the most recent route that ended AT this signal.
-- A signal used as a route's exit may deliberately face "backwards" relative to how the layout
-- actually continues from there (e.g. an Inserted VL/VS marker) -- remembering the real travel
-- direction lets a NEW route started from that same signal continue onward the way traffic was
-- actually moving, instead of blindly re-using its static printed facing.
local lastRouteTravelDir = {}

-- entranceName -> the thread waiting for a route's crossing barriers to physically come down
-- (see startCrossingArmWait). While this is set, the route's switches/crossings are already
-- thrown but its signal chain has deliberately NOT been applied yet -- signalName ==
-- activeRouteArmWait[entranceName]:kill() cancels it if the route is released early.
local activeRouteArmWait = {}

-- Reactive chaining: for a built route, activeRouteRelevant/activeRouteResult/
-- activeRouteNextName remember everything needed to recompute its whole chain of states
-- again later (not just at build time) -- entranceName -> {name=,kind=,index=} list in path
-- order, the route's own findPath result (cells/switches -- kept whole, not just
-- allStraight, so each signal's OWN segment curvature can be checked via
-- route.segmentStraight instead of the route's aggregate straight/curved flag), and the
-- name of whatever real signal was found just beyond its exit (or nil). dependents[signalName]
-- is the reverse index: which entrance routes currently have their chain depending on
-- signalName's live state, so that whenever ANY signal's state changes
-- (applyMainSignalState), everything chained off it can be recomputed and reapplied too --
-- not just at the moment a route is built.
local activeRouteRelevant = {}
local activeRouteResult = {}
local activeRouteNextName = {}
local activeRouteNextFallback = {}
local dependents = {}
local recomputingRoutes = {}

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

-- getValidStatesForSignal() returns raw SignalState objects rather than pre-stringified
-- text (unlike getState()/setState(), which explicitly go through the mod's StateToString()/
-- fromString()), so OpenComputers' automatic marshalling falls back to SignalState's generic,
-- unrelated toString() override -- which renders multi-word states as e.g. "Odnavdovjizdu"
-- instead of "OdNavDovJizdu". The controller's own setState is case-insensitive (confirmed:
-- both SignalState.contains and fromString use equalsIgnoreCase), so this only matters for
-- READING the list back; compare case-insensitively and always use our own canonical casing
-- for what we actually send/compare elsewhere in this file.
local function hasValidState(signalName, wantedState)
    local wantedLower = string.lower(wantedState)
    -- getValidStatesForSignal comes back as nil rather than an empty table when signalName
    -- has no paired receiver at all -- "or {}" treats that the same as "supports nothing",
    -- which is exactly right: hasValidState should just say no, not crash.
    for _, validState in pairs(controllers.Signals.getValidStatesForSignal(signalName) or {}) do
        if string.lower(validState) == wantedLower then
            return true
        end
    end
    return false
end

-- A downstream signal's state is treated as "restrictive" (this signal must show caution,
-- not clear) if it contains any of these -- covering every Stuj/PN variant, a standalone
-- "PosunDov", and "OdNavDovJizdu" (a shunt/departure clearance isn't a genuine main-line
-- block clear, so it doesn't justify a fully clear aspect either).
local RESTRICTIVE_SUBSTRINGS = {"Stuj", "PN", "PosunDov", "OdNavDovJizdu"}
local function isStateRestrictive(state)
    if not state then return true end
    for _, needle in ipairs(RESTRICTIVE_SUBSTRINGS) do
        if string.find(state, needle, 1, true) then
            return true
        end
    end
    return false
end

-- Function: resolveNextSignal
-- Description: Wraps route.nextSignal with the "nothing found" default: hitting an
--              unresolved switch means the next signal is genuinely unknown, so treat it as
--              the most restrictive case (as if it showed "Stuj"); running off the end of
--              the modeled track entirely is a real terminus with nothing left to protect
--              against, so treat it as fully clear ("Volno"). Returns (name, state) --
--              name is nil in both no-signal cases, so callers naturally skip any
--              name-keyed lookup (like a speed sign) for them.
local function resolveNextSignal(x, y, travelDir)
    local name, ambiguous = route.nextSignal(routeGraph, x, y, travelDir)
    if name then
        return name, controllers.Signals.getState(name)
    end
    return nil, ambiguous and "Stuj" or "Volno"
end

-- Function: defaultCurveState
-- Description: The R-prefix used for a curved segment when no physical speed sign settles
--              it (see chooseProceedState/chooseRepeaterEchoState). Czech AZD practice
--              defaults an ordinary diverging switch to 40 km/h unless a sign explicitly
--              calls for something else, so this always tries "R40"+suffix specifically --
--              never guesses at R30/R60/R80/R100, which have no real connection to this
--              particular switch and would just be whichever one happened to be listed
--              first among this signal's valid states. Falls back to nil (no prefix at all)
--              if this signal doesn't support R40 for this suffix.
local function defaultCurveState(signalName, suffix)
    local candidate = "R40" .. suffix
    if hasValidState(signalName, candidate) then
        return candidate
    end
    return nil
end

-- Function: chooseProceedState
-- Description: Picks the "route is set, proceed" state for a signal. VS/VL Inserted signals
--              always use "OdNavDovJizdu" (checked by name -- faster than querying the
--              controller, and sidesteps the casing quirk above). Other signals are asked
--              what they actually support: some shared departure signals (like "S1-3") also
--              use "OdNavDovJizdu" instead of Volno/R40...
--              downstreamState/downstreamName describe whatever signal comes right after
--              this one (see resolveNextSignal). Three possible base aspects, exactly like a
--              real distant signal: Vystraha if downstream is restrictive; OcekXX (an
--              advance speed warning, XX taken from downstream's OWN leading R-prefix, e.g.
--              downstream "R40Volno" -> "Ocek40" here) if downstream isn't restrictive but
--              still carries a speed restriction of its own; otherwise plain Volno. This
--              only looks at downstream's IMMEDIATE leading R-prefix, not any OcekYY it may
--              itself be carrying, so an advance warning doesn't keep echoing itself another
--              hop further back. allStraight is THIS signal's own segment only (see
--              route.segmentStraight) -- a curve elsewhere on the route doesn't affect it.
--              The speed prefix on top of that base aspect prefers a physical speed sign
--              posted at the next signal (getSpeedSignText) over this segment's own
--              straight/curved shape, falling back to the latter when there's no sign or
--              this signal can't show that particular speed, and to no prefix at all when
--              neither applies.
-- Function: extractDownstreamSpeed
-- Description: Pulls a speed number out of downstreamState to advance-warn about, when
--              downstream isn't restrictive but still carries one. A leading "R" prefix
--              (downstream's own required speed, e.g. "R40Volno") always counts. A
--              repeater's "Opak"-prefixed echo also counts (e.g. "OpakOcek40") -- since a
--              repeater relays whatever real signal it stands in for, this looks straight
--              through it to that speed. An ORDINARY signal's own bare advance warning
--              (plain "Ocek40", no repeater involved) does NOT chain a further hop back --
--              see the LS/S3a/S3 case: LS shows plain Volno off S3a's "Ocek40", not another
--              "Ocek40" -- that would be a preview of a preview with no real signal keeping
--              it grounded; a repeater's echo stays grounded in whatever it's relaying.
local function extractDownstreamSpeed(downstreamState, downstreamName)
    if not downstreamState then return nil end
    local speed = string.match(downstreamState, "^R(%d+)")
    if speed then return speed end
    if downstreamName and route.classifySignal(downstreamName) == "repeater" then
        speed = string.match(downstreamState, "^OpakOcek(%d+)")
        if speed then return speed end
    end
    return nil
end

local function chooseProceedState(signalName, allStraight, downstreamState, downstreamName)
    -- An Inserted (VS/VL) signal only ever shows one of two things -- "go" or its own
    -- most-restrictive "no" (chooseRestrictiveState's StujPosunZak) -- never the full
    -- Vystraha/Volno/R-prefix vocabulary a real Main signal has. It must still reflect whether
    -- what's actually downstream is clear, though: unconditionally returning "go" regardless of
    -- downstreamState (the previous behavior) let it show OdNavDovJizdu even while the real
    -- next authority beyond it sat at Stuj.
    if route.classifySignal(signalName) == "inserted" then
        return isStateRestrictive(downstreamState) and "StujPosunZak" or "OdNavDovJizdu"
    end
    if hasValidState(signalName, "OdNavDovJizdu") then
        return "OdNavDovJizdu"
    end

    local suffix
    if isStateRestrictive(downstreamState) then
        suffix = "Vystraha"
    else
        local downstreamSpeed = extractDownstreamSpeed(downstreamState, downstreamName)
        suffix = downstreamSpeed and ("Ocek" .. downstreamSpeed) or "Volno"
    end

    if downstreamName then
        local hasSign, signText = controllers.Signals.getSpeedSignText(downstreamName)
        if hasSign then
            local candidate = "R" .. signText .. suffix
            if hasValidState(signalName, candidate) then
                return candidate
            end
        end
    end

    if not allStraight then
        local prefixed = defaultCurveState(signalName, suffix)
        if prefixed then
            return prefixed
        end
    end
    return suffix
end

-- Function: chooseRepeaterEchoState
-- Description: Picks what a repeater signal (Sc/Lc) shows when echoing the state of a real
--              signal further along the route (carriedState). Starts from the same reduced
--              aspect "Pr" expect signals use (utils.simplifyStateForPreview), then -- like
--              chooseProceedState -- defaults to also carrying "R40" when THIS repeater's own
--              incoming segment is curved (allStraight false), e.g. "R40OpakOcek40" instead
--              of plain "OpakOcek40", falling back to the plain form when this repeater has
--              no such combined state (not every speed has one, e.g. there's no
--              "R40OpakVolno").
local function chooseRepeaterEchoState(signalName, allStraight, carriedState)
    local plain = "Opak" .. utils.simplifyStateForPreview(carriedState)
    if not allStraight then
        local prefixed = defaultCurveState(signalName, plain)
        if prefixed then
            return prefixed
        end
    end
    return plain
end

-- Function: chooseRestrictiveState
-- Description: The counterpart of chooseProceedState for releasing a route -- picks each
--              signal's own most-restrictive state (Inserted signals: "StujPosunZak" by
--              name; everything else: "Stuj").
local function chooseRestrictiveState(signalName)
    if route.classifySignal(signalName) == "inserted" or hasValidState(signalName, "StujPosunZak") then
        return "StujPosunZak"
    end
    return "Stuj"
end

-- applyMainSignalState and recomputeRouteChain call each other (a route's chain applies
-- state to its signals, which in turn may need to recompute other routes chained off THEM),
-- so both are forward-declared as locals first.
local applyMainSignalState
local recomputeRouteChain

-- Function: setRouteDependency
-- Description: Updates the reverse index used for reactive recomputation: entranceName's
--              chain now depends on newNextName's live state (or nothing, if nil). Clears
--              the old registration first so a route that's rebuilt or released doesn't
--              leave a stale dependency pointing at a signal it no longer cares about.
local function setRouteDependency(entranceName, newNextName)
    local oldNextName = activeRouteNextName[entranceName]
    if oldNextName and dependents[oldNextName] then
        dependents[oldNextName][entranceName] = nil
    end
    activeRouteNextName[entranceName] = newNextName
    if newNextName then
        dependents[newNextName] = dependents[newNextName] or {}
        dependents[newNextName][entranceName] = true
    end
end

-- Function: cascadeDependents
-- Description: Called after signalName's state is actually set. Recomputes every active
--              route whose chain currently depends on signalName -- this is what makes
--              signals react live to a LATER change elsewhere, not just at the moment their
--              own route was built. Guarded against re-entering a route that's already
--              mid-recompute (only possible with a cyclic layout).
local function cascadeDependents(signalName)
    local deps = dependents[signalName]
    if not deps then return end
    for entranceName in pairs(deps) do
        if not recomputingRoutes[entranceName] then
            recomputingRoutes[entranceName] = true
            recomputeRouteChain(entranceName)
            recomputingRoutes[entranceName] = nil
        end
    end
end

-- Function: applyMainSignalState
-- Description: Sets a Main signal's state on the controller, chains the expect signal, updates
--              its GUI color, and (when set back to Stuj) releases any route it was holding:
--              unlocks switches/crossings, raises any crossing it lowered, resets every other
--              signal the route had cleared along the way, and clears the highlight. Finally,
--              cascades to any other route whose displayed state was chained off this signal.
--              Shared by the manual state menu and automatic route building.
applyMainSignalState = function(signal, signalObj, state)
    controllers.Signals.setState(signal[3], state)
    utils.sendStateToExpectSig(signal[3], state)
    setSignalStateGUI(signalObj, state, signal)
    if state == "Stuj" then
        if activeRouteArmWait[signal[3]] then
            activeRouteArmWait[signal[3]]:kill()
            activeRouteArmWait[signal[3]] = nil
        end
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
                controllers.Crossings.activate(crossingName, false)
                for _, entry in ipairs(crossingObjectsByName[crossingName] or {}) do
                    entry.obj.locked = false
                    entry.obj.state = false
                    entry.obj.color = 0xB2B2B2
                    entry.obj.text = entry.cfg[3]
                end
            end
            activeRouteCrossings[signal[3]] = nil
        end
        if activeRouteSignals[signal[3]] then
            local others = activeRouteSignals[signal[3]]
            activeRouteSignals[signal[3]] = nil
            for otherName in pairs(others) do
                if signalConfigByName[otherName] and signalGuiObjects[otherName] then
                    applyMainSignalState(signalConfigByName[otherName], signalGuiObjects[otherName], chooseRestrictiveState(otherName))
                end
            end
        end
        activeRouteRelevant[signal[3]] = nil
        activeRouteResult[signal[3]] = nil
        setRouteDependency(signal[3], nil)
    end
    workspace:draw()
    cascadeDependents(signal[3])
end

-- Function: applyRouteChainStates
-- Description: Computes and applies the state for every signal in a route's chain --
--              walking back-to-front from whatever real signal lies beyond the exit (or the
--              precomputed fallback state when there is none, see resolveNextSignal), through
--              each relevant signal, to the entrance itself -- exactly like at build time.
--              Each signal's speed prefix is decided from the curvature of its OWN segment
--              only (route.segmentStraight, between its index in result.cells and whatever
--              comes right after it), not the whole route's allStraight, so a curve near one
--              end doesn't bleed an R-prefix onto a signal whose own stretch is straight.
--              Used both right after building a route and whenever recomputeRouteChain
--              re-runs it later because something it depends on changed.
local function applyRouteChainStates(entranceSignal, entranceObj, relevant, result, nextName, nextFallback)
    local carriedName = nextName
    local carriedState = nextName and controllers.Signals.getState(nextName) or nextFallback

    local downstreamIndex = #result.cells
    for i = #relevant, 1, -1 do
        local entry = relevant[i]
        local segmentStraight = route.segmentStraight(routeGraph, result, entry.index, downstreamIndex)
        local appliedState
        if entry.kind == "repeater" and carriedName then
            appliedState = chooseRepeaterEchoState(entry.name, segmentStraight, carriedState)
        else
            appliedState = chooseProceedState(entry.name, segmentStraight, carriedState, carriedName)
            carriedState = appliedState
            carriedName = entry.name
        end
        applyMainSignalState(signalConfigByName[entry.name], signalGuiObjects[entry.name], appliedState)
        downstreamIndex = entry.index
    end

    -- The entrance itself can be a repeater too (e.g. "Lc3" standing in for a departure
    -- signal) -- it echoes the same way any repeater along the route would, not just the
    -- ones strictly in between.
    local entranceSegmentStraight = route.segmentStraight(routeGraph, result, 1, downstreamIndex)
    local entranceState
    if route.classifySignal(entranceSignal[3]) == "repeater" and carriedName then
        entranceState = chooseRepeaterEchoState(entranceSignal[3], entranceSegmentStraight, carriedState)
    else
        entranceState = chooseProceedState(entranceSignal[3], entranceSegmentStraight, carriedState, carriedName)
    end
    applyMainSignalState(entranceSignal, entranceObj, entranceState)
end

-- Function: startCrossingArmWait
-- Description: A route whose path crosses a level crossing must not clear its signals until
--              the crossing's barrier arm is physically down -- the crossing controller
--              (isArmDownFor) is polled once a second; while waiting, every crossing glyph on
--              the route flashes gray/red so the operator can see it's still lowering. The
--              route's switches/crossings/lock/highlight are already in place by the time this
--              is called (only the signal chain itself is gated), so cancelling the route
--              (applyMainSignalState ... "Stuj") works exactly as it always has -- it just also
--              kills this thread if the arm hasn't come down yet. Once every crossing confirms
--              down, the glyphs settle to their normal solid activated look and the chain is
--              applied for the first time, same as an immediate route would have been.
local function startCrossingArmWait(entranceSignal, entranceObj, relevant, result, nextName, nextFallback, crossingNames)
    local armThread = thread.create(function()
        while true do
            local allDown = true
            for _, crossingName in ipairs(crossingNames) do
                if not controllers.Crossings.isArmDownFor(crossingName) then
                    allDown = false
                    break
                end
            end

            if allDown then
                for _, crossingName in ipairs(crossingNames) do
                    for _, entry in ipairs(crossingObjectsByName[crossingName] or {}) do
                        entry.obj.color = 0xFF0000
                        entry.obj.text = entry.cfg[4]
                    end
                end
                workspace:draw()
                activeRouteArmWait[entranceSignal[3]] = nil
                applyRouteChainStates(entranceSignal, entranceObj, relevant, result, nextName, nextFallback)
                return
            end

            for _, crossingName in ipairs(crossingNames) do
                for _, entry in ipairs(crossingObjectsByName[crossingName] or {}) do
                    entry.obj.color = 0xB2B2B2
                end
            end
            workspace:draw()
            os.sleep(0.5)

            for _, crossingName in ipairs(crossingNames) do
                for _, entry in ipairs(crossingObjectsByName[crossingName] or {}) do
                    entry.obj.color = 0xFF0000
                end
            end
            workspace:draw()
            os.sleep(0.5)
        end
    end)
    activeRouteArmWait[entranceSignal[3]] = armThread
    armThread:resume()
end

-- Function: recomputeRouteChain
-- Description: Re-runs applyRouteChainStates for an already-built, still-active route, using
--              its remembered relevant/result/nextName/nextFallback (the graph topology
--              hasn't changed, only live signal states have) -- this is the reactive half of
--              the cascade triggered by cascadeDependents. Skipped while the route is still
--              waiting on a crossing arm (startCrossingArmWait) -- the chain hasn't been
--              applied even once yet, so there's nothing to recompute; the arm-wait thread
--              itself will apply it for the first time once the arm confirms down.
recomputeRouteChain = function(entranceName)
    if activeRouteArmWait[entranceName] then return end
    local relevant = activeRouteRelevant[entranceName]
    if not relevant then return end
    local entranceSignal = signalConfigByName[entranceName]
    local entranceObj = signalGuiObjects[entranceName]
    if not entranceSignal or not entranceObj then return end
    applyRouteChainStates(entranceSignal, entranceObj, relevant, activeRouteResult[entranceName],
        activeRouteNextName[entranceName], activeRouteNextFallback[entranceName])
end

-- Function: commitRoute
-- Description: Given an already-computed, already-locked route result, actually builds it:
--              throws switches, activates crossings (gating the signal chain on the crossing
--              arm if needed via startCrossingArmWait), locks the highlighted cells, and
--              applies/schedules every signal's state along the way. Shared by both ways a
--              route can be built -- clicking the exit signal directly (which calls
--              route.findPath) and clicking a plain rail cell instead (which calls
--              route.findPathThroughPoint to resolve the nearest real signal beyond the click)
--              -- exitSignal is that resolved endpoint's own config table either way; it is
--              never itself given a state, exactly like a directly-clicked exit.
local function commitRoute(entranceSignal, entranceObj, exitSignal, result)
    for switchName, icon in pairs(result.switches) do
        -- Route-thrown switches bypass their own click handler, so sync the GUI (text +
        -- toggle state) here too, or it'll silently drift from the physical position until
        -- someone happens to click it manually. Locked while the route holds it, so it can't
        -- be manually toggled out from under the route.
        local switchEntry = switchGuiObjects[switchName]
        if switchEntry then
            local toggled = (icon == switchEntry.cfg[4])
            controllers.Switches.setActive(switchName, utils.switchActivateState(switchEntry.cfg, toggled))
            switchEntry.obj.text = icon
            switchEntry.obj.state = toggled
            switchEntry.obj.locked = true
        end
    end
    activeRouteSwitches[entranceSignal[3]] = result.switches

    for crossingName in pairs(result.crossings) do
        controllers.Crossings.activate(crossingName, true)
        -- Same as switches: route-activated crossings bypass their own click handler, so sync
        -- the GUI (lowered look, matching a manual toggle) here too, not just lock it. Color is
        -- left alone here -- if the arm isn't confirmed down yet, startCrossingArmWait owns
        -- flashing it; otherwise it settles the color itself once confirmed.
        for _, entry in ipairs(crossingObjectsByName[crossingName] or {}) do
            entry.obj.locked = true
            entry.obj.state = true
            entry.obj.text = entry.cfg[4]
        end
    end
    activeRouteCrossings[entranceSignal[3]] = result.crossings

    activeRouteCells[entranceSignal[3]] = result.cells
    highlightCells(result.cells, true)

    -- Any OTHER Main/Inserted/Repeater signal genuinely passed -- in its own facing direction
    -- -- along the route (e.g. a shared departure signal like S1-3, an Inserted VL/VS marking
    -- which track is in use, or a repeater "Cestové" signal dividing the block) also gets
    -- cleared. The exit itself is a pure location marker (it may deliberately face "backwards"
    -- relative to the route) and never gets a state, and neither does anything only passed
    -- against its own facing.
    local usedInserted = {}
    local touchedAlongRoute = {}
    if route.classifySignal(entranceSignal[3]) == "inserted" then
        usedInserted[entranceSignal[3]] = true
    end

    local exitTravelDir = nil
    local relevant = {}
    for _, passed in ipairs(route.signalsAlongRoute(routeGraph, result)) do
        if passed.name == exitSignal[3] then
            exitTravelDir = passed.travelDir
        end
        local passedSignal = routeGraph.signalsByName[passed.name]
        if passed.name ~= entranceSignal[3] and passed.name ~= exitSignal[3]
            and passed.travelDir == passedSignal.dir
            and (passedSignal.kind == "main" or passedSignal.kind == "inserted" or passedSignal.kind == "repeater")
            and signalConfigByName[passed.name] and signalGuiObjects[passed.name] then
            relevant[#relevant + 1] = {name = passed.name, kind = passedSignal.kind, index = passed.index}
        end
    end
    for _, entry in ipairs(relevant) do
        touchedAlongRoute[entry.name] = true
        if entry.kind == "inserted" then
            usedInserted[entry.name] = true
        end
    end

    -- Remember which direction this route was actually traveling when it reached the exit --
    -- lets a NEW route later started FROM this same signal continue onward the way traffic
    -- was actually moving, instead of always re-deriving it from the signal's static facing
    -- (see findPath's entranceDirOverride).
    if exitTravelDir then
        lastRouteTravelDir[exitSignal[3]] = exitTravelDir
    end

    -- Every Main/Inserted/Repeater signal along the route (entrance included) reacts to
    -- whatever comes right after it, like a real distant signal -- see
    -- applyRouteChainStates/chooseProceedState. nextName/nextFallback (the signal just beyond
    -- THIS route's own exit, or the default to use when there isn't one) are remembered so
    -- this route's chain can be recomputed later too, whenever THAT signal's own state
    -- actually changes (setRouteDependency/cascadeDependents).
    local nextName, nextFallback = resolveNextSignal(exitSignal[1], exitSignal[2], exitTravelDir)
    activeRouteRelevant[entranceSignal[3]] = relevant
    activeRouteResult[entranceSignal[3]] = result
    activeRouteNextFallback[entranceSignal[3]] = nextFallback
    setRouteDependency(entranceSignal[3], nextName)

    -- A route crossing a level crossing must not clear its signals until the barrier is
    -- physically confirmed down -- defer the chain to startCrossingArmWait instead of applying
    -- it immediately. Routes with no crossing behave exactly as before.
    if next(result.crossings) then
        local crossingNames = {}
        for crossingName in pairs(result.crossings) do
            crossingNames[#crossingNames + 1] = crossingName
        end
        startCrossingArmWait(entranceSignal, entranceObj, relevant, result, nextName, nextFallback, crossingNames)
    else
        applyRouteChainStates(entranceSignal, entranceObj, relevant, result, nextName, nextFallback)
    end

    -- Remember every non-entrance signal this route cleared, so cancelling the route
    -- (right-click the entrance, or manually setting it to Stuj) puts them all back to their
    -- own most-restrictive state too.
    if next(touchedAlongRoute) then
        activeRouteSignals[entranceSignal[3]] = touchedAlongRoute
    end

    -- Reset sibling Inserted signals (other tracks feeding the same shared departure signal)
    -- that weren't part of this specific route, so only one ever shows authorized at a time.
    if next(usedInserted) then
        local entranceDirOverride = lastRouteTravelDir[entranceSignal[3]]
        for _, siblingName in ipairs(route.siblingInsertedSignals(routeGraph, entranceSignal[3], usedInserted, entranceDirOverride)) do
            if signalConfigByName[siblingName] and signalGuiObjects[siblingName] then
                applyMainSignalState(signalConfigByName[siblingName], signalGuiObjects[siblingName], "StujPosunZak")
            end
        end
    end
end

-- Function: tryBuildRouteToPoint
-- Description: Handles a click on a plain track/switch/crossing cell while Route Mode is on
--              and an entrance is pending -- lets the operator pick a route by pointing at the
--              physical track instead of needing to know the name of whatever signal lies
--              further down it (see route.findPathThroughPoint). Returns false (and does
--              nothing) if there's no route-building click to handle here, so the caller can
--              fall through to that cell's own normal behavior (e.g. manually toggling a
--              switch); returns true otherwise, whether the route actually built or an alert
--              fired for "no route"/"conflicts".
local function tryBuildRouteToPoint(x, y)
    if not (routeModeActive and pendingEntrance) then
        return false
    end

    local entranceSignal = pendingEntrance
    local entranceObj = signalGuiObjects[entranceSignal[3]]
    pendingEntrance = nil

    local entranceDirOverride = lastRouteTravelDir[entranceSignal[3]]
    local result = route.findPathThroughPoint(routeGraph, entranceSignal[3], x, y, entranceDirOverride)
    if not result then
        GUI.alert("Mezi vybranými návěstidly nelze postavit cestu / No route exists between the selected signals")
        setSignalStateGUI(entranceObj, controllers.Signals.getState(entranceSignal[3]), entranceSignal)
    elseif not route.tryLock(entranceSignal[3], result) then
        GUI.alert("Cesta koliduje s již postavenou cestou / Route conflicts with one already set")
        setSignalStateGUI(entranceObj, controllers.Signals.getState(entranceSignal[3]), entranceSignal)
    else
        commitRoute(entranceSignal, entranceObj, signalConfigByName[result.exitName], result)
    end
    workspace:draw()
    return true
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
    -- A track entry spans several cells sharing this one widget, so (unlike a switch/crossing,
    -- always exactly one cell) the specific cell clicked has to be read off the touch event
    -- itself rather than assumed from track[1]/track[2] -- lets the operator pick a route by
    -- pointing at any point along the rail instead of only at a named signal.
    newTrack.eventHandler = function(workspace, object, event, _, touchX)
        if event == "touch" then
            -- math.ceil matches how the workspace itself rounds a raw touch coordinate to a
            -- cell (see handleContainer in grapes/GUI.lua) -- has to match exactly, or a touch
            -- landing on a fractional coordinate could resolve to the wrong character of a
            -- multi-cell track run.
            if tryBuildRouteToPoint(math.ceil(touchX), track[2]) then
                workspace:draw()
            end
        end
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
            if tryBuildRouteToPoint(switch[1], switch[2]) then
                workspace:draw()
                return
            end
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
            if tryBuildRouteToPoint(crossing[1], crossing[2]) then
                workspace:draw()
                return
            end
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
    -- to depart from it). Repeater (Sc/Lc, "Cestové návěstidlo") signals are dual-purpose --
    -- they can stand on their own as a departure signal too. Only Shunting and Expect
    -- signals stay out of route building.
    local isRouteEligible = signalKind == "main" or signalKind == "inserted" or signalKind == "repeater"
    newSignal.onTouch = function(_, _, _, _, _, _, mouseButton)
        -- Right-click the entrance of an already-built route to cancel it (release the
        -- lock, unlock switches/crossings, clear the highlight) -- works regardless of
        -- whether Route Mode is currently on, since it targets a specific active route.
        if mouseButton == 1 and activeRouteCells[signal[3]] then
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

                local entranceDirOverride = lastRouteTravelDir[entranceSignal[3]]
                local result = route.findPath(routeGraph, entranceSignal[3], signal[3], entranceDirOverride)
                if not result then
                    GUI.alert("Mezi vybranými návěstidly nelze postavit cestu / No route exists between the selected signals")
                    setSignalStateGUI(entranceObj, controllers.Signals.getState(entranceSignal[3]), entranceSignal)
                elseif not route.tryLock(entranceSignal[3], result) then
                    GUI.alert("Cesta koliduje s již postavenou cestou / Route conflicts with one already set")
                    setSignalStateGUI(entranceObj, controllers.Signals.getState(entranceSignal[3]), entranceSignal)
                else
                    commitRoute(entranceSignal, entranceObj, signal, result)
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
