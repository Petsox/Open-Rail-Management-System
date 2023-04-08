local event = require("event")
local component = require("component")
local gui = require("gui")
local box1_address = component.get("198")
local box1 = component.proxy(box1_address)
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
  gui.setSignal(mainGui, signalID, 0xFF0000, true)
  box1.setAspect(signalName, 5)
  Cancel()
end

local function Yellow()
  gui.setSignal(mainGui, signalID, 0xFFFF00, true)
  box1.setAspect(signalName, 3)
  Cancel()
end

local function Green()
  gui.setSignal(mainGui, signalID, 0x00FF00, true)
  box1.setAspect(signalName, 1)
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
    if gui.getText(mainGui, widgetID) == "|" then
      gui.setText(mainGui, widgetID, "-", true)

    else
      gui.setText(mainGui, widgetID, "|", true)
  end
end

return ormslib