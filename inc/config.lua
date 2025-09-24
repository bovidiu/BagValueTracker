-- inc/config.lua
local Config = {}

-- Default settings
local defaults = {
    retailMerged = true, -- true = merged view, false = per-bag view
}

function Config:Load()
    if not BagValueTrackerDB then
        BagValueTrackerDB = {}
    end
    for k, v in pairs(defaults) do
        if BagValueTrackerDB[k] == nil then
            BagValueTrackerDB[k] = v
        end
    end
end

function Config:Get(key)
    return BagValueTrackerDB[key]
end

function Config:Set(key, value)
    BagValueTrackerDB[key] = value
end

return Config
