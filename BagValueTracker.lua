-- Load the configuration file
if not BagValueTrackerConfig then
    BagValueTrackerConfig = {
        enableBagValue = { false, true, true, true, true, true }, -- Default to enabling bag value display (disable for the first bag)
    }
end

-- Create a frame to handle events
local frame = CreateFrame("Frame")

-- Table to hold text strings for bag value and slot overlays
local bagSlotTexts = {}

-- Function to update the slots overlay for closed bags
local function UpdateBagSlotOverlays()
    for bagID = 0, NUM_BAG_SLOTS do
        local bagIcon = _G["CharacterBag" .. (bagID - 1) .. "Slot"]
        if bagIcon then
            local usedSlots = 0
            local totalSlots = C_Container.GetContainerNumSlots(bagID)

            if totalSlots and totalSlots > 0 then
                for slotID = 1, totalSlots do
                    local itemInfo = C_Container.GetContainerItemInfo(bagID, slotID)
                    if itemInfo and itemInfo.itemID then
                        usedSlots = usedSlots + 1
                    end
                end
            end

            if not bagSlotTexts[bagID] then
                bagSlotTexts[bagID] = bagIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                bagSlotTexts[bagID]:SetPoint("TOP", bagIcon, "TOP", -1, 15) -- Adjust vertical offset for spacing
            end
            local bagAvail = totalSlots - usedSlots
            bagSlotTexts[bagID]:SetText(string.format("%d", bagAvail))
            bagSlotTexts[bagID]:SetTextColor(1, 1, 1)
        end
    end
end

-- Event handler function
local function OnEvent(self, event, bagID)
    if event == "BAG_OPEN" then
        BagValue.update(bagID)
    elseif event == "BAG_CLOSED" then
        UpdateBagSlotOverlays()
    elseif event == "BAG_UPDATE" then
        BagValue.update(bagID)
        UpdateBagSlotOverlays()
    elseif event == "PLAYER_LOGIN" then
        UpdateBagSlotOverlays()
    end
end

-- Register events for the frame
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("BAG_OPEN")
frame:RegisterEvent("BAG_CLOSED")
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", OnEvent)
