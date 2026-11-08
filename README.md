![BagValueTracker WoW addon](https://github.com/bovidiu/BagValueTracker/blob/main/icon.png)

# BagValueTracker

**See your gold before you sell it.** BagValueTracker is a World of Warcraft addon that shows the vendor and auction-house value of every item in your bags — right on the bag window, in your tooltips, and in a one-click junk seller — so you always know what your inventory is worth without opening an external site or app.

Works on **Retail** (including the Forever client), **Cataclysm Classic**, and **Mists of Pandaria Classic**.

## Why BagValueTracker

- 💰 **Instant bag value** - every open bag shows the total sell value of its contents at a glance.
- 🏷️ **Tooltip prices** - hover any item to see its sell value and full-stack value.
- 🗑️ **One-click junk selling** - vendor every grey item at once, or turn on auto-sell and never think about it again.
- 📈 **Net worth tracking** - `/bvt worth` tracks your bags + gold over time, per character.
- 🎒 **Bag capacity at a glance** - see free slots without opening your bags.
- ⚡ **Lightweight** - minimal memory and CPU footprint, no unnecessary polling.

## Install

- [CurseForge](https://secure.lockn.link/curseforge-bag-value-tracker)
- [Wago](https://secure.lockn.link/wago-bag-value-tracker)

## Current features

- **Bag capacity** - visually see how many free slots each bag has.
- **Cataclysm & Mists** - open all bags by pressing **B**.
- **Per-bag value** - each open bag shows the total sell value of its contents, based on the auction price* (falling back to the vendor price).
- **Tooltip value** - item tooltips show the sell value per item and for the whole stack.
- **Sell junk** - a "Sell Junk" button on the merchant window that vendors all your grey items, with an optional auto-sell.
- **Net worth** - `/bvt worth` shows your total bag value plus gold, the change this session, and the change since your last play session. History is saved per character.
- **Options panel** - open with `/bvt` (or `/bagvalue`), or from the game's AddOns settings.
- **Lightweight and Efficient** - optimised for minimal impact on game performance.
- Supported: Retail (including the Forever client), Cataclysm Classic, Mists of Pandaria Classic.

## How to use

1. Install the addon (and, optionally, [Auctionator](https://www.curseforge.com/wow/addons/auctionator) for auction-based pricing) and log in.
2. Open your bags. Each enabled bag shows its total sell value in the top-right corner.
   - With Retail's **Combine All Bags** turned on, a single combined total is shown at the bottom-left of the merged bag window (the Reagent Bag keeps its own).
   - A trailing `...` means the game is still loading item data; the total finishes filling in after a moment.
3. Hover any item to see its **Sell value** on the tooltip. Hovering a stack also shows the value of the whole stack.
4. **Selling junk:** open any merchant and click the **Sell Junk** button (attached to the right edge of the merchant window). It shows how much your grey items are worth on its second line, sells them all in one click, and reports the gold earned in chat. Hovering the button lists exactly what will be sold; on Cataclysm and Mists those bag slots are also **tinted orange** while the merchant is open. Prefer it fully automatic? Turn on *Sell junk automatically at merchants* in the options.
5. **Net worth:** type `/bvt worth` at any time to print, in chat:
   - your net worth now (bag item value + gold), broken down into items and gold,
   - how much it has changed **this session**,
   - how much it has changed **since your last play session** (the baseline is saved at logout).

   Turn on *Report net worth at login* to have this shown automatically each time you log in.

   Note that net worth counts your **bags plus gold**, so selling items to a vendor barely moves it — the item value you lose is replaced by the gold you gain. It measures wealth, not income.
6. Type `/bvt` (or `/bagvalue`), or go to **Game Menu -> Options -> AddOns -> Bag Value Tracker**, to change:
   - **Show item value on tooltips** - turn the tooltip line on or off.
   - **Use auction price when available** - when on, prices come from Auctionator's auction data (vendor price is used as a fallback); when off, only the vendor price is used.
   - **Show "Sell Junk" button at merchants** - show or hide the merchant button.
   - **Sell junk automatically at merchants** - vendor all grey items the moment any merchant window opens.
   - **Highlight junk in bags at a merchant** - tint the bag slots that will be sold (Cataclysm and Mists only).
   - **Track net worth history** - keep (or stop keeping) the per-character value history that `/bvt worth` reports from.
   - **Report net worth at login** - print net worth and the change since last session at login.
   - **Show value for:** - a checkbox per bag (Backpack, Bag 1-4, Reagent Bag) to hide the value on bags you don't care about.

   Changes apply immediately and are saved per character.

> **Notes:**
> - "Junk" means poor-quality (grey) items that have a sell price. The vendor's buyback tab only holds the last few sold items, so anything beyond that cannot be bought back.
> - Net worth currently counts your bags and gold only, not the bank. The value is taken a few seconds after login so item data has time to load.

## Changelog

### 1.5

- **New:** added support for the Forever client (Interface 16001), which shares Retail's 12.1.5 API.

### 1.4

- **New:** net-worth tracking. `/bvt worth` prints your bag value + gold, the change this session, and the change since your last session.
- **New:** a per-character value history, plus a logout baseline used for the "since last session" figure. Can be turned off with *Track net worth history*.
- **New:** optional *Report net worth at login* setting.
- **Fixed (Retail):** with **Combine All Bags** enabled the per-bag values were drawn on hidden frames and never appeared. A single combined total is now shown at the bottom-left of the merged bag window.

### 1.3

- **New:** "Sell Junk" button on the merchant window. It shows the total value of your grey items, sells them all with one click, and reports the gold earned. Hovering the button lists what will be sold; on Cataclysm and Mists those bag slots are also tinted orange while the merchant is open (toggle: *Highlight junk in bags at a merchant*).
- **New:** optional *Sell junk automatically at merchants* setting that vendors grey items whenever a merchant window opens.

### 1.2

- **New:** in-game options panel, opened with `/bvt` / `/bagvalue` or from the AddOns settings list.
- **New:** item tooltips show the sell value per item, plus the whole-stack value when hovering a stack.
- **New:** settings are now saved between sessions (per character): tooltip toggle, auction-vs-vendor pricing, and per-bag show/hide.
- **Changed:** on Cataclysm and Mists, the **Backpack** value is now hidden by default (matching Retail). Re-enable it in the options panel if you want it.
- Bag values now cover the Retail **Reagent Bag**.

### 1.1

- **Fixed:** right after logging in, bag totals could read low because item data wasn't cached yet. Totals now refresh automatically as the data loads, and show a `...` marker while incomplete.
- **Fixed:** newly added bag slots (such as the Reagent Bag) are no longer silently skipped when the saved bag list is shorter than the current number of bags.

## Upcoming features

- **Net-worth graph:** a visual history of your value over time in the options panel.
- **Bank & warband bank valuation:** include bank contents in the per-bag display and in net worth.
- **Junk value in bags:** see the grey-item total in your bags at any time, plus a "keep" list for greys you want to protect.

## Dependency (Optional)

*If you'd like to see the value of a bag based on auctioned items, you will need to install [Auctionator](https://www.curseforge.com/wow/addons/auctionator).
