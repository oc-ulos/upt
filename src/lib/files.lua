-- upt.files

local lib = {}

function lib.exists(file)
  local hand = io.open(file, "r")
  return hand and hand:close()
end

function lib.combine(...)
  return table.concat({...}, "/"):gsub("[/\\]+", "/")
end

return lib
