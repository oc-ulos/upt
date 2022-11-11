-- ULOS 2 networking module

local lib = {}

local sys = require("syscalls")
local stdio = require("posix.stdio")
local checkArg = require("checkArg")

function lib.retrieve(url, file)
  checkArg(1, url, "string")
  checkArg(2, file, "string")

  local fd, err = sys.request(url)
  if not fd then
    return nil, err
  end

  local handle, werr = io.open(file, "w")
  if not handle then
    sys.close(fd)
    return nil, werr
  end

  repeat
    local chunk = sys.read(fd, 4096)
    if chunk then handle:write(chunk) end
  until not chunk

  handle:close()
  sys.close(fd)

  return true
end

return lib
