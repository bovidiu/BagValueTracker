-- In-game options panel (Interface Options / Settings) plus the /bvt command.

local PANEL_TITLE = "Bag Value Tracker"

local BAG_LABELS = {
    [1] = "Backpack",
    [6] = "Reagent Bag",
}
local function bagLabel(index)
    return BAG_LABELS[index] or ("Bag " .. (index - 1))
end

local function refreshDisplays()
    if BagValue and BagValue.refreshAll then
        BagValue.refreshAll()
    end
end

-- Build the panel ---------------------------------------------------------------

local panel = CreateFrame("Frame")
panel.name = PANEL_TITLE

local checkboxes = {}

local function addCheckbox(label, tooltip, x, y, get, set)
    local check = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", x, y)
    check:SetSize(26, 26)

    -- Own label rather than relying on a template-specific field name.
    local labelText = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    labelText:SetPoint("LEFT", check, "RIGHT", 2, 1)
    labelText:SetText(label)

    if tooltip then
        check:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        check:SetScript("OnLeave", GameTooltip_Hide)
    end

    check:SetScript("OnClick", function(self)
        set(self:GetChecked() and true or false)
        refreshDisplays()
    end)
    check.bvtRefresh = function()
        check:SetChecked(get() and true or false)
    end
    checkboxes[#checkboxes + 1] = check
    return check
end

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(PANEL_TITLE)

local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetPoint("RIGHT", panel, "RIGHT", -32, 0)
subtitle:SetJustifyH("LEFT")
subtitle:SetText("Show the vendor / auction value of the items in each bag.")

local y = -64

addCheckbox(
    "Show item value on tooltips",
    "Append the sell value (and stack value) to item tooltips.",
    16, y,
    function() return BagValueTrackerConfig.showTooltipValue end,
    function(v) BagValueTrackerConfig.showTooltipValue = v end
)
y = y - 30

addCheckbox(
    "Use auction price when available",
    "Prefer Auctionator's auction price over the vendor sell price.",
    16, y,
    function() return BagValueTrackerConfig.useAuctionPrice end,
    function(v) BagValueTrackerConfig.useAuctionPrice = v end
)
y = y - 40

local bagsHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
bagsHeader:SetPoint("TOPLEFT", 16, y)
bagsHeader:SetText("Show value for:")
y = y - 26

-- Per-bag toggles are added once the config table exists (see onConfigReady).
local function buildBagToggles()
    local list = BagValueTrackerConfig and BagValueTrackerConfig.enableBagValue
    if type(list) ~= "table" then
        return
    end
    for index = 1, #list do
        addCheckbox(
            bagLabel(index),
            nil,
            24, y,
            function() return BagValueTrackerConfig.enableBagValue[index] end,
            function(v) BagValueTrackerConfig.enableBagValue[index] = v end
        )
        y = y - 26
    end
end

local function refreshPanel()
    for _, check in ipairs(checkboxes) do
        check.bvtRefresh()
    end
end

panel:SetScript("OnShow", refreshPanel)

-- Register with the options UI ------------------------------------------------

local openSettings

if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, PANEL_TITLE)
    category.ID = PANEL_TITLE
    Settings.RegisterAddOnCategory(category)
    openSettings = function() Settings.OpenToCategory(category:GetID()) end
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
    openSettings = function()
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel) -- twice: known Blizzard quirk
    end
end

BagValueTracker.openSettings = openSettings

-- Finish building once settings are loaded, then sync the controls.
table.insert(BagValueTracker.onConfigReady, function()
    buildBagToggles()
    refreshPanel()
end)

-- Slash command --------------------------------------------------------------

SLASH_BAGVALUETRACKER1 = "/bvt"
SLASH_BAGVALUETRACKER2 = "/bagvalue"
SlashCmdList.BAGVALUETRACKER = function()
    if BagValueTracker.openSettings then
        BagValueTracker.openSettings()
    else
        print("BagValueTracker: options panel is unavailable on this client.")
    end
end
