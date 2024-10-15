require("util")
require("__cargo-ships__/logic/ship_api")
require("__cargo-ships__/logic/ship_placement")
require("__cargo-ships__/logic/rail_placement")
require("__cargo-ships__/logic/long_reach")
require("__cargo-ships__/logic/bridge_logic")
require("__cargo-ships__/logic/pump_placement")
require("__cargo-ships__/logic/blueprint_logic")
require("__cargo-ships__/logic/ship_enter")
require("__cargo-ships__/logic/oil_rig_logic")
--require("__cargo-ships__/logic/crane_logic")


is_waterway = util.list_to_map{
  "straight-waterway",
  "half-diagonal-waterway",
  "curved-waterway-a",
  "curved-waterway-b",
  "legacy-straight-waterway",
  "legacy-curved-waterway"
}

is_rail = util.list_to_map{
  "straight-rail",
  "half-diagonal-rail",
  "curved-rail-a",
  "curved-rail-b",
  "legacy-straight-rail",
  "legacy-curved-rail",
  "rail-ramp",
}


-- spawn additional invisible entities
local function OnEntityBuilt(event)

  local entity = event.entity or event.destination
  local surface = entity.surface
  local force = entity.force
  local player = (event.player_index and game.players[event.player_index]) or nil

  log("Event happened:"..serpent.block(event))

  -- check ghost entities first
  if entity.name == "entity-ghost" then
    if is_waterway[entity.ghost_name] then
      if not entity.silent_revive{raise_revive = true} then
        entity.destroy()
      end
    elseif entity.ghost_name == "bridge_gate" then
      -- Replace with proper bridge_base ghost
      HandleBridgeGhost(entity)
    elseif entity.ghost_name == "or_tank" or entity.ghost_name == "or_pole" then
      -- Delete oil rig parts if placed without an oil_rig
      HandleOilRigPartGhost(entity)
    end

  elseif storage.boat_bodies[entity.name] then
    CheckBoatPlacement(entity, player)

  elseif (entity.type == "cargo-wagon" or entity.type == "fluid-wagon" or
          entity.type == "locomotive" or entity.type == "artillery-wagon") then
    local engine = nil
    if storage.ship_bodies[entity.name] then
      local ship_data = storage.ship_bodies[entity.name]
      if ship_data.engine then
        local engine_loc = localizeEngine(entity)
        game.print("looking for engine ghost at "..util.positiontostr(engine_loc.pos).." pointing "..tostring(engine_loc.dir))
        -- see if there is an engine ghost from a blueprint behind us
        local ghost = surface.find_entities_filtered{ghost_name=ship_data.engine, position=engine_loc.pos, force=force, limit=1}[1]
        if ghost then
          game.print("found ghost at "..util.positiontostr(ghost.position).." pointing "..tostring(ghost.orientation)..", reviving")
          local dummy
          dummy, engine = ghost.revive()
          -- If couldn't revive engine, destroy ghost
          if not engine then
            game.print("couldn't revive ghost at "..util.positiontostr(newghost.position))
            ghost.destroy()
          end
        end
        if not engine then
          game.print("Creating "..ship_data.engine.." for "..entity.name)
          engine = surface.create_entity{
            name = ship_data.engine,
            position = engine_loc.pos,
            direction = engine_loc.dir,
            force = force
          }
        end
      end
    end
    -- check placement in next tick after wagons connect
    table.insert(storage.check_placement_queue, {entity=entity, engine=engine, player=player, robot=event.robot})

  -- add oilrig component entities
  elseif entity.name == "oil_rig" then
    CreateOilRig(entity, player, event.robot)

  -- create bridge
  elseif entity.name == "bridge_base" then
    CreateBridge(entity, player, event.robot)

  -- make waterway not collide with boats by replacing it with entity that does not have "ground-tile" in its collision mask
  elseif is_rail[entity.type] then
    CheckRailPlacement(entity, player, event.robot)

  --elseif entity.name == "crane" then
  --  OnCraneCreated(entity)
  end
end

local function OnMarkedForDeconstruction(event)
  local entity = event.entity
  if is_waterway[entity.name] then
    entity.destroy()
  end
end

local function OnGiveWaterway(event)
  local player = game.get_player(event.player_index)
  local cleared = player.clear_cursor()
  if cleared then
    player.cursor_ghost = "waterway"
  end
end

-- delete invisible entities if master entity is destroyed
local function OnEntityDeleted(event)
  local entity = event.entity
  if(entity and entity.valid) then
    if storage.ship_bodies[entity.name] then
      if entity.train then
        if entity.train.back_stock then
          if storage.ship_engines[entity.train.back_stock.name] then
            entity.train.back_stock.destroy()
          end
        end
        if entity.train.front_stock then
          if storage.ship_engines[entity.train.front_stock.name] then
            entity.train.front_stock.destroy()
          end
        end
      end

    elseif storage.ship_engines[entity.name] then
      if entity.train then
        if entity.train.front_stock then
          if storage.ship_bodies[entity.train.front_stock.name] then
            entity.train.front_stock.destroy()
          end
        end
        if entity.train.back_stock then
          if storage.ship_bodies[entity.train.back_stock.name]  then
            entity.train.back_stock.destroy()
          end
        end
      end
    elseif entity.name == "entity-ghost" then
      if entity.ghost_name == "oil_rig" then
        -- Delete any or_tank or or_pole ghosts in the area
        DestroyOilRigGhost(entity)
      elseif storage.ship_bodies[entity.ghost_name] then
        -- Delete any ship engine ghost int he area
        DestroyShipGhost(entity)
      end
    end
  end
end


-- Perform the destroyed action for this unit_number
-- Each method checks if it applies
function OnObjectDestroyed(event)
  local unit_number = event.useful_id
  -- Oil Rigs
  if DestroyOilRig(unit_number) then return end
  -- Bridges
  if HandleBridgeDestroyed(unit_number) then return end
end


-- recover fuel of cargo ship engine if attempted to mine by player and robot
local function OnPreEntityMined(event)
  if(event.entity and event.entity.valid) then
    local entity = event.entity
    local okay_to_delete = true
    if storage.ship_bodies[entity.name] then
      okay_to_delete = false
      local player = (event.player_index and game.players[event.player_index]) or nil
      local robot = event.robot
      if entity.train then
        local engine
        if entity.train.back_stock and
          (storage.ship_engines[entity.train.back_stock.name]) then
          engine = entity.train.back_stock
        elseif entity.train.front_stock and
              (storage.ship_engines[entity.train.front_stock.name]) then
          engine = entity.train.front_stock
        end
        if ( engine and storage.ship_engines[engine.name].recover_fuel and
             engine.get_fuel_inventory() and not engine.get_fuel_inventory().is_empty() ) then
          local fuel_inventory = engine.get_fuel_inventory()
          if player and player.character then
            for _, fuel in pairs(fuel_inventory.get_contents()) do
              player.insert{name=fuel.name, count=fuel.count}  -- TODO 2.0 quality
              fuel_inventory.remove{name=fuel.name, count=fuel.count}
            end
          elseif robot then
            local robotInventory = robot.get_inventory(defines.inventory.robot_cargo)
            local robotSize = 1 + robot.force.worker_robots_storage_bonus
            local robotEmpty = robotInventory.is_empty()
            if robotEmpty and fuel_inventory then
              for index=1, #fuel_inventory do
                local stack = fuel_inventory[index]
                if stack.valid_for_read then
                  --game.print("Giving robot cargo stack: "..stack.name.." : "..stack.count)
                  local inserted = robotInventory.insert{name=stack.name, count=math.min(stack.count, robotSize)}
                  fuel_inventory.remove{name=stack.name, count=inserted}
                  if not robotInventory.is_empty() then
                    robotEmpty = false
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end


local function OnModSettingsChanged(event)
  if event.setting == "waterway_reach_increase" then
    storage.current_distance_bonus = settings.global["waterway_reach_increase"].value
    applyReachChanges()
  end
end

local function OnTick(event)
  processPlacementQueue()
  UpdateVisuals(event)
end

local function OnStackChanged(event)
  increaseReach(event)
  PumpVisualisation(event)
end


-- Register conditional events based on mod settting
function init_events()
  -- entity created, check placement and create invisible elements
  local entity_filters = {
      {filter="ghost", ghost_name="bridge_gate"},
      {filter="ghost", ghost_name="straight-waterway"},
      {filter="ghost", ghost_name="half-diagonal-waterway"},
      {filter="ghost", ghost_name="curved-waterway-a"},
      {filter="ghost", ghost_name="curved-waterway-b"},
      {filter="ghost", ghost_name="legacy-straight-waterway"},
      {filter="ghost", ghost_name="legacy-curved-waterway"},
      {filter="name", name="oil_rig"},
      {filter="name", name="bridge_base"},
      {filter="type", type="cargo-wagon"},
      {filter="type", type="fluid-wagon"},
      {filter="type", type="locomotive"},
      {filter="type", type="artillery-wagon"},
      {filter="type", type="straight-rail"},
      {filter="type", type="half-diagonal-rail"},
      {filter="type", type="curved-rail-a"},
      {filter="type", type="curved-rail-b"},
      {filter="type", type="rail-ramp"},
      {filter="type", type="legacy-straight-rail"},
      {filter="type", type="legacy-curved-rail"},
    }
  if storage.boat_bodies then
    for name,_ in pairs(storage.boat_bodies) do
      table.insert(entity_filters, {filter="name", name=name})
    end
  end
  script.on_event(defines.events.on_built_entity, OnEntityBuilt, entity_filters)
  script.on_event(defines.events.on_robot_built_entity, OnEntityBuilt, entity_filters)
  script.on_event(defines.events.on_entity_cloned, OnEntityBuilt, entity_filters)
  script.on_event(defines.events.script_raised_built, OnEntityBuilt, entity_filters)
  script.on_event(defines.events.script_raised_revive, OnEntityBuilt, entity_filters)

  -- delete invisible oil rig, bridge, and ship elements
  local deleted_filters = {{filter="ghost_name", name="oil_rig"}}
  if storage.ship_bodies then
    for name,_ in pairs(storage.ship_bodies) do
      table.insert(deleted_filters, {filter="name", name=name})
      table.insert(deleted_filters, {filter="ghost_name", name=name})
    end
  end
  if storage.ship_engines then
    for name,_ in pairs(storage.ship_engines) do
      table.insert(deleted_filters, {filter="name", name=name})
    end
  end
  script.on_event(defines.events.on_entity_died, OnEntityDeleted, deleted_filters)
  script.on_event(defines.events.script_raised_destroy, OnEntityDeleted, deleted_filters)
  script.on_event(defines.events.on_player_mined_entity, OnEntityDeleted, deleted_filters)
  script.on_event(defines.events.on_robot_mined_entity, OnEntityDeleted, deleted_filters)
  
  -- Handle Oil Rig and Bridge components
  script.on_event(defines.events.on_object_destroyed, OnObjectDestroyed)

  -- recover fuel from mined ships
  local mined_filters = {}
  if storage.ship_bodies then
    for name,_ in pairs(storage.ship_bodies) do
      table.insert(mined_filters, {filter="name", name=name})
    end
  end
  script.on_event(defines.events.on_pre_player_mined_item, OnPreEntityMined, mined_filters)
  script.on_event(defines.events.on_robot_pre_mined, OnPreEntityMined, mined_filters)

  local deconstructed_filters = {
    {filter="name", name="straight-waterway"},
    {filter="name", name="half-diagonal-waterway"},
    {filter="name", name="curved-waterway-a"},
    {filter="name", name="curved-waterway-b"},
    {filter="name", name="legacy-straight-waterway"},
    {filter="name", name="legacy-curved-waterway"},
  }
  script.on_event(defines.events.on_marked_for_deconstruction, OnMarkedForDeconstruction, deconstructed_filters)
  
  -- update entities
  script.on_event(defines.events.on_tick, OnTick)
  
  -- bridge queue
  if storage.bridge_destroyed_queue and next(storage.bridge_destroyed_queue) then
    script.on_nth_tick(72, HandleBridgeQueue)
  else
    script.on_nth_tick(72, nil)
  end
  
  -- long reach
  script.on_event(defines.events.on_player_cursor_stack_changed, OnStackChanged)
  script.on_event(defines.events.on_pre_player_died, deadReach)

  -- pipette
  script.on_event(defines.events.on_player_pipette, FixPipette)
  
  -- bridge blueprint
  script.on_event({defines.events.on_player_setup_blueprint,
                   defines.events.on_player_configured_blueprint}, HandleBridgeBlueprint)
  

  -- rolling stock connect (this logic was too buggy to use)
  script.on_event(defines.events.on_train_created, OnTrainCreated)

  script.on_event(defines.events.on_runtime_mod_setting_changed, OnModSettingsChanged)

  -- custom-input and shortcut button
  script.on_event({defines.events.on_lua_shortcut, "give-waterway"},
    function(event)
      if event.prototype_name and event.prototype_name ~= "give-waterway" then return end
      OnGiveWaterway(event)
    end
  )
  
  -- Compatibility with AAI Vehicles (Modify this whenever the list of boats changes)
  remote.remove_interface("aai-sci-burner")
  remote.add_interface("aai-sci-burner", {
    hauler_types = function(data)
      local types={}
      if storage.boat_bodies then
        for name,_ in pairs(storage.boat_bodies) do
          table.insert(types, name)
        end
      end
      return types
    end,
  })

end


local function init()
  -- Init storage variables
  storage.check_placement_queue = storage.check_placement_queue or {}
  storage.oil_rigs = storage.oil_rigs or {}
  storage.bridges = storage.bridges or {}
  storage.bridge_destroyed_queue = storage.bridge_destroyed_queue or {}
  storage.ship_pump_selected = storage.ship_pump_selected or {}
  storage.pump_markers = storage.pump_markers or {}
  storage.disable_this_tick = storage.disable_this_tick or {}
  storage.driving_state_locks = storage.driving_state_locks or {}
  
  init_ship_globals()  -- Init database of ship parameters

  -- Initialize or migrate long reach state
  storage.last_cursor_stack_name =
    ((type(storage.last_cursor_stack_name) == "table") and storage.last_cursor_stack_name)
      or {}
  storage.last_distance_bonus =
    ((type(storage.last_distance_bonus) == "number") and storage.last_distance_bonus)
      or settings.global["waterway_reach_increase"].value
  storage.current_distance_bonus = settings.global["waterway_reach_increase"].value

  -- Reapply long reach settings to existing characters

  -- Register conditional events
  init_events()
end

---- Register Default Events ----
-- init
script.on_load(function()
  init_events()
end)
script.on_init(function()
  init()
end)
script.on_configuration_changed(function()
  init()
end)


-- Console commands
commands.add_command("cargo-ships-dump", "Dump storage to log", function() log(serpent.block(storage)) end)


------------------------------------------------------------------------------------
--                    FIND LOCAL VARIABLES THAT ARE USED GLOBALLY                 --
--                              (Thanks to eradicator!)                           --
------------------------------------------------------------------------------------
setmetatable(_ENV,{
  __newindex=function (self,key,value) --locked_global_write
    error('\n\n[ER Global Lock] Forbidden global *write*:\n'
      .. serpent.line{key=key or '<nil>',value=value or '<nil>'}..'\n')
    end,
  __index   =function (self,key) --locked_global_read
    error('\n\n[ER Global Lock] Forbidden global *read*:\n'
      .. serpent.line{key=key or '<nil>'}..'\n')
    end ,
  })

