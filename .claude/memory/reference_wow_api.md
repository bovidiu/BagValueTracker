---
name: WoW API reference (addon-relevant)
description: Key WoW public API functions used by or relevant to BagValueTracker, including signatures, return values, deprecation status, and gotchas
type: reference
---

Full API index: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
Individual pages: https://warcraft.wiki.gg/wiki/API_<FunctionName>

---

## Container API (C_Container namespace, since 10.0.2)

### C_Container.GetContainerNumSlots(containerIndex) → numSlots
- Returns total slot count for a bag. bagID 0 = backpack, 1–4 = equipped bags, in Retail up to NUM_BAG_SLOTS (4 extra + backpack = 5 total; Retail has reagent bag as bag 5).

### C_Container.GetContainerItemInfo(containerIndex, slotIndex) → ContainerItemInfo | nil
Returns a table (nil if slot empty):
- `iconFileID` number
- `stackCount` number
- `isLocked` boolean
- `quality` Enum.ItemQuality (nullable)
- `isReadable` boolean
- `hasLoot` boolean
- `hyperlink` string  ← same as GetContainerItemLink, avoid double call
- `isFiltered` boolean
- `hasNoValue` boolean  ← true if item has no vendor value, use to skip GetItemInfo calls
- `itemID` number
- `isBound` boolean

### C_Container.GetContainerItemLink(containerIndex, slotIndex) → itemLink
- Redundant if you already called GetContainerItemInfo — use `itemInfo.hyperlink` instead.

---

## Item API

### C_Item.GetItemInfo(itemInfo) → (name, link, quality, level, minLevel, type, subType, stackCount, equipLoc, texture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent, itemDescription)
- **Replaces deprecated `GetItemInfo`** (deprecated 10.2.6)
- Returns nil if item not in client cache yet (async — use `ItemMixin:ContinueOnItemLoad()` for reliable access)
- `sellPrice` (field 11) = vendor sell price in copper

### C_Item.GetItemInfoInstant(itemInfo) → (itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID)
- **Replaces deprecated `GetItemInfoInstant`** (deprecated 10.2.6)
- Returns cached data only, no network request, faster
- Does NOT return sellPrice

### ItemMixin:ContinueOnItemLoad(callback)
- Use this when you need item data that may not be cached yet instead of calling GetItemInfo and getting nil

---

## Key Binding API (Cata/MoP only, #nocombat restricted)

### SetBinding(key [, command [, mode]]) → ok
- Binds a key to a command string (e.g. "OPENALLBAGS")
- Changes are NOT saved until SaveBindings() is called
- Cannot be called during combat

### SaveBindings(which)
- which: 1 = ACCOUNT_BINDINGS, 2 = CHARACTER_BINDINGS
- Writes to WTF/Account/.../bindings-cache.wtf
- Fires UPDATE_BINDINGS event

### GetCurrentBindingSet() → which
- Returns 1 or 2 depending on active binding set

---

## Constants

- `NUM_BAG_SLOTS` — number of equippable bag slots (4 in most versions, excludes backpack)
- Bag IDs: 0 = backpack, 1–NUM_BAG_SLOTS = equipped bags

---

## Deprecation summary (as of 10.2.6)

| Old | New |
|-----|-----|
| `GetItemInfo` | `C_Item.GetItemInfo` |
| `GetItemInfoInstant` | `C_Item.GetItemInfoInstant` |
| `GetContainerNumSlots` | `C_Container.GetContainerNumSlots` |
| `GetContainerItemInfo` | `C_Container.GetContainerItemInfo` |
| `GetContainerItemLink` | `C_Container.GetContainerItemLink` |
