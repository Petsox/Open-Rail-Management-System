local component = require("component")
local gpu = component.gpu
gpu.setResolution(160,50)
local gui = require("gui")
local event = require("event")
local ormslib = require("ormslib")

gui.checkVersion(2,5)
 
local prgName = "RMS"
local version = "v0.5"
local color = 0xffffff

-- Begin: Callbacks

local function exitButtonCallback(guiID, id)
   local result = gui.getYesNo("", "Do you really want to exit?", "")
   if result == true then
      gui.exit()
   end
   gui.displayGui(mainGui)
end

local function Switch(guiID, widgetID)
   ormslib.Switch(guiID, widgetID)
end

local function Signal(name, widgetID)
   ormslib.Signal(gui.getName(mainGui, widgetID), widgetID)
end

-- End: Callbacks

-- Begin: Menu definitions
mainGui = gui.newGui(2, 2, 158, 48, true)
-- Station Names
Lednice = gui.newLabel(mainGui, 88, 2, " LEDNICE ", 0x0000FF, color, 7)
VyhZiznikov = gui.newLabel(mainGui, 131, 6, " VYH. ZIZNIKOV ", 0x0000FF, color, 15)
VyhStraky = gui.newLabel(mainGui, 29, 9, " VYH. STRAKY ", 0x0000FF, color, 13)
Pilnikov = gui.newLabel(mainGui, 72, 14, " PILNIKOV ", 0x0000FF, color, 10)
Brno = gui.newLabel(mainGui, 45, 33, " BRNO ", 0x0000FF, color, 6)
KalnaVoda = gui.newLabel(mainGui, 107, 36, " KALNA VODA ", 0x0000FF, color, 13)
Krupka = gui.newLabel(mainGui, 30, 41, " KRUPKA ", 0x0000FF, color, 8)
Svoboda = gui.newLabel(mainGui, 71, 41, " SVOBODA n. UPOU ", 0x0000FF, color, 17)
-- End Station Names

-- Signals
LeOS1 = gui.newSignal(mainGui, 90, 3, "LeOS1", 0xFF0000, "<", Signal)
LeOS2 = gui.newSignal(mainGui, 90, 5, "LeOS2", 0xFF0000, "<", Signal)
LeOZ1 = gui.newSignal(mainGui, 93, 5, "LeOZ1", 0xFF0000, ">", Signal)
LeOZ2 = gui.newSignal(mainGui, 93, 7, "LeOZ2", 0xFF0000, ">", Signal)
LeVZ1 = gui.newSignal(mainGui, 98, 5, "LeOV1", 0xFF0000, "<", Signal)
LeVS1 = gui.newSignal(mainGui, 85, 7, "LeOV2", 0xFF0000, ">", Signal)
-- End Signals

-- Switches

-- End Switches

--Tracks
Rail1 = gui.newLabel(mainGui, 89, 4, "╔════╗", 0x000000, color, 6)
Rail2 = gui.newLabel(mainGui, 89, 5, "║", 0x000000, color, 1)
Rail3 = gui.newLabel(mainGui, 94, 5, "║", 0x000000, color, 1)
Rail4 = gui.newLabel(mainGui, 90, 6, "════", 0x000000, color, 6)
--End Tracks
exitButton = gui.newButton(mainGui, 153, 48, "exit", exitButtonCallback)
-- End: Menu definitions
 
gui.clearScreen()
gui.setTop("Rail Managment System by Petsox")
gui.setBottom("Made with Gui library v2.5 reworked by Petsox")
 
--[[
Rail1 = gui.newLabel(mainGui, 25, 10, "=========================", 0x000000, color, 7)
Switch1 = gui.newSwitch(mainGui, 23, 10, "|", Switch)
Switch2 = gui.newSwitch(mainGui, 51, 10, "|", Switch)
Signal1 = gui.newSignal(mainGui, 51, 11, "PiOB1", 0xFF0000, < Signal)
Signal2 = gui.newSignal(mainGui, 51, 12, "PiOB2", 0xFF0000, > Signal)
Rail2 = gui.newLabel(mainGui, 25, 9, "=========================", 0x000000, 0xffffff, 7)
Rail3 = gui.newLabel(mainGui, 15, 10, "=======", 0x000000, 0xffffff, 7)
Rail4 = gui.newLabel(mainGui, 53, 10, "=======", 0x000000, 0xffffff, 7)

dirs: < > V ^
]]--

-- Main loop
while true do
   gui.runGui(mainGui)
end