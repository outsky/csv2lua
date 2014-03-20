local function get_file_name(str)
    str = str:match(".+/([^/]*%.%w+)$")
    local idx = str:match(".+()%.%w+$")
    if idx then
        return str:sub(1, idx-1)
    else
        return str
    end
end

local usage = string.format("lua %s csvpath luadir", arg[0])

if #arg~=2 then
    print(usage)
    return
end

local csvpath = arg[1]
local luadir = arg[2]
local filename = get_file_name(csvpath)

local plua = require("plua")
local csv  = require('csv')
local tab = csv.load(csvpath, ',')
local str = plua(tab)
local outpath = luadir .. "/" .. filename .. ".lua"

local f = io.open(outpath, "w")
f:write(str)

print("[OK] " .. csvpath .. " -> " .. outpath)
