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
    -- Fixed three-way junctions (plain Track glyphs, not a Switch -- always open all three
    -- ways at once, no throwable position). continuationsFor/search already handle a
    -- non-switch cell offering more than one onward direction generically (the DFS just
    -- tries each and backtracks on failure), so no other change is needed to support these.
    ["╠"] = {U = true, D = true, R = true},
    ["╣"] = {U = true, D = true, L = true},
    ["╦"] = {L = true, R = true, D = true},
    ["╩"] = {L = true, R = true, U = true},
    -- Tunnel mouths: purely decorative, pass straight through.
    ["⦗"] = {L = true, R = true},
    ["⦘"] = {L = true, R = true},
    ["︹"] = {U = true, D = true},
    ["︺"] = {U = true, D = true},
}

local CURVE_GLYPHS = {["╗"] = true, ["╝"] = true, ["╚"] = true, ["╔"] = true}

-- Signal facing icon -> direction of authorized travel through the signal.
local FACING_DIR = {
    ["<"] = "L", ["◀"] = "L", ["◁"] = "L", ["˂"] = "L",
    [">"] = "R", ["▶"] = "R", ["▷"] = "R", ["˃"] = "R",
    ["^"] = "U", ["▲"] = "U", ["△"] = "U", ["˄"] = "U",
    ["V"] = "D", ["▼"] = "D", ["▽"] = "D", ["˅"] = "D",
}

local function key(x, y)
    return x .. "," .. y
end

local function stateKey(x, y, dir)
    return x .. "," .. y .. "," .. dir
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
    elseif prefix == "Sc" or prefix == "Lc" then
        return "repeater"
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
            -- A fixed multi-way junction (╠╣╦╩) can offer more than one continuation at
            -- once, unlike every other plain track glyph. Try continuing straight through
            -- (same direction as arrival) before turning, same principle as switches
            -- preferring their straight icon over the curved one -- otherwise a search
            -- arriving here always tries the turn first (DIR_ORDER doesn't know "straight"
            -- from "turn"), producing a needlessly roundabout route whenever the straight
            -- option would also have worked.
            if dirs[cameFromDir] then
                results[#results + 1] = {dir = cameFromDir}
            end
            for _, d in ipairs(DIR_ORDER) do
                if d ~= entrySide and d ~= cameFromDir and dirs[d] then
                    results[#results + 1] = {dir = d}
                end
            end
        end
    end

    return results
end

local function cloneTable(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

-- strictExit: if true, the exit must also be arrived at heading in ITS OWN facing
-- direction (used internally for sibling-reachability checks). If false, the exit is a
-- pure location marker -- any arrival direction counts, since the operator's clicked exit
-- signal may deliberately face "backwards" relative to the route (e.g. selecting VL3 to
-- mean "route to track 3" even though the train travels opposite VL3's own facing).
--
-- Breadth-first, not depth-first: a depth-first search always finishes exploring "keep
-- going straight" before ever backtracking to a nearby switch, so on a track with several
-- switches in a row it tends to find some valid-but-circuitous route through a distant one
-- before ever trying the closest one -- backtracking unwinds from whichever switch was
-- visited LAST, not whichever is nearest the entrance. Searching breadth-first instead
-- guarantees the first route found is a shortest one (fewest cells), which is what actually
-- matches what a dispatcher would expect.
--
-- visited is a single table SHARED across the whole search (not cloned per branch), keyed by
-- "x,y,dir" and marked at enqueue time -- this is the standard BFS dedup: once some branch has
-- reached a given cell heading a given direction, no other branch can usefully reach that same
-- state again (BFS processes strictly non-decreasing path length, so the first arrival is via a
-- shortest path). Without this, a station with N switches feeding into each other lets many
-- different switch-commitment histories re-converge on the same physical cells, and the queue
-- grows combinatorially in N instead of staying roughly linear in graph size -- this is exactly
-- what made routes crossing a station's whole switch ladder (many switches) hang, while shorter
-- routes crossing only a few switches stayed fast. switchChoices/path are still cloned only when
-- they actually change, same as before, so different branches can still commit differently to a
-- switch they haven't reached yet.
local function findPathInternal(graph, entranceName, exitName, strictExit)
    local entrance = graph.signalsByName[entranceName]
    local exit = graph.signalsByName[exitName]
    if not entrance or not exit or not entrance.dir then
        return nil
    end

    local vec = DIRS[entrance.dir]
    local startX, startY, startDir = entrance.x + vec.dx, entrance.y + vec.dy, entrance.dir
    local visited = {[stateKey(startX, startY, startDir)] = true}
    local queue = {
        {
            x = startX, y = startY, dir = startDir,
            switchChoices = {},
            path = {{x = entrance.x, y = entrance.y}},
        },
    }
    local head = 1

    while head <= #queue do
        local node = queue[head]
        head = head + 1

        if node.x == exit.x and node.y == exit.y and (not strictExit or node.dir == exit.dir) then
            local path = cloneTable(node.path)
            path[#path + 1] = {x = node.x, y = node.y}

            local allStraight = true
            for _, icon in pairs(node.switchChoices) do
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

            return {switches = node.switchChoices, crossings = crossings, cells = path, allStraight = allStraight}
        end

        local cell = graph.cells[key(node.x, node.y)]
        if cell then
            local path = cloneTable(node.path)
            path[#path + 1] = {x = node.x, y = node.y}

            for _, opt in ipairs(continuationsFor(cell, node.dir, node.switchChoices)) do
                local optVec = DIRS[opt.dir]
                local nx, ny = node.x + optVec.dx, node.y + optVec.dy
                -- Never step back onto the entrance's own cell, from any direction -- it's
                -- the start of the route, not a valid waypoint.
                if not (nx == entrance.x and ny == entrance.y) then
                    local sk = stateKey(nx, ny, opt.dir)
                    if not visited[sk] then
                        visited[sk] = true
                        local switchChoices = node.switchChoices
                        if opt.icon then
                            switchChoices = cloneTable(node.switchChoices)
                            switchChoices[cell.name] = opt.icon
                        end
                        queue[#queue + 1] = {
                            x = nx, y = ny, dir = opt.dir,
                            switchChoices = switchChoices, path = path,
                        }
                    end
                end
            end
        end
    end

    return nil
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
-- with the direction the route actually travels through that cell and its index within
-- result.cells: {{name = "S1-3", travelDir = "L", index = 7}, ...}. Compare travelDir
-- against that signal's own .dir to know whether it was passed "the right way" (and should
-- have its state updated) or merely passed through/against its facing (and must be left
-- alone). index is what lets route.segmentStraight check curvature between two specific
-- signals along the path, rather than the route as a whole.
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
                found[#found + 1] = {name = name, travelDir = d, index = i}
            end
        end
    end
    return found
end

-- Whether the stretch of a built route between result.cells[fromIndex] and
-- result.cells[toIndex] (inclusive) passes through any switch used in its curved position.
-- result.allStraight covers the WHOLE route; this covers just one hop of it, so a signal
-- whose own immediate segment is straight doesn't inherit an R-prefix caused by a curve
-- somewhere else entirely on the route.
function route.segmentStraight(graph, result, fromIndex, toIndex)
    local lo, hi = fromIndex, toIndex
    if lo > hi then
        lo, hi = hi, lo
    end
    for i = lo, hi do
        local c = result.cells[i]
        local cell = graph.cells[key(c.x, c.y)]
        if cell and cell.kind == "switch" then
            local icon = result.switches[cell.name]
            if icon and route.isCurveGlyph(icon) then
                return false
            end
        end
    end
    return true
end

-- Checks (x, y) itself first (before walking anywhere), then walks forward in travelDir,
-- finds the first Main/Inserted/Repeater signal reached facing that same direction of
-- travel -- any signal that carries a real state a following signal could react to
-- (shunting/expect signals are just pass-through markers, and a signal facing the opposite
-- way is for the other direction, so both are skipped, not stopped at). Checking the
-- starting position itself matters for a route's own exit: if it's approached facing the
-- SAME way it's posted, it IS the next real authority (nothing needs to be found beyond
-- it) -- only a "backwards" exit (used as a pure location marker, e.g. selecting a track by
-- its Inserted signal) needs the walk to continue past it. Returns name = nil when no such
-- signal is reachable; the second return distinguishes WHY: true if the walk hit a switch
-- cell first (the next signal depends on a position nothing here has set, so it's genuinely
-- ambiguous which one comes next), false if the walk ran off the graph entirely (a real
-- dead end/terminus -- there's nothing further to be cautious about).
function route.nextSignal(graph, x, y, travelDir)
    if not travelDir then
        return nil, false
    end

    local byPosition = {}
    for name, sig in pairs(graph.signalsByName) do
        local k = key(sig.x, sig.y)
        byPosition[k] = byPosition[k] or {}
        table.insert(byPosition[k], name)
    end

    local function signalAt(cx, cy, dir)
        for _, name in ipairs(byPosition[key(cx, cy)] or {}) do
            local sig = graph.signalsByName[name]
            if sig.dir == dir and (sig.kind == "main" or sig.kind == "inserted" or sig.kind == "repeater") then
                return name
            end
        end
        return nil
    end

    local startMatch = signalAt(x, y, travelDir)
    if startMatch then
        return startMatch, false
    end

    local visited = {}
    local cx, cy, dir = x, y, travelDir
    while true do
        local vec = DIRS[dir]
        cx, cy = cx + vec.dx, cy + vec.dy
        local k = key(cx, cy)
        if visited[k] then
            return nil, false
        end
        visited[k] = true

        local cell = graph.cells[k]
        if not cell then
            return nil, false
        end
        if cell.kind == "switch" then
            return nil, true
        end

        local found = signalAt(cx, cy, dir)
        if found then
            return found, false
        end

        local entrySide = OPPOSITE[dir]
        local dirs = cell.dirs
        local nextDirs = {}
        if dirs and dirs[entrySide] then
            for _, d in ipairs(DIR_ORDER) do
                if d ~= entrySide and dirs[d] then
                    nextDirs[#nextDirs + 1] = d
                end
            end
        end
        if #nextDirs > 1 then
            -- A fixed three-way junction (no throwable switch) offers more than one way
            -- onward here -- just as undecidable as an unresolved switch, so treat it the
            -- same way: ambiguous, not a dead end.
            return nil, true
        end
        local nextDir = nextDirs[1]
        if not nextDir then
            return nil, false
        end
        dir = nextDir
    end
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
