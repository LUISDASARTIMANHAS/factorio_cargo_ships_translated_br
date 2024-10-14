--[[
  Copied from AAI Vehicles: Ironclad with permission from Earendel
]]
local math2d = require("math2d")

local enter_ship_radius = 10

-- When the button is pressed decide the action, record it, and perform it.
-- Apply a short term lock.
-- If the default behaviour undoes the chosen effect, then set it back again.

function vehicle_exit(player, position)
  local character = player.character
  if character.vehicle.get_driver() == character then
    character.vehicle.set_driver(nil)
  else
    -- This can't be a train, because the player will always be in the driver slot
    character.vehicle.set_passenger(nil)
  end
  character.teleport(position)
end

function vehicle_enter(player, vehicle)
  local character = player.character
  if remote.interfaces["aai-vehicles-ironclad"] then
    -- Prevent infinite loop of raised events
    remote.call("aai-vehicles-ironclad", "disable_this_tick", player.index)
  end
  if not vehicle.get_driver() then
    vehicle.set_driver(character)
  elseif vehicle.type == "car" and not vehicle.get_passenger() then
    -- Don't try passenger if it's a train
    vehicle.set_passenger(character)
  end
end

function on_enter_vehicle_keypress (event)
  local player = game.players[event.player_index]
  local character = player.character
  if not character then return end

  if storage.disable_this_tick[player.index] and storage.disable_this_tick[player.index] == event.tick then
    return
  end
  local non_ship_radius = character.prototype.enter_vehicle_distance
  --if character.vehicle and storage.enter_ship_entities[character.vehicle.name] then
  if character.vehicle then
    local radius = non_ship_radius
    if storage.enter_ship_entities[character.vehicle.name] then
      radius = enter_ship_radius
    end
    local position = character.surface.find_non_colliding_position(character.name, character.position, radius, 0.5, true)
    if position then
      storage.driving_state_locks[player.index] = {valid_time = game.tick + 1, position = position}
      vehicle_exit(player, position)
    end
  else
    local vehicles = character.surface.find_entities_filtered{
      type = {"car", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon", "spider-vehicle"},
      position = character.position,
      radius = enter_ship_radius
    }
    local closest_vehicle
    local closest_distance = 2*enter_ship_radius
    for _, vehicle in pairs(vehicles) do
      local distance = math2d.position.distance(vehicle.position, character.position)
      if distance < closest_distance then
        if distance < non_ship_radius or storage.enter_ship_entities[vehicle.name] then
          closest_vehicle = vehicle
          closest_distance = distance
        end
      end
    end
    if closest_vehicle then
      storage.driving_state_locks[player.index] = {valid_time = game.tick + 1, vehicle = closest_vehicle}
      vehicle_enter(player, closest_vehicle)
    end
  end
end
script.on_event("enter-vehicle", on_enter_vehicle_keypress)

function on_player_driving_changed_state (event)
  local player = game.players[event.player_index]
  local character = player.character
  if not character then return end

  if storage.disable_this_tick[player.index] and storage.disable_this_tick[player.index] == event.tick then
    return
  end

  if storage.driving_state_locks[player.index] then
    if storage.driving_state_locks[player.index].valid_time >= game.tick then
      local lock = storage.driving_state_locks[player.index]
      if lock.vehicle then
        if not lock.vehicle.valid then
          storage.driving_state_locks[player.index] = nil
        else
          if not character.vehicle then
            vehicle_enter(player, lock.vehicle)
          elseif character.vehicle ~= lock.vehicle then
            if character.vehicle.get_driver() == character then
              character.vehicle.set_driver(nil)
            else
              character.vehicle.set_passenger(nil)
            end
            vehicle_enter(player, lock.vehicle)
          end
        end
      else
        if player.vehicle then
          vehicle_exit(player, lock.position)
        end
      end
    else
      storage.driving_state_locks[player.index] = nil
    end
  end
end
script.on_event(defines.events.on_player_driving_changed_state, on_player_driving_changed_state)

function disable_this_tick(player_index)
  storage.disable_this_tick[player_index] = game.tick
end

remote.add_interface(
    "cargo-ships-enter",
    {
        disable_this_tick = disable_this_tick,
    }
)
