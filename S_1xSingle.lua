local gui = require("gui")
local component = require("component")


local boxNa = component.proxy(component.get("9a29")) -- Signal controller

local SaS_1xSingle = {}

function SaS_1xSingle.reset()
  boxVy.setEveryAspect(5)
  boxNa.setEveryAspect(5)
end

--Signals

function SaS_1xSingle.Stuj(signalName)
  boxNa.setAspect(signalName, 5)
end

function SaS_1xSingle.Vystraha(signalName)
  boxNa.setAspect(signalName, 3)
end

function SaS_1xSingle.Volno(signalName)
  boxNa.setAspect(signalName, 1)
end

return S_1xSingle
