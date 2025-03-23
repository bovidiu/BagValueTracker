
-- Create the configuration panel
local configFrame = CreateFrame("Frame", "BagValueTrackerConfigFrame", UIParent)
configFrame.name = "Bag Value Tracker"

local category = Settings.RegisterCanvasLayoutCategory(configFrame, "Bag Value Tracker")
Settings.RegisterAddOnCategory(category)

local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Bag Value Tracker")

local description = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
description:SetText("Select which bags should display their value.")

-- Create checkboxes for each bag
local checkboxes = {}
local function CreateCheckbox(index)
    local check = CreateFrame("CheckButton", nil, configFrame, "UICheckButtonTemplate")
    check:SetSize(24, 24)
    check:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, - (index * 30))
    check.text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    check.text:SetPoint("LEFT", check, "RIGHT", 4, 0)
    check.text:SetText("Bag " .. index)

    check:SetScript("OnClick", function(self)
        BagValueTrackerConfig.enableBagValue[index + 1] = self:GetChecked() and true or false
        BagValue.update(index + 1)
        -- Update when toggling checkboxes
    end)

    checkboxes[index] = check
end

for i = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
    CreateCheckbox(i)
end

-- Load saved settings when opening the UI
configFrame:SetScript("OnShow", function()
    for i, check in pairs(checkboxes) do
        check:SetChecked(BagValueTrackerConfig.enableBagValue[i + 1])
    end
end)
