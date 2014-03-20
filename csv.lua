-- Using lua to parse CSV file to a table.

local error = error
local setmetatable = setmetatable
local lines = io.lines
local insert = table.insert
local concat = table.concat
local ipairs = ipairs
local string = string
local print = print

module(...)

string.split = function(str, pattern)
    local tb = {}
    local s = 1
    local e = 1
    while true do
        s,e = str:find(",", 1, true)
        if not s then
            break
        end
        local sub = str:sub(1, s-1)
        str = str:sub(e+1)
        insert(tb, sub)
    end

    return tb
end

local function parse_title(title, sep)
    local desc = title:split("[^" .. sep .. "]+")
    local class_mt = {}
    for k, v in ipairs(desc) do
        class_mt[v] = k
    end
    return class_mt
end

local function parse_line(mt, line, sep)
    local data = line:split("[^" .. sep .. "]+")
    setmetatable(data, mt)
    return data
end

function load(path, sep)
    local tag, sep, mt, data = false, sep or '|', nil, {}
    local i = 1
    local keys = {}
    local attrs = {}
    for line in lines(path) do
        if i==2 then
            if not tag then
                tag = true
                mt = parse_title(line, sep)
                mt.__index = function(t, k) if mt[k] then return t[mt[k]] else return nil end end
                mt.__newindex = function(t, k, v) error('attempt to write to undeclare variable "' .. k .. '"') end
            end
            -- get keys
            keys = parse_line(mt, line, sep)

        elseif i==4 then
            -- get attrs
            local t_attrs = parse_line(mt, line, sep)
            for k,v in ipairs(t_attrs) do
                if v=="key" or v=="key1" or v=="key2" then
                    if attrs[v] then
                        print("too many keys")
                        return nil
                    end
                    attrs[v] = k
                end
            end
            if not attrs.key and not attrs.key1 then return nil end

        elseif i>4 then
            local tvalue = parse_line(mt, line, sep)
            local kvalue = {}
            for k,v in ipairs(tvalue) do
                local key = keys[k]
                if key and #key>2 then
                    kvalue[key] = tvalue[k]
                end
            end
            local kidx = attrs["key"] or attrs["key1"]
            local key_id = tvalue[kidx]
            data[key_id] = data[key_id] or {}
            insert(data[key_id], kvalue)
        end

        i = i+1
    end
    return data
end

local class_mt = {
    __newindex = function(t, k, v)
        error('attempt to write to undeclare variable "' .. k .. '"')
    end
}

setmetatable(_M, class_mt)
