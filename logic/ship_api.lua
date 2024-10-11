-- Make the global variables and remote interface to add new ships
local math2d = require("math2d")

local default_offset = {    -- Relative position to place engine for each straight rail direction
  [0] = {x = 0, y = 9.5},   -- North-facing
  [1] = {x = -4.4, y = 8.4},   -- NNE-facing
  [2] = {x = -7, y = 7},    -- Northeast-facing
  [3] = {x = -8.4, y = 4.4},   -- ENE-facing
  [4] = {x = -9.5, y = 0},  -- East-facing
  [5] = {x = -8.4, y = -4.4},   -- ESE-facing
  [6] = {x = -7, y = -7},   -- Southeast-facing
  [7] = {x = -4.4, y = -8.8},   -- SSE-facing
  [8] = {x = 0, y = -9.5},  -- South-facing
  [9] = {x = 4.4, y = -8.8},   -- SSW-facing
  [10] = {x = 7, y = -7},    -- Southwest-facing
  [11] = {x = 8.8, y = -4.4},   -- WSW-facing
  [12] = {x = 9.5, y = 0},   -- West-facing
  [13] = {x = 8.8, y = 4.4},   -- WNW-facing
  [14] = {x = 7, y = 7},      -- Northwest-facing
  [15] = {x = 4.4, y = 8.8},   -- NNW-facing
}

function create_storage()
  storage.boat_bodies = storage.boat_bodies or {}
  storage.ship_engines = storage.ship_engines or {}
  storage.ship_bodies = storage.ship_bodies or {}
  storage.enter_ship_entities = storage.enter_ship_entities or {}
end


--[[
    add_ship:  Adds definition for a new ship and ship engine (rolling-stock types)
    parameters:
      name (string, mandatory): Name of the ship body entity
      placing_item (string, optional): Name of item that places this ship, if different from prototype data.
      engine (string, optional): Name of engine entity
      engine_offset (table of Position, optional): Table of relative positions to place the engine. [0]=N, [1]=NNE, etc.
      engine_scale (float, optional): Ignored if engine_offset is present. Defaults to 1 if not specified. Scales the standard cargo ship offset table.
      engine_at_front (boolean, optional): Ignored if engine_offset is present. If true, the engine is placed in front of the ship body rather than behind. Applies negative sign to engine_scale.
      engine_orientation (table of Integer, optional): Lookup table for engine direction, if different from default. Usually don't need to specify this.
      recover_fuel (boolean, optional): Whether fuel items in this ship's engine should be collected when mining the ship. If not specified, will use the engine's prototype data.
--]]
function add_ship(params)
  local ship_data = {}
  log("Adding ship '"..tostring(params.name).."':")
  create_storage()

  -- Check ship name
  if not (params.name and prototypes.entity[params.name]) then
    log("Error adding ship data: Cannot find entity named '"..tostring(params.name).."'")
    return
  end
  if storage.ship_bodies[params.name] then
    log("Warning: Ship '"..params.name.."' already added")
  end
  ship_data.name = params.name

  -- Find the item to refund if building fails
  if params.placing_item then
    if prototypes.item[params.placing_item] then
      ship_data.placing_item = params.placing_item
    else
      log("Error adding ship data: Cannot find item named '"..tostring(params.placing_item).."'")
      return
    end
  else
    ship_data.placing_item = prototypes.entity[params.name].items_to_place_this and prototypes.entity[params.name].items_to_place_this[1].name
  end

  -- Process engine data, if any
  if params.engine and prototypes.entity[params.engine] then
    ship_data.engine = params.engine
    if params.engine_offset then
      -- Engine offset coordinates specified explicitly
      for i=0,15 do
        if not params.engine_offset[i] then
          log("Error adding ship data: engine_offset must have array indicies 0 through 15")
          return
        end
        params.engine_offset[i] = math2d.position.ensure_xy(params.engine_offset[i])
        if not (params.engine_offset[i].x and params.engine_offset[i].y) then
          log("Error adding ship data: each engine_offset must be a 2d vector")
          return
        end
      end
      ship_data.engine_offset = table.deepcopy(params.engine_offset)
      if ship_data.engine_offset[0].y > 0 then
        ship_data.coupled_engine = defines.rail_direction.back  -- Engine is behind body
      else
        ship_data.coupled_engine = defines.rail_direction.front  -- Engine is in front of body
      end
    else
      -- Engine offset coordinates specified by scale and/or direction
      local offset_scale = 1
      if params.engine_scale then
        if type(params.engine_scale) == "number" and params.engine_scale > 0 then
          offset_scale = params.engine_scale
        else
          log("Error adding ship data: engine_scale must be a number greater than 0")
          return
        end
      end
      -- Record coupling direction
      ship_data.coupled_engine = defines.rail_direction.back  -- 1=Engine is behind body by default (ship)
      if params.engine_at_front then
        offset_scale = offset_scale * -1
        ship_data.coupled_engine = defines.rail_direction.front  -- -1=Engine is in front of body (boat)
      end
      -- Apply scaling to default offset table
      ship_data.engine_offset = table.deepcopy(default_offset)
      for i=0,15 do
        ship_data.engine_offset[i] = math2d.position.multiply_scalar(ship_data.engine_offset[i], offset_scale)
      end
    end

    -- If set, use default orientation. otherwise don't store the orientation table at all
    if params.engine_orientation then
      -- Engine orientation specified in a custom table
      for i=0,15 do
        if not (params.engine_orientation[i] and type(params.engine_orientation[i]) == "number" and params.engine_orientation[i] >= 0 and params.engine_orientation[i] <= 15) then
          log("Error adding ship data: engine_orientation must have array indices 0 through 15 and contain integers valued 0 through 15")
          return
        end
      end
      ship_data.engine_orientation = table.deepcopy(params.engine_orientation)
    end

    -- Add data on this engine
    if not storage.ship_engines[ship_data.engine] then
      storage.ship_engines[ship_data.engine] = {
        name = ship_data.engine,
        -- engine is coupled in opposite direction from body
        coupled_ship = ship_data.coupled_engine == defines.rail_direction.front and defines.rail_direction.back or defines.rail_direction.front,
        compatible_ships = {[ship_data.name] = true},
      }

      -- Check if fuel should be recovered when mining the ship
      if params.engine_recover_fuel ~= nil then
        storage.ship_engines[ship_data.engine].recover_fuel = params.engine_recover_fuel  -- Use specified value
      elseif ( prototypes.entity[ship_data.engine] and prototypes.entity[ship_data.engine].burner_prototype and
               ( prototypes.entity[ship_data.engine].burner_prototype.fuel_inventory_size > 0 or
                 prototypes.entity[ship_data.engine].burner_prototype.burnt_inventory_size > 0 ) ) then
        storage.ship_engines[ship_data.engine].recover_fuel = true  -- Engine prototype has burner inventories
      else
        storage.ship_engines[ship_data.engine].recover_fuel = false  -- Not specified, and no burner inventories
      end

      -- Add to map of enterable ships
      if prototypes.entity[ship_data.engine].allow_passengers then
        storage.enter_ship_entities[ship_data.engine] = true
      end

    else
      -- Engine already exists, make sure things match
      if storage.ship_engines[ship_data.engine].coupled_ship == ship_data.coupled_engine then
        log("Error adding ship data: Engine '"..ship_data.engine.."' has already been added by another ship with the wrong coupling direction")
        return
      end

      -- Add this ship to map of compatible ships
      storage.ship_engines[ship_data.engine].compatible_ships[ship_data.name] = true
    end

  end

  storage.ship_bodies[ship_data.name] = ship_data

  -- Add to map of enterable ships
  if prototypes.entity[ship_data.name].allow_passengers then
    storage.enter_ship_entities[ship_data.name] = true
  end

  log("Added ship specification:\n"..serpent.line(ship_data))

end


--[[
    add_boat:  Adds definition for a new boat (car-type vehicle)
    parameters:
      name (string, mandatory): Name of the boat entity
      placing_item (string, optional): Name of item that places this boat, if different from prototype data.
      rail_version (string, optional): Name of the ship entity to be placed instead, if this boat is placed on a waterway. (Ship definition must be added first)
--]]
function add_boat(params)
  local boat_data = {}
  log("Adding boat '"..tostring(params.name).."':")
  create_storage()
  
  -- Check boat name
  if not (params.name and prototypes.entity[params.name]) then
    log("Error adding boat data: Cannot find entity named '"..tostring(params.name).."'")
    return
  end
  if storage.boat_bodies[params.name] then
    log("Warning: Boat '"..params.name.."' already added")
  end
  boat_data.name = params.name

  -- Find the item to refund if building fails
  if params.placing_item then
    if prototypes.item[params.placing_item] then
      boat_data.placing_item = params.placing_item
    else
      log("Error adding boat data: Cannot find item named '"..tostring(params.placing_item).."'")
      return
    end
  else
    boat_data.placing_item = prototypes.entity[params.name].items_to_place_this and prototypes.entity[params.name].items_to_place_this[1].name
  end

  -- Add rail-version of this boat, if any
  if params.rail_version then
    if storage.ship_bodies[params.rail_version] then
      boat_data.rail_version = params.rail_version
    else
      log("Error adding boat data: Cannot find ship defintion named '"..tostring(params.rail_version).."'")
      return
    end
  end

  -- Add to map of enterable ships
  if prototypes.entity[boat_data.name].allow_passengers then
    storage.enter_ship_entities[boat_data.name] = true
  end

  storage.boat_bodies[boat_data.name] = boat_data
  log("Added boat specification:\n"..serpent.line(boat_data))

end


function init_ship_globals()
  -- Clear the existing ship database
  storage.ship_bodies = {}
  storage.ship_engines = {}
  storage.boat_bodies = {}
  storage.enter_ship_entities = {}
  
  -- Create the built-in ships and boat
  add_ship({
    name = "cargo_ship",
    engine = "cargo_ship_engine",
    engine_scale = 1,
    engine_at_front = false,
  })

  add_ship({
    name = "oil_tanker",
    engine = "cargo_ship_engine",
    engine_scale = 1,
    engine_at_front = false,
  })

  add_ship({
    name = "boat",
    placing_item = "boat",
    engine = "boat_engine",
    engine_scale = 0.3,
    engine_at_front = true,
  })

  add_boat({
    name = "indep-boat",
    placing_item = "boat",
    rail_version = "boat",
  })
  -- List ship engines 
  log("Ship Engines Defined:")
  for _,eng in pairs(storage.ship_engines) do
    log(serpent.line(eng))
  end

  -- List of entities to use the "Enter Ship" command with (any of the above that accepts passengers)
  log("Enterable ships:\n"..serpent.line(storage.enter_ship_entities))
end


remote.add_interface("cargo-ships", {

    add_ship = function(params)
      add_ship(params)
      init_events()
    end,

    add_boat = function(params)
      add_boat(params)
      init_events()
    end,

  }
)
