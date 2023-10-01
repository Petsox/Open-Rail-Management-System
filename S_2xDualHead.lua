local gui = require("gui")
local component = require("component")


local boxNaUpUp = component.proxy(component.get("b046")) -- Signal controller (top dual, top light - 0) - žlutá
local boxNaUpDn = component.proxy(component.get("7631")) -- Signal controller (top dual, bottom light - 1) - zelená

local boxNaDnUp = component.proxy(component.get("147a")) -- Signal controller (bottom dual, top light - 2) - červená
local boxNaDnDn = component.proxy(component.get("c2cb")) -- Signal controller (bottom dual, bottom light - 3) - žlutá

local S_2xDualHead = {}

function S_2xDualHead.reset()
  boxNaUpUp.setEveryAspect(8)
  boxNaUpDn.setEveryAspect(8)
  boxNaDnUp.setEveryAspect(5)
  boxNaDnDn.setEveryAspect(8)
end

--Signals

function S_2xDualHead.Stuj(signalName)
  boxNaUpUp.setAspect(signalName .. "U", 8)
  boxNaUpDn.setAspect(signalName .. "U", 8)
  boxNaDnUp.setAspect(signalName .. "D", 5)
  boxNaDnDn.setAspect(signalName .. "D", 8)
end

function S_2xDualHead.Vystraha(signalName)
  boxNaUpUp.setAspect(signalName .. "U", 3)
  boxNaUpDn.setAspect(signalName .. "U", 8)
  boxNaDnUp.setAspect(signalName .. "D", 8)
  boxNaDnDn.setAspect(signalName .. "D", 3)
end

function S_2xDualHead.Volno40(signalName)
  boxNaUpUp.setAspect(signalName .. "U", 8)
  boxNaUpDn.setAspect(signalName .. "U", 1)
  boxNaDnUp.setAspect(signalName .. "D", 8)
  boxNaDnDn.setAspect(signalName .. "D", 3)
end

function S_2xDualHead.Volno(signalName)
  boxNaUpUp.setAspect(signalName .. "U", 8)
  boxNaUpDn.setAspect(signalName .. "U", 1)
  boxNaDnUp.setAspect(signalName .. "D", 8)
  boxNaDnDn.setAspect(signalName .. "D", 8)
end

return S_2xDualHead
