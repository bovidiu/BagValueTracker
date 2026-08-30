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

-- Bag-slot highlight -------------------------------------------------------
-- While a merchant is open, tint every bag slot that holds an item the Sell
-- Junk button will vendor. Classic clients only - Retail's bag frames recycle
-- item buttons aggressively and lack the update hook needed to keep the tints
-- in sync.
local ENABLE_SLOT_MARKS = WOW_PROJECT_ID ~= nil
    and WOW_PROJECT_MAINLINE ~= nil
    and WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

local function slotMark(itemButton)
    if not itemButton.bvtJunkMark then
        local tex = itemButton:CreateTexture(nil, "OVERLAY")
        tex:SetColorTexture(1, 0.55, 0.1, 0.25)
        tex:SetAllPoints(itemButton)
        itemButton.bvtJunkMark = tex
    end
    return itemButton.bvtJunkMark
end

local function forEachItemButton(fn)
    -- Individual bag frames.
    for frameIndex = 1, 13 do
        local frame = _G["ContainerFrame" .. frameIndex]
        if frame then
            for slotIndex = 1, 36 do
                local itemButton = _G["ContainerFrame" .. frameIndex .. "Item" .. slotIndex]
                if itemButton then
                    fn(itemButton)
                end
            end
        end
    end
    -- Retail combined-bags frame.
    local combined = _G.ContainerFrameCombinedBags
    if combined then
        local slotIndex = 1
        while true do
            local itemButton = _G["ContainerFrameCombinedBagsItem" .. slotIndex]
            if not itemButton then
                break
            end
            fn(itemButton)
            slotIndex = slotIndex + 1
        end
    end
end

function Junk.markBags(show)
    if not ENABLE_SLOT_MARKS then
        return
    end

    if show and not (BagValueTrackerConfig and BagValueTrackerConfig.highlightJunkInBags) then
        show = false -- setting off: fall through and clear any existing tints
    end

    local junkSet
    if show then
        junkSet = {}
        local items = Junk.scan()
        for _, entry in ipairs(items) do
            junkSet[entry.bag .. ":" .. entry.slot] = true
        end
    end

    forEachItemButton(function(itemButton)
        local isJunk = false
        if junkSet and itemButton:IsShown() then
            local parent = itemButton:GetParent()
            local bag = (itemButton.GetBagID and itemButton:GetBagID())
                or (parent and parent.GetID and parent:GetID())
            local slot = itemButton.GetID and itemButton:GetID()
            if bag and slot and junkSet[bag .. ":" .. slot] then
                isJunk = true
            end
        end

        if isJunk then
            slotMark(itemButton):Show()
        elseif itemButton.bvtJunkMark then
            itemButton.bvtJunkMark:Hide()
        end
    end)
end

-- Merchant button ------------------------------------------------------------

local button = CreateFrame("Button", "BagValueTrackerSellJunkButton", MerchantFrame, "UIPanelButtonTemplate")
button:SetHeight(44)
-- Attach outside the right edge of the merchant window, near the top - clear of
-- the repair buttons, the money frame and the Merchant/Buyback tabs.
button:SetPoint("TOPLEFT", MerchantFrame, "TOPRIGHT", 2, -24)

-- Two-line label ("Sell Junk" over the value); the template's own single-line
-- font string is not used.
local templateText = button:GetFontString()
if templateText then
    templateText:SetText("")
    templateText:Hide()
end

local titleLine = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleLine:SetPoint("TOP", button, "TOP", 0, -10)
titleLine:SetText("Sell Junk")

local valueLine = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
valueLine:SetPoint("TOP", titleLine, "BOTTOM", 0, -2)

local MIN_WIDTH = 106
local SIDE_PADDING = 36 -- border art + 5px breathing room each side

local function fitButtonWidth()
    local widest = math.max(titleLine:GetStringWidth(), valueLine:GetStringWidth())
    button:SetWidth(math.max(MIN_WIDTH, math.ceil(widest) + SIDE_PADDING))
end

local function updateButton()
    if not BagValueTrackerConfig or not BagValueTrackerConfig.sellJunkButton then
        button:Hide()
        return
    end
    button:Show()

    local items, total = Junk.scan()
    button.junkItems = items
    button.junkTotal = total

    local hasJunk = #items > 0
    valueLine:SetText(hasJunk and GetCoinTextureString(total) or "nothing to sell")
    if hasJunk then
        button:Enable()
        titleLine:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        valueLine:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
    else
        button:Disable()
        titleLine:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
        valueLine:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
    end

    fitButtonWidth()
    Junk.markBags(merchantOpen)
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
events:RegisterEvent("BAG_OPEN")
events:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_CLOSED" then
        merchantOpen = false
        Junk.markBags(false) -- clear the bag-slot tints
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
        -- Re-mark shortly after, once any bag frames opening alongside the
        -- merchant have finished building their item buttons.
        if ENABLE_SLOT_MARKS then
            C_Timer.After(0.1, function()
                if merchantOpen then
                    Junk.markBags(true)
                end
            end)
        end
    end
end)

-- Re-apply the tints when the bag UI redraws (sorting, paging, etc.).
if ENABLE_SLOT_MARKS and type(_G.ContainerFrame_Update) == "function" then
    hooksecurefunc("ContainerFrame_Update", function()
        if merchantOpen then
            Junk.markBags(true)
        end
    end)
end
