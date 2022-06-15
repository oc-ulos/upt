--[[
  The ULOS Packaging Tool.
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

local argv = require("argcompat").command("upt", ...)
local upt = require("upt")

-- fancy option/help message building
local supported_opts = {
  --  fields: description,    arg name or false, option name(s)
  { "Show this help message", false,             "h", "help"},
  { "Be verbose",             false,             "v", "verbose"},
  { "Print version and exit", false,             "V", "version"}
}

local options = {
}

local usage_opts = {}

for i=1, #supported_opts, 1 do
  local opt = supported_opts[i]
  local use = {}
  for n=3, #opt, 1 do
    options[opt[n]] = not not opt[2]
    use[#use+1] = (#opt[n] == 1 and "-" or "--") .. opt[n]
  end
  usage_opts[#usage_opts+1] = string.format("%s%s\t%s",
    table.concat(use, ", "), opt[2] and (" " .. opt[2]) or "", opt[1])
end

local usage = ([=[
usage: %s [options] [action [...]]

options:
  %s

actions:
 %s

Copyright (c) 2022 ULOS Developers under the GNU GPLv3.
]=]):format(argv[0], table.concat(usage_opts, "\n  "), "")

local args, opts = require("getopt").getopt({
  options = options,
  help_message = "pass '--help' for help\n",
  exit_on_bad_opt = true,
  allow_finish = true,
}, argv)

local function die(...)
  io.stderr:write(string.format(...), "\n")
  os.exit(1)
end

if opts.h or #args == 0 then
  die("%s", usage)
end
