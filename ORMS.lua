local component = require("component")
local gpu = component.gpu
gpu.setResolution(160,50)
local gui = require("gui")
local event = require("event")

gui.checkVersion(2,5)
 
local prgName = "RMS"
local version = "v0.1"
local color = 0xffffff

-- Begin: Callbacks
local function Switch1(guiID, buttonID)
   if gui.getText(mainGui, Switch1) == "|" then
      gui.setText(mainGui, Switch1, "-", true)

   else
      gui.setText(mainGui, Switch1, "", true)
      gui.setFgColor(mainGui, Rail1, 0xff0000, true)

end

end
local function Switch2(guiID, buttonID)
    if gui.getText(mainGui, Switch2) == "|" then
       gui.setText(mainGui, Switch2, "-", true)

   else
      gui.setText(mainGui, Switch2, "|", true)

   end
      
end

local function exitButtonCallback(guiID, id)
   local result = gui.getYesNo("", "Do you really want to exit?", "")
   if result == true then
      gui.exit()
   end
   gui.displayGui(mainGui)
end
-- End: Callbacks
 
-- Begin: Menu definitions
mainGui = gui.newGui(2, 2, 158, 48, true)
Rail1 = gui.newLabel(mainGui, 25, 10, "=========================", 0x000000, color, 7)
Switch1 = gui.newSwitch(mainGui, 23, 10, "|", Switch1)
Switch2 = gui.newSwitch(mainGui, 51, 10, "|", Switch2)
Switch2 = gui.newSignal(mainGui, 51, 10, "PiOB01")
Rail2 = gui.newLabel(mainGui, 25, 9, "=========================", 0x000000, 0xffffff, 7)
Rail3 = gui.newLabel(mainGui, 15, 10, "=======", 0x000000, 0xffffff, 7)
Rail4 = gui.newLabel(mainGui, 53, 10, "=======", 0x000000, 0xffffff, 7)
exitButton = gui.newButton(mainGui, 153, 48, "exit", exitButtonCallback)
-- End: Menu definitions
 
gui.clearScreen()
gui.setTop("Rail Managment System by Petsox")
gui.setBottom("Made with Gui library v2.5 heavly modified by Petsox")
 
-- Main loop
while true do
   gui.runGui(mainGui)
end