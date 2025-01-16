local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) -- Retail
local isWrathOrCata = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and select(4, GetBuildInfo()) >= 40000)

if isRetail then
    print("MyAddon: Running on Retail")
    -- Load Retail-specific logic
    LoadAddOn("BagValueTracker_Retail")
elseif isWrathOrCata then
    print("MyAddon: Running on Cataclysm Classic")
    -- Load Cataclysm-specific logic
    LoadAddOn("BagValueTracker_Cata")
else
    print("MyAddon: Unsupported WoW version")
end