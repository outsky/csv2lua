-- Using lua to parse CSV file to a table.

local error = error
local setmetatable = setmetatable
local lines = io.lines
local insert = table.insert
local concat = table.concat
local ipairs = ipairs
local string = string
local print = print
local tonumber = tonumber

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

local function trim_right(line)
    return line:gsub("%s+$", "")
end

local function make_line_end(line)
    if line:sub(-1)~=',' then
        line = line .. ","
    end

    return line
end

function load(path, sep)
    local tag, sep, mt, data = false, sep or '|', nil, {}
    local i = 1
    local keys = {}
    local attrs = {}
    local last_key = nil
    local info = ""
    for line in lines(path) do
        line = make_line_end( trim_right(line) )
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
                        info = "too many " .. v
                        return nil, info
                    end
                    attrs[v] = k
                end
            end
            if not attrs.key and not attrs.key1 then
                info = "no key"
                return nil, info
            elseif attrs.key and (attrs.key1 or attrs.key2) then
                info = "key and (key1 or key2) exist at the same time"
                return nil, info
            elseif attrs.key1 and not attrs.key2 then
                info = "key1 exist but key2 missed"
                return nil, info
            end

            if attrs.key then
                info = "key: " .. keys[attrs.key]
            elseif attrs.key1 then
                info = "key1: " .. keys[attrs.key1] ..", key2: " .. keys[attrs.key2]
            end

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
            if not tonumber(key_id) then
                key_id = last_key
            else
                last_key = key_id
            end
            data[key_id] = data[key_id] or {}
            insert(data[key_id], kvalue)
        end

        i = i+1
    end
    return data, info
end

local class_mt = {
    __newindex = function(t, k, v)
        error('attempt to write to undeclare variable "' .. k .. '"')
    end
}

setmetatable(_M, class_mt)
