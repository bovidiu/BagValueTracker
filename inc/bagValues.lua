BagValue = {}

-- Store bag value text (one FontString per individual bag frame, plus one for
-- the Retail "Combine All Bags" frame).
local bagValueTexts = {}
local combinedText

-- Highest container index that may carry a value display. NUM_BAG_SLOTS covers
-- the backpack (0) plus the four equippable bag slots; on Retail the reagent bag
-- sits one slot past that.
local function maxBagID()
    local maxID = NUM_BAG_SLOTS or 4
    if Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag then
        maxID = math.max(maxID, Enum.BagIndex.ReagentBag)
    end
    return maxID
end
BagValue.maxBagID = maxBagID

-- Is the value display enabled for this bag? Tolerates a config table that is
-- shorter than the current bag count (e.g. an older list that predates the
-- reagent bag) instead of silently treating the missing entry as disabled.
local function isEnabled(bagID)
    local list = BagValueTrackerConfig and BagValueTrackerConfig.enableBagValue
    if type(list) ~= "table" then
        return bagID ~= 0
    end

    local value = list[bagID + 1]
    if value == nil then
        return bagID ~= 0 -- default: on for every bag except the backpack
    end
    return value
end

-- Sum the value of every item in one bag.
-- Returns: total value, incomplete (true if an item could not be valued yet).
local function sumBag(bagID)
    local total = 0
    local incomplete = false

    local numSlots = C_Container.GetContainerNumSlots(bagID)
    if numSlots and numSlots > 0 then
        for slotID = 1, numSlots do
            local itemLink = C_Container.GetContainerItemLink(bagID, slotID)
            if itemLink then
                local itemInfo = C_Container.GetContainerItemInfo(bagID, slotID)
                local itemCount = itemInfo and itemInfo.stackCount or 1

                local itemValue, pending = ItemValue.get(itemLink)
                if pending then
                    incomplete = true
                end
                total = total + (itemValue * itemCount)
            end
        end
    end

    return total, incomplete
end

-- Write a formatted value onto a FontString (blank when there is nothing to show).
local function applyValueText(fontString, total, incomplete)
    if total > 0 then
        local formatted = Currency.format(total)
        if incomplete then
            formatted = formatted .. " ..." -- data still loading; total will rise
        end
        fontString:SetText(formatted)
        fontString:SetTextColor(1, 1, 0) -- bright yellow
    else
        fontString:SetText("")
    end
end

-- The Retail combined-bags frame, when it exists and is shown, replaces the
-- individual ContainerFrame1..N. Drawing on the hidden per-bag frames in that
-- mode makes the value invisible, so it needs its own display.
local function combinedBagsFrame()
    local frame = _G.ContainerFrameCombinedBags
    if frame and frame:IsShown() then
        return frame
    end
    return nil
end

-- Update the single total shown on the combined-bags frame (backpack + equipped
-- bags; the reagent bag keeps its own separate frame and display).
BagValue.updateCombined = function()
    local frame = combinedBagsFrame()
    if not frame then
        if combinedText then
            combinedText:SetText("")
        end
        return
    end

    local total, incomplete = 0, false
    for bagID = 0, (NUM_BAG_SLOTS or 4) do
        if isEnabled(bagID) then
            local bagTotal, bagIncomplete = sumBag(bagID)
            total = total + bagTotal
            incomplete = incomplete or bagIncomplete
        end
    end

    if not combinedText then
        -- Host the text on a dedicated high-level frame so the money frame and
        -- other bottom-of-window pieces cannot draw over it.
        local holder = CreateFrame("Frame", nil, frame)
        holder:SetAllPoints(frame)
        local base = frame.GetFrameLevel and frame:GetFrameLevel() or 1
        local money = frame.MoneyFrame or _G.ContainerFrameCombinedBagsMoneyFrame
        if money and money.GetFrameLevel then
            base = math.max(base, money:GetFrameLevel())
        end
        holder:SetFrameLevel(base + 20)

        combinedText = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        combinedText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 10)
        combinedText:SetJustifyH("LEFT")
    end
    applyValueText(combinedText, total, incomplete)
end

-- Update the value shown on one individual bag frame.
BagValue.update = function(bagID)
    if not bagID then
        return
    end

    -- In combined mode the equipped bags share one frame; let updateCombined
    -- handle those and only keep drawing the reagent bag individually.
    if combinedBagsFrame() and bagID <= (NUM_BAG_SLOTS or 4) then
        if bagValueTexts[bagID] then
            bagValueTexts[bagID]:SetText("")
        end
        BagValue.updateCombined()
        return
    end

    local totalVendorValue, incomplete = sumBag(bagID)

    -- Display vendor value only when the bag is open and enabled for that bag
    local bagFrame = _G["ContainerFrame" .. (bagID + 1)]
    if bagFrame and isEnabled(bagID) then
        if not bagValueTexts[bagID] then
            bagValueTexts[bagID] = bagFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            bagValueTexts[bagID]:SetPoint("TOPRIGHT", bagFrame, "TOPRIGHT", -10, -30)
        end
        applyValueText(bagValueTexts[bagID], totalVendorValue, incomplete)
    else
        if bagValueTexts[bagID] then
            bagValueTexts[bagID]:SetText("") -- not enabled / backpack
        end
    end
end

-- Redraw every value display.
local refreshQueued = false
local function refreshAllBags()
    refreshQueued = false
    BagValue.updateCombined()
    for bagID = 0, maxBagID() do
        BagValue.update(bagID)
    end
end

-- Used by the options panel when a setting changes.
BagValue.refreshAll = refreshAllBags

-- Right after login/reload GetItemInfo returns nil for items the client has not
-- cached, so freshly opened bags read low until the next BAG_UPDATE. Re-run the
-- value pass as item data streams in, coalescing the burst of events into one
-- refresh every 0.3s.
local refreshFrame = CreateFrame("Frame")
refreshFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
refreshFrame:RegisterEvent("BAG_UPDATE")
refreshFrame:RegisterEvent("BAG_OPEN")
refreshFrame:RegisterEvent("BAG_CLOSED")
refreshFrame:RegisterEvent("PLAYER_LOGIN")
refreshFrame:SetScript("OnEvent", function(_, event)
    if event == "GET_ITEM_INFO_RECEIVED" then
        if refreshQueued then
            return
        end
        refreshQueued = true
        C_Timer.After(0.3, refreshAllBags)
    else
        -- Bag opened / contents changed: keep the combined total in sync (the
        -- per-bag frames are already handled by the core event handler).
        BagValue.updateCombined()
    end
end)

-- Catch the combined frame being shown when no bag event fires alongside it.
if _G.ContainerFrameCombinedBags then
    _G.ContainerFrameCombinedBags:HookScript("OnShow", function()
        BagValue.updateCombined()
    end)
end
