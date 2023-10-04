local gui = require("gui")
local component = require("component")
local controllers = require("controllers")

local S_Expect = {}

function S_Expect.reset()
  controllers.ExpectUp.setEveryAspect(3)
  controllers.ExpectDn.setEveryAspect(6)
end

--Signals

function S_Expect.Volno(signalName)
  controllers.ExpectUp.setAspect(signalName, 6)
  controllers.ExpectDn.setAspect(signalName, 1)
end

function S_Expect.Vystraha(signalName)
  controllers.ExpectUp.setAspect(signalName, 3)
  controllers.ExpectDn.setAspect(signalName, 6)
end

function S_Expect.Ocek40(signalName)
  controllers.ExpectUp.setAspect(signalName, 2)
  controllers.ExpectDn.setAspect(signalName, 6)
end

return S_Expect