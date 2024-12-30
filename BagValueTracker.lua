-- Load the configuration file
if not BagValueTrackerConfig then
    BagValueTrackerConfig = {
        enableBagValue = { true, true, true, true, true, true }, -- Default to enabling bag value display (disable for the first bag)
    }
end

-- Create a frame to handle events
local frame = CreateFrame("Frame")

-- Table to hold text strings for bag value and slot overlays
local bagValueTexts = {}
local bagSlotTexts = {}

-- Function to get vendor value for an item
local function GetItemValue(itemLink)
    local vendorValue = 0 -- Initialize vendor value

    if itemLink then
        -- Get item ID from the item link
        local itemID = GetItemInfoInstant(itemLink)

        -- Calculate vendor value (if available)
        local itemPrice = select(11, GetItemInfo(itemID)) -- This gets the vendor sell price
        if itemPrice then
            vendorValue = itemPrice
        end
    end

    return vendorValue
end

-- Function to format total value into gold, silver, and copper
local function FormatCurrency(value)
    local gold = floor(value / 10000)
    local silver = floor((value % 10000) / 100)
    local copper = value % 100

    -- Construct formatted string with icons
    local formattedValue = ""
    if gold > 0 then
        formattedValue = string.format("%d |TInterface\\MoneyFrame\\UI-GoldIcon:0|t ", gold)
    end
    if silver > 0 then
        formattedValue = formattedValue .. string.format("%d |TInterface\\MoneyFrame\\UI-SilverIcon:0|t ", silver)
    end
    if copper > 0 then
        formattedValue = formattedValue .. string.format("%d |TInterface\\MoneyFrame\\UI-CopperIcon:0|t", copper)
    end

    return formattedValue
end

-- Function to update and display the vendor value when the bag is opened
local function UpdateBagValues(bagID)
    local totalVendorValue = 0

    local numSlots = C_Container.GetContainerNumSlots(bagID)
    if numSlots and numSlots > 0 then
        for slotID = 1, numSlots do
            local itemLink = C_Container.GetContainerItemLink(bagID, slotID)
            if itemLink then
                local itemInfo = C_Container.GetContainerItemInfo(bagID, slotID)
                local itemCount = itemInfo and itemInfo.stackCount or 1 -- Safely get the count of the item

                -- Get the vendor value and multiply it by the count
                local itemValue = GetItemValue(itemLink)
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
            local formattedValue = FormatCurrency(totalVendorValue)
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

-- Function to update the slots overlay for closed bags
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
                bagSlotTexts[bagID]:SetPoint("TOP", bagIcon, "TOP", 0, 15) -- Adjust vertical offset for spacing
            end
            bagSlotTexts[bagID]:SetText(string.format("%d/%d", usedSlots, totalSlots))
            bagSlotTexts[bagID]:SetTextColor(1, 1, 1)
        end
    end
end

-- Event handler function
local function OnEvent(self, event, bagID)
    if event == "BAG_OPEN" then
        UpdateBagValues(bagID)
    elseif event == "BAG_CLOSED" then
        UpdateBagSlotOverlays()
    elseif event == "BAG_UPDATE" then
        UpdateBagValues(bagID)
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

-- Addon initialization message
print("BagValueTracker addon loaded!")
