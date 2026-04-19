# TODO

## Bugs

- ~~**[Retail] Combined bags mode not supported**~~ ✓ fixed — `updateCombined()` in `bagValues.lua` targets `ContainerFrameCombinedBags`; `BagValue.update` routes there when `combinedBags` CVar is "1"
- ~~**[Retail] After disabling combined bags, bag value stops showing**~~ ✓ fixed — `USE_COMBINED_BAGS_CHANGED` event now calls `BagValue.reset()` to clear stale FontString cache

- ~~**`itemValue.lua:18`** — dead code~~ ✓ removed
- ~~**Retail `.toc` missing `SavedVariables`**~~ ✓ fixed — added `BagValueTrackerConfig` to all three `.toc` files
- ~~**`GetItemInfo` / `GetItemInfoInstant` deprecated**~~ ✓ fixed — `itemValue.lua` now uses `(C_Item and C_Item.GetItemInfo) or GetItemInfo` compat shim; works on Cata/MoP and Retail
- ~~**`hasNoValue` field ignored**~~ ✓ fixed — `bagValues.lua` now guards with `not itemInfo.hasNoValue`
- ~~**Redundant `GetContainerItemLink` call**~~ ✓ fixed — `bagValues.lua` now uses `itemInfo.hyperlink` directly

## Ideas / Improvements

- Add a `/bvt` slash command to toggle per-bag value display on/off at runtime without editing config
- Show total value across all bags somewhere (minimap button tooltip, or chat print on demand)
- Auctionator fallback is silent — consider showing a visual indicator when AH price vs vendor price is being used
- Use `ItemMixin:ContinueOnItemLoad()` for async item data loading to handle uncached items properly instead of silently returning 0

## Notes

- Slot overlay offset differs between versions: Retail uses `(-1, 15)`, Cata/MoP use `(1, -17)` — intentional for different UI layouts, keep in sync if bag frame changes
- Cata and MoP entry points are currently identical — consider a single shared file if they stay in sync
- `SetBinding` / `SaveBindings` are `#nocombat` restricted — the B-key bind in Cata/MoP only runs on `PLAYER_LOGIN` so this is safe, but worth noting
