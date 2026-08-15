local shell = require("shell")
local fs = require("filesystem")
local internet = require("internet")
local json = require("json")

local repoOwner = "Petsox"
local repoName = "Open-Rail-Management-System"
local branch = "automatic-route-building"
local repo = "https://raw.githubusercontent.com/" .. repoOwner .. "/" .. repoName .. "/" .. branch .. "/"
local repoFiles = { "init.lua", "json.lua", "controllers.lua", "updater.lua", "utils.lua", "route.lua", "grapes/Color.lua", "grapes/Event.lua", "grapes/Filesystem.lua", "grapes/GUI.lua", "grapes/Image.lua", "grapes/Keyboard.lua", "grapes/Number.lua", "grapes/Paths.lua", "grapes/Screen.lua", "grapes/Text.lua" }
local installLoc = "/home/orms/"
local manifestPath = installLoc .. "update_manifest.json"

shell.setWorkingDirectory(installLoc)

for file, _ in fs.list(installLoc) do
  print("Are you sure you want to update ORMS?\nThis will NOT delete your station configuration. (Y - Continue/N - Cancel)")
  ::Update::
  local input = string.lower(io.read())
  if input ~= "n" and input ~= "y" then
    print("Invalid choice (Y/N)")
    goto Update
  end

  if input == "n" then
    print("Update won't be installed")
    os.exit()
  end
  break
end

-- Function: httpGet
-- Description: Reads a full HTTP(S) response body. internet.request returns a callable
--              iterator over response chunks (NOT the whole body from one call), so this
--              drains it completely before returning. Returns nil, errorMessage on failure
--              (bad URL, connection refused, etc.) instead of raising, so callers can fall
--              back gracefully.
local function httpGet(url, headers)
  local ok, request = pcall(internet.request, url, nil, headers)
  if not ok then
    return nil, tostring(request)
  end
  local body = {}
  local readOk, err = pcall(function()
    for chunk in request do
      body[#body + 1] = chunk
    end
  end)
  if not readOk then
    return nil, tostring(err)
  end
  return table.concat(body)
end

-- Function: fetchRemoteHashes
-- Description: Fetches the current git blob SHA of every file in the repo in a single
--              request (GitHub's recursive tree listing) -- this is what lets the updater
--              tell which tracked files actually changed without downloading any of them
--              first. Returns nil, errorMessage on any failure (network, rate limit,
--              unparseable JSON) so the caller can fall back to updating everything, same as
--              before this feature existed.
local function fetchRemoteHashes()
  local url = "https://api.github.com/repos/" .. repoOwner .. "/" .. repoName .. "/git/trees/" .. branch .. "?recursive=1"
  local body, err = httpGet(url, {["User-Agent"] = "ORMS-Updater"})
  if not body then
    return nil, err
  end

  local ok, data = pcall(json.decode, body)
  if not ok or type(data) ~= "table" or type(data.tree) ~= "table" then
    return nil, "unexpected response from GitHub API"
  end

  local hashes = {}
  for _, entry in ipairs(data.tree) do
    if entry.type == "blob" and entry.path and entry.sha then
      hashes[entry.path] = entry.sha
    end
  end
  return hashes
end

-- Function: loadManifest / saveManifest
-- Description: The manifest remembers each tracked file's git blob SHA as of the last
--              successful update, so this run can tell "changed since we last updated" by
--              comparing it against a fresh fetchRemoteHashes() -- no local hashing needed
--              at all (and no dependency on a Data Card component being installed). Missing
--              or unreadable/corrupt manifests are treated as empty, which naturally makes
--              every tracked file look "changed" and get downloaded, same as a fresh install.
local function loadManifest()
  if not fs.exists(manifestPath) then
    return {}
  end
  local file = io.open(manifestPath, "r")
  if not file then
    return {}
  end
  local content = file:read("*a")
  file:close()
  local ok, data = pcall(json.decode, content)
  if ok and type(data) == "table" then
    return data
  end
  return {}
end

local function saveManifest(manifest)
  local file = io.open(manifestPath, "w")
  if not file then
    return
  end
  file:write(json.encode(manifest))
  file:close()
end

print("Checking which files changed...")
local remoteHashes, hashErr = fetchRemoteHashes()
local previousManifest = loadManifest()

local filesToDownload = {}
if remoteHashes then
  for _, file in pairs(repoFiles) do
    local remoteHash = remoteHashes[file]
    if not remoteHash or previousManifest[file] ~= remoteHash then
      filesToDownload[#filesToDownload + 1] = file
    end
  end
  print(#filesToDownload .. " of " .. #repoFiles .. " file(s) changed.")
else
  print("Couldn't reach GitHub's API (" .. tostring(hashErr) .. "), updating every file instead.")
  filesToDownload = repoFiles
end

if #filesToDownload == 0 then
  print("Everything is already up to date.")
else
  for _, file in ipairs(filesToDownload) do
    print("Updating " .. file .. "...")
    shell.execute("wget -f " .. repo .. file .. " -O " .. file)
  end
end

-- Only the hashes actually confirmed this run get recorded; anything fetchRemoteHashes
-- didn't return (e.g. it failed entirely) keeps its previous recorded hash rather than being
-- wiped, so a later successful run can still compare against real data.
if remoteHashes then
  local newManifest = {}
  for _, file in pairs(repoFiles) do
    newManifest[file] = remoteHashes[file] or previousManifest[file]
  end
  saveManifest(newManifest)
end

print("Update Complete, rebooting")
os.sleep(2)
shell.execute("reboot")