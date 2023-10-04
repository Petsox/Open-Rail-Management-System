local gui = require("gui")
local component = require("component")
local controllers = require("controllers")

local S_2xDualHead = {}

function S_2xDualHead.reset()
  controllers.Light4UpUp.setEveryAspect(6)
  controllers.Light4UpDn.setEveryAspect(6)
  controllers.Light4DnUp.setEveryAspect(5)
  controllers.Light4DnDn.setEveryAspect(6)
end

--Signals

function S_2xDualHead.Stuj(signalName)
  controllers.Light4UpUp.setAspect(signalName .. "U", 6)
  controllers.Light4UpDn.setAspect(signalName .. "U", 6)
  controllers.Light4DnUp.setAspect(signalName .. "D", 5)
  controllers.Light4DnDn.setAspect(signalName .. "D", 6)
end

function S_2xDualHead.Vystraha40(signalName)
    controllers.Light4UpUp.setAspect(signalName .. "U", 3)
    controllers.Light4UpDn.setAspect(signalName .. "U", 6)
    controllers.Light4DnUp.setAspect(signalName .. "D", 6)
    controllers.Light4DnDn.setAspect(signalName .. "D", 6)
  end

function S_2xDualHead.Vystraha(signalName)
  controllers.Light4UpUp.setAspect(signalName .. "U", 3)
  controllers.Light4UpDn.setAspect(signalName .. "U", 6)
  controllers.Light4DnUp.setAspect(signalName .. "D", 6)
  controllers.Light4DnDn.setAspect(signalName .. "D", 3)
end

function S_2xDualHead.Volno40(signalName)
  controllers.Light4UpUp.setAspect(signalName .. "U", 6)
  controllers.Light4UpDn.setAspect(signalName .. "U", 1)
  controllers.Light4DnUp.setAspect(signalName .. "D", 6)
  controllers.Light4DnDn.setAspect(signalName .. "D", 3)
end

function S_2xDualHead.Volno(signalName)
  controllers.Light4UpUp.setAspect(signalName .. "U", 6)
  controllers.Light4UpDn.setAspect(signalName .. "U", 1)
  controllers.Light4DnUp.setAspect(signalName .. "D", 6)
  controllers.Light4DnDn.setAspect(signalName .. "D", 6)
end

return S_2xDualHead