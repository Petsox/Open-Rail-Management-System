local gui = require("gui")
local component = require("component")
local controllers = require("controllers")

local S_1xDualHead1xSingle = {}

function S_2xDualHead.reset()
  controllers.Light3UpUp.setEveryAspect(6)
  controllers.Light3UpDn.setEveryAspect(5)
  controllers.Light3Dn.setEveryAspect(6)
end

--Signals

function S_2xDualHead.Stuj(signalName)
  controllers.Light3UpUp.setAspect(signalName .. "U", 6)
  controllers.Light3UpDn.setAspect(signalName .. "D", 5)
  controllers.Light3Dn.setAspect(signalName, 6)
end


function S_2xDualHead.Volno(signalName)
  controllers.Light3UpUp.setAspect(signalName .. "U", 1)
  controllers.Light3UpDn.setAspect(signalName .. "D", 6)
  controllers.Light4DnDn.setAspect(signalName, 6)
end

function S_2xDualHead.Posun(signalName)
  controllers.Light3UpUp.setAspect(signalName .. "U", 6)
  controllers.Light3UpDn.setAspect(signalName .. "D", 6)
  controllers.Light3Dn.setAspect(signalName, 7)
end

return S_2xDualHead