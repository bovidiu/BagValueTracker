BagValue={}

-- Store bag value text
local bagValueTexts = {}

-- Function to update and display the vendor value when the bag is opened
BagValue.update = function(bagID)
    local totalVendorValue = 0

    local numSlots = C_Container.GetContainerNumSlots(bagID)
    if numSlots and numSlots > 0 then
        for slotID = 1, numSlots do
            local itemLink = C_Container.GetContainerItemLink(bagID, slotID)
            if itemLink then
                local itemInfo = C_Container.GetContainerItemInfo(bagID, slotID)
                local itemCount = itemInfo and itemInfo.stackCount or 1 -- Safely get the count of the item

                -- Get the vendor value and multiply it by the count
                local itemValue = ItemValue.get(itemLink)
                totalVendorValue = totalVendorValue + (itemValue * itemCount) -- Add the item's total value (value * count)
            end
        end
    end

    -- Display vendor value only when the bag is open and enabled for that bag
    local bagFrame = _G["ContainerFrame" .. (bagID + 1)]
    if bagFrame and BagValueTrackerConfig.enableBagValue[bagID + 1] then
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
