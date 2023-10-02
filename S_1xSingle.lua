local gui = require("gui")
local component = require("component")


local boxNa = component.proxy(component.get("9a29")) -- Signal controller

local S_1xSingle = {}

function S_1xSingle.reset()
  boxNa.setEveryAspect(5)
end

--Signals

function S_1xSingle.Stuj(signalName)
  boxNa.setAspect(signalName, 5)
end

function S_1xSingle.Vystraha(signalName)
  boxNa.setAspect(signalName, 3)
end

function S_1xSingle.Volno(signalName)
  boxNa.setAspect(signalName, 1)
end

return S_1xSingle
