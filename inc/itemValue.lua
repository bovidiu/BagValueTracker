ItemValue = {}

-- Function to get Auctionator price
ItemValue.getAuctionatorPrice = function(itemLink)
    if not Auctionator or not Auctionator.API or not Auctionator.API.v1 then
        return nil
    end

    local price = Auctionator.API.v1.GetAuctionPriceByItemLink("BagValueTracker", itemLink)
    return price
end

-- Function to get item value (auction or vendor fallback).
-- Returns: value (number), pending (boolean)
--   pending is true when the item is not in the local cache yet, so the value
--   returned is 0 and the caller's total should be treated as incomplete.
ItemValue.get = function(itemLink)
    if not itemLink then
        return 0, false
    end

    -- Prefer the auction price when Auctionator can supply one.
    local auctionPrice = ItemValue.getAuctionatorPrice(itemLink)
    if auctionPrice then
        return auctionPrice, false
    end

    -- Fall back to the vendor sell price (field 11 of GetItemInfo).
    local vendorPrice = select(11, GetItemInfo(itemLink))
    if vendorPrice == nil then
        -- Item data has not been cached by the client yet. GetItemInfo above has
        -- already kicked off a server query; nudge it along where the API exists
        -- and tell the caller this item could not be valued this pass.
        local itemID = GetItemInfoInstant(itemLink)
        if itemID and C_Item and C_Item.RequestLoadItemDataByID then
            C_Item.RequestLoadItemDataByID(itemID)
        end
        return 0, true
    end

    return vendorPrice, false
end
