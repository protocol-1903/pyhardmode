local coal_plant = function(entity)
    local picture = entity.surface.create_entity {
        name = entity.name .. "-picture",
        position = entity.position,
        force = entity.force_index
    }
    storage.coal_plants[entity.unit_number] = {entity, picture}
    return {picture}
end

local composite_entity_creation = {
    ["py-coal-powerplant-mk01"] = coal_plant,
    ["py-coal-powerplant-mk02"] = coal_plant,
    ["py-coal-powerplant-mk03"] = coal_plant,
    ["py-coal-powerplant-mk04"] = coal_plant,
}

local function on_built(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    local f = composite_entity_creation[entity.name]
    if not f then return end
    local sub_entities = f(entity)
    for _, sub_entity in pairs(sub_entities) do
        sub_entity.destructible = false
    end
    storage.composite_entities[entity.unit_number] = sub_entities
end

local function on_destroyed(event)
    local entity = event.entity
    if not entity or not entity.valid then return end
    if not composite_entity_creation[entity.name] then return end
    local sub_entities = storage.composite_entities[entity.unit_number]
    if not sub_entities then return end
    for _, sub_entity in pairs(sub_entities) do
        if sub_entity and sub_entity.valid then
            sub_entity.destroy()
        end
    end
    storage.composite_entities[entity.unit_number] = nil
end

script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_revive,
    defines.events.script_raised_built,
}, on_built)

-- on_entity_died is deliberately absent here. A mod may register a handler only
-- once per event - a second registration silently replaces the first - and
-- control.lua needs on_entity_died for the chest-spill. It calls on_destroyed
-- for us; registering here as well would have thrown this cleanup away and left
-- an orphaned animation behind every powerplant that died.
script.on_event({
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.script_raised_destroy,
}, on_destroyed)

script.on_event(defines.events.on_entity_cloned, function(event)
    local source = event.source
    if not source or not source.valid then return end
    if not composite_entity_creation[source.name] then return end
    on_destroyed {entity = source}
    on_built {entity = event.destination}
    if source.valid then source.destroy() end
end)

return {
    on_built = on_built,
    on_destroyed = on_destroyed,
}
