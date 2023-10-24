local gui = require("gui")
local component = require("component")
local controllers = require("controllers")
local oneLight = require("S_1xSingle")
local fourLights = require("S_2xDualHead")
local threeLights = require("S_1xDualHead1xSingle")
local fiveLights = require("S_2xDualHead1xSingle")
local shuntLights = require("S_Shunt")
local expectLights = require("S_Expect")

local function startswith(str, prefix)
  return str:sub(1, #prefix) == prefix
end

local SaS = {}

function SaS.reset()
  controllers.Switches.setEveryAspect(5)
  oneLight.reset()
  threeLights.reset()
  fourLights.reset()
  fiveLights.reset()
  shuntLights.reset()
  expectLights.reset()
end

SaS.reset()

function SaS.Stuj(signalName)
  if startswith(signalName, "1") then
      oneLight.Stuj(signalName)
  elseif startswith(signalName, "3") then
      threeLights.Stuj(signalName)
  elseif startswith(signalName, "4") then
      fourLights.Stuj(signalName)
  elseif startswith(signalName, "5") then
      fiveLights.Stuj(signalName)
  end
  expectLights.Vystraha("Pr" .. signalName)
end

function SaS.Vystraha40(signalName)
  if startswith(signalName, "4") then
    fourLights.Vystraha40(signalName)
  elseif startswith(signalName, "5") then
    fiveLights.Vystraha40(signalName)
  end
  expectLights.Ocek40("Pr" .. signalName)
end

function SaS.Vystraha(signalName)
  if startswith(signalName, "1") then
    oneLight.Vystraha(signalName)
  elseif startswith(signalName, "4") then
    fourLights.Vystraha(signalName)
  elseif startswith(signalName, "5") then
    fiveLights.Vystraha(signalName)
  end
  expectLights.Volno("Pr" .. signalName)
end

function SaS.Volno40(signalName)
  if startswith(signalName, "4") then
    fourLights.Volno40(signalName)
  elseif startswith(signalName, "5") then
    fiveLights.Volno40(signalName)
  end
  expectLights.Ocek40("Pr" .. signalName)
end

function SaS.Volno(signalName)
  if startswith(signalName, "1") then
    oneLight.Volno(signalName)
  elseif startswith(signalName, "3") then
    threeLights.Volno(signalName)
  elseif startswith(signalName, "4") then
    fourLights.Volno(signalName)
  elseif startswith(signalName, "5") then
    fiveLights.Volno(signalName)
  end
  expectLights.Volno("Pr" .. signalName)
end

function SaS.Posun(signalName)
  if startswith(signalName, "Sh") then
    shuntLights.Posun(signalName)
  elseif startswith(signalName, "3") then
    threeLights.Posun(signalName)
  elseif startswith(signalName, "5") then
    fiveLights.Posun(signalName)
  end
end

function SaS.NePosun(signalName)
  if startswith(signalName, "Sh") then
    shuntLights.nePosun(signalName)
  end
end

function SaS.switchFrom(switchName)
  controllers.Switches.setAspect(switchName, 5)
end

function SaS.switchTo(switchName)
  controllers.Switches.setAspect(switchName, 1)
end

return SaS