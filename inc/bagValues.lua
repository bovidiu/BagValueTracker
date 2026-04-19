BagValue={}

local bagValueTexts = {}
local combinedValueText = nil

BagValue.reset = function()
    for _, text in pairs(bagValueTexts) do
        if text then text:SetText("") end
    end
    bagValueTexts = {}
    if combinedValueText then
        combinedValueText:SetText("")
        combinedValueText = nil
    end
end

local function isCombined()
    return C_CVar and C_CVar.GetCVar("combinedBags") == "1"
end

local function updateCombined()
    local totalValue = 0
    for bagID = 0, NUM_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        if numSlots and numSlots > 0 then
            for slotID = 1, numSlots do
                local itemInfo = C_Container.GetContainerItemInfo(bagID, slotID)
                if itemInfo and not itemInfo.hasNoValue then
                    local itemValue = ItemValue.get(itemInfo.hyperlink)
                    totalValue = totalValue + (itemValue * itemInfo.stackCount)
                end
            end
        end
    end

    local bagFrame = _G["ContainerFrameCombinedBags"]
    if not bagFrame or not bagFrame:IsShown() then return end

    if not combinedValueText then
        combinedValueText = bagFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        combinedValueText:SetPoint("TOPRIGHT", bagFrame, "TOPRIGHT", -10, -30)
    end

    if totalValue > 0 then
        combinedValueText:SetText(Currency.format(totalValue))
        combinedValueText:SetTextColor(1, 1, 0)
    else
        combinedValueText:SetText("")
    end
end

BagValue.update = function(bagID)
    if isCombined() then
        updateCombined()
        return
    end

    local totalVendorValue = 0
    local numSlots = C_Container.GetContainerNumSlots(bagID)
    if numSlots and numSlots > 0 then
        for slotID = 1, numSlots do
            local itemInfo = C_Container.GetContainerItemInfo(bagID, slotID)
            if itemInfo and not itemInfo.hasNoValue then
                local itemValue = ItemValue.get(itemInfo.hyperlink)
                totalVendorValue = totalVendorValue + (itemValue * itemInfo.stackCount)
            end
        end
    end

    local bagFrame = _G["ContainerFrame" .. (bagID + 1)]
    if bagFrame and BagValueTrackerConfig.enableBagValue[bagID + 1] then
        if bagValueTexts[bagID] then
            bagValueTexts[bagID]:SetText("")
        else
            bagValueTexts[bagID] = bagFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            bagValueTexts[bagID]:SetPoint("TOPRIGHT", bagFrame, "TOPRIGHT", -10, -30)
        end
        if totalVendorValue > 0 then
            bagValueTexts[bagID]:SetText(Currency.format(totalVendorValue))
            bagValueTexts[bagID]:SetTextColor(1, 1, 0)
        else
            bagValueTexts[bagID]:SetText("")
        end
    else
        if bagValueTexts[bagID] then
            bagValueTexts[bagID]:SetText("")
        end
    end
end
