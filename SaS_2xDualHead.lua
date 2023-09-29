local gui = require("gui")
local component = require("component")

local boxVy = component.proxy(component.get("0aec")) -- Switch controller

local boxNaUpUp = component.proxy(component.get("b046")) -- Signal controller (top dual, top light - 0) - žlutá
local boxNaUpDn = component.proxy(component.get("7631")) -- Signal controller (top dual, bottom light - 1) - zelená

local boxNaDnUp = component.proxy(component.get("147a")) -- Signal controller (bottom dual, top light - 2) - červená
local boxNaDnDn = component.proxy(component.get("c2cb")) -- Signal controller (bottom dual, bottom light - 3) - žlutá

local SaS = {}

function SaS.reset()
  boxVy.setEveryAspect(5)
  boxNaUpUp.setEveryAspect(6)
  boxNaUpDn.setEveryAspect(6)
  boxNaDnUp.setEveryAspect(5)
  boxNaDnDn.setEveryAspect(6)
end

SaS.reset()

--Signals

function SaS.Red(signalName)
  boxNaUpUp.setAspect(signalName .. "U", 6)
  boxNaUpDn.setAspect(signalName .. "U", 6)
  boxNaDnUp.setAspect(signalName .. "D", 5)
  boxNaDnDn.setAspect(signalName .. "D", 6)
end

function SaS.Yellow(signalName)
  boxNaUpUp.setAspect(signalName .. "U", 3)
  boxNaUpDn.setAspect(signalName .. "U", 6)
  boxNaDnUp.setAspect(signalName .. "D", 6)
  boxNaDnDn.setAspect(signalName .. "D", 3)
end

function SaS.Green(signalName)
  boxNaUpUp.setAspect(signalName .. "U", 6)
  boxNaUpDn.setAspect(signalName .. "U", 1)
  boxNaDnUp.setAspect(signalName .. "D", 6)
  boxNaDnDn.setAspect(signalName .. "D", 6)
end

function SaS.switchFrom(switchName)
  boxVy.setAspect(switchName, 5)
end

function SaS.switchTo(switchName)
  boxVy.setAspect(switchName, 1)
end

return SaS
