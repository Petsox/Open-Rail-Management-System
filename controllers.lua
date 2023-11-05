local component = require("component")

local controllerNames = {}
local controllerAdrs = {}

for address, name in component.list("controller", false) do

  table.insert(controllerNames, component.proxy(component.get(address)).getControllerName())
  table.insert(controllerAdrs, component.get(address))
  
end

function table_contains(tbl, x)
  found = false
  for _, v in pairs(tbl) do
      if v == x then 
          found = true 
      end
  end
  return found
end

function findIndexInTable(table, x)
  for i, value in ipairs(table) do
      if value == x then
          return i
      end
  end
  return nil
end

local function getAddress(name)
  if table_contains(controllerNames, name) then
      for var=#controllerNames,1,-1 do
        if (controllerNames[var] == name) then
            return controllerAdrs[var]
          end
        end
      else
    table.insert(controllerNames, name)
    table.insert(controllerAdrs, "NotConnected")
    return "NotConnected"
  end
end

local controllers = {}

function controllers.isConnected(name)
  local var = findIndexInTable(controllerNames, name)
  if (controllerAdrs[var] == "NotConnected") then
    return false
  end
  return true 
end

function controllers.printTable()
  for var=#controllerNames,1,-1 do
      print(controllerNames[var])
      print(controllerAdrs[var])
  end
end

-- Switches
controllers.Switches    = component.proxy(getAddress("Sw")) -- Switches

-- Single light signal (S_1xSingle)
controllers.Single      = component.proxy(getAddress("Single")) -- Signal controller (single)

-- Two light shunting signal (S_Shunt)
controllers.ShuntUp     = component.proxy(getAddress("ShUp")) -- Signal controller (dual, top light - 0) - bílá
controllers.ShuntDn     = component.proxy(getAddress("ShDn")) -- Signal controller (dual, bottom light - 1) - modrá

-- 2x Two light signal (S_2xDualHead)
controllers.Light4UpUp  = component.proxy(getAddress("4UpUp")) -- Signal controller (top dual, top light - 0) - žlutá
controllers.Light4UpDn  = component.proxy(getAddress("4UpDn")) -- Signal controller (top dual, bottom light - 1) - zelená

controllers.Light4DnUp  = component.proxy(getAddress("4DnUp")) -- Signal controller (bottom dual, top light - 2) - červená
controllers.Light4DnDn  = component.proxy(getAddress("4DnDn")) -- Signal controller (bottom dual, bottom light - 3) - žlutá

-- 1x Two light signal 1x Single signal (S_1xDualHead_1xSingle)
controllers.Light3UpUp  = component.proxy(getAddress("3UpUp")) -- Signal controller (top dual, top light - 0) - zelená
controllers.Light3UpDn  = component.proxy(getAddress("3UpDn")) -- Signal controller (top dual, bottom light - 1) - červená

controllers.Light3Dn  = component.proxy(getAddress("3Dn")) -- Signal controller (bottom dual, top light - 2) - bíla

-- 2x Two light signal + 1x Single light signal (S_2xDualHead1xSingle)
controllers.Light5UpUp  = component.proxy(getAddress("5UpUp")) -- Signal controller (top dual, top light - 0) - žlutá
controllers.Light5UpDn  = component.proxy(getAddress("5UpDn")) -- Signal controller (top dual, bottom light - 1) - zelená

controllers.Light5DnUp  = component.proxy(getAddress("5DnUp")) -- Signal controller (bottom dual, top light - 2) - červená
controllers.Light5DnDn  = component.proxy(getAddress("5DnDn")) -- Signal controller (bottom dual, bottom light - 3) - bílá

controllers.Light5Dn    = component.proxy(getAddress("5Dn")) -- Signal controller (bottom single - 4) - žlutá

-- Expect signals (Předvěsti)
controllers.ExpectUp    = component.proxy(getAddress("ExUp")) -- Signal controller (top light - 0) - žlutá
controllers.ExpectDn    = component.proxy(getAddress("ExDn")) -- Signal controller (bottom light - 1) - zelená

return controllers