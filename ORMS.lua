local component = require("component")
local gpu = component.gpu
gpu.setResolution(160,50)
local gui = require("gui")
local event = require("event")
local rs = component.redstone

gui.checkVersion(2,5)
 
local prgName = "RMS"
local version = "v0.1"
local x = true
local y = true

-- Begin: Callbacks
local function Switch1(guiID, buttonID)
   if x then
      gui.setText(mainGui, LSwitch1, "-", true)
      x = false
      rs.setBundledOutput(1, 0, 200)
      os.sleep(1)
      rs.setBundledOutput(1, 0, 0)
   else
      gui.setText(mainGui, LSwitch1, "|", true)
      x = true
      rs.setBundledOutput(1, 0, 200)
      os.sleep(1)
      rs.setBundledOutput(1, 0, 0)
end

end
local function Switch2(guiID, buttonID)
   if y then
      gui.setText(mainGui, LSwitch2, "-", true)
      y = false
   else
      gui.setText(mainGui, LSwitch2, "|", true)
      y = true
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
Rail1 = gui.newLabel(mainGui, 25, 10, "=========================", 0x000000, 0xffffff, 7)
Switch1 = gui.newButton(mainGui, 22, 10, "|", Switch1)
Switch2 = gui.newButton(mainGui, 50, 10, "|", Switch2)
Rail2 = gui.newLabel(mainGui, 25, 9, "=========================", 0x000000, 0xffffff, 7)
Rail3 = gui.newLabel(mainGui, 15, 10, "=======", 0x000000, 0xffffff, 7)
Rail4 = gui.newLabel(mainGui, 53, 10, "=======", 0x000000, 0xffffff, 7)
LSwitch1 = gui.newLabel(mainGui, 23, 10, "|", 0x000000, 0xffffff, 1)
LSwitch2 = gui.newLabel(mainGui, 51, 10, "|", 0x000000, 0xffffff, 1)
exitButton = gui.newButton(mainGui, 153, 48, "exit", exitButtonCallback)
-- End: Menu definitions
 
gui.clearScreen()
gui.setTop("Rail Managment System by Petsox")
gui.setBottom("Made with Visual Gui v0.1a and Gui library v2.5")
 
-- Main loop
while true do
   gui.runGui(mainGui)
end