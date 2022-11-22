--- UPT filesystem utilities.
-- @module upt.filesystem
-- @alias lib

local checkArg = require("checkArg")
local dirent = require("posix.dirent")
local stat = require("posix.sys.stat")

local lib = {}

--- Check for file existence.
function lib.exists(file)
  checkArg(1, file, "string")
  return not not stat.stat(file)
end

--- Check if a file is a directory.
-- Returns false, and an error message, if the file does not exist.
function lib.isDirectory(file)
  checkArg(1, file, "string")

  local sx, err = stat.stat(file)
  if not sx then return nil, err end

  return stat.S_ISDIR(sx.st_mode) ~= 0
end

function lib.makeDirectory(file)
  return stat.mkdir(file, 0x1FF)
end

function lib.list(dir)
  checkArg(1, dir, "string")
  local files = dirent.dir(dir)
  table.sort(files)
  if files[1] == "." then table.remove(files, 1) end
  if files[1] == ".." then table.remove(files, 1) end
  return files
end

--- Combine file paths
function lib.combine(...)
  return (table.concat({...}, "/"):gsub("[/\\]+", "/"))
end

return lib
