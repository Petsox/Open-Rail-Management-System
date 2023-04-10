local component = require("component")
local gpu = component.gpu
gpu.setResolution(160,50)
local gui = require("gui")
local event = require("event")
local ormslib = require("ormslib")

gui.checkVersion(2,5)
 
local prgName = "RMS"
local version = "v0.7"
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
   ormslib.Switch(mainGui, widgetID)
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
Krupka = gui.newLabel(mainGui, 30, 39, " KRUPKA ", 0x0000FF, color, 8)
Svoboda = gui.newLabel(mainGui, 71, 41, " SVOBODA n. UPOU ", 0x0000FF, color, 17)
-- End Station Names

-- Signals
--    dirs: < > V ^
-- Lednice
LeOS1 = gui.newSignal(mainGui, 90, 3, "LeOS1", 0xFF0000, "<", Signal)
LeOS2 = gui.newSignal(mainGui, 90, 5, "LeOS2", 0xFF0000, "<", Signal)
LeOZ1 = gui.newSignal(mainGui, 93, 5, "LeOZ1", 0xFF0000, ">", Signal)
LeOZ2 = gui.newSignal(mainGui, 93, 7, "LeOZ2", 0xFF0000, ">", Signal)
LeVZ1 = gui.newSignal(mainGui, 98, 5, "LeOV1", 0xFF0000, "<", Signal)
LeVS1 = gui.newSignal(mainGui, 85, 7, "LeOV2", 0xFF0000, ">", Signal)
-- Vyh. Straky
StVLe1 = gui.newSignal(mainGui, 27, 8, "StVLe1", 0xFF0000, "V", Signal)
StVKr1 = gui.newSignal(mainGui, 27, 20, "StVKr1", 0xFF0000, "^", Signal)
StOKr1 = gui.newSignal(mainGui, 22, 16, "StOKr1", 0xFF0000, "V", Signal)
StOKr2 = gui.newSignal(mainGui, 24, 16, "StOKr2", 0xFF0000, "V", Signal)
StOKr3 = gui.newSignal(mainGui, 26, 16, "StOKr3", 0xFF0000, "V", Signal)
StOKr4 = gui.newSignal(mainGui, 28, 16, "StOKr4", 0xFF0000, "V", Signal)
StOLe1 = gui.newSignal(mainGui, 24, 12, "StOLe1", 0xFF0000, "^", Signal)
StOLe1 = gui.newSignal(mainGui, 26, 12, "StOLe2", 0xFF0000, "^", Signal)
StOLe1 = gui.newSignal(mainGui, 28, 12, "StOLe3", 0xFF0000, "^", Signal)
StOLe1 = gui.newSignal(mainGui, 30, 12, "StOLe4", 0xFF0000, "^", Signal)
-- Krupka
KrVSt1 = gui.newSignal(mainGui, 27, 43, "KrVSt1", 0xFF0000, ">", Signal)
KrVBr1 = gui.newSignal(mainGui, 39, 41, "KrVSt1", 0xFF0000, "<", Signal)
KrOSt1 = gui.newSignal(mainGui, 30, 41, "KrOSt1", 0xFF0000, "<", Signal)
KrOBr1 = gui.newSignal(mainGui, 35, 43, "KrOBr1", 0xFF0000, ">", Signal)
-- End Signals

--Tracks
Lednice = {
   gui.newLabel(mainGui, 89, 4, "╔════╗", 0x000000, color, 6),
   gui.newLabel(mainGui, 89, 5, "|", 0x000000, color, 1),
   gui.newLabel(mainGui, 94, 5, "|", 0x000000, color, 1),
   gui.newLabel(mainGui, 90, 6, "════", 0x000000, color, 6),
}

Vyh_Straky = {
   gui.newLabel(mainGui, 25, 10, "╔", 0x000000, color, 1),
   gui.newLabel(mainGui, 27, 10, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 24, 11, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 28, 11, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 23, 11, "╔", 0x000000, color, 1),
   gui.newLabel(mainGui, 29, 11, "╗", 0x000000, color, 1),
   gui.newMultiLineLabel(mainGui, 23, 11, 1, 0, "|||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 25, 11, 1, 0, "|||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 27, 11, 1, 0, "|||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 29, 11, 1, 0, "|||||", 0x000000, color),
   gui.newLabel(mainGui, 23, 17, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 29, 17, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 24, 17, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 28, 17, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 25, 17, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 27, 17, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 25, 18, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 27, 18, "╝", 0x000000, color, 1),
   gui.newMultiLineLabel(mainGui, 26, 18, 1, 0, "|||||||||||||||||||||||", 0x000000, color)
}

Krupka = {
   gui.newLabel(mainGui, 27, 42, "═══════════════════════", 0x000000, color, 23),
}
Other = {
   gui.newLabel(mainGui, 95, 6, "════════════════════════════════", 0x000000, color, 32),
   gui.newLabel(mainGui, 27, 6, "══════════════════════════════════════════════════════════════", 0x000000, color, 62),
   gui.newLabel(mainGui, 26, 6, "╔", 0x000000, color, 1),
   gui.newMultiLineLabel(mainGui, 26, 6, 1, 0, "|||", 0x000000, color),
   gui.newLabel(mainGui, 26, 42, "╚", 0x000000, color, 1),
}
-- End Tracks
-- Switches
Lednice = {
   LeSw1 = gui.newSwitch(mainGui, 89, 6, "╝", "═", Switch),
   LeSw2 = gui.newSwitch(mainGui, 94, 6, "╚", "═", Switch)
}

Vyh_Straky = {
   gui.newSwitch(mainGui, 26, 10, "╝", "╚", Switch),
   gui.newSwitch(mainGui, 25, 11, "╝", "║", Switch),
   gui.newSwitch(mainGui, 27, 11, "╚", "║", Switch),
   gui.newSwitch(mainGui, 25, 17, "╗", "║", Switch),
   gui.newSwitch(mainGui, 27, 17, "╔", "║", Switch),
   gui.newSwitch(mainGui, 26, 18, "╔", "╗", Switch)
}

-- End Switches

exitButton = gui.newButton(mainGui, 153, 48, "exit", exitButtonCallback)
-- End: Menu definitions
 
gui.clearScreen()
gui.setTop("Rail Managment System by Petsox")
gui.setBottom("Made with Gui library v2.5 reworked by Petsox")
 



-- Main loop
while true do
   gui.runGui(mainGui)
end