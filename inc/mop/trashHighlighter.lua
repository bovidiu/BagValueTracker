--[[ 
    BagValueTracker: MoP Vendor Trash Highlighter
    Highlights poor-quality, vendorable items in bags with:
    - Red border
    - Small coin icon overlay
    Works only on MoP, fails gracefully on other clients
--]]

-- Safe wrapper for MoP-only
local GetNumSlots, GetItemLink
if GetContainerNumSlots and GetContainerItemLink then
    GetNumSlots = GetContainerNumSlots
    GetItemLink = GetContainerItemLink
else
    print("BagValueTracker trashHighlighter: not running on MoP, disabling.")
    return
end

-- Check if item is vendor trash
local function IsVendorTrash(itemLink)
    if not itemLink then return false end
    local name, _, quality, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemLink)
    if not name then return false end -- item info not yet cached
    return (quality == 0 and sellPrice and sellPrice > 0)
end

-- Create coin overlay
local function GetOrCreateCoinIcon(button)
    if not button.CoinIcon then
        local icon = button:CreateTexture(nil, "OVERLAY")
        icon:SetSize(14, 14)
        icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
        icon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")
        icon:Hide()
        button.CoinIcon = icon
    end
    return button.CoinIcon
end

-- Highlight a single button
local function HighlightButton(button, itemLink)
    local coinIcon = GetOrCreateCoinIcon(button)
    if IsVendorTrash(itemLink) then
        if button.IconBorder then
            button.IconBorder:SetVertexColor(1, 0, 0)
            button.IconBorder:Show()
        else
            button:SetBackdropBorderColor(1, 0, 0)
        end
        coinIcon:Show()
    else
        if button.IconBorder then
            button.IconBorder:SetVertexColor(1, 1, 1)
        else
            button:SetBackdropBorderColor(1, 1, 1)
        end
        coinIcon:Hide()
    end
end

-- Highlight all slots in a bag
local function HighlightBag(bag)
    local numSlots = GetNumSlots(bag)
    local frame = _G["ContainerFrame"..(bag+1)]
    if not frame then return end -- bag frame not shown yet

    for slot = 1, numSlots do
        local button = _G["ContainerFrame"..(bag+1).."Item"..slot]
        if button then
            local itemLink = GetItemLink(bag, slot)
            if itemLink then
                if not select(1, GetItemInfo(itemLink)) then
                    -- item info not cached, retry shortly
                    C_Timer.After(0.5, function() HighlightBag(bag) end)
                else
                    HighlightButton(button, itemLink)
                end
            else
                GetOrCreateCoinIcon(button):Hide()
            end
        end
    end
end

-- Highlight all bags
local function HighlightAllBags()
    for bag = 0, NUM_BAG_SLOTS do
        HighlightBag(bag)
    end
end

-- Event frame
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("BAG_UPDATE")
f:RegisterEvent("BAG_UPDATE_DELAYED")

f:SetScript("OnEvent", function()
    C_Timer.After(0.5, HighlightAllBags) -- allow caching
end)
