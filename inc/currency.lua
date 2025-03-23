Currency = {}
-- Function to format total value into gold, silver, and copper
Currency.format = function(value)
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