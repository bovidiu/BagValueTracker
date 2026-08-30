-- Adds a "Sell value" line to item tooltips, showing the per-item value and, for
-- a stack, the value of the whole stack. Controlled by the showTooltipValue
-- setting.

local LABEL = "Sell value"
local VALUE_R, VALUE_G, VALUE_B = 1, 1, 1

-- Stack size of the item whose tooltip is currently being built, captured from
-- the bag-slot call because the tooltip data itself does not carry a count.
local pendingCount

if C_Container and C_Container.GetContainerItemInfo then
    hooksecurefunc(GameTooltip, "SetBagItem", function(_, bag, slot)
        local info = C_Container.GetContainerItemInfo(bag, slot)
        pendingCount = info and info.stackCount or 1
    end)
end

local function appendValueLine(tooltip, itemLink)
    if not itemLink then
        return
    end
    if not BagValueTrackerConfig or not BagValueTrackerConfig.showTooltipValue then
        return
    end

    local unitValue = ItemValue.get(itemLink)
    if not unitValue or unitValue <= 0 then
        return
    end

    tooltip:AddDoubleLine(LABEL, Currency.format(unitValue), nil, nil, nil, VALUE_R, VALUE_G, VALUE_B)

    local count = pendingCount
    if count and count > 1 then
        tooltip:AddDoubleLine(
            string.format("%s (x%d)", LABEL, count),
            Currency.format(unitValue * count),
            nil, nil, nil, VALUE_R, VALUE_G, VALUE_B
        )
    end
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip)
        if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then
            return
        end
        local _, itemLink = tooltip:GetItem()
        appendValueLine(tooltip, itemLink)
        pendingCount = nil
    end)
else
    -- Older tooltip API (pre-10.0 style clients).
    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        local _, itemLink = self:GetItem()
        appendValueLine(self, itemLink)
        pendingCount = nil
    end)
end
