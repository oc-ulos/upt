#!/usr/bin/env lua
-- uptg - download packages

local upt = require("upt")
local net = require("upt.network")
local fs = require("upt.filesystem")
local repos = require("upt.db.repo")
local lists = require("upt.db.lists")
local arg = require("argcompat")
local getopt = require("getopt")
local unistd = require("posix.unistd")

local options, usage, condense = getopt.build {
  { "Be verbose", false, "V", "verbose" },
  { "\tBe colorful", false, "c", "color" },
  { "Alternative root filesystem", "PATH", "r", "root" },
  {"Show UPT version", false, "v", "version" },
  {"\tDisplay this help message", false, "h", "help"}
}

local args, opts = getopt.getopt({
  options = options,
  exit_on_bad_opt = true,
  help_message = "pass '--help' for help"
}, arg.command("uptg", ...))

condense(opts)

require("upt.logger").setColored(opts.c)

if opts.v then
  print("UPT " .. upt._VERSION)
  os.exit(0)
end

if #args == 0 or opts.h then
  io.stderr:write(([[
usage: uptg <pkgname> [dest]
Downloads the given package.  If DEST is provided and points to a folder, uptg
will place the downloaded archive there;  DEST defaults to the current working
directory.

options:
%s

Copyright (c) 2022 ULOS Developers under the GNU GPLv3.
]]):format(usage))
end

local dest = unistd.getcwd()

if args[2] then
  if fs.isDirectory(args[2]) then
    dest = args[2]
  else
    upt.throw(args[2] .. ": not a directory")
  end
end

local dbL = lists.load(opts.r)
local entries, err = dbL:retrieve(args[1])

if not entries then
  return upt.throw(err)

elseif #entries > 1 then
  upt.throw("TODO: handle multiple identical package entries")
end

local repo, pkgname, pkgver = entries[1][1], entries[1][2], entries[1][3]
dest = fs.combine(dest, pkgname .. "-" .. pkgver .. ".mtar")

-- get package URL
local dbR = repos.load(opts.r)
local repoent = dbR:retrieve(repo)

if not repoent then
  return upt.throw("repository not present for given package")
end

local baseurl = repoent[1][3]

local ok, nerr = net.retrieve(
  baseurl .. "/" .. pkgname .. "-" .. pkgver .. ".mtar", dest)

if not ok then
  upt.throw(nerr)
end
