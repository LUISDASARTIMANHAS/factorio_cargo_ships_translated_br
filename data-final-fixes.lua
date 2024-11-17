require("__cargo-ships__/constants")
local collision_mask_util = require("__core__/lualib/collision-mask-util")

data:extend{
  {
    type = "collision-layer",
    name = "waterway",
  },
  {
    type = "collision-layer",
    name = "pump",
  },
}


-- Prevent waterways being placed on land, but without colliding with ground-tile directly, so that ships don't collide
for _, tile in pairs(data.raw.tile) do
  if tile.collision_mask.layers["ground_tile"] then
    tile.collision_mask.layers["waterway"] = true
  end
end
data.raw["straight-rail"]["straight-waterway"].collision_mask.layers["waterway"] = true
data.raw["half-diagonal-rail"]["half-diagonal-waterway"].collision_mask.layers["waterway"] = true
data.raw["curved-rail-a"]["curved-waterway-a"].collision_mask.layers["waterway"] = true
data.raw["curved-rail-b"]["curved-waterway-b"].collision_mask.layers["waterway"] = true
data.raw["legacy-straight-rail"]["legacy-straight-waterway"].collision_mask.layers["waterway"] = true
data.raw["legacy-curved-rail"]["legacy-curved-waterway"].collision_mask.layers["waterway"] = true


data.raw["rail-signal"]["buoy"].collision_mask.layers["waterway"] = true
data.raw["rail-chain-signal"]["chain_buoy"].collision_mask.layers["waterway"] = true
data.raw["rail-chain-signal"]["invisible-chain-signal"].collision_mask.layers["waterway"] = true

data.raw.tile["landfill"].check_collision_with_entities = true

-- Change drawing of fish to be underneath bridges
-- TODO 2.0 check if needed
--data.raw.fish["fish"].collision_mask = {"ground-tile", "colliding-with-tiles-only"}
--data.raw.fish["fish"].pictures[1].draw_as_shadow = true
--data.raw.fish["fish"].pictures[2].draw_as_shadow = true
--data.raw.fish["fish"].selection_priority = 48

-- Change inserters to not catch fish when waiting for ships
if settings.startup["no_catching_fish"].value then
  for _, inserter in pairs(data.raw.inserter) do
    inserter.use_easter_egg = false
  end
end

-- Krastorio2 fuel compatibility
if mods["Krastorio2"] and settings.startup['kr-rebalance-vehicles&fuels'].value then
  data.raw.locomotive["cargo_ship_engine"].energy_source.fuel_categories = { "chemical", "vehicle-fuel" }
  log("Updated cargo_ship_engine to use chemical fuel and Krastorio2 vehicle-fuel")
  data.raw.locomotive["boat_engine"].energy_source.fuel_categories = { "vehicle-fuel" }
  log("Updated boat_engine to use only Krastorio2 vehicle-fuel")
end

-- Ensure player collides with pump

local pump = data.raw["pump"]["pump"]
local pump_collision_mask = collision_mask_util.get_mask(pump)
pump_collision_mask.layers["pump"] = true
pump.collision_mask = pump_collision_mask
for _, character in pairs(data.raw.character) do
  local collision_mask = collision_mask_util.get_mask(character)
  if collision_mask.layers["player"] then
    collision_mask.layers["pump"] = true
    character.collision_mask = collision_mask
  end
end

-- Compatibility for pump upgrade mods
for _, other_pump in pairs(data.raw.pump) do
  if other_pump.fast_replaceable_group == pump.fast_replaceable_group then
    other_pump.collision_mask = table.deepcopy(pump.collision_mask)
  end
end

-----------------------------
---- DEEP OIL GENERATION ----
-----------------------------

if data.raw.resource["offshore-oil"] then
  -- Make sure the oil rig can mine deep oil:
  data.raw["mining-drill"]["oil_rig"].resource_categories = {data.raw.resource["offshore-oil"].category}
  -- Make sure the oil rig can burn crude-oil
  data.raw.fluid["crude-oil"].fuel_value = data.raw.fluid["crude-oil"].fuel_value or "100MJ"

end
