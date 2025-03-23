ItemValue = {}

-- Function to get vendor value for an item
ItemValue.get = function(itemLink)
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