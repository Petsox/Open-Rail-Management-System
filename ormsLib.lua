local gui = require("gui")
local event = require("event")
local component = require("component")

local signalRunning = false
local yesNoValue = false

yesNoGui = gui.newGui("center", "center", 40, 10, true, "Signal" + name)
yesNoMsgLabel1 = gui.newLabel(yesNoGui, "center", 3, "")
yesNoMsgLabel2 = gui.newLabel(yesNoGui, "center", 4, "")
yesNoMsgLabel3 = gui.newLabel(yesNoGui, "center", 5, "")
yesNoYesButton = gui.newButton(yesNoGui, 3, 8, "yes", yesNoCallbackYes)
yesNoNoButton = gui.newButton(yesNoGui, 33, 8, "no", yesNoCallbackNo)

function ormsLib.Signal(name)
   signalRunning = true
   gui.displayGui(yesNoGui)
   gui.setText(yesNoGui, yesNoMsgLabel1, msg1 or "")
   gui.setText(yesNoGui, yesNoMsgLabel2, msg2 or "")
   gui.setText(yesNoGui, yesNoMsgLabel3, msg3 or "")
   while yesNoRunning == true do
     gui.runGui(yesNoGui)
   end
   gui.closeGui(yesNoGui)
   return yesNoValue
 end