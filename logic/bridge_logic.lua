local math2d = require("math2d")

bridge_placement_boxes = {
  [defines.direction.north] = {{-4.5, -3}, {6.5, 3}},
  [defines.direction.south] = {{-6.5, -3}, {4.5, 3}},
  [defines.direction.east] = {{-3, -4.5}, {3, 6.5}},
  [defines.direction.west] = {{-3, -6.5}, {3, 4.5}}
}

bridge_definitions = {
  -- Bridge North: Waterway going north-south, bridge on the right side
  [defines.direction.north] = {
    bridge_offset = {-0.5, -0.5},
    waterway_offsets = {{-2,-2},{-2,0},{-2,2}},
    rail_offsets = {{-4,0},{-2,0},{0,0},{2,0},{4,0},{6,0}},
    rail_direction = defines.direction.east,
    signal_offsets = {{-3.5,-1.5},{-3.5,1.5},{-0.5,-1.5},{-0.5,1.5},  -- waterway signals
                      {-4.5,-1.5},{6.5,-1.5},{-4.5,1.5},{6.5,1.5}},
    signal_directions = {defines.direction.north, defines.direction.north, defines.direction.south, defines.direction.south,
                         defines.direction.east, defines.direction.east, defines.direction.west, defines.direction.west}
  },
  -- Bridge South: Waterway going north-south, bridge on the left side
  [defines.direction.south] = {
    bridge_offset = {0.5, 0.5},
    waterway_offsets = {{2,-2}, {2,0}, {2,2}},
    rail_offsets = {{4,0},{2,0},{0,0},{-2,0},{-4,0},{-6,0}},
    rail_direction = defines.direction.east,
    signal_offsets = {{3.5,-1.5},{3.5,1.5},{0.5,-1.5},{0.5,1.5},  -- waterway signals
                      {4.5,-1.5},{-6.5,-1.5},{4.5,1.5},{-6.5,1.5}},
    signal_directions = {defines.direction.south, defines.direction.south, defines.direction.north, defines.direction.north,
                         defines.direction.east, defines.direction.east, defines.direction.west, defines.direction.west}
  },
  -- Bridge East: Waterway going east-west, bridge on the bottom side
  [defines.direction.east] = {
    bridge_offset = {0.5, -0.5},
    waterway_offsets = {{-2,-2}, {0,-2}, {2,-2}},
    rail_offsets = {{0,-4},{0,-2},{0,0},{0,2},{0,4},{0,6}},
    rail_direction = defines.direction.north,
    signal_offsets = {{-1.5,-3.5},{1.5,-3.5},{-1.5,-0.5},{1.5,-0.5},  -- waterway signals
                      {-1.5,-4.5},{-1.5,6.5},{1.5,-4.5},{1.5,6.5}},
    signal_directions = {defines.direction.east, defines.direction.east, defines.direction.west, defines.direction.west,
                         defines.direction.north, defines.direction.north, defines.direction.south, defines.direction.south},
  },
  -- Bridge West: Waterway going east-west, bridge on the top side
  [defines.direction.west] = {
    bridge_offset = {-0.5, 0.5},
    waterway_offsets = {{-2,2}, {0,2}, {2,2}},
    rail_offsets = {{0,4},{0,2},{0,0},{0,-2},{0,-4},{0,-6}},
    rail_direction = defines.direction.north,
    signal_offsets = {{-1.5,3.5},{1.5,3.5},{-1.5,0.5},{1.5,0.5},  -- waterway signals
                      {-1.5,4.5},{-1.5,-6.5},{1.5,4.5},{1.5,-6.5}},
    signal_directions = {defines.direction.west, defines.direction.west, defines.direction.east, defines.direction.east,
                         defines.direction.north, defines.direction.north, defines.direction.south, defines.direction.south}
  }
}

function offsetArea(area, vector)
  return {math2d.position.add(vector, area.left_top or area[1]), 
          math2d.position.add(vector, area.right_bottom or area[2])}
end

function CreateBridge(entity, player, robot)
  local position = entity.position
  local direction = entity.direction
  local force = entity.force
  local ver, hor, x, y
  local surface = entity.surface
  
  -- Area to check for conflicting entities
  local placement_area = offsetArea(bridge_placement_boxes[direction], position)
  -- TODO: This needs to be replaced with a better collision mask check
  local found = surface.find_entities_filtered{area=placement_area, invert=true, type={"fish", "character", "logistic-robot", "construction-robot", "combat-robot", "explosion", "fire"}}
  local num_waterways = 0
  local conflicts = {}
  for k,e in pairs(found) do
    if e.name == "legacy-straight-waterway" or e.name == "straight-waterway" then
      num_waterways = num_waterways + 1
    elseif e.name ~= "bridge_base" then
      table.insert(conflicts, e)
    end
  end
  if num_waterways > 3 or next(conflicts) then
    -- Area is not clear, return item to player/robot
    game.print("Items blocking bridge construction: \n"..serpent.block(conflicts))
    if player and player.valid then
      player.insert{name=entity.name, count=1}
      player.print{"cargo-ship-message.error-ship-no-space", entity.localised_name}
    elseif robot and robot.valid then
      -- Give the robot back the thing
      local return_item = entity.name
      robot.get_inventory(defines.inventory.robot_cargo).insert{name=return_item, count=1}
      game.print{"cargo-ship-message.error-ship-no-space", entity.localised_name}
    else
      game.print{"cargo-ship-message.error-canceled", entity.localised_name}
    end
    entity.destroy()
    return
  end
  
  -- No conflicts, so clear the area (including existing waterways and placement port object) and build the bridge
  entity.destroy()
  for _,e in pairs(conflicts) do
    e.destroy()
  end
  
  -- Bridge consists of:
  -- 1x bridge_gate in the correct location
  -- 3x straight-waterway in bridge named direction
  -- 6x invisible-rail crossing the waterways
  -- 8x invisible-chain-signal at all entrances

  local bridge_defintion = bridge_definitions[direction]
  
  -- Build bridge
  local bridge = surface.create_entity{
    name = "bridge_gate",
    position = math2d.position.add(position, bridge_defintion.bridge_offset),
    direction = direction,
    force = force
  }
  
  if bridge then
  
    -- Build waterways
    for _,w in pairs(bridge_defintion.waterway_offsets) do
      local newpos = math2d.position.add(position, w)
      surface.create_entity{
        name = "straight-waterway",
        position = newpos,
        direction = direction,
        snap_to_grid = true,
        force = force,
        create_build_effect_smoke = false
      }
    end
    
    -- Build rails
    local rails = {}
    for _,r in pairs(bridge_defintion.rail_offsets) do
      local newpos = math2d.position.add(position, r)
      local newr = surface.create_entity{
        name = "invisible-rail",
        position = newpos,
        direction = bridge_defintion.rail_direction,
        snap_to_grid = true,
        force = force,
        create_build_effect_smoke = false
      }
      if not newr then
        game.print("Warning, could not build invisible bridge rail at "..util.positiontostr(newpos))
      else
        table.insert(rails, newr)
      end
    end
    
    -- Build signals
    local signals = {}
    for i,s in pairs(bridge_defintion.signal_offsets) do
      local newpos = math2d.position.add(position, s)
      --game.print("Making signal at "..util.positiontostr(newpos).." pointing "..tostring(bridge_defintion.signal_directions[i]))
      local news = surface.create_entity{
        name = "invisible-chain-signal",
        position = newpos,
        direction = bridge_defintion.signal_directions[i],
        snap_to_grid = true,
        force = force,
        create_build_effect_smoke = false
      }
      if not news then
        game.print("Warning, could not build invisible bridge signal at "..util.positiontostr(newpos))
      else
        table.insert(signals, news)
      end
    end
    
    -- Register event for destruction
    script.register_on_object_destroyed(bridge)
    
    -- Store entity references
    storage.bridges[bridge.unit_number] = {
      surface = bridge.surface,
      position = bridge.position,  -- Store where the ghost will be if it's killed
      bridge = bridge,
      rails = rails,
      signals = signals
    }
  end
end

-- Try to delete all the bridge entities. Return false if any of them failed.
function DeleteBridgeEntities(bridge_data)
  for _,r in pairs(bridge_data.rails) do
    if not r.destroy() then
      return false
    end
  end
  for _,s in pairs(bridge_data.signals) do
    if not s.destroy() then
      return false
    end
  end
  if bridge_data.bridge then
    if not bridge_data.bridge.destroy() then
      return false
    end
  end
  return true
end

-- Check if there are trains/ships on any of the rails and queue for later if necessary
local function isBlockEmpty(bridge_data)
  for _,r in pairs(bridge_data.rails) do
    if r.valid and r.trains_in_block > 0 then
      return false
    end
  end
  return true
end

-- OnObjectDestroyed handler for when the bridge entity (bridge_gate) has alreay been destroyed/mined
function HandleBridgeDestroyed(unit_number)
  if storage.bridges and storage.bridges[unit_number] then
    local bridge_data = storage.bridges[unit_number]
    bridge_data.bridge = nil  -- Bridge already died
    
    -- Fix the ghost that was created, if any
    if bridge_data.surface and bridge_data.position then
      local ghost = bridge_data.surface.find_entity("entity-ghost",bridge_data.position)
      if ghost and ghost.ghost_name == "bridge_gate" then
        HandleBridgeGhost(ghost)
      end
    end
    
    local success = false
    if isBlockEmpty(bridge_data) then
      success = DeleteBridgeEntities(bridge_data)
    end
    if not success then
      -- Some or all components could not be deleted.
      -- Put in queue to delete later
      storage.bridge_destroyed_queue[unit_number] = bridge_data
      script.on_nth_tick(72, HandleBridgeQueue)
    end

    storage.bridges[unit_number] = nil
    return true
  end
end

function HandleBridgeQueue()
  for k,bridge_data in pairs(storage.bridge_destroyed_queue) do
    local success = false
    if isBlockEmpty(bridge_data) then
      success = DeleteBridgeEntities(bridge_data)
    end
    if success then
      storage.bridge_destroyed_queue[k] = nil
      break
    end
  end
end


-- Use the fact that rail grid is always 
local function bridgeLocationFromGate(gatepos)
  -- Rails and trains stops are always on odd-numbered integer coordinates
  -- Round to the nearest odd number for x and y
  local bridgepos = {x=math.ceil(gatepos.x),y=math.ceil(gatepos.y)}
  if bridgepos.x % 2 == 0 then
    bridgepos.x = bridgepos.x - 1
  end
  if bridgepos.y % 2 == 0 then
    bridgepos.y = bridgepos.y - 1
  end
  
  local bridgedir
  local vector_to_gate = math2d.position.subtract(gatepos, bridgepos)
  if vector_to_gate.x == -0.5 and vector_to_gate.y == -0.5 then
    bridgedir = defines.direction.north
  elseif vector_to_gate.x == 0.5 and vector_to_gate.y == 0.5 then
    bridgedir = defines.direction.south
  elseif vector_to_gate.x == 0.5 and vector_to_gate.y == -0.5 then
    bridgedir = defines.direction.east
  elseif vector_to_gate.x == -0.5 and vector_to_gate.y == 0.5 then
    bridgedir = defines.direction.west
  else
    game.print("couldn't find bridge direction")
    return
  end
  
  return {position=bridgepos, direction=bridgedir}
end

function HandleBridgeGhost(ghost)
  -- Somebody made a bridge_gate ghost and we have to clean up after them
  local bridge = bridgeLocationFromGate(ghost.position)
  if bridge then
    ghost.surface.create_entity{
      name = "entity-ghost",
      ghost_name = "bridge_base",
      force = ghost.force,
      position = bridge.position,
      direction = bridge.direction,
      snap_to_grid = true,
    }
  end
  ghost.destroy()
end

function HandleBridgeBlueprint(event)
  local item1 = game.get_player(event.player_index).blueprint_to_setup
  local item2 = game.get_player(event.player_index).cursor_stack
  local bp = nil
  if item1 and item1.valid_for_read==true then
    bp = item1
  elseif item2 and item2.valid_for_read==true and item2.is_blueprint==true then
    bp = item2
  end
  local changed = false
  
  -- Get Entity table from blueprint
  local entities = bp.get_blueprint_entities()
  
  if entities and next(entities) then
    for k,bridge in pairs(entities) do
      if bridge.name == "bridge_gate" then
        game.print("Found bridge_gate in blueprint at "..util.positiontostr(bridge.position))
        local bridge_success = false
        
        local bridge_location = bridgeLocationFromGate(bridge.position)
        if bridge then
          -- Change the bridge_gate to a bridge_base at this position
          entities[k] = {
            entity_number = entities[k].entity_number,
            name = "bridge_base",
            position = bridge_location.position,
            direction = bridge_location.direction
          }
          changed = true
          game.print("Bridge replaced at "..util.positiontostr(bridge_location.position).." pointing "..tostring(bridge_location.direction))
          bridge_success = true
        end
        
        -- If we couldn't replace the bridge, delete item
        if not bridge_success then
          entities[k] = nil
          changed = true
        end
      end
    end
  end
  
  -- Write the new blueprint
  if changed then
    bp.set_blueprint_entities(entities)
  end
end
