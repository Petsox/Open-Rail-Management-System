local component = require("component")
local gpu = component.gpu
gpu.setResolution(160, 50)
local gui = require("gui")
local term = require("term")
local SaS = require("SaS")
local controllers = require("controllers")
local computer = require("computer")
local ormslib = require("ormsLib")
local config = require("station")

gui.checkVersion(2, 5)

local white = 0xffffff
local black = 0x000000
local red = 0xff0000
local blue = 0x0000ff
local yellow = 0xffff00

-- Begin: Callbacks
local function exitButtonCallback(guiID, id)
  local result = gui.getYesNo("", "Do you really want to exit?", "")
  if result == true then
    SaS.reset()
    term.clear()
    os.exit()
  end
  gui.displayGui(mainGui)
end

local function Switch(guiID, widgetID, name)
  ormslib.Switch(mainGui, widgetID, gui.getName(mainGui, widgetID))
end

local function SignalOne(name, widgetID)
  ormslib.SignalOne(gui.getName(mainGui, widgetID), widgetID)
end

local function SignalThree(name, widgetID)
  ormslib.SignalThree(gui.getName(mainGui, widgetID), widgetID)
end

local function SignalFour(name, widgetID)
  ormslib.SignalFour(gui.getName(mainGui, widgetID), widgetID)
end

local function SignalFive(name, widgetID)
  ormslib.SignalFive(gui.getName(mainGui, widgetID), widgetID)
end

local function SignalShunt(name, widgetID)
  ormslib.SignalShunt(gui.getName(mainGui, widgetID), widgetID)
end

local function SignalExpect(name, widgetID)
  ormslib.SignalExpect(gui.getName(mainGui, widgetID), widgetID)
end
-- End: Callbacks

-- Begin: Menu definitions
mainGui = gui.newGui(2, 2, 158, 48, true)
exitButton = gui.newButton(mainGui, 153, 48, "exit", exitButtonCallback)
-- End: Menu definitions

-- Begin: Station configuration
if controllers.isConnected("Single") then
  for _,signal in pairs(config.Signal1) do
    gui.newSignal(mainGui, signal[1], signal[2], signal[3], red, signal[4], SignalOne)
  end
end

if controllers.isConnected("3UpUp") then
  for _,signal in pairs(config.Signal3) do
    gui.newSignal(mainGui, signal[1], signal[2], signal[3], red, signal[4], SignalThree)
  end
end

if controllers.isConnected("4UpUp") then
  for _,signal in pairs(config.Signal4) do
    gui.newSignal(mainGui, signal[1], signal[2], signal[3], red, signal[4], SignalFour)
  end
end

if controllers.isConnected("5UpUp") then
  for _,signal in pairs(config.Signal5) do
    gui.newSignal(mainGui, signal[1], signal[2], signal[3], red, signal[4], SignalFive)
  end
end
--Serazovaci
if controllers.isConnected("ShUp") then
  for _,signal in pairs(config.SignalSh) do
    gui.newSignal(mainGui, signal[1], signal[2], signal[3], blue, signal[4], SignalShunt)
  end
end
--Predvesti
if controllers.isConnected("ExUp") then
  for _,signal in pairs(config.SignalEx) do
    gui.newSignal(mainGui, signal[1], signal[2], signal[3], yellow, signal[4], SignalExpect)
  end
end
--Koleje
for _,track in pairs(config.Tracks) do
  gui.newLabel(mainGui, track[1], track[2], track[3], black, white, 1)
end
--Vyhybky
if controllers.isConnected("Sw") then
  for _,switch in pairs(config.Switches) do
    gui.newSwitch(mainGui, switch[1], switch[2], switch[3], switch[4], switch[5], Switch)
  end
end
-- End: Station configuration

gui.clearScreen()
gui.setTop("Open-Rail-Management-System by Petsox")
gui.setBottom("Made with Gui library v2.5 reworked and rewritten by Petsox")

-- Main loop
while true do
  gui.runGui(mainGui)
end
