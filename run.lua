require("plua")
csv  = require('csv')
tab = csv.load('MapEctypeNormal.csv', ',')
for k,v in ipairs(tab) do
    print(k, v)
    for kk,vv in ipairs(v) do
        print(kk,vv)
    end
end

local str = plua(tab)

local f = io.open("out.lua", "w")
f:write(str)
