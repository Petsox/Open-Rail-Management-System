local gui = require("gui")
local component = require("component")
local controllers = require("controllers")

local S_2xDualHead1xSingle = {}

function S_2xDualHead1xSingle.reset()
  controllers.5LightUpUp.setEveryAspect(6)
  controllers.5LightUpDn.setEveryAspect(6)
  controllers.5LightDnUp.setEveryAspect(5)
  controllers.5LightDnDn.setEveryAspect(6)
  controllers.5LightDn.setEveryAspect(6)
end

--Signals

function S_2xDualHead1xSingle.Stuj(signalName)
  controllers.5LightUpUp.setAspect(signalName .. "U", 6)
  controllers.5LightUpDn.setAspect(signalName .. "U", 6)
  controllers.5LightDnUp.setAspect(signalName .. "D", 5)
  controllers.5LightDnDn.setAspect(signalName .. "D", 6)
  controllers.5LightDn.setAspect(signalName, 6)
end

function S_2xDualHead1xSingle.Vystraha(signalName)
  controllers.5LightUpUp.setAspect(signalName .. "U", 3)
  controllers.5LightUpDn.setAspect(signalName .. "U", 6)
  controllers.5LightDnUp.setAspect(signalName .. "D", 6)
  controllers.5LightDnDn.setAspect(signalName .. "D", 3)
  controllers.5LightDn.setAspect(signalName, 6)
end

function S_2xDualHead1xSingle.Volno40(signalName)
  controllers.5LightUpUp.setAspect(signalName .. "U", 6)
  controllers.5LightUpDn.setAspect(signalName .. "U", 1)
  controllers.5LightDnUp.setAspect(signalName .. "D", 6)
  controllers.5LightDnDn.setAspect(signalName .. "D", 6)
  controllers.5LightDn.setAspect(signalName, 3)
end

function S_2xDualHead1xSingle.Volno(signalName)
  controllers.5LightUpUp.setAspect(signalName .. "U", 6)
  controllers.5LightUpDn.setAspect(signalName .. "U", 1)
  controllers.5LightDnUp.setAspect(signalName .. "D", 6)
  controllers.5LightDnDn.setAspect(signalName .. "D", 6)
  controllers.5LightDn.setAspect(signalName, 6)
end

function S_2xDualHead1xSingle.Posun(signalName)
  controllers.5LightUpUp.setAspect(signalName .. "U", 6)
  controllers.5LightUpDn.setAspect(signalName .. "U", 6)
  controllers.5LightDnUp.setAspect(signalName .. "D", 6)
  controllers.5LightDnDn.setAspect(signalName .. "D", 6)
  controllers.5LightDn.setAspect(signalName, 7)
end

return S_2xDualHead1xSingle