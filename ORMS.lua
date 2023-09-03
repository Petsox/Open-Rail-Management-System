local component = require("component")
local gpu = component.gpu
gpu.setResolution(160, 50)
local gui = require("gui")
local term = require("term")
local SaS = require("SaS")
local computer = require("computer")
local ormslib = require("ormsLib")

gui.checkVersion(2, 5)

local prgName = "RMS"
local version = "v1.0"
local white = 0xffffff
local black = 0x000000
local red = 0xff0000

-- Begin: Callbacks

local function exitButtonCallback(guiID, id)
	local result = gui.getYesNo("", "Do you really want to exit?", "")
	if result == true then
		SaS.reset()
		term.clear()
		os.exit()
		--computer.shutdown()
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
--Paste generated code here. ORMS Layout generator available on my github.

--End Generated Code
exitButton = gui.newButton(mainGui, 153, 48, "exit", exitButtonCallback)
-- End: Menu definitions

gui.clearScreen()
gui.setTop("Open-Rail-Management-System by Petsox")
gui.setBottom("Made with Gui library v2.5 reworked and rewritten by Petsox")

-- Main loop
while true do
	gui.runGui(mainGui)
end
