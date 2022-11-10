-- UPT build code

local checkArg = require("checkArg")
local versions = require("upt.versions")
local mtar = require("libmtar")
local tree = require("treeutil").tree
local upt = require("upt")
local fs = require("upt.filesystem")

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
  preproc = true,
  prebuild = true,
}

local function verify_string(x)
  return type(x) == "string" and #x > 0
end

local function relative_exists(x)
  return fs.exists("./" .. x)
end

local verifiers = {
  name = verify_string,
  authors = verify_string,
  version = versions.parse,
  depends = function(x) return type(x) == "string" end,
  license = function(_) return true end,
  description = verify_string,
  srcdir = relative_exists,
  prebuild = relative_exists,
  preproc = relative_exists
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
    if not (options[k] or optional[k]) then
      upt.throw("missing build config key - '%s'", k)
    end
  end
end

function lib.build(options)
  lib.verify(options)

  if options.preproc then
    fs.mkdir("./temp")
  end

  -- bundle all the files into an MTAR
  local out, err = io.open(options.name .. "-"
    .. options.version .. ".mtar", "w")
  if not out then
    upt.throw(err)
  end

  local writer = mtar.writeto(out)

  -- TODO: use preprocessor
  local files = tree("./" .. options.srcdir)
  for i=1, #files do
    local base = files[i]:sub(#options.srcdir + 2)
    writer:add(files[i], "/files/" .. base)
  end

  local size = out:seek("cur")
  writer:close()

  return string.format("%s %s %d:%s:%s:%s:%s",
    options.name, options.version, size, options.authors,
    options.depends or "", options.description, options.license or "")
end

return lib
