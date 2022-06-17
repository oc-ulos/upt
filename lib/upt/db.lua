-- UPT "database" backend
-- database format: header, index, entries
-- numbers are little-endian
-- header:
--    2 bytes: magic number 0x41DB
--    2 bytes: number of entries
--    4 bytes: index size
-- index:
--    indexentry foreach entry
-- indexentry:
--    4 bytes: offset into file
--    1 byte: name length
--    length bytes: name
-- entry:
--    4 bytes: length
--    repeat attribute until length exceeded
-- attribute:
--    1 byte: idlength
--    idlength bytes: identifier
--    2 bytes: datalength
--    datalength bytes: data

local lib = {}

local db = {}

-- read and parse the header and index
function db:readHeader()
  local header = self.fd:read(8)
  local magic, nent, idxsize = string.unpack("<I2I2I4", header)
  if magic ~= 0x41DB then
    error("upt.db: invalid database header", 0)
  end

  self.index = {}
  self.indexsize = idxsize
  local read = 0
  for i=1, nent, 1 do
    local ehead = self.fd:read(5)
    local offset, namelen = string.unpack("<I4I1", ehead)
    local name = self.fd:read(namelen)
    read = read + 5 + namelen
    self.index[i] = {offset = offset, name = name}
  end

  if read < idxsize then
    self.fd:seek("cur", idxsize - read)
  end
end

function db:addEntry()
end

function lib.open(path)
  local handle, err = io.open(path, "r+")
  if not handle then
    return nil, err
  end

  local new = setmetatable({fd = handle}, {__index = db})
  new:readHeader()

  return new
end

return lib
