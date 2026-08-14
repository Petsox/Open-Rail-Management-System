local utils = {}
local Config = require("config")
local internet = require("internet")
local json = require("json")
local controllers = require("controllers")
local route = require("route")

-- Function: utils.calcSwitchTextPos
-- Description: Calculate the position of the switch text
-- Parameters: switchTbl - table containing the switch data
-- Returns: table containing the x and y position of the switch text
utils.calcSwitchTextPos = function(switchTbl)
    local result = {}
    local x, y = switchTbl[1], switchTbl[2]

    if switchTbl[3] == "╗" or switchTbl[4] == "╗" then
        y = switchTbl[2] - 1
    elseif switchTbl[3] == "╝" or switchTbl[4] == "╝" then
        y = switchTbl[2] + 1
    elseif switchTbl[3] == "╚" or switchTbl[4] == "╚" then
        y = switchTbl[2] + 1
    elseif switchTbl[3] == "╔" or switchTbl[4] == "╔" then
        y = switchTbl[2] - 1
    end
    x = switchTbl[5]:len() == 1 and x or x - 1

    result["x"] = x
    result["y"] = y
    return result
end

-- Function: utils.calcSignalTextPos
-- Description: Calculate the position of the signal text
-- Parameters: signalTbl - table containing the signal data
-- Returns: table containing the x and y position of the signal text
utils.calcSignalTextPos = function(signalTbl)
    local result = {}
    local x, y = signalTbl[1], signalTbl[2]

    if signalTbl[4] == "<" or signalTbl[4] == "◀" or signalTbl[4] == "◁" then
        x = signalTbl[1] - (string.len(signalTbl[3]) / 2)
        if string.len(signalTbl[3]) % 2 == 0 then x = x + 1 end
        y = signalTbl[2] - 1
    elseif signalTbl[4] == ">" or signalTbl[4] == "▶" or signalTbl[4] == "▷" then
        x = signalTbl[1] - (string.len(signalTbl[3]) / 2)
        if string.len(signalTbl[3]) % 2 == 0 then x = x + 1 end
        y = signalTbl[2] + 1
    elseif signalTbl[4] == "^" or signalTbl[4] == "▲" or signalTbl[4] == "△" then
        x = signalTbl[1] + 1
        y = signalTbl[2]
    elseif signalTbl[4] == "V" or signalTbl[4] == "▼" or signalTbl[4] == "▽" then
        x = signalTbl[1] - string.len(signalTbl[3])
        y = signalTbl[2]
    end

    result["x"] = x
    result["y"] = y
    return result
end

-- Function: string.split
-- Description: Splits a string by a separator
-- Parameters: inputstr - the string to split
--             sep - the separator
-- Returns: table containing the split strings
function string.split(inputstr, sep)
    if sep == nil then
       sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
       table.insert(t, str)
    end
    return t
end

-- Function: utils.debugPrint
-- Description: Logs a message to the log file if debug is enabled
-- Parameters: message - the message to print
utils.debugPrint = function(message)
    if not Config.Debug then return end

    local file = io.open("log.txt", "a")
    if not file then
        print("Failed to open log file")
        return os.exit()
    end
    local rawTime = json.decode(internet.request("https://worldtimeapi.org/api/timezone/Europe/Prague")())["datetime"]
    local time = string.split(rawTime, "T")[1] .. " " .. string.split(string.split(rawTime, "T")[2], ".")[1]
    file:write(time .. "  " .. tostring(message) .. "\n")
    file:close()
end

-- Define connected controllers
local switchesConnected = controllers.isConnected("Switches")
local signalsConnected  = controllers.isConnected("Signals")
local crossingsConnected = controllers.isConnected("Crossings")

-- Function: utils.isSwitchDefaultCurve
-- Description: Whether a switch's default (untoggled) layout icon is a curve.
--              The Universal Digital Controller's activate() is true for this default position.
-- Parameters: switch - table containing the switch data
-- Returns: boolean
utils.isSwitchDefaultCurve = function(switch)
    return route.isCurveGlyph(switch[3])
end

-- Function: utils.resetLayout
-- Description: Resets the switches, crossings and signals according to the default layout
utils.resetLayout = function()
    if switchesConnected then
        for _, switch in pairs(Config.Switches) do
            controllers.Switches.setActive(switch[5], utils.isSwitchDefaultCurve(switch))
        end
    end

    if crossingsConnected then controllers.Crossings.activateAll(false) end

    if signalsConnected then controllers.Signals.setMostRestrictiveOnAll() end
end

-- Function: utils.toggleSwitch
-- Description: Sends the switch's new toggled state to the controller
-- Parameters: switch - table containing the switch data
--             toggled - whether the switch is now showing its non-default icon
utils.toggleSwitch = function(switch, toggled)
    if not switchesConnected then return end
    controllers.Switches.setActive(switch[5], toggled ~= utils.isSwitchDefaultCurve(switch))
end

-- Function: utils.toggleCrossing
-- Description: Sends the crossing's new state to the controller
-- Parameters: crossingName - the name of the crossing
--             lowered - true lowers the barriers, false raises them
utils.toggleCrossing = function(crossingName, lowered)
    if not crossingsConnected then return end
    controllers.Crossings.activate(crossingName, lowered)
end

-- Function: utils.simplifyStateForPreview
-- Description: Maps any Main signal state down to the reduced aspect vocabulary used by
--              preview/echo signals: Vystraha, Volno, Ocek40, Ocek60, Ocek80 or Ocek100.
--              Shared by the "Pr" expect signal (sent as-is) and "Opak"-prefixed repeater
--              signals (prefixed with "Opak" -- SignalState.java only defines OpakVolno/
--              OpakVystraha/OpakOcek40/OpakOcek60/OpakOcek80/OpakOcek100, so only this
--              reduced set of results is ever valid to prefix). R30 has no Ocek30
--              counterpart in SignalState.java, so it falls through to the Vystraha default
--              same as any other unrecognized state.
-- Parameters: state - the state of the signal being echoed
-- Returns: string
utils.simplifyStateForPreview = function(state)
    if state == "Stuj" then
        return "Vystraha"
    elseif state == "PN" then
        return "Vystraha"
    elseif state == "Vystraha" then
        return "Volno"
    elseif state == "Volno" then
        return "Volno"
    elseif string.sub(state, 1, 4) == "R100" then
        return "Ocek100"
    elseif string.sub(state, 1, 3) == "R40" then
        return "Ocek40"
    elseif string.sub(state, 1, 3) == "R60" then
        return "Ocek60"
    elseif string.sub(state, 1, 3) == "R80" then
        return "Ocek80"
    elseif string.sub(state, 1, 4) == "Ocek" then
        return "Volno"
    elseif string.sub(state, 1, 4) == "Opak" then
        return string.sub(state, 5)
    else
        return "Vystraha"
    end
end

-- Function: utils.sendStateToExpectSig
-- Description: Sends the state of the signal to the expect signal
-- Parameters: signalName - the name of the signal
--             state - the state of the signal
utils.sendStateToExpectSig = function(signalName, state)
    if not signalsConnected then return end
    controllers.Signals.setState("Pr" .. signalName, utils.simplifyStateForPreview(state))
end

-- Simple shallow copy of a table
function table.clone(org)
    return {table.unpack(org)}
end

return utils, table.clone, string.split
