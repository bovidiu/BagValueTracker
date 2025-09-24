--- inc/bagCompat.lua
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

BagCompat = {}  -- IMPORTANT: no "local" here, must be global

function BagCompat.GetContainerNumSlots(bagID)
    if isRetail then
        return C_Container.GetContainerNumSlots(bagID)
    else
        return GetContainerNumSlots(bagID)
    end
end

function BagCompat.GetContainerItemInfo(bagID, slot)
    if isRetail then
        return C_Container.GetContainerItemInfo(bagID, slot)
    else
        local texture, count, locked, quality, readable, lootable, link, isFiltered, noValue, itemID =
            GetContainerItemInfo(bagID, slot)
        if texture then
            return {
                iconFileID = texture,
                stackCount = count,
                isLocked = locked,
                quality = quality,
                isReadable = readable,
                hasLoot = lootable,
                hyperlink = link,
                isFiltered = isFiltered,
                hasNoValue = noValue,
                itemID = itemID,
            }
        end
    end
end

function BagCompat.GetContainerItemID(bagID, slot)
    if isRetail then
        return C_Container.GetContainerItemID(bagID, slot)
    else
        return GetContainerItemID(bagID, slot)
    end
end
