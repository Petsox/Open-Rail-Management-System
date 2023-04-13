local event = require("event")
local component = require("component")
local gui = require("gui")
local SaS = require("SaS")
local ormslib = {}

local signalRunning = false
local signalValue = false
local signalID = ""
local signalName = ""

local function Cancel()
  signalRunning = false
  signalValue = true
end

--Signals

local function Red()
  SaS.Red(signalName, signalID)
  Cancel()
end

local function Yellow()
  SaS.Yellow(signalName, signalID)
  Cancel()
end

local function Green()
  SaS.Green(signalName, signalID)
  Cancel()
end

function ormslib.Signal(name, widgetID)

signalGui = gui.newGui("center", "center", 40, 10, true, "Signal " .. name )
signalCancelButton = gui.newButton(signalGui, 3, 8, "Cancel", Cancel)
signalRedButton = gui.newButton(signalGui, 3, 3, "Set Aspect to Red", Red)
signalYellowButton = gui.newButton(signalGui, 3, 4, "Set Aspect to Yellow", Yellow)
signalGreenButton = gui.newButton(signalGui, 3, 5, "Set Aspect to Green", Green)

    signalID = widgetID
    signalName = name
    signalRunning = true
    gui.displayGui(signalGui)
    while signalRunning == true do
      gui.runGui(signalGui)
    end
    gui.closeGui(signalGui)
    return signalValue
  end

--Switches

function ormslib.Switch(guiID, widgetID)
    if mainGui[widgetID].from == mainGui[widgetID].text then
      gui.setText(mainGui, widgetID, mainGui[widgetID].to, true)

    else
      gui.setText(mainGui, widgetID, mainGui[widgetID].from, true)
  end
end

return ormslib