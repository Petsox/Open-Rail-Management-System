local component = require("component")
local gpu = component.gpu
gpu.setResolution(160,50)
local gui = require("gui")
local SaS = require("SaS")
local computer = require("computer")
local event = require("event")
local ormslib = require("ormsLib")

gui.checkVersion(2,5)
 
local prgName = "RMS"
local version = "v1.0"
local color = 0xffffff

-- Begin: Callbacks

local function exitButtonCallback(guiID, id)
   local result = gui.getYesNo("", "Do you really want to exit?", "")
   if result == true then
      SaS.reset()
      computer.shutdown()
   end
   gui.displayGui(mainGui)
end

local function Switch(guiID, widgetID, name)
   ormslib.Switch(mainGui, widgetID, gui.getName(mainGui, widgetID))
end

local function Signal(name, widgetID)
   ormslib.Signal(gui.getName(mainGui, widgetID), widgetID)
end

-- End: Callbacks

-- Begin: Menu definitions
mainGui = gui.newGui(2, 2, 158, 48, true)
-- Station Names
Lednice = gui.newLabel(mainGui, 88, 1, " LEDNICE ", 0x0000FF, color, 7)
VyhZiznikov = gui.newLabel(mainGui, 131, 6, " VYH. ZIZNIKOV ", 0x0000FF, color, 15)
VyhStraky = gui.newLabel(mainGui, 29, 9, " VYH. STRAKY ", 0x0000FF, color, 13)
Pilnikov = gui.newLabel(mainGui, 72, 13, " PILNIKOV ", 0x0000FF, color, 10)
Brno = gui.newLabel(mainGui, 45, 33, " BRNO ", 0x0000FF, color, 6)
KalnaVoda = gui.newLabel(mainGui, 89, 34, " KALNA VODA ", 0x0000FF, color, 13)
Krupka = gui.newLabel(mainGui, 30, 39, " KRUPKA ", 0x0000FF, color, 8)
Svoboda = gui.newLabel(mainGui, 71, 45, " SVOBODA n. UPOU ", 0x0000FF, color, 17)
-- End Station Names

-- Signals
--    dirs: < > V ^
--Pilníkov
PiVBr1 = gui.newSignal(mainGui, 60, 21, "PiVBr1", 0xFF0000, ">", Signal)
PiNBr1 = gui.newSignal(mainGui, 71, 21, "PiNBr1", 0xFF0000, ">", Signal)
PiN1 = gui.newSignal(mainGui, 71, 27, "PiN1", 0xFF0000, ">", Signal)
PiN2 = gui.newSignal(mainGui, 71, 29, "PiN2", 0xFF0000, ">", Signal)
PiN3 = gui.newSignal(mainGui, 71, 19, "PiN3", 0xFF0000, ">", Signal)
PiN4 = gui.newSignal(mainGui, 73, 25, "PiN4", 0xFF0000, "<", Signal)
PiN5 = gui.newSignal(mainGui, 75, 15, "PiN5", 0xFF0000, "<", Signal)
PiN6 = gui.newSignal(mainGui, 89, 23, "PiN6", 0xFF0000, "<", Signal)
PiN7 = gui.newSignal(mainGui, 92, 17, "PiN7", 0xFF0000, "^", Signal)
PiN8 = gui.newSignal(mainGui, 92, 14, "PiN8", 0xFF0000, "V", Signal)
PiN9 = gui.newSignal(mainGui, 90, 12, "PiN9", 0xFF0000, "V", Signal)
PiN10 = gui.newSignal(mainGui, 88, 12, "PiN10", 0xFF0000, "V", Signal)
PiOBr4 = gui.newSignal(mainGui, 75, 17, "PiOBr4", 0xFF0000, "<", Signal)
PiOBr3 = gui.newSignal(mainGui, 75, 19, "PiOBr3", 0xFF0000, "<", Signal)
PiOBr2 = gui.newSignal(mainGui, 75, 21, "PiOBr2", 0xFF0000, "<", Signal)
PiOBr1 = gui.newSignal(mainGui, 75, 23, "PiOBr1", 0xFF0000, "<", Signal)
PiOZi1 = gui.newSignal(mainGui, 81, 17, "PiOZi1", 0xFF0000, ">", Signal)
PiOZi2 = gui.newSignal(mainGui, 81, 19, "PiOZi2", 0xFF0000, ">", Signal)
PiOZi3 = gui.newSignal(mainGui, 83, 21, "PiOZi3", 0xFF0000, ">", Signal)
PiOZi4 = gui.newSignal(mainGui, 85, 23, "PiOZi4", 0xFF0000, ">", Signal)
PiOZi5 = gui.newSignal(mainGui, 85, 25, "PiOZi5", 0xFF0000, ">", Signal)
PiOZi6 = gui.newSignal(mainGui, 85, 27, "PiOZi6", 0xFF0000, ">", Signal)
PiOZi7 = gui.newSignal(mainGui, 85, 29, "PiOZi7", 0xFF0000, ">", Signal)
PiOZi8 = gui.newSignal(mainGui, 90, 18, "PiOZi8", 0xFF0000, "V", Signal)
PiVZi1 = gui.newSignal(mainGui, 105, 21, "PiVZi1", 0xFF0000, "<", Signal)
PiVZi2 = gui.newSignal(mainGui, 97, 21, "PiVZi2", 0xFF0000, "<", Signal)
PiVZi3 = gui.newSignal(mainGui, 97, 23, "PiVZi3", 0xFF0000, "<", Signal)
PiVKa1 = gui.newSignal(mainGui, 100, 25, "PiVKa1", 0xFF0000, "<", Signal)
-- Lednice
LeOS1 = gui.newSignal(mainGui, 90, 3, "LeOSt1", 0xFF0000, "<", Signal)
LeOS2 = gui.newSignal(mainGui, 90, 5, "LeOSt2", 0xFF0000, "<", Signal)
LeOZ1 = gui.newSignal(mainGui, 93, 5, "LeOZi1", 0xFF0000, ">", Signal)
LeOZ2 = gui.newSignal(mainGui, 93, 7, "LeOZi2", 0xFF0000, ">", Signal)
LeVZ1 = gui.newSignal(mainGui, 98, 5, "LeVZi1", 0xFF0000, "<", Signal)
LeVS1 = gui.newSignal(mainGui, 85, 7, "LeVSt1", 0xFF0000, ">", Signal)
-- Vyh. Straky
StVLe1 = gui.newSignal(mainGui, 27, 8, "StVLe1", 0xFF0000, "V", Signal)
StVKr1 = gui.newSignal(mainGui, 27, 20, "StVKr1", 0xFF0000, "^", Signal)
StOKr1 = gui.newSignal(mainGui, 22, 16, "StOKr1", 0xFF0000, "V", Signal)
StOKr2 = gui.newSignal(mainGui, 24, 16, "StOKr2", 0xFF0000, "V", Signal)
StOKr3 = gui.newSignal(mainGui, 26, 16, "StOKr3", 0xFF0000, "V", Signal)
StOKr4 = gui.newSignal(mainGui, 28, 16, "StOKr4", 0xFF0000, "V", Signal)
StOLe1 = gui.newSignal(mainGui, 24, 12, "StOLe1", 0xFF0000, "^", Signal)
StOLe2 = gui.newSignal(mainGui, 26, 12, "StOLe2", 0xFF0000, "^", Signal)
StOLe3 = gui.newSignal(mainGui, 28, 12, "StOLe3", 0xFF0000, "^", Signal)
StOLe4 = gui.newSignal(mainGui, 30, 12, "StOLe4", 0xFF0000, "^", Signal)
--Vyh. Ziznikov
ZiVLe1 = gui.newSignal(mainGui, 120, 7, "ZiVLe1", 0xFF0000, ">", Signal)
ZiVPi1 = gui.newSignal(mainGui, 120, 23, "ZiVPi1", 0xFF0000, ">", Signal)
ZiOPi1 = gui.newSignal(mainGui, 127, 19, "ZiOPi1", 0xFF0000, "V", Signal)
ZiOPi2 = gui.newSignal(mainGui, 129, 17, "ZiOPi2", 0xFF0000, "V", Signal)
ZiOPi3 = gui.newSignal(mainGui, 131, 15, "ZiOPi3", 0xFF0000, "V", Signal)
ZiOPi4 = gui.newSignal(mainGui, 133, 15, "ZiOPi4", 0xFF0000, "V", Signal)
ZiOLe1 = gui.newSignal(mainGui, 129, 8, "ZiOLe1", 0xFF0000, "^", Signal)
ZiOLe2 = gui.newSignal(mainGui, 131, 10, "ZiOLe2", 0xFF0000, "^", Signal)
ZiOLe3 = gui.newSignal(mainGui, 133, 12, "ZiOLe3", 0xFF0000, "^", Signal)
ZiOLe4 = gui.newSignal(mainGui, 135, 12, "ZiOLe4", 0xFF0000, "^", Signal)
-- Krupka
KrVSt1 = gui.newSignal(mainGui, 27, 43, "KrVSt1", 0xFF0000, ">", Signal)
KrVBr1 = gui.newSignal(mainGui, 39, 41, "KrVBr1", 0xFF0000, "<", Signal)
KrOSt1 = gui.newSignal(mainGui, 30, 41, "KrOSt1", 0xFF0000, "<", Signal)
KrOBr1 = gui.newSignal(mainGui, 35, 43, "KrOBr1", 0xFF0000, ">", Signal)
--Brno
BrVPi1 = gui.newSignal(mainGui, 52, 27, "BrVPi1", 0xFF0000, "V", Signal)
BrVKr1 = gui.newSignal(mainGui, 55, 39, "BrVKr1", 0xFF0000, "^", Signal)
BrOPi1 = gui.newSignal(mainGui, 55, 29, "BrOPi1", 0xFF0000, "^", Signal)
BrOKr1 = gui.newSignal(mainGui, 52, 37, "BrOKr1", 0xFF0000, "V", Signal)
--Kalná Voda
KaVPi1 = gui.newSignal(mainGui, 104, 29, "KaVPi1", 0xFF0000, "V", Signal)
KaOSv1 = gui.newSignal(mainGui, 104, 39, "KaOSv1", 0xFF0000, "V", Signal)
KaVSv1 = gui.newSignal(mainGui, 106, 40, "KaVSv1", 0xFF0000, "^", Signal)
KaOPi1 = gui.newSignal(mainGui, 106, 30, "KaOPi1", 0xFF0000, "^", Signal)
--Svoboda n. Upou
SvVKa1 = gui.newSignal(mainGui, 90, 41, "SvVKa1", 0xFF0000, "<", Signal)
SvOKa1 = gui.newSignal(mainGui, 88, 43, "SvOKa1", 0xFF0000, ">", Signal)
-- End Signals

--Tracks
Lednice = {
   gui.newLabel(mainGui, 89, 4, "╔════╗", 0x000000, color, 6),
   gui.newLabel(mainGui, 89, 5, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 94, 5, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 90, 6, "════", 0x000000, color, 6),
   gui.newLabel(mainGui, 95, 6, "═════════════════════════════════", 0x000000, color, 33),
   gui.newLabel(mainGui, 27, 6, "══════════════════════════════════════════════════════════════", 0x000000, color, 62),
}

Vyh_Straky = {
   gui.newLabel(mainGui, 25, 10, "╔", 0x000000, color, 1),
   gui.newLabel(mainGui, 27, 10, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 24, 11, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 28, 11, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 23, 11, "╔", 0x000000, color, 1),
   gui.newLabel(mainGui, 29, 11, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 26, 6, "╔", 0x000000, color, 1),
   gui.newMultiLineLabel(mainGui, 26, 6, 1, 0, "|||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 23, 11, 1, 0, "|||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 25, 11, 1, 0, "|||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 27, 11, 1, 0, "|||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 29, 11, 1, 0, "|||||", 0x000000, color),
   gui.newLabel(mainGui, 23, 17, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 29, 17, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 24, 17, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 28, 17, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 25, 18, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 27, 18, "╝", 0x000000, color, 1),
   gui.newMultiLineLabel(mainGui, 26, 18, 1, 0, "|||||||||||||||||||||||", 0x000000, color)
}

Vyh_Ziznikov = {
   gui.newLabel(mainGui, 128, 6, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 128, 22, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 128, 21, "║", 0x000000, color, 1),
   gui.newMultiLineLabel(mainGui, 128, 7, 1, 0, "||||||||||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 130, 9, 1, 0, "||||||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 132, 11, 1, 0, "||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 134, 11, 1, 0, "||||", 0x000000, color),
   gui.newLabel(mainGui, 129, 7, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 129, 20, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 131, 9, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 131, 18, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 133, 11, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 133, 16, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 130, 7, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 132, 9, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 134, 11, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 130, 20, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 132, 18, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 134, 16, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 130, 8, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 130, 19, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 132, 17, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 132, 10, "║", 0x000000, color, 1),
}

Krupka = {
   gui.newLabel(mainGui, 27, 42, "══════════════════════════", 0x000000, color, 26),
   gui.newLabel(mainGui, 53, 42, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 26, 42, "╚", 0x000000, color, 1),
}

Brno = {
   gui.newMultiLineLabel(mainGui, 53, 20, 1, 0, "|||||||||||||||||||||", 0x000000, color),
   gui.newLabel(mainGui, 53, 20, "╔", 0x000000, color, 1),
}

Pilnikov = {
   gui.newLabel(mainGui, 89, 8, "╥", 0x000000, color, 1),
   gui.newLabel(mainGui, 91, 8, "╥", 0x000000, color, 1),
   gui.newLabel(mainGui, 93, 8, "╥", 0x000000, color, 1),
   gui.newLabel(mainGui, 105, 26, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 72, 16, "╔", 0x000000, color, 1),
   gui.newLabel(mainGui, 72, 17, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 74, 19, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 91, 14, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 73, 18, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 73, 20, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 73, 22, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 87, 26, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 89, 24, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 85, 20, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 83, 18, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 72, 27, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 72, 28, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 86, 27, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 86, 28, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 88, 25, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 88, 26, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 103, 23, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 103, 24, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 82, 16, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 82, 17, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 84, 18, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 84, 19, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 86, 20, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 86, 21, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 93, 20, "╗", 0x000000, color, 1),
   gui.newLabel(mainGui, 93, 21, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 72, 21, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 72, 22, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 72, 21, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 72, 22, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 74, 23, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 74, 24, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 90, 25, "║", 0x000000, color, 1),
   gui.newLabel(mainGui, 90, 26, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 92, 20, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 91, 20, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 90, 13, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 89, 13, "╚", 0x000000, color, 1),
   gui.newLabel(mainGui, 92, 15, "═", 0x000000, color, 1),
   gui.newLabel(mainGui, 93, 15, "╝", 0x000000, color, 1),
   gui.newLabel(mainGui, 75, 18, "═══════", 0x000000, color, 7),
   gui.newLabel(mainGui, 65, 18, "╞══════", 0x000000, color, 7),
   gui.newLabel(mainGui, 65, 26, "╞══════", 0x000000, color, 7),
   gui.newLabel(mainGui, 65, 28, "╞══════", 0x000000, color, 7),
   gui.newLabel(mainGui, 87, 22, "══════", 0x000000, color, 6),
   gui.newLabel(mainGui, 80, 28, "╞═════", 0x000000, color, 6),
   gui.newLabel(mainGui, 75, 20, "═════════", 0x000000, color, 9),
   gui.newLabel(mainGui, 73, 16, "═════════", 0x000000, color, 9),
   gui.newLabel(mainGui, 94, 22, "═════════", 0x000000, color, 9),
   gui.newLabel(mainGui, 75, 22, "═══════════", 0x000000, color, 11),
   gui.newLabel(mainGui, 91, 24, "════════════", 0x000000, color, 12),
   gui.newLabel(mainGui, 75, 24, "═════════════", 0x000000, color, 13),
   gui.newLabel(mainGui, 73, 26, "═════════════", 0x000000, color, 13),
   gui.newLabel(mainGui, 91, 26, "══════════════", 0x000000, color, 14),
   gui.newLabel(mainGui, 54, 20, "══════════════════", 0x000000, color, 18),
   gui.newLabel(mainGui, 104, 22, "════════════════════════", 0x000000, color, 24),
   gui.newMultiLineLabel(mainGui, 91, 15, 1, 0, "||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 89, 8, 1, 0, "||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 91, 8, 1, 0, "||||", 0x000000, color),
   gui.newMultiLineLabel(mainGui, 93, 8, 1, 0, "||||||", 0x000000, color),
}

Kalna_Voda = {
   gui.newMultiLineLabel(mainGui, 105, 26, 1, 0, "|||||||||||||||", 0x000000, color),
   gui.newLabel(mainGui, 105, 42, "╝", 0x000000, color, 1),
}

Svoboda = {
   gui.newLabel(mainGui, 77, 42, "╞═══════════════════════════", 0x000000, color, 28),
}

-- End Tracks
-- Switches
Lednice = {
   LeSw1 = gui.newSwitch(mainGui, 89, 6, "╝", "═", "LeSw1", Switch),
   LeSw2 = gui.newSwitch(mainGui, 94, 6, "╚", "═", "LeSw2", Switch)
}

Vyh_Straky = {
   gui.newSwitch(mainGui, 26, 10, "╝", "╚", "StSw1", Switch),
   gui.newSwitch(mainGui, 25, 11, "╝", "║", "StSw2", Switch),
   gui.newSwitch(mainGui, 27, 11, "╚", "║", "StSw3", Switch),
   gui.newSwitch(mainGui, 25, 17, "╗", "║", "StSw4", Switch),
   gui.newSwitch(mainGui, 27, 17, "╔", "║", "StSw5", Switch),
   gui.newSwitch(mainGui, 26, 18, "╔", "╗", "StSw6", Switch)
}

Vyh_Ziznikov = {
   gui.newSwitch(mainGui, 128, 7, "╚", "║", "ZiSw1", Switch),
   gui.newSwitch(mainGui, 130, 9, "╚", "║", "ZiSw2", Switch),
   gui.newSwitch(mainGui, 132, 11, "╚", "║", "ZiSw3", Switch),
   gui.newSwitch(mainGui, 128, 20, "╔", "║", "ZiSw4", Switch),
   gui.newSwitch(mainGui, 130, 18, "╔", "║", "ZiSw5", Switch),
   gui.newSwitch(mainGui, 132, 16, "╔", "║", "ZiSw6", Switch),
}

Pilnikov = {
   gui.newSwitch(mainGui, 72, 18, "╝", "═", "PiSw1", Switch),
   gui.newSwitch(mainGui, 72, 20, "╗", "═", "PiSw2", Switch),
   gui.newSwitch(mainGui, 72, 26, "╔", "═", "PiSw3", Switch),
   gui.newSwitch(mainGui, 74, 18, "╔", "═", "PiSw4", Switch),
   gui.newSwitch(mainGui, 74, 20, "╝", "═", "PiSw5", Switch),
   gui.newSwitch(mainGui, 74, 22, "╗", "═", "PiSw6", Switch),
   gui.newSwitch(mainGui, 82, 18, "╚", "═", "PiSw7", Switch),
   gui.newSwitch(mainGui, 84, 20, "╚", "═", "PiSw8", Switch),
   gui.newSwitch(mainGui, 86, 22, "╚", "═", "PiSw9", Switch),
   gui.newSwitch(mainGui, 86, 26, "╔", "═", "PiSw10", Switch),
   gui.newSwitch(mainGui, 88, 24, "╔", "═", "PiSw11", Switch),
   gui.newSwitch(mainGui, 90, 24, "╗", "═", "PiSw12", Switch),
   gui.newSwitch(mainGui, 93, 22, "╚", "═", "PiSw13", Switch),
   gui.newSwitch(mainGui, 103, 22, "╔", "═", "PiSw14", Switch),
   gui.newSwitch(mainGui, 91, 13, "╗", "║", "PiSw15", Switch),
   gui.newSwitch(mainGui, 91, 15, "╔", "║", "PiSw16", Switch),
}

-- End Switches
exitButton = gui.newButton(mainGui, 153, 48, "exit", exitButtonCallback)
-- End: Menu definitions
 
gui.clearScreen()
gui.setTop("Open-Rail-Management-System by Petsox")
gui.setBottom("Made with Gui library v2.5 reworked and rewritten by Petsox")


-- Main loop
while true do
   gui.runGui(mainGui)
end