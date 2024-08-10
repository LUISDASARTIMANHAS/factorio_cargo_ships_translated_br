require("__cargo-ships__/constants")
local collision_mask_util = require "__core__/lualib/collision-mask-util"

data:extend{
  {
    type = "collision-layer",
    name = "waterway",
  },
  {
    type = "collision-layer",
    name = "pump",
  },
  {
    type = "collision-layer",
    name = "land_resource",
  },
}


-- Prevent waterways being placed on land, but without colliding with ground-tile directly, so that ships don't collide
for _, tile in pairs(data.raw.tile) do
  if tile.collision_mask.layers["ground"] then
    tile.collision_mask.layers["waterway"] = true
  end
end
data.raw["legacy-straight-rail"]["straight-water-way"].collision_mask.layers["waterway"] = true
data.raw["legacy-curved-rail"]["curved-water-way"].collision_mask.layers["waterway"] = true
data.raw["legacy-straight-rail"]["invisible_rail"].collision_mask.layers["waterway"] = true
data.raw["legacy-straight-rail"]["bridge_crossing"].collision_mask.layers["waterway"] = true

data.raw["rail-signal"]["buoy"].collision_mask.layers["waterway"] = true
data.raw["rail-chain-signal"]["chain_buoy"].collision_mask.layers["waterway"] = true
data.raw["rail-chain-signal"]["invisible_chain_signal"].collision_mask.layers["waterway"] = true

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
    collision_mask["pump"] = true
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

-- Disable sea oil generation and extraction if Omnimatter or Seablock are installed
if data.raw.resource.deep_oil then

  -- If Water_Ores is not installed, make it so that:
  -- 1. Crude Oil can generate on deepwater tiles, and
  -- 2. Other resources cannot generate on any water tiles
  -- (Water ores removes resource-layer from all water tiles, so crude oil AND ores can generate on water.
  --  In that case, it is up to the player if they want Offshore Oil to be consolidated, or leave the vanilla patches.)
  if not mods["Water_Ores"] then
    -- Replace 'resource' with 'land_resource' in the collision masks of water tiles where oil can go
    if settings.startup["no_shallow_oil"].value then
      valid_oil_tiles = {"deepwater","deepwater-green"}
    else
      valid_oil_tiles = {"water","water-green","deepwater","deepwater-green"}
    end
    for _, name in pairs(valid_oil_tiles) do
      if data.raw.tile[name] then
        local collision_mask = data.raw.tile[name].collision_mask
        if collision_mask.layers["resource"] then
          log("Replacing collision layer 'resource' with 'land_resource' on tile '"..name.."'")
          collision_mask.layers["resource"] = nil
          collision_mask.layers["land_resource"] = true
        end
      end
    end

    -- Add a new "land_resource" collision layer to land resources (If Water_Ores is not installed)
    for name, prototype in pairs(data.raw.resource) do
      if name ~= "crude-oil" and name ~= "deep_oil" then
        local collision_mask = collision_mask_util.get_mask(prototype)
        collision_mask.layers["land_resource"] = true
        prototype.collision_mask = collision_mask
        prototype.selection_priority = math.max((prototype.selection_priority or 50) - 1, 0)
        log("Adding collision layer 'land_resource' to resource '"..name.."' and demoting to selection_priority="..tostring(prototype.selection_priority))
      end
    end

    -- Fix Alien Biomes tree selection priority
    for name, _ in pairs(data.raw.tree) do
      if data.raw.tree[name].selection_priority and data.raw.tree[name].selection_priority == 0 then
        data.raw.tree[name].selection_priority = 1
      end
    end

  end

  -- Make sure the oil rig can mine deep oil:
  data.raw["mining-drill"]["oil_rig"].resource_categories = {data.raw.resource["deep_oil"].category}
end
