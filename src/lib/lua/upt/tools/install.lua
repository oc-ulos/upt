-- UPT package installer

local installed = require("upt.db.installed")
local logger = require("upt.logger")
local errno = require("posix.errno")
local stat = require("posix.sys.stat")
local meta = require("upt.meta")
local mtar = require("libmtar")
local upt = require("upt")
local fs = require("upt.filesystem")

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
        if type(package[6]) == "string" then
          if #package[6] > 0 then
            package[6] = {package[6]}
          else
            package[6] = {}
          end
        end

        if type(package[6]) == "table" then
          depcheck(package[2], db, package[6], true, result, checking)

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
  logger.ok("%s package '%s'",
    depcheck_mode == 1 and "checking" or "installing", file)

  root = root or "/"
  depcheck_mode = depcheck_mode or 0

  local handle, err = io.open(file, "r")
  if not handle then
    return nil, upt.throw(err)
  end

  local reader = mtar.reader(handle)

  local metadata = { reader:seek("/meta") }
  if #metadata == 0 then
    return upt.throw("package '%s' is missing /meta", file)
  end

  -- read and parse metadata from the package
  metadata = meta.split(handle:read(metadata[4]))
  if type(metadata[5]) == "string" then metadata[5] = {} end

  local db = installed.load(root)

  logger.ok("checking dependencies")
  if depcheck_mode == 0 then -- depcheck mode 0: error on unmet dependencies
    local depends = depcheck(metadata[1], db, metadata[5])

    if #depends > 0 then
      upt.throw("unmet dependencies: %s", table.concat(depends, ", "))
    end

  elseif depcheck_mode == 1 then -- depcheck mode 1: return unmet dependencies
    return depcheck(metadata[1], db, metadata[5])

  elseif depcheck_mode == 2 then -- depcheck mode 2: skip dependency checking
    logger.warn("installing package '%s' without checking dependencies", file)

  elseif depcheck_mode == 3 then
    -- depcheck mode 3: skip dependency checking and do not warn
  end

  local postinstalls = {}

  logger.ok("extracting package")
  for _, name, tags, ds in reader:iterate() do
    if name == "/meta" then break end

    -- literal file for the filesystem
    if name:sub(1, 6) == "/files" then
      if tags.mode and stat.S_ISDIR(tags.mode) ~= 0 then
        local path = fs.combine("/", root)

        for segment in name:gmatch("[^/\\]+") do
          if segment ~= "files" then
            path = path .. segment .. "/"

            local result, derr, eno = fs.makeDirectory(path)
            if not result and eno ~= errno.EEXIST then
              logger.fail("!! DIRECTORY CREATION FAILED !!")
              upt.throw(derr)
            end
          end
        end

      else
        local path = fs.combine(root, name:sub(7))
        local whandle, werr = io.open(path, "w")

        if not whandle then
          return upt.throw(werr)
        end

        repeat
          local diff = math.min(2048, ds)
          ds = ds - diff
          whandle:write(handle:read(diff))
        until ds == 0

        whandle:close()
      end

    elseif file:sub(1, 5) == "/post" then -- postinstall script
      postinstalls[#postinstalls+1] = { name, handle:seek("cur"), ds }
    end
  end

  logger.ok("running postinstall scripts")

  table.sort(postinstalls, function(a, b)
    return a[1] < b[1]
  end)

  for i=1, #postinstalls do
    local pi = postinstalls[i]
    handle:seek("set", pi[2])
    local data = handle:read(pi[3])

    logger.ok("(%d/%d) %s", i, #postinstalls, pi[1])

    local func, lerr = load(data, "="..pi[1], "t", _G)
    if not func then
      upt.fail("load error: %s", lerr)
    else

      local ok, perr = pcall(func)
      if not ok and perr then
        upt.fail("script error: %s", perr)
      end
    end
  end

  logger.ok("cleaning up")
  handle:close()

  return true
end

--- Install a package from a repository.
function lib.install_repo(name, root, depcheck_mode)
  local get = require("upt.tools.get").get
  root = root or "/"
  fs.makeDirectory(fs.combine(root, "/etc/upt/cache/"))

  local ok, err = get(name, "/etc/upt/cache/", root)
  if not ok then
    return upt.throw(err)
  end
  logger.ok("retrieved package '%s'", name)

  if depcheck_mode < 2 then
    local deps = lib.install_local(ok, root, 1)

    if deps then
      for i=1, #deps do
        lib.install_repo(deps[i], root, depcheck_mode)
      end
    end
  end

  lib.install_local(ok, root, depcheck_mode)

  os.remove(ok)
end

return lib
