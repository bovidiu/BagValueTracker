-- ============================================
-- BagValueTracker
-- Slot overlay support for combined + split bags
-- ============================================

-- SavedVariables
if not BagValueTrackerConfig then
    BagValueTrackerConfig = {
        enableBagValue = { false, true, true, true, true, true },
    }
end

-- Frame for events
local frame = CreateFrame("Frame")

-- FontStrings cache
local bagSlotTexts = {}

-- --------------------------------------------
-- Helpers
-- --------------------------------------------

local function IsCombinedBags()
    return GetCVarBool("combinedBags")
end

-- Helper: Format copper into gold/silver/copper string
local function FormatMoney(copper)
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local copper = copper % 100
    return string.format("%dg %ds %dc", gold, silver, copper)
end

-- Returns true if at least one bag frame is visible
local function AreBagsOpen()
    for i = 1, NUM_CONTAINER_FRAMES do
        local frame = _G["ContainerFrame"..i]
        if frame and frame:IsShown() then
            return true, frame
        end
    end
    return false, nil
end


-- Count total free slots across all bags
local function GetTotalFreeSlots()
    local used, total = 0, 0

    for bagID = 0, 4 do
        local slots = C_Container.GetContainerNumSlots(bagID)
        total = total + slots

        for slotID = 1, slots do
            if C_Container.GetContainerItemInfo(bagID, slotID) then
                used = used + 1
            end
        end
    end

    return total - used, total
end

-- Hide all existing overlays
local function HideAllOverlays()
    for _, text in pairs(bagSlotTexts) do
        text:Hide()
    end
end

-- --------------------------------------------
-- Combined bags overlay (single number)
-- --------------------------------------------

local function UpdateCombinedOverlay()
    HideAllOverlays()

    if not ContainerFrameCombinedBags or not ContainerFrameCombinedBags:IsShown() then
        return
    end

    local free = GetTotalFreeSlots()
    local totalValue = 0
    if BagValue and BagValue.getTotal then
        totalValue = BagValue.getTotal() or 0
    end

    -- Use TOPRIGHT anchor, slightly above bag contents
    if not bagSlotTexts.combined then
        bagSlotTexts.combined = ContainerFrameCombinedBags:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        -- Position inside the frame, above contents
        bagSlotTexts.combined:SetPoint("TOPRIGHT", ContainerFrameCombinedBags, "TOPRIGHT", -40, -40)
    end
    print(FormatMoney(totalValue))
    bagSlotTexts.combined:SetText(string.format("Slots: %d   %s", free, FormatMoney(totalValue)))
    bagSlotTexts.combined:SetTextColor(1, 1, 1)
    bagSlotTexts.combined:Show()
end





-- --------------------------------------------
-- Individual bag overlays
-- --------------------------------------------

local function UpdateIndividualOverlays()
    HideAllOverlays()

    for bagID = 0, 4 do
        local bagIcon = _G["CharacterBag" .. (bagID - 1) .. "Slot"]
        if bagIcon then
            local used, total = 0, C_Container.GetContainerNumSlots(bagID)

            for slotID = 1, total do
                if C_Container.GetContainerItemInfo(bagID, slotID) then
                    used = used + 1
                end
            end

            if not bagSlotTexts[bagID] then
                bagSlotTexts[bagID] =
                    bagIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                bagSlotTexts[bagID]:SetPoint("TOP", bagIcon, "TOP", -1, 15)
            end

            bagSlotTexts[bagID]:SetText(total - used)
            bagSlotTexts[bagID]:SetTextColor(1, 1, 1)
            bagSlotTexts[bagID]:Show()
        end
    end
end

-- --------------------------------------------
-- Unified updater
-- --------------------------------------------

local function UpdateBagSlotOverlays()
    print("Combined:", GetCVar("combinedBags"))

    if IsCombinedBags() then
        UpdateCombinedOverlay()
    else
        UpdateIndividualOverlays()
    end
end

-- --------------------------------------------
-- Event handler
-- --------------------------------------------

local function OnEvent(self, event, bagID)
    if event == "BAG_OPEN" or event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
        if BagValue and BagValue.update and bagID ~= nil then
            BagValue.update(bagID)
        end
        UpdateBagSlotOverlays()

    elseif event == "BAG_CLOSED" then
        UpdateBagSlotOverlays()

    elseif event == "PLAYER_LOGIN" then
        UpdateBagSlotOverlays()
    elseif event == "BAG_UPDATE_DELAYED" then
        UpdateBagSlotOverlays()

    end
end


-- --------------------------------------------
-- Event registration
-- --------------------------------------------

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("BAG_OPEN")
frame:RegisterEvent("BAG_CLOSED")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:SetScript("OnEvent", OnEvent)
