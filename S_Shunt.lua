local gui = require("gui")
local component = require("component")
local controllers = require("controllers")

local S_Shunt = {}

function S_Shunt.reset()
  controllers.ShuntUp.setEveryAspect(8)
  controllers.ShuntDn.setEveryAspect(6)
end

--Signals

function S_Shunt.Posun(signalName)
  controllers.ShuntUp.setAspect(signalName, 6)
  controllers.ShuntDn.setAspect(signalName, 7)
end

function S_Shunt.nePosun(signalName)
  controllers.ShuntUp.setAspect(signalName, 8)
  controllers.ShuntDn.setAspect(signalName, 6)
end

return S_Shunt