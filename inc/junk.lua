-- Junk selling: a "Sell Junk" button on the merchant window that vendors every
-- poor-quality (grey) item in your bags, with an optional auto-sell.

BagValueTracker = BagValueTracker or {}
local Junk = {}
BagValueTracker.Junk = Junk

local POOR_QUALITY = (Enum and Enum.ItemQuality and Enum.ItemQuality.Poor) or 0

-- Set between MERCHANT_SHOW and MERCHANT_CLOSED. Selling is only allowed while a
-- merchant is open; relying on this rather than MerchantFrame:IsShown() avoids a
-- race with Blizzard's own handler showing the frame.
local merchantOpen = false

-- Scan the bags for sellable grey items.
-- Returns: array of { bag, slot, link, count, value }, and the summed value.
function Junk.scan()
    local items = {}
    local total = 0

    local maxBag = (BagValue and BagValue.maxBagID and BagValue.maxBagID()) or (NUM_BAG_SLOTS or 4)
    for bag = 0, maxBag do
        local numSlots = C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, numSlots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.quality == POOR_QUALITY and not info.hasNoValue and not info.isLocked then
                local link = C_Container.GetContainerItemLink(bag, slot)
                local unitPrice = link and select(11, GetItemInfo(link)) or 0
                if unitPrice > 0 then
                    local count = info.stackCount or 1
                    local value = unitPrice * count
                    items[#items + 1] = { bag = bag, slot = slot, link = link, count = count, value = value }
                    total = total + value
                end
            end
        end
    end

    return items, total
end

-- Sell every grey item found by Junk.scan(). Only acts while a merchant is open.
-- Returns the number of item stacks sold and the gold earned.
function Junk.sell()
    if not merchantOpen then
        return 0, 0
    end

    local items, total = Junk.scan()
    for _, entry in ipairs(items) do
        C_Container.UseContainerItem(entry.bag, entry.slot)
    end

    return #items, total
end

local function report(verb, count, total)
    if count > 0 then
        BagValueTracker.print(string.format(
            "%s %d junk item%s for %s.", verb, count, count == 1 and "" or "s", GetCoinTextureString(total)
        ))
    end
end

-- Merchant button ------------------------------------------------------------

local button = CreateFrame("Button", "BagValueTrackerSellJunkButton", MerchantFrame, "UIPanelButtonTemplate")
button:SetSize(112, 22)
button:SetPoint("BOTTOMLEFT", MerchantFrame, "BOTTOMLEFT", 18, 33)

local function updateButton()
    if not BagValueTrackerConfig or not BagValueTrackerConfig.sellJunkButton then
        button:Hide()
        return
    end
    button:Show()

    local items, total = Junk.scan()
    button.junkItems = items
    button.junkTotal = total

    if #items == 0 then
        button:SetText("No Junk")
        button:Disable()
    else
        button:SetText("Sell Junk  " .. GetCoinTextureString(total))
        button:Enable()
    end
end
Junk.updateButton = updateButton

button:SetScript("OnClick", function()
    local count, total = Junk.sell()
    report("sold", count, total)
    updateButton()
end)

button:SetScript("OnEnter", function(self)
    local items = self.junkItems
    if not items or #items == 0 then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Will sell:")
    for i = 1, math.min(#items, 12) do
        local entry = items[i]
        local name = entry.link:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        name = name:match("%[(.-)%]") or name
        local qty = entry.count > 1 and (" x" .. entry.count) or ""
        GameTooltip:AddDoubleLine(name .. qty, GetCoinTextureString(entry.value), 1, 1, 1, 1, 1, 1)
    end
    if #items > 12 then
        GameTooltip:AddLine(string.format("...and %d more", #items - 12))
    end
    GameTooltip:Show()
end)
button:SetScript("OnLeave", GameTooltip_Hide)

-- Events -------------------------------------------------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("MERCHANT_SHOW")
events:RegisterEvent("MERCHANT_CLOSED")
events:RegisterEvent("BAG_UPDATE")
events:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_CLOSED" then
        merchantOpen = false
        return
    end

    if event == "MERCHANT_SHOW" then
        merchantOpen = true
        if BagValueTrackerConfig and BagValueTrackerConfig.autoSellJunk then
            report("auto-sold", Junk.sell())
        end
    end

    if merchantOpen then
        updateButton()
    end
end)
