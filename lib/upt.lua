--[[
  The ULOS Packaging Tool backend library.
  Copyright (C) 2022 ULOS Developers

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

--- UPT backend module.
-- This API uses state-based streams.  Every function returns a @{upt.State}
-- object.
-- @module upt
-- @alias upt

local db = require("upt.db")
local uname = require("posix.sys.utsname").uname()
local platform = require("upt."..uname.sysname:lower())

local upt = {}

-------- object for doing state -------
upt.State = {}

function upt.State:run(...)
  if not self.over then
    local result = self.func(...)
    if result == "done" then
      self.over = true
    end
    return result
  end
end

------- internal functions -------
upt.internal = {}
function upt.internal.search(dbase, pattern)
  local result = db.search(dbase, pattern)
  coroutine.yield(result)
  return "done"
end

function upt.internal.download(name)
  local url, size = db.search("remote", name, true)
  return "done"
end

------- create not-internal functions -------
local call = function(t, ...) return t:run(...) end

for k,v in pairs(upt.internal) do
  upt[k] = function(...)
    local new = setmetatable({func=coroutine.wrap(v)},
      {__index = upt.State, __call = call})
    new:run(...)
    return new
  end
end

return upt
