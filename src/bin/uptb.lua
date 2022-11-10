#!/usr/bin/env lua
-- uptb - the UPT Build Tool

--local mtar = require("libmtar")
local upt = require("upt")
local arg = require("argcompat")
local getopt = require("getopt")

local options, usage, condense = getopt.build {
  { "Be verbose", false, "V", "verbose" },
  { "Be colorful", false, "c", "color" },
  { "Show UPT version", false, "v", "version" },
  { "Display this help message", false, "h", "help" },
}

local _, opts = getopt.getopt({
  options = options,
  exit_on_bad_opt = true,
  help_message = "pass '--help' for help"
}, arg.command("uptb", ...))

condense(opts)

require("upt.logger").setColored(opts.c)

if opts.h then
  io.stderr:write(([[
usage: uptb [options]
Builds UPT packages according to uptbuild.conf in the current working directory.

Prints the appropriate package list entry on success.

options:
%s

Copyright (c) 2022 ULOS Developers under the GNU GPLv3.
]]):format(usage))
  os.exit(1)
end

if opts.v then
  print(string.format("UPT %s", upt._VERSION))
  os.exit(0)
end

print(upt.build_package(opts.V))
