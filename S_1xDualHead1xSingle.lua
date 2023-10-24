local gui = require("gui")
local component = require("component")
local controllers = require("controllers")

local S_1xDualHead1xSingle = {}

function S_1xDualHead1xSingle.reset()
  controllers.Light3UpUp.setEveryAspect(6)
  controllers.Light3UpDn.setEveryAspect(5)
  controllers.Light3Dn.setEveryAspect(6)
end

--Signals

function S_1xDualHead1xSingle.Stuj(signalName)
  controllers.Light3UpUp.setAspect(signalName .. "U", 6)
  controllers.Light3UpDn.setAspect(signalName .. "U", 5)
  controllers.Light3Dn.setAspect(signalName .. "D", 6)
end


function S_1xDualHead1xSingle.Volno(signalName)
  controllers.Light3UpUp.setAspect(signalName .. "U", 1)
  controllers.Light3UpDn.setAspect(signalName .. "U", 6)
  controllers.Light3Dn.setAspect(signalName .. "D", 6)
end

function S_1xDualHead1xSingle.Posun(signalName)
  controllers.Light3UpUp.setAspect(signalName .. "U", 6)
  controllers.Light3UpDn.setAspect(signalName .. "U", 6)
  controllers.Light3Dn.setAspect(signalName .. "D", 7)
end

return S_1xDualHead1xSingle