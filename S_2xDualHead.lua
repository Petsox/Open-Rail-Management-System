local gui = require("gui")
local component = require("component")
local controllers = require("controllers")

local S_2xDualHead = {}

function S_2xDualHead.reset()
  controllers.4LightUpUp.setEveryAspect(6)
  controllers.4LightUpDn.setEveryAspect(6)
  controllers.4LightDnUp.setEveryAspect(5)
  controllers.4LightDnDn.setEveryAspect(6)
end

--Signals

function S_2xDualHead.Stuj(signalName)
  controllers.4LightUpUp.setAspect(signalName .. "U", 6)
  controllers.4LightUpDn.setAspect(signalName .. "U", 6)
  controllers.4LightDnUp.setAspect(signalName .. "D", 5)
  controllers.4LightDnDn.setAspect(signalName .. "D", 6)
end

function S_2xDualHead.Vystraha(signalName)
  controllers.4LightUpUp.setAspect(signalName .. "U", 3)
  controllers.4LightUpDn.setAspect(signalName .. "U", 6)
  controllers.4LightDnUp.setAspect(signalName .. "D", 6)
  controllers.4LightDnDn.setAspect(signalName .. "D", 3)
end

function S_2xDualHead.Volno40(signalName)
  controllers.4LightUpUp.setAspect(signalName .. "U", 6)
  controllers.4LightUpDn.setAspect(signalName .. "U", 1)
  controllers.4LightDnUp.setAspect(signalName .. "D", 6)
  controllers.4LightDnDn.setAspect(signalName .. "D", 3)
end

function S_2xDualHead.Volno(signalName)
  controllers.4LightUpUp.setAspect(signalName .. "U", 6)
  controllers.4LightUpDn.setAspect(signalName .. "U", 1)
  controllers.4LightDnUp.setAspect(signalName .. "D", 6)
  controllers.4LightDnDn.setAspect(signalName .. "D", 6)
end

return S_2xDualHead