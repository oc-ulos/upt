--- UPT version parser
-- Can parse versions like:
--  - 0.2.2 and 0.6.2.4.5
--  - 0.4-dev1 and 0.5.1-alpha4
-- Version format is more or less:
--   Real.Version.Info.Numbers-BuildInformation

local checkArg = require("checkArg")

local lib = {}

--- Parse a version string
-- @treturn table The version information, as a table of numbers
-- @treturn[opt] string The build information string
function lib.parse(ver)
  checkArg(1, ver, "string")

  local components
  if ver:match("-") then
    components = {ver:match("([^%-]+)(%-)(.+)")}
  else
    components = {ver}
  end

  local c1 = {}
  for num in components[1]:gmatch("[^%.]+") do
    if not tonumber(num) then
      return nil, "invalid number '"..num.."' in version string component 1"
    end
    c1[#c1+1] = tonumber(num)
  end

  components[1] = c1

  return table.unpack(components)
end

return lib
