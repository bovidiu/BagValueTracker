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
    if BagValueTracker.Junk and BagValueTracker.Junk.updateButton then
        BagValueTracker.Junk.updateButton()
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

-- Row spacing kept tight so the whole panel fits the (shorter) Classic settings
-- canvas without being clipped.
local ROW = 26      -- between checkboxes in a group
local GROUP = 34    -- between the last checkbox of a group and the next header
local HEADER = 22   -- between a header and its first checkbox

local function header(text, atY)
    local fs = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("TOPLEFT", 16, atY)
    fs:SetText(text)
end

local y = -60

addCheckbox(
    "Show item value on tooltips",
    "Append the sell value (and stack value) to item tooltips.",
    16, y,
    function() return BagValueTrackerConfig.showTooltipValue end,
    function(v) BagValueTrackerConfig.showTooltipValue = v end
)
y = y - ROW

addCheckbox(
    "Use auction price when available",
    "Prefer Auctionator's auction price over the vendor sell price.",
    16, y,
    function() return BagValueTrackerConfig.useAuctionPrice end,
    function(v) BagValueTrackerConfig.useAuctionPrice = v end
)
y = y - GROUP

header("Junk selling", y)
y = y - HEADER

addCheckbox(
    "Show \"Sell Junk\" button at merchants",
    "Adds a button to the merchant window that vendors every grey item in your bags.",
    16, y,
    function() return BagValueTrackerConfig.sellJunkButton end,
    function(v) BagValueTrackerConfig.sellJunkButton = v end
)
y = y - ROW

addCheckbox(
    "Sell junk automatically at merchants",
    "Vendor all grey items as soon as you open any merchant window.",
    16, y,
    function() return BagValueTrackerConfig.autoSellJunk end,
    function(v) BagValueTrackerConfig.autoSellJunk = v end
)
y = y - ROW

-- Bag-slot tinting only runs on the Classic clients, so only offer the toggle there.
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
    addCheckbox(
        "Highlight junk in bags at a merchant",
        "Tint the bag slots the Sell Junk button will vendor.",
        16, y,
        function() return BagValueTrackerConfig.highlightJunkInBags end,
        function(v) BagValueTrackerConfig.highlightJunkInBags = v end
    )
    y = y - ROW
end
y = y - (GROUP - ROW)

header("Net worth", y)
y = y - HEADER

addCheckbox(
    "Track net worth history",
    "Keep a per-character record of your bag value and gold over time. Use /bvt worth to see it.",
    16, y,
    function() return BagValueTrackerConfig.trackNetWorth end,
    function(v) BagValueTrackerConfig.trackNetWorth = v end
)
y = y - ROW

addCheckbox(
    "Report net worth at login",
    "Print your net worth and the change since your last session when you log in.",
    16, y,
    function() return BagValueTrackerConfig.reportWorthOnLogin end,
    function(v) BagValueTrackerConfig.reportWorthOnLogin = v end
)
y = y - GROUP

header("Show value for:", y)
y = y - HEADER

-- Per-bag toggles are added once the config table exists (see onConfigReady).
-- Laid out in two columns to save vertical space.
local function buildBagToggles()
    local list = BagValueTrackerConfig and BagValueTrackerConfig.enableBagValue
    if type(list) ~= "table" then
        return
    end
    local rowY = y
    for index = 1, #list do
        local leftColumn = (index % 2 == 1)
        addCheckbox(
            bagLabel(index),
            nil,
            leftColumn and 24 or 210,
            rowY,
            function() return BagValueTrackerConfig.enableBagValue[index] end,
            function(v) BagValueTrackerConfig.enableBagValue[index] = v end
        )
        if not leftColumn then
            rowY = rowY - ROW
        end
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
SlashCmdList.BAGVALUETRACKER = function(msg)
    local arg = (msg or ""):lower():match("^%s*(%S*)")

    if arg == "worth" or arg == "networth" then
        if BagValueTracker.Worth then
            BagValueTracker.Worth.report()
        end
        return
    end

    if BagValueTracker.openSettings then
        BagValueTracker.openSettings()
    else
        BagValueTracker.print("options panel is unavailable on this client. Try /bvt worth.")
    end
end
