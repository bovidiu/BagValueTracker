-- Addon namespace and saved settings.
--
-- BagValueTrackerConfig is a SavedVariable (see the .toc files). The client
-- replaces the global with the stored table just before ADDON_LOADED fires for
-- this addon, so defaults must be filled in there rather than at file scope.

BagValueTracker = BagValueTracker or {}

local addonName = ...

-- Default settings. enableBagValue is indexed by bagID + 1:
--   [1] backpack (0)   [2]-[5] equipped bags (1-4)   [6] reagent bag (5, Retail)
local DEFAULTS = {
    enableBagValue = { false, true, true, true, true, true },
    showTooltipValue = true, -- append the sell value to item tooltips
    useAuctionPrice = true,   -- prefer Auctionator's auction price over vendor price
}

BagValueTracker.DEFAULTS = DEFAULTS

-- Copy any missing keys from defaults into target, recursing into subtables and
-- extending arrays, without overwriting values the player has already set.
local function applyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            applyDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

-- Callbacks to run once BagValueTrackerConfig is populated (used by the options
-- panel to build its controls against real values).
BagValueTracker.onConfigReady = {}

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, loadedName)
    if loadedName ~= addonName then
        return
    end
    self:UnregisterEvent("ADDON_LOADED")

    if type(BagValueTrackerConfig) ~= "table" then
        BagValueTrackerConfig = {}
    end
    applyDefaults(BagValueTrackerConfig, DEFAULTS)

    for _, callback in ipairs(BagValueTracker.onConfigReady) do
        pcall(callback)
    end
end)
