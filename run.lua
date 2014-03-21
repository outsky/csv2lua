local function get_file_name(str)
    str = str:match(".+/([^/]*%.%w+)$")
    local idx = str:match(".+()%.%w+$")
    if idx then
        return str:sub(1, idx-1)
    else
        return str
    end
end

local usage = string.format("lua %s root csvpath luadir", arg[0])

if #arg~=3 then
    print(usage)
    return
end

local root = arg[1]
local csvpath = arg[2]
local luadir = arg[3]
local filename = get_file_name(csvpath)

local plua = require("plua")
local csv  = require('csv')
local tab, info = csv.load(csvpath, ',')
if not tab then
    print(string.format("[x] %s : %s", csvpath, info))
    return nil
end

local str = plua(tab)
local header = string.format("-- csv2lua: %s\n-- [ %s ]\n%s = %s or {}\n\n%s[\"%s\"] = ", os.date("%Y-%m-%d %H:%M:%S"), info, root, root, root, filename)

local outpath = luadir .. "/" .. filename .. ".lua"
local f = io.open(outpath, "w")
f:write(header .. str)
f:close()

print("[-] " .. csvpath .. " -> " .. outpath)

