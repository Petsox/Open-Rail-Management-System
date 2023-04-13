local gui = require("gui")
local component = require("component")

local boxLe_Sig_address = component.get("beab")
local boxLe_Swi_address = component.get("354a")
local boxSt_Sig_address = component.get("77e6")
local boxSt_Swi_address = component.get("e718")
local boxPi_Sig_address = component.get("f788")
local boxPi_Swi_address = component.get("d794")
local boxZi_Sig_address = component.get("c770")
local boxZi_Swi_address = component.get("f788")
local boxBr_Sig_address = component.get("f68d")
local boxKr_Sig_address = component.get("5dfd")
local boxKa_Sig_address = component.get("9360")
local boxSv_Sig_address = component.get("12ad")

local boxLe_Sig = component.proxy(boxLe_Sig_address)
local boxLe_Swi = component.proxy(boxLe_Swi_address)
local boxSt_Sig = component.proxy(boxSt_Sig_address)
local boxSt_Swi = component.proxy(boxSt_Swi_address)
local boxPi_Sig = component.proxy(boxPi_Sig_address)
local boxPi_Swi = component.proxy(boxPi_Swi_address)
local boxZi_Sig = component.proxy(boxZi_Sig_address)
local boxZi_Swi = component.proxy(boxZi_Swi_address)
local boxBr_Sig = component.proxy(boxBr_Sig_address)
local boxKr_Sig = component.proxy(boxKr_Sig_address)
local boxKa_Sig = component.proxy(boxKa_Sig_address)
local boxSv_Sig = component.proxy(boxSv_Sig_address)

local SaS = {}

--Signals

function SaS.Red(signalName, signalID)

  if     string.sub(signalName, 1, 2) == "Le" then boxLe_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "St" then boxSt_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Pi" then boxPi_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Zi" then boxZi_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Br" then boxBr_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Kr" then boxKr_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Ka" then boxKa_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Sv" then boxSv_Sig.setAspect(signalName, 5)
  else print(signalName)
  end

  gui.setSignal(mainGui, signalID, 0xFF0000, true)

end

function SaS.Yellow(signalName, signalID)

  if     string.sub(signalName, 1, 2) == "Le" then boxLe_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "St" then boxSt_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Pi" then boxPi_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Zi" then boxZi_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Br" then boxBr_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Kr" then boxKr_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Ka" then boxKa_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Sv" then boxSv_Sig.setAspect(signalName, 3)
  end

  gui.setSignal(mainGui, signalID, 0xFFFF00, true)

end

function SaS.Green(signalName, signalID)

  if     string.sub(signalName, 1, 2) == "Le" then boxLe_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "St" then boxSt_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Pi" then boxPi_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Zi" then boxZi_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Br" then boxBr_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Kr" then boxKr_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Ka" then boxKa_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Sv" then boxSv_Sig.setAspect(signalName, 1)
  end

  gui.setSignal(mainGui, signalID, 0x00FF00, true)

end

return SaS