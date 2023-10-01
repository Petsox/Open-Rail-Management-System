local gui = require("gui")
local component = require("component")


local boxNaUp = component.proxy(component.get("9a29")) -- Signal controller (top dual, top light - 0) - bílá
local boxNaDn = component.proxy(component.get("9a29")) -- Signal controller (top dual, bottom light - 1) - modrá

local S_Shunt = {}

function S_Shunt.reset()
  boxNaUp.setEveryAspect(8)
  boxNaDn.setEveryAspect(7)
end

--Signals

function S_Shunt.Posun(signalName)
  boxNaUp.setAspect(signalName, 6)
  boxNaDn.setAspect(signalName, 8)
end

function S_Shunt.NePosun(signalName)
  boxNaUp.setAspect(signalName, 8)
  boxNaDn.setAspect(signalName, 7)
end

return S_Shunt
