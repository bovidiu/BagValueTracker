-- Net-worth tracking: total value of everything in your bags plus gold on hand,
-- a per-session change, and a saved per-character history.

BagValueTracker = BagValueTracker or {}
local Worth = {}
BagValueTracker.Worth = Worth

local MAX_HISTORY = 60
local SNAPSHOT_WINDOW = 6 * 3600 -- replace, rather than append, samples closer than this

-- Net worth (item value + money) captured shortly after login; the baseline for
-- the "this session" figure. Kept in memory only.
local sessionStartWorth

-- Total value of every item across all bags.
function Worth.bagItemValue()
    local total = 0
    local maxBag = (BagValue and BagValue.maxBagID and BagValue.maxBagID()) or (NUM_BAG_SLOTS or 4)
    for bag = 0, maxBag do
        local numSlots = C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, numSlots do
            local link = C_Container.GetContainerItemLink(bag, slot)
            if link then
                local info = C_Container.GetContainerItemInfo(bag, slot)
                local count = info and info.stackCount or 1
                local value = ItemValue.get(link) or 0
                total = total + value * count
            end
        end
    end
    return total
end

-- Returns itemValue, money, netWorth (all in copper).
function Worth.current()
    local itemValue = Worth.bagItemValue()
    local money = GetMoney() or 0
    return itemValue, money, itemValue + money
end

local function coin(value)
    return GetCoinTextureString(math.max(0, math.floor(value + 0.5)))
end

local function signedCoin(delta)
    local rounded = math.floor(math.abs(delta) + 0.5)
    if rounded == 0 then
        return "no change"
    end
    return (delta < 0 and "-" or "+") .. GetCoinTextureString(rounded)
end

local function lastSessionWorth()
    local last = BagValueTrackerCharDB and BagValueTrackerCharDB.lastSession
    if type(last) == "table" then
        return (last.item or 0) + (last.money or 0)
    end
    return nil
end

-- Print the current net worth and how it has changed.
function Worth.report()
    local itemValue, money, net = Worth.current()

    BagValueTracker.print(string.format("net worth %s  (items %s + gold %s)", coin(net), coin(itemValue), coin(money)))

    if sessionStartWorth then
        BagValueTracker.print(string.format("  this session: %s", signedCoin(net - sessionStartWorth)))
    end

    local previousWorth = lastSessionWorth()
    if previousWorth then
        BagValueTracker.print(string.format("  since last session: %s", signedCoin(net - previousWorth)))
    end
end

-- Append (or refresh) a history sample, for the future net-worth graph.
local function appendHistory()
    local db = BagValueTrackerCharDB
    if type(db) ~= "table" then
        return
    end
    db.history = db.history or {}

    local itemValue, money = Worth.current()
    local now = time()
    local entry = { t = now, item = itemValue, money = money }

    local last = db.history[#db.history]
    if last and (now - (last.t or 0)) < SNAPSHOT_WINDOW then
        db.history[#db.history] = entry
    else
        db.history[#db.history + 1] = entry
    end

    while #db.history > MAX_HISTORY do
        table.remove(db.history, 1)
    end
end

-- Record the end-of-session baseline. Written on logout only, so a /reload
-- mid-session doesn't move the reference that "since last session" compares to
-- (beyond the reload itself being a session boundary).
local function recordLogout()
    if not (BagValueTrackerConfig and BagValueTrackerConfig.trackNetWorth) then
        return
    end
    local db = BagValueTrackerCharDB
    if type(db) ~= "table" then
        return
    end

    local itemValue, money = Worth.current()
    db.lastSession = { t = time(), item = itemValue, money = money }
    appendHistory()
end
Worth.recordLogout = recordLogout

-- Wiring -------------------------------------------------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_LOGOUT")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGOUT" then
        recordLogout()
        return
    end

    -- PLAYER_LOGIN: wait a few seconds for the item cache to warm before taking
    -- the session baseline.
    C_Timer.After(4, function()
        local _, _, net = Worth.current()
        sessionStartWorth = net

        if BagValueTrackerConfig and BagValueTrackerConfig.trackNetWorth then
            appendHistory()
        end

        if BagValueTrackerConfig and BagValueTrackerConfig.reportWorthOnLogin then
            BagValueTracker.print(string.format("net worth %s", coin(net)))
            local previousWorth = lastSessionWorth()
            if previousWorth then
                BagValueTracker.print(string.format("  since last session: %s", signedCoin(net - previousWorth)))
            end
        end
    end)
end)
