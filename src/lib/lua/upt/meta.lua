--- Common package metadata stuff.

local lib = {}

local function split_on(str, c)
  str = str:gsub("%" .. c .. "%" .. c, c .. "!#!" .. c)
  local parts = {}
  for part in str:gmatch("[^%"..c.."]+") do
    if part == "!#!" then part = "" end
    parts[#parts+1] = part
  end
  return parts
end

lib.split_on = split_on

function lib.split(meta)
  local split = split_on(meta, ":")

  for i=1, #split do
    if split[i]:find(",", nil, true) and i < #split then
      split[i] = split_on(split[i], ",")
    end
  end

  return split
end

function lib.assemble(...)
  local args = table.pack(...)

  for i=1, args.n do
    if type(args[i]) == "table" then
      args[i] = table.concat(args[i], ",")

    elseif not args[i] then
      args[i] = ""
    end
  end

  return table.concat(args, ":")
end

return lib
