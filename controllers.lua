local component = require("component")

local function findControllerAddress(componentType, name)
    for address in component.list(componentType, true) do
        if component.proxy(address).getControllerName() == name then
            return address
        end
    end
    return nil
end

local controllers = {}
local addresses = {}

local function connect(componentType, name)
    local address = findControllerAddress(componentType, name)
    addresses[name] = address
    if address then
        controllers[name] = component.proxy(address)
    end
end

connect("signalcraft_controller", "Signals")                    -- Signals (Digital Controller)
connect("signalcraft_universal_controller", "Switches")         -- Switches (Universal Digital Controller)
connect("signalcraft_crossing_controller", "Crossings")         -- Crossings (Digital Crossing Controller)

function controllers.isConnected(name)
    return addresses[name] ~= nil
end

function controllers.printTable()
    for name, address in pairs(addresses) do
        print(name)
        print(address or "NotConnected")
    end
end

return controllers
