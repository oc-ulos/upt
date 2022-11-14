#!/usr/bin/env lua
-- upti - install UPT packages

local mtar = require("libmtar")
local arg = require("argcompat")
local getopt = require("getopt")

local options, usage, condense = getopt.build {
  { "Be verbose", false, "V", "verbose" },
  { "\tBe colorful", false, "c", "color" },
  { "Alternative root filesystem", "PATH", "r", "rootfs" },
  { "Show UPT version", false, "v", "version" },
  { "\tDisplay this help message", false, "h", "help" }
}

local args, opts = getopt.getopt({
  options = options,
  exit_on_bad_opt = true,
  help_message = "pass '--help' for help",
}, arg.command("upti", ...))

condense(opts)

require("upt.logger").setColored(opts.c)

local function showUsage()
  io.stderr:write(([[
usage: upti <file ...>
Installs given packages.  All FILE arguments must be absolute paths to local
files.

options:
%s

Copyright (c) 2022 ULOS Developers under the GNU GPLv3.
]]):format(usage))
  os.exit(1)
end

if #args == 0 or opts.h then
  showUsage()
end
