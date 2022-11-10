--- UPT package list databases

local fs = require("upt.filesystem")
local dirent = require("posix.dirent")
local checkArg = require("checkArg")

local lib = {}

local dbo = {}

function dbo:retrieve(search, match)
  checkArg(1, search, "string")
  checkArg(2, match, "boolean", "nil")

  for file in dirent.files("/etc/upt/lists/") do
    for line in io.lines("/etc/upt/lists/" .. file) do
      local name, version, size, authors, depends, license, desc =
        line:match("([^ ]+) ([^ ]+) ([^:]+):([^:]+):([^:]*):([^:]*):(.*)")

      if search == name or (match and name:match(search)) then
        return name, version, size, authors, depends, license, desc
      end
    end
  end

  return nil, "entry not found"
end

function dbo:add()
  return nil, "operation not supported"
end

function dbo:remove()
  return nil, "operation not supported"
end

function dbo:close()
end

function lib.load()
  local files = fs.list("/etc/upt/lists")

  return setmetatable({files = files}, {__index = dbo})
end

return lib
