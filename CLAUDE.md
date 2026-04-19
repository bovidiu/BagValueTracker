# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

BagValueTracker is a World of Warcraft addon that displays the vendor (or auction house) value of items in player bags, with per-bag totals and available slot counts overlaid on bag icons.

## Deployment

There is no build step. The addon is deployed directly to CurseForge (ID: 1133227) and Wago (ID: kGr0en6y). Version bumping is automated via `.github/workflows/bump_version.yml` on push to `main`.

## Multi-Version Structure

The addon targets three WoW versions, each with its own `.toc` and main Lua file:

| File | Version | Interface |
|---|---|---|
| `BagValueTracker.toc` / `BagValueTracker.lua` | Retail/TWW | 110205–120001 |
| `BagValueTracker_Cata.toc` / `BagValueTracker_Cata.lua` | Cataclysm | 40402 |
| `BagValueTracker_Mists.toc` / `BagValueTracker_Mists.lua` | Mists of Pandaria | 50501–50503 |

All three share the modules in `inc/`:
- `currency.lua` — formats gold/silver/copper with texture icons (`Currency` table)
- `itemValue.lua` — resolves item price via Auctionator API or vendor fallback (`ItemValue` table)
- `bagValues.lua` — calculates and renders per-bag totals (`BagValue` table)

## Key Patterns

**Module namespace**: Each module exposes a global table (`BagValue`, `Currency`, `ItemValue`) with methods. There are no OOP classes or metatables.

**Event-driven**: A single WoW frame registers for `BAG_OPEN`, `BAG_CLOSED`, `BAG_UPDATE`, and `PLAYER_LOGIN`. All UI updates flow through `BagValue.update()`.

**Retail vs. Classic differences**: Retail disables value tracking for the primary bag (index 0) by default. Cataclysm and Mists versions add a B-key binding to open all bags, gated behind `BagValueTrackerDB` (a `SavedVariables` persisted across sessions).

**Auctionator integration**: `ItemValue.getPrice()` checks for the Auctionator addon at runtime. If absent, it falls back to vendor sell price.

## When Making Changes

- Changes to shared logic (price calculation, currency formatting) go in `inc/`. Changes to initialization, event handling, or version-specific behavior go in the respective main Lua file.
- After touching any `.lua` file, verify the same change is needed (or intentionally not needed) in the other two version entry points.
- Interface version numbers in `.toc` files are bumped automatically by the CI workflow — do not edit them manually unless correcting a mistake.
