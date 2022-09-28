--- Library for reading and writing MTAR v2 files.
-- @module libmtar
-- @alias lib


-- only supports mtar v2 files
-- TODO: maybe move to its own package?

local lib = {}

local HEADER = "\xFF\xFF\x02M"

local function readint(handle, size)
  return string.unpack("<I"..math.floor(size), handle:read(size))
end

local function readFileTags(handle, tagsize)
  local have_read = 0
  local tags = {}
  while have_read < tagsize do
    local tagspec_length = readint(handle, 2)
    local tag_name_length = readint(handle, 1)
    local tag_name = handle:read(tag_name_length)
    local tag_data_length = readint(handle, 2)
    local tag_data = handle:read(tag_data_length)
    if tagspec_length ~= tag_name_length + tag_data_length + 5 then
      error(string.format("mismatched tagspec length (specified %d, got %d)",
        tagspec_length, tag_name_length + tag_data_length + 5))
    end
    have_read = have_read + tagspec_length
  end
end

local function readFileRecord(handle)
  local recsize = readint(handle, 8)
  local name_length = readint(handle, 1)
  local name = handle:read(name_length)
  local tagsize = readint(handle, 2)
  local tags = readFileTags(handle, tagsize)
  local datsize = readint(handle, 8)
  return recsize, name, tags, datasize
end

--- Iterate over all MTAR file records in the given stream.
-- The stream must be compatible with the functions provided in standard `io` library streams.
-- The returned iterator expects the calling program to read all file data before calling it again.
function lib.iterate(stream)
  local header = stream:read(4)
  if header ~= HEADER then
    error(string.format(
      "bad MTAR v2 header (expected 0xFFFF024D, got %08x)",
      string.unpack("<I8", header)))
  end

  return function()
    return readFileRecord(stream)
  end
end


------
-- Writer object returned by @{writeto}.
-- @type Writer
local writer = {}

--- add a file from disk to the output
function writer:add()
end

--- add a custom file to the output
function writer:create()
end

--- Write MTAR data to a stream.
-- This function expects 
function lib.writeto(stream)
  
end

return lib
