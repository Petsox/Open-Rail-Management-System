local gui = require("gui")
local component = require("component")
local controllers = require("controllers")

local S_Shunt = {}

function S_Shunt.reset()
  controllers.ShuntUp.setEveryAspect(6)
  controllers.ShuntDn.setEveryAspect(7)
end

--Signals

function S_Shunt.Posun(signalName)
  controllers.ShuntUp.setAspect(signalName, 6)
  controllers.ShuntDn.setAspect(signalName, 6)
end

function S_Shunt.NePosun(signalName)
  controllers.ShuntUp.setAspect(signalName, 6)
  controllers.ShuntDn.setAspect(signalName, 7)
end

return S_Shunt