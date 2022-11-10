#!/usr/bin/env lua
-- uptd - query UPT databases

local upt = require("upt")
local arg = require("argcompat")
local getopt = require("getopt")

local options, usage, condense = getopt.build {
  { "Be verbose", false, "V", "verbose" },
  { "Be colorful", false, "c", "color" },
  { "Show UPT version", false, "v", "version" }
  { "Display this help message", false, "h", "help" }
}

local args, opts = getopt.getopt({
  options = options,
  exit_on_bad_opt = true,
  help_message = "pass '--help' for help"
}, arg.command("uptd", ...))

condense(opts)

require("upt.logger").setColored(opts.c)

if #args == 0 or opts.h then
  io.stderr:write(([[
usage: uptd <db> <query ...>
Searches or manipulates the given UPT database.

The given database 'db' may be one of:
  i, inst, install, installed - installed packages
  l, list, package, pkglist   - all package lists
  r, repo, repository         - repository lists

The following queries are supported:
  a, c, cr, add, create - add an entry to the database
  r, rm, remove         - remove an entry from the database
  s, sh, show           - print an entry from the database to stdout

options:
%s

Copyright (c) 2022 ULOS Developers under the GNU GPLv3.
]]):format(usage))
  os.exit(1)
end
