local gui = require("gui")
local component = require("component")
local controllers = require("controllers")

local S_2xDualHead1xSingle = {}

function S_2xDualHead1xSingle.reset()
  controllers.Light5UpUp.setEveryAspect(6)
  controllers.Light5UpDn.setEveryAspect(6)
  controllers.Light5DnUp.setEveryAspect(5)
  controllers.Light5DnDn.setEveryAspect(6)
  controllers.Light5Dn.setEveryAspect(6)
end

--Signals

function S_2xDualHead1xSingle.Stuj(signalName)
  controllers.Light5UpUp.setAspect(signalName .. "U", 6)
  controllers.Light5UpDn.setAspect(signalName .. "U", 6)
  controllers.Light5DnUp.setAspect(signalName .. "D", 5)
  controllers.Light5DnDn.setAspect(signalName .. "D", 6)
  controllers.Light5Dn.setAspect(signalName, 6)
end

function S_2xDualHead1xSingle.Vystraha(signalName)
  controllers.Light5UpUp.setAspect(signalName .. "U", 3)
  controllers.Light5UpDn.setAspect(signalName .. "U", 6)
  controllers.Light5DnUp.setAspect(signalName .. "D", 6)
  controllers.Light5DnDn.setAspect(signalName .. "D", 3)
  controllers.Light5Dn.setAspect(signalName, 6)
end

function S_2xDualHead1xSingle.Volno40(signalName)
  controllers.Light5UpUp.setAspect(signalName .. "U", 6)
  controllers.Light5UpDn.setAspect(signalName .. "U", 1)
  controllers.Light5DnUp.setAspect(signalName .. "D", 6)
  controllers.Light5DnDn.setAspect(signalName .. "D", 6)
  controllers.Light5Dn.setAspect(signalName, 3)
end

function S_2xDualHead1xSingle.Volno(signalName)
  controllers.Light5UpUp.setAspect(signalName .. "U", 6)
  controllers.Light5UpDn.setAspect(signalName .. "U", 1)
  controllers.Light5DnUp.setAspect(signalName .. "D", 6)
  controllers.Light5DnDn.setAspect(signalName .. "D", 6)
  controllers.Light5Dn.setAspect(signalName, 6)
end

function S_2xDualHead1xSingle.Posun(signalName)
  controllers.Light5UpUp.setAspect(signalName .. "U", 6)
  controllers.Light5UpDn.setAspect(signalName .. "U", 6)
  controllers.Light5DnUp.setAspect(signalName .. "D", 6)
  controllers.Light5DnDn.setAspect(signalName .. "D", 6)
  controllers.Light5Dn.setAspect(signalName, 7)
end

return S_2xDualHead1xSingle