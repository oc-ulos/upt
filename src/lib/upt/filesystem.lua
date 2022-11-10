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

return lib
