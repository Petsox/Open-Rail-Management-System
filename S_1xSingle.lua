local gui = require("gui")
local component = require("component")
local controllers = require("controllers")

local S_1xSingle = {}

function S_1xSingle.reset()
  controllers.Single.setEveryAspect(5)
end

--Signals

function S_1xSingle.Stuj(signalName)
  controllers.Single.setAspect(signalName, 5)
end

function S_1xSingle.Vystraha(signalName)
  controllers.Single.setAspect(signalName, 3)
end

function S_1xSingle.Volno(signalName)
  controllers.Single.setAspect(signalName, 1)
end

return S_1xSingle