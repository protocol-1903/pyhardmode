data.raw.technology["tar-processing"].ignore_tech_cost_multiplier = true
data.raw.technology["engine"].ignore_tech_cost_multiplier = true
data.raw.technology["ash-separation"].ignore_tech_cost_multiplier = true
data.raw.technology["concrete"].ignore_tech_cost_multiplier = true
data.raw.technology["crusher"].ignore_tech_cost_multiplier = true

-- 2.1 turned recipe.category into a categories list, and pyindustry's void
-- recipes now declare `categories = {"py-runoff"}` etc. Reading the singular
-- field silently matched nothing, so every voiding restriction below became a
-- no-op - the mod loaded fine but hard mode was not actually hard.
local function has_category(recipe, category)
    if recipe.categories then
        for _, c in pairs(recipe.categories) do
            if c == category then return true end
        end
        return false
    end
    return recipe.category == category
end

for name, recipe in pairs(data.raw.recipe) do
    if has_category(recipe, "py-incineration") or has_category(recipe, "py-runoff") then
        if name == "water-pyvoid-fluid" then
            recipe.energy_required = 20
        elseif name == "zipir1-pyvoid" or name == "zipir1-pyvoid-hatchery" then
            recipe.enabled = false
            recipe.categories = {"hpf"}
            recipe.flags = {}
            recipe.hidden = nil
        else
            data.raw.recipe[name] = nil
        end
    elseif has_category(recipe, "py-venting") then
        recipe.ingredients[1].amount = 50
        RECIPE(name):add_ingredient {name = "filtration-media", amount = 1, type = "item"}:add_unlock("filtration")
        data.raw.recipe[name].energy_required = 0.5
        recipe.enabled = false
        recipe.flags = {}
        recipe.hidden = nil
    end
end

if type(data.data_crawler) == "string" and string.sub(data.data_crawler, 1, 5) == "yafc " then
    data.script_enabled = data.script_enabled or {}
    table.insert(data.script_enabled, {
        type = "item",
        name = "burner-mining-drill",
    })
    table.insert(data.script_enabled, {
        type = "item",
        name = "offshore-pump",
    })
end

RECIPE("zipir1-pyvoid"):add_unlock("zipir")
