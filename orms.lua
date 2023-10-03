local component = require("component")
local gpu = component.gpu
gpu.setResolution(160, 50)
local gui = require("gui")
local term = require("term")
local SaS = require("SaS")
local computer = require("computer")
local ormslib = require("ormsLib")
local config = require("station")
local thread = require("thread")

local expectLights = require("S_Expect")

gui.checkVersion(2, 5)

local white = 0xffffff
local black = 0x000000
local red = 0xff0000
local blue = 0x0000ff

-- Begin: Callbacks
local function exitButtonCallback(guiID, id)
  local result = gui.getYesNo("", "Do you really want to exit?", "")
  if result == true then
    SaS.reset()
    term.clear()
    os.exit()
  end
  gui.displayGui(mainGui)
end

local function Switch(guiID, widgetID, name)
  ormslib.Switch(mainGui, widgetID, gui.getName(mainGui, widgetID))
end

local function SignalOne(name, widgetID)
  ormslib.SignalOne(gui.getName(mainGui, widgetID), widgetID)
end

local function SignalFour(name, widgetID)
  ormslib.SignalFour(gui.getName(mainGui, widgetID), widgetID)
end

local function SignalFive(name, widgetID)
  ormslib.SignalFive(gui.getName(mainGui, widgetID), widgetID)
end

local function SignalShunt(name, widgetID)
  ormslib.SignalShunt(gui.getName(mainGui, widgetID), widgetID)
end

local function SignalExpect(name, widgetID)
  ormslib.SignalExpect(gui.getName(mainGui, widgetID), widgetID)
end
-- End: Callbacks

-- Begin: Menu definitions
mainGui = gui.newGui(2, 2, 158, 48, true)
exitButton = gui.newButton(mainGui, 153, 48, "exit", exitButtonCallback)
-- End: Menu definitions

-- Begin: Station configuration
for _,signal in pairs(config.Signal1) do
  gui.newSignal(mainGui, signal[1], signal[2], signal[3], red, signal[4], SignalOne)
end

for _,signal in pairs(config.Signal4) do
  gui.newSignal(mainGui, signal[1], signal[2], signal[3], red, signal[4], SignalFour)
end

for _,signal in pairs(config.Signal5) do
  gui.newSignal(mainGui, signal[1], signal[2], signal[3], red, signal[4], SignalFive)
end

for _,signal in pairs(config.SignalSh) do
  gui.newSignal(mainGui, signal[1], signal[2], signal[3], blue, signal[4], SignalShunt)
end

--Predvesti
local function startswith(str, prefix)
  return str:sub(1, #prefix) == prefix
end

for _,signal in pairs(config.SignalEx) do
  local signalId = gui.newSignal(mainGui, signal[1], signal[2], signal[3], white, signal[4], SignalExpect)
  local mainSignalName = signal[3]:sub(3)

  thread.create(function()
    while true do
      if startswith(mainSignalName, "1") then
        local aspectSingle = controllers.Single.getAspect(mainSignalName)
        if aspectSingle == 5 then
          expectLights.Vystraha(signal[3])
          gui.setSignal(mainGui, signalId, 0xFFFF00, true)
        else
          expectLights.Volno(signal[3])
          gui.setSignal(mainGui, signalId, 0x00FF00, true)
        end
      elseif startswith(mainSignalName, "4") then
        local aspectUpDn = controllers.Light4UpDn.getAspect(mainSignalName)
        local aspectDnUp = controllers.Light4DnUp.getAspect(mainSignalName)
        local aspectDnDn = controllers.Light4DnDn.getAspect(mainSignalName)

        if aspectDnUp == 5 then
          expectLights.Vystraha(signal[3])
          gui.setSignal(mainGui, signalId, 0xFFFF00, true)
        elseif aspectUpDn == 1 and aspectDnDn == 3 then
          expectLights.Ocek40(signal[3])
          gui.setSignal(mainGui, signalId, 0xFF9900, true)
        else
          expectLights.Volno(signal[3])
          gui.setSignal(mainGui, signalId, 0x00FF00, true)
        end
      elseif startswith(mainSignalName, "5") then
        local aspectUpUp = controllers.Light5UpUp.getAspect(mainSignalName)
        local aspectUpDn = controllers.Light5UpDn.getAspect(mainSignalName)
        local aspectDnUp = controllers.Light5DnUp.getAspect(mainSignalName)
        local aspectDnDn = controllers.Light5DnDn.getAspect(mainSignalName)
        local aspectDn = controllers.Light5Dn.getAspect(mainSignalName)

        if aspectDnUp == 5 then
          expectLights.Vystraha(signal[3])
          gui.setSignal(mainGui, signalId, 0xFFFF00, true)
        elseif aspectUpDn == 1 and aspectDn == 3 then
          expectLights.Ocek40(signal[3])
          gui.setSignal(mainGui, signalId, 0xFF9900, true)
        else
          expectLights.Volno(signal[3])
          gui.setSignal(mainGui, signalId, 0x00FF00, true)
        end
      end
    end
    os.sleep(0)
  end)
end

for _,track in pairs(config.Tracks) do
  gui.newLabel(mainGui, track[1], track[2], track[3], black, white, 1)
end

for _,switch in pairs(config.Switches) do
  gui.newSwitch(mainGui, switch[1], switch[2], switch[3], switch[4], switch[5], Switch)
end

-- End: Station configuration

gui.clearScreen()
gui.setTop("Open-Rail-Management-System by Petsox")
gui.setBottom("Made with Gui library v2.5 reworked and rewritten by Petsox")

-- Main loop
while true do
  gui.runGui(mainGui)
end
