-- Master migration to 2.0.0
require("util")
require("__cargo-ships__/logic/bridge_logic")
local math2d = require("math2d")

-- We will copy over the things that we want and create an entirely new storage table
local newstorage = {}

-- In case any waterway ghosts were migrated from very old saves, revive them
for _, surface in pairs(game.surfaces) do
  for _, entity in pairs(surface.find_entities_filtered{name="entity-ghost", ghost_name={"legacy-straight-waterway", "legacy-curved-waterway"}}) do
    if not entity.silent_revive() then
      entity.destroy()  -- If there is a collision preventing revival, delete the ghost
    end
  end
end

-- Cached settings will be updated in init():
--   current_distance_bonus

-- Created fresh by init_ship_globals() and ship api:
--   boat_bodies
--   ship_bodies
--   ship_engines
--   enter_ship_entities

-- check_placement_queue: migrate from check_entity_placement, change array indexing to dictionary
newstorage.check_placement_queue = storage.check_placement_queue or {}
if storage.check_entity_placement then
  for _,entry in pairs(storage.check_entity_placement) do
    local entity = entry.entity or entry[1]
    local engine = entry.engine or entry[2]
    local player = entry.player or entry[3]
    local robot = entry.robot or entry[4]
    
    if entity and entity.valid then
      -- Entity is valid
      if not engine or engine.valid then
        -- Engine is nil or valid
        if player and type(player)=="number" then
          -- Old style table had player index
          player = game.players[player]
        end
        table.insert(newstorage.check_placement_queue, {entity=entity, engine=engine, player=player, robot=robot})
      end
    end
  end
end

-- Used by the enter_ship logic, migrate directly:
newstorage.driving_state_locks = storage.driving_state_locks or {}
newstorage.disable_this_tick = storage.disable_this_tick or {}

-- Used by long_reach logic, migrate directly:
newstorage.last_cursor_stack_name = storage.last_cursor_stack_name
newstorage.last_distance_bonus = storage.last_distance_bonus

-- Used by the pump marker visualizations
newstorage.pump_markers = storage.pump_markers or {}
newstorage.ship_pump_selected = storage.ship_pump_selected or {}

-----------------------------------------------------------------------------------------------------------
-- bridges: Migrated bridges were all converted to bridge-base entities
-- Need to find them all and replace them with the proper entities
newstorage.bridges = {}
for _, surface in pairs(game.surfaces) do
  local stored_entities = {}
  for _, base in pairs(surface.find_entities_filtered{name="bridge_base"}) do
    -- base position is where we would normally have built the placement entity
    -- It should be adjacent to a straight-waterway and on top of an invisible-rail
    -- The direction will probably always be north though, so we need to fix that
    log("Migrating bridge "..tostring(base))
    -- Find the invisible-rail at the origin
    local bridge_failed = false
    local position = base.position
    local force = base.force
    local origin_rail = surface.find_entities_filtered{position=position, name={"invisible-rail", "legacy-invisible-rail"}}
    if not (origin_rail and #origin_rail==1) then
      log("Error, couldn't find singular invisible-rail under bridge at "..util.positiontostr(position)..". Deleting bridge components.")
      bridge_failed = false
    else
      origin_rail = origin_rail[1]
      
      -- Find the waterway that crosses next to the origin rail
      local north_ww, south_ww, east_ww, west_ww
      local ww_count = 0
      local bridge_direction
      if origin_rail.direction == defines.direction.east then
        -- rail crossing east-west, means waterway and bridge is north-south
        north_ww = surface.find_entities_filtered{
          position = math2d.position.add(position, {-2,0}),
          name = {"straight-waterway", "legacy-straight-waterway"}}[1]
        if north_ww then
          ww_count = ww_count + 1
          bridge_direction = defines.direction.north
        end
        south_ww = surface.find_entities_filtered{
          position = math2d.position.add(position, {2,0}),
          name = {"straight-waterway", "legacy-straight-waterway"}}[1]
        if south_ww then
          ww_count = ww_count + 1
          bridge_direction = defines.direction.south
        end
      else
        -- rail crossing north-south, means bridge is east-west
        east_ww = surface.find_entities_filtered{
          position = math2d.position.add(position, {0,-2}),
          name = {"straight-waterway", "legacy-straight-waterway"}}[1]
        if east_ww then
          ww_count = ww_count + 1
          bridge_direction = defines.direction.east
        end
        west_ww = surface.find_entities_filtered{
          position = math2d.position.add(position, {0,2}),
          name = {"straight-waterway", "legacy-straight-waterway"}}[1]
        if west_ww then
          ww_count = ww_count + 1
          bridge_direction = defines.direction.west
        end
      end
      if ww_count ~= 1 then
        log("Error, found "..tostring(ww_count).." waterways near bridge at "..util.positiontostr(position)..". Deleting bridge components.")
        bridge_failed = true
      else
        local crossing_waterway = north_ww or south_ww or east_ww or west_ww
        
        -- Replace the bridge_base with the appropriate bridge_gate over the origin invisible-rail
        base.destroy()
        -- Build bridge
        local bridge = surface.create_entity{
          name = "bridge_gate",
          position = math2d.position.add(position, bridge_definitions[bridge_direction].bridge_offset),
          direction = bridge_direction,
          force = force,
          create_build_effect_smoke = false
        }
        if not bridge then
          log("Error, could not create new bridge at "..util.positiontostr(position)..". Deleting bridge components.")
        else
          -- Now we know the direction and where the original rail and waterways are.
          -- We can search the appropriate area for existing bridge entities.
          local search_area = offsetArea(bridge_placement_boxes[bridge_direction], position)
          local found_waterways = surface.find_entities_filtered{area=search_area, name={"straight-waterway", "legacy-straight-waterway"}}
          local found_rails = surface.find_entities_filtered{area=search_area, name={"invisible-rail", "legacy-invisible-rail"}}
          local found_signals = surface.find_entities_filtered{area=search_area, name="invisible-chain-signal"}
          if #found_waterways ~= 3 then
            log("Error, expected 3 but found "..tostring(#found_waterways).." waterway near bridge at "..util.positiontostr(position)..". Deleting bridge components.")
            bridge_failed = true
          end
          if #found_rails ~= 6 then
            log("Error, expected 6 but found "..tostring(#found_rails).." invisble-rail near bridge at "..util.positiontostr(position)..". Deleting bridge components.")
            bridge_failed = true
          end
          if #found_signals ~= 8 then
            log("Error, expected 8 but found "..tostring(#found_signals).." invisible-chain-signal near bridge at "..util.positiontostr(position)..". Deleting bridge components.")
            bridge_failed = true
          end
          
          if not bridge_failed then
            -- Register event for destruction
            script.register_on_object_destroyed(bridge)
            
            -- Now add everything to the new storage entry!
            newstorage.bridges[bridge.unit_number] = {
              surface = bridge.surface,
              position = bridge.position,  -- Store where the ghost will be if it's killed
              bridge = bridge,
              rails = found_rails,
              signals = found_signals
            }
            
            -- Remember these bridge parts so we don't delete them later
            stored_entities[bridge.unit_number] = true
            for _,rail in pairs(found_rails) do
              stored_entities[rail.unit_number] = true
            end
            for _,signal in pairs(found_signals) do
              stored_entities[signal.unit_number] = true
            end
          end
        end
      end
    end
    
    if bridge_failed then
      log("Failed to migrate bridge at "..util.positiontostr(position))
    end
  end
  -- Now delete all the unused bridge entities on this surface
  local found_entities = surface.find_entities_filtered{name={"bridge_base", "bridge_gate", "invisible-rail", "legacy-invisible-rail", "invisible-chain-signal"}}
  if #found_entities > 0 then
    for _,entity in pairs(found_entities) do
      if not stored_entities[entity.unit_number] then
        entity.destroy()
        log("Deleting unused bridge component:\n"..tostring(entity))
      end
    end
  end
end
log("Migrated "..tostring(table_size(newstorage.bridges)).." bridges successfully:\n"..serpent.block(newstorage.bridges))

-- bridge_destroyed_queue: New list of bridges with rails to remove that still have trains on them
newstorage.bridge_destroyed_queue = {}


local function find_teleport_make(name, surface, area, position, force, flags)
  local entity
  local found = surface.find_entities_filtered{name=name, area=area}
  for _,e in pairs(found) do
    if e.position.x == position.x and e.position.y == position.y then
      entity = e
      log("Found existing "..name.." entity "..tostring(entity))
      break
    end
  end
  if not entity and found[1] then
    entity = found[1]
    log("Teleporting existing "..name.." entity "..tostring(entity))
    entity.teleport(position)
  end
  if not entity then
    entity = surface.create_entity(util.merge{{name=name, position=position, force=force, create_build_effect_smoke=false}, flags or {}})
    log("Making new "..name.." entity "..tostring(entity))
  end
  return entity
end

-----------------------------------------------------------------------------------------------------------
-- oil_rigs: Need to rebuild table and make new entities. Find and search
if settings.startup["offshore_oil_enabled"].value then
  newstorage.oil_rigs = {}
  for _, surface in pairs(game.surfaces) do
    local stored_entities = {}
    for _, entity in pairs(surface.find_entities_filtered{name="oil_rig"}) do
      log("Migrating oil_rig "..tostring(entity))
      -- Old oil rigs had multiple directions.  Not sure how this will migrate.  Just ignore direction for now.
      -- There might not be offshore-oil under the oil_rig anymore.  We're going to ignore that so the player can come and move it.
      entity.direction = defines.direction.north
      
      local force = entity.force
      local position = entity.position
      local direction = entity.direction
      
      -- To be nice, we can try and preserve the amount of oil in the mining_drill buffer when it moves to the storage tank.
      log("get_fluid_contents() => "..serpent.line(entity.get_fluid_contents()))
      log('get_fluid_count("crude-oil") => '..tostring(entity.get_fluid_count("crude-oil")))
      log('fluidbox[1] => '..serpent.line(entity.fluidbox[1]))
      local oil_contents = entity.get_fluid_count("crude-oil")
      
      -- Search for existing entities, and they might not be in the right place
      local power, pole, radar, tank
      local area = offsetArea(entity.prototype.selection_box, position)
      
      -- Fluid burning generator, or_power_electric
      power = find_teleport_make("or_power_electric", surface, area, position, force)
      
      -- Electric pole, or_pole
      pole = find_teleport_make("or_pole", surface, area, position, force)
      
      -- Radar, or_radar
      radar = find_teleport_make("or_radar", surface, area, position, force)
      
      -- Storage tank, or_tank
      tank = find_teleport_make("or_tank", surface, area, position, force)
      
      if not (power and pole and radar and tank) then
        log("Could not create all oil rig components. Oil rig "..tostring(entity).." will be deleted.")
      else
        -- Make components invincible
        power.destructible = false
        pole.destructible = false
        radar.destructible = false
        tank.destructible = false
        -- Link pumpjack and generator to tank
        entity.fluidbox.add_linked_connection(1, tank, 1)
        power.fluidbox.add_linked_connection(1, tank, 2)
        -- Prime the energy generator with some oil
        power.insert_fluid{name="crude-oil", amount=power.fluidbox.get_capacity(1)}
        -- Migrate stored oil to storage tank
        if oil_contents > 0 then
          local saved_contents = tank.insert_fluid{name="crude-oil", amount=oil_contents}
          log("Migrated "..tostring(saved_contents).." crude-oil to the storage tank.")
        end
        -- Register for destruction event
        script.register_on_object_destroyed(entity)
        newstorage.oil_rigs[entity.unit_number] = {
          surface = surface,
          position = position,
          entity = entity,
          pole = pole,
          radar = radar,
          power = power,
          tank = tank
        }
        stored_entities[entity.unit_number] = true
        stored_entities[power.unit_number] = true
        stored_entities[pole.unit_number] = true
        stored_entities[radar.unit_number] = true
        stored_entities[tank.unit_number] = true
      end
    end
    -- Now delete all the unused bridge entities on this surface
    local found_entities = surface.find_entities_filtered{name={"oil_rig", "or_power_electric", "or_pole", "or_radar", "or_tank"}}
    if #found_entities > 0 then
      for _,entity in pairs(found_entities) do
        if not stored_entities[entity.unit_number] then
          entity.destroy()
          log("Deleting unused oil_rig component:\n"..tostring(entity))
        end
      end
    end
  end
  log("Migrated "..tostring(table_size(newstorage.oil_rigs)).." oil_rigs successfully:\n"..serpent.block(newstorage.oil_rigs))
end

-- Destroy any existing oil rig guis
local OILRIG_FRAME = "oilStorageFrame"
for _, player in pairs(game.players) do
  if player.gui.relative[OILRIG_FRAME] then
    player.gui.relative[OILRIG_FRAME].destroy()
  end
  if player.gui.top[OILRIG_FRAME] then
    player.gui.top[OILRIG_FRAME].destroy()
  end
end


-- Replace the old storage data with the new table, erasing all unused fields
storage = newstorage
