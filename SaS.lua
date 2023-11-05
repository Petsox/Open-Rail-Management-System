local gui = require("gui")
local component = require("component")
local controllers = require("controllers")
local oneLight
local fourLights
local threeLights
local fiveLights
local shuntLights
local expectLights

--Connections

local spojSw = controllers.isConnected("Sw")
local spoj1 = controllers.isConnected("Single")
local spojSh = controllers.isConnected("ShUp")
local spoj4 = controllers.isConnected("4UpUp")
local spoj3 = controllers.isConnected("3UpUp")
local spoj5 = controllers.isConnected("5UpUp")
local spojEx = controllers.isConnected("ExUp")

--Imports

if spoj1 then
  oneLight = require("S_1xSingle")
else
  oneLight = "NC"
end

if spoj3 then
  threeLights = require("S_1xDualHead1xSingle")
else
  threeLights = "NC"
end

if spoj4 then
  fourLights = require("S_2xDualHead")
else
  fourLights = "NC"
end

if spoj5 then
  fiveLights = require("S_2xDualHead1xSingle")
else
  fiveLights = "NC"
end

if spojSh then
  shuntLights = require("S_Shunt")
else
  shuntLights = "NC"
end

if spojEx then
  expectLights = require("S_Expect")
else
  expectLights = "NC"
end

--Imports end

local function startswith(str, prefix)
  return str:sub(1, #prefix) == prefix
end

local SaS = {}

function SaS.reset()
  if spojSw then controllers.Switches.setEveryAspect(5) end
  if spoj1 then oneLight.reset() end
  if spojSh then shuntLights.reset() end
  if spoj4 then fourLights.reset() end
  if spoj3 then threeLights.reset() end
  if spoj5 then fiveLights.reset() end
  if spojEx then expectLights.reset() end
end

SaS.reset()

function SaS.Stuj(signalName)
  if startswith(signalName, "1") and spoj1 then
      oneLight.Stuj(signalName)
  elseif startswith(signalName, "3") and spoj3  then
      threeLights.Stuj(signalName)
  elseif startswith(signalName, "4") and spoj4 then
      fourLights.Stuj(signalName)
  elseif startswith(signalName, "5") and spoj5 then
      fiveLights.Stuj(signalName)
  end
  expectLights.Vystraha("Pr" .. signalName)
end

function SaS.Vystraha40(signalName)
  if startswith(signalName, "4") and spoj4  then
    fourLights.Vystraha40(signalName)
  elseif startswith(signalName, "5") and spoj5  then
    fiveLights.Vystraha40(signalName)
  end
  expectLights.Ocek40("Pr" .. signalName)
end

function SaS.Vystraha(signalName)
  if startswith(signalName, "1") and spoj1  then
    oneLight.Vystraha(signalName)
  elseif startswith(signalName, "4") and spoj4  then
    fourLights.Vystraha(signalName)
  elseif startswith(signalName, "5") and spoj5  then
    fiveLights.Vystraha(signalName)
  end
  expectLights.Volno("Pr" .. signalName)
end

function SaS.Volno40(signalName)
  if startswith(signalName, "4") and spoj4  then
    fourLights.Volno40(signalName)
  elseif startswith(signalName, "5") and spoj5  then
    fiveLights.Volno40(signalName)
  end
  expectLights.Ocek40("Pr" .. signalName)
end

function SaS.Volno(signalName)
  if startswith(signalName, "1") and spoj1  then
    oneLight.Volno(signalName)
  elseif startswith(signalName, "3") and spoj3  then
    threeLights.Volno(signalName)
  elseif startswith(signalName, "4") and spoj4  then
    fourLights.Volno(signalName)
  elseif startswith(signalName, "5") and spoj5  then
    fiveLights.Volno(signalName)
  end
  expectLights.Volno("Pr" .. signalName)
end

function SaS.Posun(signalName)
  if startswith(signalName, "Sh") and spojSh then
    shuntLights.Posun(signalName)
  elseif startswith(signalName, "3") and spoj3 then
    threeLights.Posun(signalName)
  elseif startswith(signalName, "5") and spoj5 then
    fiveLights.Posun(signalName)
  end
end

function SaS.NePosun(signalName)
  if startswith(signalName, "Sh") and spojSh then
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