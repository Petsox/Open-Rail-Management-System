local event = require("event")
local component = require("component")
local gui = require("gui")
local ormslib = {}

local signalRunning = false
local signalNoValue = false

signalGui = gui.newGui("center", "center", 40, 10, true, "Signal" )
signalMsgLabel1 = gui.newLabel(signalGui, "center", 3, "")
signalNoYesButton = gui.newButton(signalGui, 3, 8, "yes", yesNoCallbackYes)
signalNoNoButton = gui.newButton(signalGui, 33, 8, "no", yesNoCallbackNo)

function ormslib.Signal(name)
   signalRunning = true
   gui.displayGui(signalGui)
   gui.setText(signalGui, signalMsgLabel1, "name" or "")
   while signalNoRunning == true do
     gui.runGui(signalNoGui)
   end
   gui.closeGui(signalNoGui)
   return signalNoValue
 end

return ormslib