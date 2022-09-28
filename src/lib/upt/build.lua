-- UPT build code

local checkArg = require("checkArg")
local versions = require("upt.versions")
local files = require("upt.files")
local mtar = require("libmtar")
local upt = require("upt")

local valid = {
  name = true,
  authors = true,
  version = true,
  depends = true,
  license = true,
  description = true,
  srcdir = true,
  preproc = true
}

local optional = {
  depends = true,
  license = true,
  preproc = true
}

local function verify_string(x)
  return type(x) == "string" and #x > 0
end

local verifiers = {
  name = verify_string,
  authors = verify_string,
  version = versions.verify(v),
  depends = function(x) return type(x) == "string" end,
  license = function(x) return true end,
  description = verify_string,
  srcdir = files.exists,
  preproc = files.exists
}

local lib = {}

function lib.verify(options)
  checkArg(1, options, "table")

  for k, v in pairs(options) do
    k, v = tostring(k), tostring(v)
    if not valid[k] then
      upt.throw("invalid build config key - '%s'", k)
    end

    if not verifiers[k](v) then
      upt.throw("invalid build config value - '%s' is invalid for %s", v, k)
    end
  end

  for k in pairs(valid) do
    if not options[k] or optional[k] then
      upt.throw("missing build config key - '%s'", k)
    end
  end
end

function lib.build(options)
  lib.verify(options)
end

return lib
