local component = require("component")

local function getController(address)
    return component.proxy(component.get(address))
end

local controllers = {}

-- Switches
controllers.Switches    = getController("CHANGE_ME") -- Switches

-- Single light signal (S_1xSingle)
controllers.Single      = getController("CHANGE_ME") -- Signal controller (single)

-- Two light shunting signal (S_Shunt)
controllers.ShuntUp     = getController("CHANGE_ME") -- Signal controller (dual, top light - 0) - bílá
controllers.ShuntDn     = getController("CHANGE_ME") -- Signal controller (dual, bottom light - 1) - modrá

-- 2x Two light signal (S_2xDualHead)
controllers.Light4UpUp  = getController("CHANGE_ME") -- Signal controller (top dual, top light - 0) - žlutá
controllers.Light4UpDn  = getController("CHANGE_ME") -- Signal controller (top dual, bottom light - 1) - zelená

controllers.Light4DnUp  = getController("CHANGE_ME") -- Signal controller (bottom dual, top light - 2) - červená
controllers.Light4DnDn  = getController("CHANGE_ME") -- Signal controller (bottom dual, bottom light - 3) - žlutá

-- 2x Two light signal + 1x Single light signal (S_2xDualHead1xSingle)
controllers.Light5UpUp  = getController("CHANGE_ME") -- Signal controller (top dual, top light - 0) - žlutá
controllers.Light5UpDn  = getController("CHANGE_ME") -- Signal controller (top dual, bottom light - 1) - zelená

controllers.Light5DnUp  = getController("CHANGE_ME") -- Signal controller (bottom dual, top light - 2) - červená
controllers.Light5DnDn  = getController("CHANGE_ME") -- Signal controller (bottom dual, bottom light - 3) - bílá

controllers.Light5Dn    = getController("CHANGE_ME") -- Signal controller (bottom single - 4) - žlutá

return controllers