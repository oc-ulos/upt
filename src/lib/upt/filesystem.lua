--- UPT filesystem utilities.
-- @module upt.filesystem
-- @alias lib

local stat = require("posix.sys.stat")
local checkArg = require("checkArg")

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

return lib
