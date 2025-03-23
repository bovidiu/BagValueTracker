-- Create or load the saved settings
BagValueTrackerConfig = BagValueTrackerConfig or { enableBagValue = { false, true, true, true, true, true } }

-- Create a frame to handle events
local frame = CreateFrame("Frame")

-- Event handler function
local function OnEvent(self, event, bagID)
    -- Only process bag events (exclude ADDON_LOADED event if bagID is not a valid number)
    if event == "ADDON_LOADED" then
        -- Only execute when the addon is loaded, skip any bagID processing
        if bagID == "BagValueTracker" then
            -- Ensure all bags have a setting
            for i = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1 do
                if BagValueTrackerConfig.enableBagValue[i] == nil then
                    BagValueTrackerConfig.enableBagValue[i] = true
                end
            end
        end
        return -- exit early for ADDON_LOADED
    end

    -- Skip non-bag events (bagID is a string like "TomTom")
    if not tonumber(bagID) then
        return
    end

    if event == "BAG_OPEN" then
        BagValue.update(bagID)
    elseif event == "BAG_CLOSED" then
        BagValue.update(bagID)
    elseif event == "BAG_UPDATE" then
        BagValue.update(bagID)
    elseif event == "PLAYER_LOGIN" then
        BagValue.update(bagID)
    end
end

-- Register events for the frame
frame:RegisterEvent("ADDON_LOADED") -- Ensures settings are loaded on login
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("BAG_OPEN")
frame:RegisterEvent("BAG_CLOSED")
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", OnEvent)
