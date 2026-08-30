BagValue = {}

-- Store bag value text
local bagValueTexts = {}

-- Highest container index that may carry a value display. NUM_BAG_SLOTS covers
-- the backpack (0) plus the four equippable bag slots; on Retail the reagent bag
-- sits one slot past that.
local function maxBagID()
    local maxID = NUM_BAG_SLOTS or 4
    if Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag then
        maxID = math.max(maxID, Enum.BagIndex.ReagentBag)
    end
    return maxID
end
BagValue.maxBagID = maxBagID

-- Is the value display enabled for this bag? Tolerates a config table that is
-- shorter than the current bag count (e.g. an older list that predates the
-- reagent bag) instead of silently treating the missing entry as disabled.
local function isEnabled(bagID)
    local list = BagValueTrackerConfig and BagValueTrackerConfig.enableBagValue
    if type(list) ~= "table" then
        return bagID ~= 0
    end

    local value = list[bagID + 1]
    if value == nil then
        return bagID ~= 0 -- default: on for every bag except the backpack
    end
    return value
end

-- Function to update and display the vendor value when the bag is opened
BagValue.update = function(bagID)
    if not bagID then
        return
    end

    local totalVendorValue = 0
    local incomplete = false

    local numSlots = C_Container.GetContainerNumSlots(bagID)
    if numSlots and numSlots > 0 then
        for slotID = 1, numSlots do
            local itemLink = C_Container.GetContainerItemLink(bagID, slotID)
            if itemLink then
                local itemInfo = C_Container.GetContainerItemInfo(bagID, slotID)
                local itemCount = itemInfo and itemInfo.stackCount or 1 -- Safely get the count of the item

                -- Get the vendor value and multiply it by the count
                local itemValue, pending = ItemValue.get(itemLink)
                if pending then
                    incomplete = true -- at least one item could not be valued yet
                end
                totalVendorValue = totalVendorValue + (itemValue * itemCount) -- Add the item's total value (value * count)
            end
        end
    end

    -- Display vendor value only when the bag is open and enabled for that bag
    local bagFrame = _G["ContainerFrame" .. (bagID + 1)]
    if bagFrame and isEnabled(bagID) then
        -- Remove existing text if it exists
        if bagValueTexts[bagID] then
            bagValueTexts[bagID]:SetText("") -- Clear previous text
        else
            -- Create the text string only if it doesn't exist
            bagValueTexts[bagID] = bagFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            -- Move the text to the right side of the bag
            bagValueTexts[bagID]:SetPoint("TOPRIGHT", bagFrame, "TOPRIGHT", -10, -30) -- Adjust position as needed
        end
        -- Update the text with the new vendor value formatted
        if totalVendorValue > 0 then
            local formattedValue = Currency.format(totalVendorValue)
            if incomplete then
                formattedValue = formattedValue .. " ..." -- data still loading; total will rise
            end
            bagValueTexts[bagID]:SetText(formattedValue)
            bagValueTexts[bagID]:SetTextColor(1, 1, 0) -- Set text color to bright yellow (RGB)
        else
            bagValueTexts[bagID]:SetText("") -- Clear if no items have vendor value
        end
    else
        -- Clear the display if not enabled or bagID is 0
        if bagValueTexts[bagID] then
            bagValueTexts[bagID]:SetText("") -- Clear text if not enabled for that bag
        end
    end
end

-- Right after login/reload GetItemInfo returns nil for items the client has not
-- cached, so freshly opened bags read low until the next BAG_UPDATE. Re-run the
-- value pass as item data streams in, coalescing the burst of events into one
-- refresh every 0.3s.
local refreshFrame = CreateFrame("Frame")
local refreshQueued = false

local function refreshAllBags()
    refreshQueued = false
    for bagID = 0, maxBagID() do
        BagValue.update(bagID)
    end
end

refreshFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
refreshFrame:SetScript("OnEvent", function()
    if refreshQueued then
        return
    end
    refreshQueued = true
    C_Timer.After(0.3, refreshAllBags)
end)
