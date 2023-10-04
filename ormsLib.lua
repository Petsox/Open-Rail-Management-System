local gui = require("gui")
local SaS = require("SaS")
local expectLights = require("S_Expect")
local ormslib = {}

local signalRunning = false
local signalValue = false
local signalID = ""
local signalName = ""

local function Cancel()
  signalRunning = false
  signalValue = true
end

--Signals

local function Stuj()
  SaS.Stuj(signalName, signalID)
  Cancel()
  gui.setSignal(mainGui, signalID, 0xFF0000, true)

  local predvest = gui.getSignal(mainGui, "Pr" .. signalName)
  gui.setSignal(mainGui, predvest, 0xFFFF00, true)
end

local function Vystraha40()
  SaS.Vystraha40(signalName, signalID)
  Cancel()
  gui.setSignal(mainGui, signalID, 0xD7FC03, true)

  local predvest = gui.getSignal(mainGui, "Pr" .. signalName)
  gui.setSignal(mainGui, predvest, 0xFF9900, true)
end

local function Vystraha()
  SaS.Vystraha(signalName, signalID)
  Cancel()
  gui.setSignal(mainGui, signalID, 0xFFFF00, true)

  local predvest = gui.getSignal(mainGui, "Pr" .. signalName)
  gui.setSignal(mainGui, predvest, 0x00FF00, true)
end

local function Volno40()
  SaS.Volno40(signalName, signalID)
  Cancel()
  gui.setSignal(mainGui, signalID, 0xFF9900, true)

  local predvest = gui.getSignal(mainGui, "Pr" .. signalName)
  gui.setSignal(mainGui, predvest, 0xFF9900, true)
end

local function Volno()
  SaS.Volno(signalName, signalID)
  Cancel()
  gui.setSignal(mainGui, signalID, 0x00FF00, true)

  local predvest = gui.getSignal(mainGui, "Pr" .. signalName)
  gui.setSignal(mainGui, predvest, 0x00FF00, true)
end

local function Posun()
  SaS.Posun(signalName, signalID)
  Cancel()
  gui.setSignal(mainGui, signalID, 0x7D7E80, true)

  expectLights.Vystraha("Pr" .. signalName)
  gui.setSignal(mainGui, predvest, 0xFFFF00, true)
end

local function NePosun()
  SaS.NePosun(signalName, signalID)
  Cancel()
  gui.setSignal(mainGui, signalID, 0x0000FF, true)
end

-- 5 svetelny navestidlo
function ormslib.SignalFive(name, widgetID)
  signal5Gui = gui.newGui(111, 27, 40, 12, true, "Návěst " .. name)
  signalCancelButton = gui.newButton(signal5Gui, 3, 10, "Zrušit", Cancel)
  signalStujButton = gui.newButton(signal5Gui, 3, 3, "Návěst na Stůj", Stuj)
  signalVystraha40Button = gui.newButton(signal5Gui, 3, 4, "Návěst na Výstraha + 40", Vystraha40)
  signalVystrahaButton = gui.newButton(signal5Gui, 3, 5, "Návěst na Výstraha", Vystraha)
  signalVolno40Button = gui.newButton(signal5Gui, 3, 6, "Návěst na Volno + 40", Volno40)
  signalVolnoButton = gui.newButton(signal5Gui, 3, 7, "Návěst na Volno", Volno)
  signalPosunButton = gui.newButton(signal5Gui, 3, 8, "Návěst na Posun Povolen", Posun)

  signalID = widgetID
  signalName = name
  signalRunning = true
  gui.displayGui(signal5Gui)
  while signalRunning == true do
    gui.runGui(signal5Gui)
  end
  gui.closeGui(signal5Gui)
  return signalValue
end

function ormslib.SignalOne(name, widgetID)
  signal1Gui = gui.newGui(111, 27, 40, 10, true, "Návěst " .. name)
  signalCancelButton = gui.newButton(signal1Gui, 3, 8, "Zrušit", Cancel)
  signalStujButton = gui.newButton(signal1Gui, 3, 3, "Návěst na Stůj", Stuj)
  signalVystrahaButton = gui.newButton(signal1Gui, 3, 4, "Návěst na Výstraha", Vystraha)
  signalVolnoButton = gui.newButton(signal1Gui, 3, 5, "Návěst na Volno", Volno)

  signalID = widgetID
  signalName = name
  signalRunning = true
  gui.displayGui(signal1Gui)
  while signalRunning == true do
    gui.runGui(signal1Gui)
  end
  gui.closeGui(signal1Gui)
  return signalValue
end

-- 4 svetelny navestidlo
function ormslib.SignalFour(name, widgetID)
  signal4Gui = gui.newGui(111, 27, 40, 11, true, "Návěst " .. name)
  signalCancelButton = gui.newButton(signal4Gui, 3, 9, "Zrušit", Cancel)
  signalStujButton = gui.newButton(signal4Gui, 3, 3, "Návěst na Stůj", Stuj)
  signalVystraha40Button = gui.newButton(signal4Gui, 3, 4, "Návěst na Výstraha + 40", Vystraha40)
  signalVystrahaButton = gui.newButton(signal4Gui, 3, 5, "Návěst na Výstraha", Vystraha)
  signalVolno40Button = gui.newButton(signal4Gui, 3, 6, "Návěst na Volno + 40", Volno40)
  signalVolnoButton = gui.newButton(signal4Gui, 3, 7, "Návěst na Volno", Volno)

  signalID = widgetID
  signalName = name
  signalRunning = true
  gui.displayGui(signal4Gui)
  while signalRunning == true do
    gui.runGui(signal4Gui)
  end
  gui.closeGui(signal4Gui)
  return signalValue
end

function ormslib.SignalShunt(name, widgetID)
  signalShGui = gui.newGui(111, 27, 40, 10, true, "Návěst " .. name)
  signalCancelButton = gui.newButton(signalShGui, 3, 8, "Zrušit", Cancel)
  signalBlueButton = gui.newButton(signalShGui, 3, 3, "Návěst na Posun Zakázán", NePosun)
  signalWhiteButton = gui.newButton(signalShGui, 3, 4, "Návěst na Posun Povolen", Posun)

  signalID = widgetID
  signalName = name
  signalRunning = true
  gui.displayGui(signalShGui)
  while signalRunning == true do
    gui.runGui(signalShGui)
  end
  gui.closeGui(signalShGui)
  return signalValue
end

--Predvest
function ormslib.SignalExpect(name, widgetID)
  predvestGui = gui.newGui(111, 27, 40, 5, true, "Předvěst " .. name)
  signalCancelButton = gui.newButton(predvestGui, 3, 2, "Zrušit", Cancel)

  signalID = widgetID
  signalName = name
  signalRunning = true
  gui.displayGui(predvestGui)
  while signalRunning == true do
    gui.runGui(predvestGui)
  end
  gui.closeGui(predvestGui)
  return signalValue
end

--Switches

function ormslib.Switch(guiID, widgetID, name)
  if mainGui[widgetID].from == mainGui[widgetID].text then
    SaS.switchTo(mainGui[widgetID].name)
    gui.setText(mainGui, widgetID, mainGui[widgetID].to, true)
  else
    SaS.switchFrom(mainGui[widgetID].name)
    gui.setText(mainGui, widgetID, mainGui[widgetID].from, true)
  end
end

return ormslib
