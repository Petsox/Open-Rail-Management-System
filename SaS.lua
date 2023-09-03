local gui = require("gui")
local component = require("component")

local boxVy = component.proxy(component.get("511d")) -- Switch controller
local boxNa = component.proxy(component.get("9a29")) -- Signal controller

local SaS = {}

function SaS.reset()
  boxVy.setEveryAspect(5)
  boxNa.setEveryAspect(5)
end

SaS.reset()

--Signals

function SaS.Red(signalName)
  boxNa.setAspect(signalName, 5)
end

function SaS.Yellow(signalName)
  boxNa.setAspect(signalName, 3)
end

function SaS.Green(signalName)
  boxNa.setAspect(signalName, 1)
end

function SaS.switchFrom(switchName)
  boxVy.setAspect(switchName, 5)
end

function SaS.switchTo(switchName)
  boxVy.setAspect(switchName, 1)
end

return SaS