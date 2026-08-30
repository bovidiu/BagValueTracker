![BagValueTracker WoW addon](https://github.com/bovidiu/BagValueTracker/blob/main/icon.png)

BagValueTracker is an intuitive addon designed to enhance your World of Warcraft gaming experience by providing a clear overview of the value of items in your bags. With a user-friendly interface, this addon enables players to quickly assess the worth of their inventory without the hassle of external tools.

## Install

- [CurseForge](https://secure.lockn.link/curseforge-bag-value-tracker)
- [Wago](https://secure.lockn.link/wago-bag-value-tracker)

## Current features

- **Bag capacity** - visually see how many free slots each bag has.
- **Cataclysm & Mists** - open all bags by pressing **B**.
- **Per-bag value** - each open bag shows the total sell value of its contents, based on the auction price* (falling back to the vendor price).
- **Tooltip value** - item tooltips show the sell value per item and for the whole stack.
- **Sell junk** - a "Sell Junk" button on the merchant window that vendors all your grey items, with an optional auto-sell.
- **Options panel** - open with `/bvt` (or `/bagvalue`), or from the game's AddOns settings.
- **Lightweight and Efficient** - optimised for minimal impact on game performance.
- Supported: Retail, Cataclysm Classic, Mists of Pandaria Classic.

## How to use

1. Install the addon (and, optionally, [Auctionator](https://www.curseforge.com/wow/addons/auctionator) for auction-based pricing) and log in.
2. Open your bags. Each enabled bag shows its total sell value in the top-right corner.
   - A trailing `...` means the game is still loading item data; the total finishes filling in after a moment.
3. Hover any item to see its **Sell value** on the tooltip. Hovering a stack also shows the value of the whole stack.
4. **Selling junk:** open any merchant and click the **Sell Junk** button (bottom-left of the merchant window). It shows how much your grey items are worth, sells them all in one click, and reports the gold earned in chat. Hover the button first to see exactly what will be sold. Prefer it fully automatic? Turn on *Sell junk automatically at merchants* in the options.
5. Type `/bvt` (or `/bagvalue`), or go to **Game Menu -> Options -> AddOns -> Bag Value Tracker**, to change:
   - **Show item value on tooltips** - turn the tooltip line on or off.
   - **Use auction price when available** - when on, prices come from Auctionator's auction data (vendor price is used as a fallback); when off, only the vendor price is used.
   - **Show "Sell Junk" button at merchants** - show or hide the merchant button.
   - **Sell junk automatically at merchants** - vendor all grey items the moment any merchant window opens.
   - **Show value for:** - a checkbox per bag (Backpack, Bag 1-4, Reagent Bag) to hide the value on bags you don't care about.

   Changes apply immediately and are saved per character.

> **Note:** "junk" means poor-quality (grey) items that have a sell price. The vendor's buyback tab only holds the last few sold items, so anything beyond that cannot be bought back.

## Changelog

### 1.3

- **New:** "Sell Junk" button on the merchant window. It shows the total value of your grey items, sells them all with one click, and reports the gold earned. Hovering the button lists what will be sold.
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

- **Junk value in bags:** see the grey-item total in your bags at any time, not just at a merchant, plus a "keep" list for greys you want to protect.
- **Session & net-worth tracking:** see how much your bag value changed this session and over time.
- **Bank & warband bank valuation.**

## Dependency (Optional)

*If you'd like to see the value of a bag based on auctioned items, you will need to install [Auctionator](https://www.curseforge.com/wow/addons/auctionator).
