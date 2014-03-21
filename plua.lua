-- print lua variable in well-formatted format, especially for table

local tostring = tostring
local function key_str(k)
    if type(k)=="number" or tostring(tonumber(k))==k then
        return "[" .. tostring(k) .. "]"
    else
        return "[\"" .. tostring(k) .. "\"]"
    end
end

local tsort = table.sort

local function pairs_by_key(t)
    local tmp = {}
    for n in pairs(t) do
        tmp[#tmp+1] = n
    end
    tsort(tmp)
    local i = 0
    return function()
        i = i + 1
        return tmp[i], t[tmp[i]]
    end
end

local function plua(v)
    local function str(t)
        return type(t)=="string" and ('"' .. string.gsub(t,"\n","\\n") .. '"') or tostring(t)
    end

    local root = "__root_tmp__"
    local reg = {}
    local ret = {}
    local function _plua(k,t,tab)
        if type(t)=="table" then
            if reg[t]~=nil then
                ret[#ret+1] = reg[t] .. "\n"
            else
                reg[t] = key_str(k) .. "(" .. tostring(t) .. "),"
                ret[#ret+1] = "{\n"
                local old = tab
                tab = tab .. "    "
                for k,v in pairs_by_key(t) do
                    ret[#ret+1] = tab .. key_str(k) .. " = "
                    _plua(k,v,tab)
                end

                if k==root then
                    ret[#ret+1] = old .. "}\n"
                else
                    ret[#ret+1] = old .. "}, --" .. key_str(k) .. "\n"
                end
            end
        else
            ret[#ret+1] = str(t) .. ",\n"
        end
    end

    _plua(root, v, "")
    return table.concat(ret)
end

return plua
