--- UPT's logger
--@module upt.logger
--@alias lib

local lib = {}

local prefixes = {
  ok   = {
    color = "\27[97m[  \27[92mOK\27[97m  ] ",
    standard = "[  OK  ] "
  },
  warn = {
    color = "\27[97m[ \27[93mWARN\27[97m ] ",
    standard = "[ WARN ] "
  },
  fail = {
    color = "\27[97m[ \27[91mFAIL\27[97m ] ",
    standard = "[ FAIL ] "
  },
}

local color = false
for k, v in pairs(prefixes) do
  lib[k] = function(...)
    io.stderr:write(color and v.color or v.standard, string.format(...), "\n")
  end
end

function lib.setColored(b)
  color = not not b
  return not color
end

return lib
