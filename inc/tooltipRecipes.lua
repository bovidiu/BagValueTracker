-- BagValueTracker/inc/tooltipRecipes.lua

local _, BVT = ...

local recipeCache = {}

local function IsRetail()
    local _, _, _, toc = GetBuildInfo()
    return toc >= 100000
end

function BVT.IsItemUsedInRecipe(itemLink)
    local itemID = tonumber(string.match(itemLink, "item:(%d+)"))
    if not itemID then return false end

    if recipeCache[itemID] ~= nil then
        return recipeCache[itemID]
    end

    if not C_TradeSkillUI or not C_TradeSkillUI.GetAllRecipeIDs then
        recipeCache[itemID] = false
        return false
    end

    local allRecipes = C_TradeSkillUI.GetAllRecipeIDs()
    if not allRecipes then
        recipeCache[itemID] = false
        return false
    end

    for _, recipeID in ipairs(allRecipes) do
        local numReagents = C_TradeSkillUI.GetRecipeNumReagents(recipeID)
        for reagentIndex = 1, numReagents do
            local reagentLink = C_TradeSkillUI.GetRecipeReagentItemLink(recipeID, reagentIndex)
            if reagentLink then
                local reagentID = tonumber(string.match(reagentLink, "item:(%d+)"))
                if reagentID == itemID then
                    recipeCache[itemID] = true
                    return true
                end
            end
        end
    end

    recipeCache[itemID] = false
    return false
end

if IsRetail() then
    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        local _, itemLink = self:GetItem()
        if not itemLink then return end

        if BVT.IsItemUsedInRecipe(itemLink) then
            self:AddLine("|cff00ff00Used in a recipe|r")
            self:Show()
        end
    end)
end
