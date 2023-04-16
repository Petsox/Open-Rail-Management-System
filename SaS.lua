local gui = require("gui")
local component = require("component")

local boxLe_Sig = component.proxy(component.get("beab"))
local boxLe_Swi = component.proxy(component.get("354a"))
local boxSt_Sig = component.proxy(component.get("77e6"))
local boxSt_Swi = component.proxy(component.get("e718"))
local boxPi_Sig = component.proxy(component.get("f788"))
local boxPi_Swi = component.proxy(component.get("d794"))
local boxZi_Sig = component.proxy(component.get("c770"))
local boxZi_Swi = component.proxy(component.get("9724"))
local boxBr_Sig = component.proxy(component.get("f68d"))
local boxKr_Sig = component.proxy(component.get("5dfd"))
local boxKa_Sig = component.proxy(component.get("9360"))
local boxSv_Sig = component.proxy(component.get("12ad"))

local SaS = {}

function SaS.reset()

  boxLe_Sig.setEveryAspect(5)
  boxSt_Sig.setEveryAspect(5)
  boxPi_Sig.setEveryAspect(5)
  boxZi_Sig.setEveryAspect(5)
  boxBr_Sig.setEveryAspect(5)
  boxKr_Sig.setEveryAspect(5)
  boxKa_Sig.setEveryAspect(5)
  boxSv_Sig.setEveryAspect(5)
  boxLe_Swi.setEveryAspect(5)
  boxSt_Swi.setEveryAspect(5)
  boxPi_Swi.setEveryAspect(5)
  boxZi_Swi.setEveryAspect(5)

end

SaS.reset()

--Signals

function SaS.Red(signalName)

  if     string.sub(signalName, 1, 2) == "Le" then boxLe_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "St" then boxSt_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Pi" then boxPi_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Zi" then boxZi_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Br" then boxBr_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Kr" then boxKr_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Ka" then boxKa_Sig.setAspect(signalName, 5)
  elseif string.sub(signalName, 1, 2) == "Sv" then boxSv_Sig.setAspect(signalName, 5)
  end

end

function SaS.Yellow(signalName)

  if     string.sub(signalName, 1, 2) == "Le" then boxLe_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "St" then boxSt_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Pi" then boxPi_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Zi" then boxZi_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Br" then boxBr_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Kr" then boxKr_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Ka" then boxKa_Sig.setAspect(signalName, 3)
  elseif string.sub(signalName, 1, 2) == "Sv" then boxSv_Sig.setAspect(signalName, 3)
  end

end

function SaS.Green(signalName)

  if     string.sub(signalName, 1, 2) == "Le" then boxLe_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "St" then boxSt_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Pi" then boxPi_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Zi" then boxZi_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Br" then boxBr_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Kr" then boxKr_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Ka" then boxKa_Sig.setAspect(signalName, 1)
  elseif string.sub(signalName, 1, 2) == "Sv" then boxSv_Sig.setAspect(signalName, 1)
  end

end

function SaS.switchFrom(switchName)

  if     string.sub(switchName, 1, 2) == "Le" then boxLe_Swi.setAspect(switchName, 5)
  elseif string.sub(switchName, 1, 2) == "St" then boxSt_Swi.setAspect(switchName, 5)
  elseif string.sub(switchName, 1, 2) == "Pi" then boxPi_Swi.setAspect(switchName, 5)
  elseif string.sub(switchName, 1, 2) == "Zi" then boxZi_Swi.setAspect(switchName, 5)
  end

end

function SaS.switchTo(switchName)

  if     string.sub(switchName, 1, 2) == "Le" then boxLe_Swi.setAspect(switchName, 1)
  elseif string.sub(switchName, 1, 2) == "St" then boxSt_Swi.setAspect(switchName, 1)
  elseif string.sub(switchName, 1, 2) == "Pi" then boxPi_Swi.setAspect(switchName, 1)
  elseif string.sub(switchName, 1, 2) == "Zi" then boxZi_Swi.setAspect(switchName, 1)
  end

end

return SaS