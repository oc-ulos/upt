--- UPT installed package database

local dirent = require("posix.dirent")
local checkArg = require("checkArg")
local fs = require("upt.filesystem")

local lib = {}

local dbo = {}

function dbo:retrieve(search, match, full)
  checkArg(1, search, "string")
  checkArg(2, match, "boolean", "nil")
  checkArg(3, full, "boolean", "nil")

  for file in dirent.files("/etc/upt/db") do
    if search == file or (match and file:match(search)) then
      local hand = assert(io.open("/etc/upt/db/"..file, "r"))
      local first = hand:read("l")

      local version, authors, depends, license, repo, desc =
        first:match("([^ ]+) ([^:]+):([^:]*):([^:]*)([^:]+):(.*)")

      local files = {}
      if full then
        for line in hand:lines() do
          files[#files+1] = line
        end
      end

      return version, authors, depends, license, repo, desc, files
    end
  end
end

-- only adds metadata, not files.
function dbo:add(name, version, authors, depends, license, repo, desc)
  checkArg(1, name, "string")
  checkArg(2, version, "string")
  checkArg(3, authors, "string")
  checkArg(4, depends, "string", "nil")
  checkArg(5, license, "string", "nil")
  checkArg(6, repo, "string")
  checkArg(7, desc, "string", "nil")

  depends = depends or ""
  license = license or ""
  desc = desc or ""

  if fs.exists("/etc/upt/db/" .. name) then
    return nil, "entry already exists"
  end

  local handle, oerr = io.open("/etc/upt/db/" .. name, "w")
  if not handle then
    return nil, oerr
  end

  handle:write(string.format("%s %s:%s:%s:%s:%s", version, authors, depends,
    license, repo, desc))

  handle:close()

  return true
end

-- does not remove package files from the disk, only removes db entries.
function dbo:remove(name)
  checkArg(1, name, "string")
  if fs.exists("/etc/upt/db/"..name) then
    os.remove("/etc/upt/db/"..name)
  end
end

function dbo:close()
end

function lib.load()
  return setmetatable({}, {__index = dbo})
end

return lib
