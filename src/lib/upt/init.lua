--- UPT's core library
--@module upt
--@alias lib

-- This module loads other submodules from the `upt.*` namespace as-needed for speed reasons, and only nativewly provides a few common functions.  Otherwise loading the module would be quite slow.

local logger = require("upt.logger")

local lib = {}

function lib.throw(...)
  logger.fail(...)
  os.exit(1)
end

--- Trigger a package build.
function lib.build_package(verbose)
  local build = require("upt.build")

  verbose = not not verbose

  local bconf = config.load("uptbuild.conf")
  build.verify(options)
  build.build(options)
end

return lib
