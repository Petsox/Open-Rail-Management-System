local unicode = require("unicode")

local route = {}

-- Grid convention: y increases downward, matching the GUI/screen coordinate system.
local DIRS = {
    U = {dx = 0, dy = -1},
    D = {dx = 0, dy = 1},
    L = {dx = -1, dy = 0},
    R = {dx = 1, dy = 0},
}
local DIR_ORDER = {"L", "R", "U", "D"}
local OPPOSITE = {U = "D", D = "U", L = "R", R = "L"}

-- Glyph -> set of cardinal directions it connects to, as seen from the cell itself.
local GLYPH_DIRS = {
    ["═"] = {L = true, R = true},
    ["║"] = {U = true, D = true},
    ["╔"] = {D = true, R = true},
    ["╗"] = {D = true, L = true},
    ["╚"] = {U = true, R = true},
    ["╝"] = {U = true, L = true},
    -- Buffer stops (end of track): the crossbar is the wall, track continues only on the open side.
    ["╞"] = {R = true},
    ["╡"] = {L = true},
    ["╥"] = {D = true},
    ["╨"] = {U = true},
    -- Tunnel mouths: purely decorative, pass straight through.
    ["⦗"] = {L = true, R = true},
    ["⦘"] = {L = true, R = true},
    ["︹"] = {U = true, D = true},
    ["︺"] = {U = true, D = true},
}

local CURVE_GLYPHS = {["╗"] = true, ["╝"] = true, ["╚"] = true, ["╔"] = true}

-- Signal facing icon -> direction of authorized travel through the signal.
local FACING_DIR = {
    ["<"] = "L", ["◀"] = "L", ["◁"] = "L",
    [">"] = "R", ["▶"] = "R", ["▷"] = "R",
    ["^"] = "U", ["▲"] = "U", ["△"] = "U",
    ["V"] = "D", ["▼"] = "D", ["▽"] = "D",
}

local function key(x, y)
    return x .. "," .. y
end

function route.isCurveGlyph(glyph)
    return CURVE_GLYPHS[glyph] == true
end

function route.classifySignal(name)
    local prefix = name:sub(1, 2)
    if prefix == "Se" then
        return "shunting"
    elseif prefix == "Pr" then
        return "expect"
    elseif prefix == "VS" or prefix == "VL" then
        return "inserted"
    end
    return "main"
end

-- Builds the cell adjacency graph from a loaded config table (Config from config.lua).
function route.buildGraph(config)
    local cells = {}
    local signalsByName = {}

    for _, t in pairs(config.Tracks or {}) do
        local x, y, glyphs = t[1], t[2], t[3]
        local length = unicode.len(glyphs)
        for i = 1, length do
            local ch = unicode.sub(glyphs, i, i)
            local dirs = GLYPH_DIRS[ch]
            if dirs then
                cells[key(x + i - 1, y)] = {kind = "track", dirs = dirs}
            end
        end
    end

    for _, s in pairs(config.Switches or {}) do
        local x, y, iconDefault, iconToggled, name = s[1], s[2], s[3], s[4], s[5]
        cells[key(x, y)] = {kind = "switch", name = name, iconDefault = iconDefault, iconToggled = iconToggled}
    end

    for _, c in pairs(config.Crossings or {}) do
        local x, y, _, iconToggled, name = c[1], c[2], c[3], c[4], c[5]
        -- The default icon (e.g. "╪") is a decorative road-crossing marker; the toggled icon
        -- is always the plain rail glyph, so it's what actually determines rail connectivity.
        local dirs = GLYPH_DIRS[iconToggled]
        if dirs then
            cells[key(x, y)] = {kind = "crossing", name = name, dirs = dirs}
        end
    end

    for _, sig in pairs(config.Signals or {}) do
        local x, y, name, facingIcon = sig[1], sig[2], sig[3], sig[4]
        local dir = FACING_DIR[facingIcon]
        signalsByName[name] = {x = x, y = y, dir = dir, kind = route.classifySignal(name)}

        local k = key(x, y)
        if not cells[k] and dir then
            -- Some layouts leave the signal's own cell out of the Tracks data entirely
            -- (the signal glyph fills the gap visually); synthesize a plain pass-through
            -- connector along its facing axis so the cell chain isn't broken.
            local axis = (dir == "L" or dir == "R") and {L = true, R = true} or {U = true, D = true}
            cells[k] = {kind = "track", dirs = axis}
        end
    end

    return {cells = cells, signalsByName = signalsByName}
end

-- Given a cell and the direction of travel used to arrive at it, returns the list of
-- possible continuations: {{dir = "R"[, icon = "═"]}, ...}. For switch cells, both icon
-- states are considered (unless a state was already committed earlier on this path),
-- straight/collinear icons are tried before curved ones so the straightest route wins ties.
local function continuationsFor(cell, cameFromDir, switchChoices)
    local entrySide = OPPOSITE[cameFromDir]
    local results = {}

    if cell.kind == "switch" then
        local candidates = {cell.iconDefault, cell.iconToggled}
        if route.isCurveGlyph(candidates[1]) and not route.isCurveGlyph(candidates[2]) then
            candidates[1], candidates[2] = candidates[2], candidates[1]
        end
        local forced = switchChoices[cell.name]
        for _, icon in ipairs(candidates) do
            if forced == nil or forced == icon then
                local dirs = GLYPH_DIRS[icon]
                if dirs and dirs[entrySide] then
                    for _, d in ipairs(DIR_ORDER) do
                        if d ~= entrySide and dirs[d] then
                            results[#results + 1] = {dir = d, icon = icon}
                        end
                    end
                end
            end
        end
    else
        local dirs = cell.dirs
        if dirs and dirs[entrySide] then
            for _, d in ipairs(DIR_ORDER) do
                if d ~= entrySide and dirs[d] then
                    results[#results + 1] = {dir = d}
                end
            end
        end
    end

    return results
end

-- strictExit: if true, the exit must also be arrived at heading in ITS OWN facing
-- direction (used internally for sibling-reachability checks). If false, the exit is a
-- pure location marker -- any arrival direction counts, since the operator's clicked exit
-- signal may deliberately face "backwards" relative to the route (e.g. selecting VL3 to
-- mean "route to track 3" even though the train travels opposite VL3's own facing).
local function search(graph, x, y, cameFromDir, exit, strictExit, visited, switchChoices, path)
    local k = key(x, y)
    if visited[k] then
        return false
    end

    if x == exit.x and y == exit.y and (not strictExit or cameFromDir == exit.dir) then
        path[#path + 1] = {x = x, y = y}
        return true
    end

    local cell = graph.cells[k]
    if not cell then
        return false
    end

    visited[k] = true
    path[#path + 1] = {x = x, y = y}

    for _, opt in ipairs(continuationsFor(cell, cameFromDir, switchChoices)) do
        local previousChoice
        if opt.icon then
            previousChoice = switchChoices[cell.name]
            switchChoices[cell.name] = opt.icon
        end

        local vec = DIRS[opt.dir]
        if search(graph, x + vec.dx, y + vec.dy, opt.dir, exit, strictExit, visited, switchChoices, path) then
            return true
        end

        if opt.icon then
            switchChoices[cell.name] = previousChoice
        end
    end

    visited[k] = nil
    path[#path] = nil
    return false
end

local function findPathInternal(graph, entranceName, exitName, strictExit)
    local entrance = graph.signalsByName[entranceName]
    local exit = graph.signalsByName[exitName]
    if not entrance or not exit or not entrance.dir then
        return nil
    end

    local visited = {[key(entrance.x, entrance.y)] = true}
    local switchChoices = {}
    local path = {{x = entrance.x, y = entrance.y}}

    local vec = DIRS[entrance.dir]
    local ok = search(graph, entrance.x + vec.dx, entrance.y + vec.dy, entrance.dir, exit, strictExit, visited, switchChoices, path)
    if not ok then
        return nil
    end

    local allStraight = true
    for _, icon in pairs(switchChoices) do
        if route.isCurveGlyph(icon) then
            allStraight = false
            break
        end
    end

    local crossings = {}
    for _, c in ipairs(path) do
        local cell = graph.cells[key(c.x, c.y)]
        if cell and cell.kind == "crossing" then
            crossings[cell.name] = true
        end
    end

    return {switches = switchChoices, crossings = crossings, cells = path, allStraight = allStraight}
end

-- Finds a route from entranceName to exitName. entranceName forces the route's first step
-- in ITS OWN facing direction (a signal only permits movement one way); exitName is purely
-- positional -- the route just needs to reach its cell, regardless of which way it faces.
-- Returns nil if none exists, otherwise {switches = {[switchName] = requiredIconGlyph, ...},
-- crossings = {[crossingName] = true, ...}, cells = {{x,y}, ...}, allStraight = bool}.
function route.findPath(graph, entranceName, exitName)
    return findPathInternal(graph, entranceName, exitName, false)
end

local function dirFromVector(dx, dy)
    for d, vec in pairs(DIRS) do
        if vec.dx == dx and vec.dy == dy then
            return d
        end
    end
    return nil
end

-- Given a route's result, returns every signal (any kind, any name) whose cell the route
-- passes through -- excluding the entrance's own cell (index 1 of result.cells) -- paired
-- with the direction the route actually travels through that cell:
-- {{name = "S1-3", travelDir = "L"}, ...}. Compare travelDir against that signal's own
-- .dir to know whether it was passed "the right way" (and should have its state updated)
-- or merely passed through/against its facing (and must be left alone).
function route.signalsAlongRoute(graph, result)
    local byPosition = {}
    for name, sig in pairs(graph.signalsByName) do
        local k = key(sig.x, sig.y)
        byPosition[k] = byPosition[k] or {}
        table.insert(byPosition[k], name)
    end

    local found = {}
    for i = 2, #result.cells do
        local prev, cur = result.cells[i - 1], result.cells[i]
        local d = dirFromVector(cur.x - prev.x, cur.y - prev.y)
        local names = byPosition[key(cur.x, cur.y)]
        if names then
            for _, name in ipairs(names) do
                found[#found + 1] = {name = name, travelDir = d}
            end
        end
    end
    return found
end

-- Stations that share one departure signal across several tracks (e.g. "L1-3" serving
-- tracks 1 and 3) mark which specific track is in use with an "Inserted Signal" (VS/VL
-- prefix) placed on that track. Given the set of Inserted-signal names actually used by
-- the route just built (usedNames, keyed by name), returns the other Inserted signals
-- strictly reachable from the same entrance (arriving in their own facing direction) that
-- were NOT used -- these should be reset to their most-restrictive state so only one
-- track ever shows authorized off a shared departure signal at a time.
function route.siblingInsertedSignals(graph, entranceName, usedNames)
    local siblings = {}
    for name, sig in pairs(graph.signalsByName) do
        if sig.kind == "inserted" and not usedNames[name] and findPathInternal(graph, entranceName, name, true) then
            siblings[#siblings + 1] = name
        end
    end
    return siblings
end

-- Lightweight in-memory route reservation. Only guards against two ORMS-built routes
-- claiming the same track/switch cells; there is no real train-occupancy detection.
local lockedCells = {}
local locksByEntrance = {}

function route.tryLock(entranceName, result)
    for _, c in ipairs(result.cells) do
        local owner = lockedCells[key(c.x, c.y)]
        if owner and owner ~= entranceName then
            return false
        end
    end

    route.unlock(entranceName)
    local claimed = {}
    for _, c in ipairs(result.cells) do
        local k = key(c.x, c.y)
        lockedCells[k] = entranceName
        claimed[k] = true
    end
    locksByEntrance[entranceName] = claimed
    return true
end

function route.unlock(entranceName)
    local claimed = locksByEntrance[entranceName]
    if not claimed then
        return
    end
    for k in pairs(claimed) do
        if lockedCells[k] == entranceName then
            lockedCells[k] = nil
        end
    end
    locksByEntrance[entranceName] = nil
end

function route.isLocked(x, y)
    return lockedCells[key(x, y)] ~= nil
end

return route
