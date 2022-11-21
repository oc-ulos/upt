-- UPT package installer

local installed = require("upt.db.installed")
local logger = require("upt.logger")
local meta = require("upt.meta")
local mtar = require("libmtar")
local upt = require("upt")

local lib = {}

local function depcheck(name, db, depends, recurse, result, checking)
  result = result or {}
  checking = checking or {}

  if checking[name] then
    return logger.warn()
  end

  checking[name] = true

  for i=1, #depends do
    local entry = db:retrieve(depends[i])
    if not entry then
      depends[#depends+1] = depends[i]

    elseif recurse then
      for j=1, #entry do
        local package = entry[j]
        if type(package[6]) == "table" then
          depcheck(db, package[6], true, result, checking)

        else
          -- no point in dependency checking packages that are already installed
          break
        end
      end
    end
  end

  return result
end

--- Install a local package.
-- @tparam string file The package file to install
-- @tparam[opt="/"] string root Alternative root filesystem to use
-- @tparam[opt=0] number depcheck_mode Dependency checking mode
function lib.install_local(file, root, depcheck_mode)
  root = root or "/"
  depcheck_mode = depcheck_mode or 0

  local handle, err = io.open(file, "r")
  if not handle then
    return nil, upt.throw(err)
  end

  local reader = mtar.reader(handle)

  local metadata = { reader:seek("/meta") }
  if #metadata == 0 then
    return upt.throw("package '"..file.."' is missing /meta")
  end

  -- read and parse metadata from the package
  metadata = meta.split(handle:read(metadata[4]))

  local db = installed.load(root)

  if depcheck_mode == 0 then -- depcheck mode 0: error on unmet dependencies
    local depends = depcheck(db, metadata[5])

    if #depends > 0 then
      upt.throw("unmet dependencies: " .. table.concat(depends, ", "))
    end

  elseif depcheck_mode == 1 then -- depcheck mode 1: return unmet dependencies
    return depcheck(db, metadata[5])

  elseif depcheck_mode == 2 then -- depcheck mode 2: ignore unmet dependencies
    logger.warn("instaling package '"..file.."' without checking dependencies")
  end

end

--- Install a package from the repo.
function lib.install_repo()
end

return lib
