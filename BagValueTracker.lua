local _, _, _, tocVersion = GetBuildInfo()

if tocVersion < 50000 then
    -- Load Cataclysm module
    dofile("cata.lua")
else
    -- Load Dragonflight module
    dofile("tww.lua")
end
