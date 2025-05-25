ItemValue = {}

-- Function to get Auctionator price
ItemValue.getAuctionatorPrice = function(itemLink)
    if not Auctionator or not Auctionator.API.v1 then
        return nil
    end

    local price = Auctionator.API.v1.GetAuctionPriceByItemLink("BagValueTracker", itemLink)
    return price
end

-- Function to get item value (auction or vendor fallback)
ItemValue.get = function(itemLink)
    local vendorValue = 0 -- default

    if itemLink then
        local itemID = GetItemInfoInstant(itemLink)
        local auctionPrice = ItemValue.getAuctionatorPrice(itemLink)

        -- Get vendor price using GetItemInfo
        local itemPrice = select(11, GetItemInfo(itemLink)) or 0

        if auctionPrice then
            vendorValue = auctionPrice
        else
            vendorValue = itemPrice
        end
    end

    return vendorValue
end
