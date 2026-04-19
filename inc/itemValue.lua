ItemValue = {}

local _GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo

ItemValue.getAuctionatorPrice = function(itemLink)
    if not Auctionator or not Auctionator.API.v1 then
        return nil
    end

    local price = Auctionator.API.v1.GetAuctionPriceByItemLink("BagValueTracker", itemLink)
    return price
end

ItemValue.get = function(itemLink)
    if not itemLink then return 0 end

    local auctionPrice = ItemValue.getAuctionatorPrice(itemLink)
    if auctionPrice then return auctionPrice end

    return select(11, _GetItemInfo(itemLink)) or 0
end
