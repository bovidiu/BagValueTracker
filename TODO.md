# TODO

## Bugs

- **`itemValue.lua:18`** — `GetItemInfoInstant(itemLink)` result assigned to `itemID` but never used (dead code)
- **Retail `.toc` missing `SavedVariables`** — `BagValueTrackerConfig` is never persisted in Retail, resets to defaults on every login (Cata/MoP have `SavedVariables: BagValueTrackerDB` but not the config table)
- **`GetItemInfo` is deprecated since 10.2.6** — should migrate to `C_Item.GetItemInfo(itemLink)`. Also returns `nil` if item not cached yet (async), which means `sellPrice` silently falls back to 0 for uncached items
- **`GetItemInfoInstant` is deprecated since 10.2.6** — modern replacement is `C_Item.GetItemInfoInstant`
- **`hasNoValue` field ignored** — `C_Container.GetContainerItemInfo` returns a `hasNoValue` boolean we could use to skip items with no vendor value instead of relying on `GetItemInfo` returning 0
- **`C_Container.GetContainerItemInfo` already returns `hyperlink`** — `bagValues.lua` makes a separate `GetContainerItemLink` call per slot, but the same link is already in `itemInfo.hyperlink` from the prior `GetContainerItemInfo` call (double API call per slot)

## Ideas / Improvements

- Add a `/bvt` slash command to toggle per-bag value display on/off at runtime without editing config
- Show total value across all bags somewhere (minimap button tooltip, or chat print on demand)
- Auctionator fallback is silent — consider showing a visual indicator when AH price vs vendor price is being used
- Use `ItemMixin:ContinueOnItemLoad()` for async item data loading to handle uncached items properly instead of silently returning 0

## Notes

- Slot overlay offset differs between versions: Retail uses `(-1, 15)`, Cata/MoP use `(1, -17)` — intentional for different UI layouts, keep in sync if bag frame changes
- Cata and MoP entry points are currently identical — consider a single shared file if they stay in sync
- `SetBinding` / `SaveBindings` are `#nocombat` restricted — the B-key bind in Cata/MoP only runs on `PLAYER_LOGIN` so this is safe, but worth noting
