local math2d = require("math2d")

function localizeEngine(entity, ship_name)
  --game.print("entity orientation = "..tostring(entity.orientation))
  local ship_dir = (math.floor((entity.orientation*16)+0.5))%16  -- Direction-value dependent, updated for 16-way rails
  --game.print("ship_dir = "..tostring(ship_dir))
  local ship_data = storage.ship_bodies[ship_name or entity.name]
  --game.print("ship_data = "..serpent.line(ship_data))
  local eng_pos = math2d.position.add(entity.position, ship_data.engine_offset[ship_dir])
  --game.print("eng_pos = "..serpent.line(eng_pos))
  local eng_dir = (ship_data.engine_orientation and ship_data.engine_orientation[ship_dir]) or ship_dir
  --game.print("eng_dir = "..tostring(eng_dir))
  return {pos=eng_pos, dir=eng_dir}
end

local function hasCorrectConnectedStock(wagon)
  local train = wagon.train
  local ship_data = storage.ship_bodies[wagon.name]
  if ship_data then
    -- Look for engine in the correct direction
    local engine = wagon.get_connected_rolling_stock(ship_data.coupled_engine)
    if engine and engine.name == ship_data.engine then
      -- Now make sure the engine is facing the right way
      local engine_data = storage.ship_engines[ship_data.engine]
      if engine_data and engine.get_connected_rolling_stock(engine_data.coupled_ship) == wagon then
          -- If this is the engine we expect, then we're good
        return true
      end
    end
  end
  local engine_data = storage.ship_engines[wagon.name]
  if engine_data then
    -- Look for body in front of engine (ship)
    local ship = wagon.get_connected_rolling_stock(engine_data.coupled_ship)
    -- If this is the engine we expect, then we're good
    if ship and engine_data.compatible_ships[ship.name] then
      local ship_data = storage.ship_bodies[ship.name]
      if ship_data and ship.get_connected_rolling_stock(ship_data.coupled_engine) == engine then
        return true
      end
    end
  end
  --game.print("didn't find matching entity for "..wagon.name.." in train of "..#train.carriages.." wagons")
  return false
end

local function cancelPlacement(entity, player, robot)
  if not storage.ship_engines[entity.name] then
    if player and player.valid then
      player.insert{name=entity.name, count=1}
      if storage.ship_bodies[entity.name] then
        player.create_local_flying_text{text={"cargo-ship-message.error-ship-no-space", entity.localised_name}, create_at_cursor=true}
      else
        player.create_local_flying_text{text={"cargo-ship-message.error-train-on-waterway", entity.localised_name}, create_at_cursor=true}
      end
    elseif robot and robot.valid then
      -- Give the robot back the thing
      local return_item = prototypes.entity[entity.name].items_to_place_this[1]
      robot.get_inventory(defines.inventory.robot_cargo).insert(return_item)
      if storage.ship_bodies[entity.name] then
        game.print{"cargo-ship-message.error-ship-no-space", entity.localised_name}
      else
        game.print{"cargo-ship-message.error-train-on-waterway", entity.localised_name}
      end
    else
      game.print{"cargo-ship-message.error-canceled", entity.localised_name}
    end
  end
  entity.destroy()
end


function CheckBoatPlacement(entity, player, robot)
  -- check if waterways present
  local boat_pos = entity.position
  local surface = entity.surface
  local local_name = entity.localised_name
  local boat_data = storage.boat_bodies[entity.name]
  local ww = nil
  if boat_data and boat_data.rail_version then
    ww = surface.find_entities_filtered{
      area=math2d.bounding_box.create_from_centre(boat_pos,2),
      name={"straight-waterway", "legacy-straight-waterway"}
    }
  end

  -- if so place waterway bound version of boat
  if ww and next(ww) then
    local ship_name = boat_data.rail_version
    local ship_data = storage.ship_bodies[ship_name]
    local force = entity.force
    local quality = entity.quality
    local ship_loc = localizeEngine(entity, ship_name)
    entity.destroy()
    local ship = surface.create_entity{name=ship_name, quality=quality, position=boat_pos, direction=ship_loc.dir, force=force}
    if ship then
      if player then
        player.create_local_flying_text{text={"cargo-ship-message.place-on-waterway", local_name}, create_at_cursor=true}
      else
        game.print{"cargo-ship-message.place-on-waterway", local_name}
      end
      local engine_loc = localizeEngine(ship)  -- Get better position for engine now that boat is on rails
      local engine = surface.create_entity{name=ship_data.engine, position=engine_loc.pos, direction=engine_loc.dir, force=force}
      table.insert(storage.check_placement_queue, {entity=ship, engine=engine, player=player, robot=robot})
      RegisterPlacementOnTick()
    else
      local refund = prototypes.entity[ship_name].items_to_place_this[1]
      refund.quality = quality
      if player then
        player.insert(refund)
        player.create_local_flying_text{text={"cargo-ship-message.error-place-on-waterway", local_name}, create_at_cursor=true}
      else
        if robot then
          robot.get_inventory(defines.inventory.robot_cargo).insert(refund)
        end
        game.print{"cargo-ship-message.error-place-on-waterway", local_name}
      end
    end
  else
    if player then
      player.create_local_flying_text{text={"cargo-ship-message.place-independent", local_name}, create_at_cursor=true}
    else
      game.print{"cargo-ship-message.place-independent", local_name}
    end
  end
end

-- checks placement of rolling stock, and returns the placed entities to the player if necessary
function processPlacementQueue()
  --if #storage.check_placement_queue > 0 then
  --  game.print(tostring(game.tick)..": checking placement "..tostring(#storage.check_placement_queue).." entities")
  --end
  for _, entry in pairs(storage.check_placement_queue) do
    local entity = entry.entity
    local engine = entry.engine
    local player = entry.player
    local robot = entry.robot
    
    --game.print("checking "..entity.name.." "..tostring(entity.unit_number))

    if entity and entity.valid then
      if storage.ship_bodies[entity.name] then
        local ship_data = storage.ship_bodies[entity.name]
        -- check for too many connections
        -- check for correct engine placement
        if ship_data.engine and not engine then
          -- See if there is already an engine connected to this ship
          if not hasCorrectConnectedStock(entity) then
            --game.print("incorrectly coupled ship / no engine")
            cancelPlacement(entity, player, robot)
          else
            --game.print("Correct stock coupled but wasn't given by creator")
          end
        elseif ship_data.engine and entity.orientation ~= engine.orientation then
          --game.print("engine is wrong orientation")
          cancelPlacement(entity, player, robot)
          cancelPlacement(engine, player)
        elseif entity.train then
          -- check if connected to too many carriages
          if ((ship_data.engine and #entity.train.carriages > 2) or
              (not ship_data.engine and #entity.train.carriages > 1)) then
            --game.print("too many carriages connected together")
            cancelPlacement(entity, player, robot)
            cancelPlacement(engine, player)
          -- check if on rails
          elseif entity.train.front_end then
            if not is_waterway[entity.train.front_end.rail.name] then
              --game.print("front is not waterway")
              cancelPlacement(entity, player, robot)
              cancelPlacement(engine, player)
            else
              --game.print("front is waterway, okay")
            end
          elseif entity.train.back_end then
            if not is_waterway[entity.train.back_end.rail.name] then
              --game.print("back is not waterway")
              cancelPlacement(entity, player, robot)
              cancelPlacement(engine, player)
            else
              --game.print("back is waterway, okay")
            end
          else
            --game.print("Not sure what this means")
          end
        end

      elseif storage.ship_engines[entity.name] then
        if not hasCorrectConnectedStock(entity) then
          game.print{"cargo-ship-message.error-unlinked-engine", entity.localised_name}
          cancelPlacement(entity, player)
        end

      -- else: trains
      elseif entity.train then
        -- check if on waterways
        if entity.train.front_end then
          if is_waterway[entity.train.front_end.rail.name] then
            cancelPlacement(entity, player, robot)
          end
        elseif entity.train.back_end.rail then
          if is_waterway[entity.train.back_end.rail.name] then
            cancelPlacement(entity, player, robot)
          end
        end
      end
    end
  end
  storage.check_placement_queue = {}
  RegisterPlacementOnTick()
end

-- Disconnects/reconnects rolling stocks if they get wrongly connected/disconnected
function OnTrainCreated(event)
  local contains_ship_engine = false
  local parts = event.train.carriages
  -- check if rolling stock contains any ships (engines)
  for i = 1, #parts do
    if storage.ship_engines[parts[i].name] then
      contains_ship_engine = true
      break
    end
  end
  --if no ships involved return
  if contains_ship_engine == false then
    return
  end
  --game.print("Checking train "..tostring(event.train.id).." with ship engine in it")
  -- if ship  has been split reconnect
  if #parts == 1 then
    -- reconnect!
    local engine = parts[1]
    -- Connect engine in the direction of the expected ship body
    local connected = engine.connect_rolling_stock(storage.ship_engines[engine.name].coupled_ship)
    --game.print("Tried connecting lonely "..engine.name.." at "..util.positiontostr(engine.position)..", result: "..tostring(connected))

  -- else if ship has been overconnected, split again
  elseif #parts > 2 then
    for i = 1, #parts do
      local name = parts[i].name
      local right_direction = ((storage.ship_bodies[name] and storage.ship_bodies[name].coupled_engine) or 
                               (storage.ship_engines[name] and storage.ship_engines[name].coupled_ship)) or nil
      if right_direction ~= nil then
        -- This is a ship or engine that is supposed to connected in right_direction
        -- Check if it's also connected in the wrong_direction
        local wrong_direction = right_direction == defines.rail_direction.front and defines.rail_direction.back or defines.rail_direction.front
        local stock = parts[i]
        if stock.get_connected_rolling_stock(wrong_direction) then
          --game.print("Cargo ships disconnecting rolling stock from "..(wrong_direction==defines.rail_direction.front and "front" or "back").." of "..name.." #"..tostring(stock.unit_number))
          if stock.disconnect_rolling_stock(wrong_direction) then 
            break
          end
        end
      end
    end
  end
end

function DestroyShipGhost(ghost)
  local engine_name = storage.ship_bodies[ghost.ghost_name].engine
  local engine_loc = localizeEngine(ghost, ghost.ghost_name)
  local engine_ghosts = ghost.surface.find_entities_filtered{
    ghost_name = engine_name,
    position = engine_loc.position,
    radius = 1
  }
  for _,engine_ghost in pairs(engine_ghosts) do
    engine_ghost.destroy()
  end

end

function RegisterPlacementOnTick()
  if storage.placement_queue and next(storage.placement_queue) then
    script.on_event(defines.events.on_tick, processPlacementQueue)
  else
    script.on_event(defines.events.on_tick, nil)
  end
end
