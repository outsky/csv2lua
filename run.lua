require("plua")
csv  = require('csv')
tab = csv.load('csv/MapEctypeNormal.csv', ',')
local str = plua(tab)

local f = io.open("lua/MapEctypeNormal.lua", "w")
f:write(str)
