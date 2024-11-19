local resource_autoplace = require("resource-autoplace")

if not settings.startup["offshore_oil_enabled"].value then return end
----------------------------------------------------------------
------------------------- OFFSHORE OIL --------------------------
----------------------------------------------------------------
data:extend{
  {
    type = "autoplace-control",
    name = "offshore-oil",
    localised_name = {"", "[entity=offshore-oil] ", {"entity-name.offshore-oil"}},
    richness = true,
    can_be_disabled = true,
    order = "a-e-a",
    category = "resource"
  },
}
resource_autoplace.initialize_patch_set("offshore-oil", false)

data:extend{
  {
    type = "resource-category",
    name = "offshore-fluid"
  },
  {
    type = "collision-layer",
    name = "water_resource",
  },  
  {
    type = "resource",
    name = "offshore-oil",
    icon = "__cargo-ships-graphics__/graphics/icons/crude-oil-resource.png",
    flags = {"placeable-neutral"},
    category = "offshore-fluid",
    subgroup = "mineable-fluids",
    order="a-b-a",
    infinite = true,
    highlight = true,
    minimum = 60000,
    normal = 300000,
    infinite_depletion_amount = 25,
    resource_patch_search_radius = 50,
    minable =
    {
      mining_time = 1,
      results =
      {
        {
          type = "fluid",
          name = "crude-oil",
          amount_min = 10,
          amount_max = 10,
          probability = 1
        }
      }
    },
    walking_sound = data.raw.resource["crude-oil"].walking_sound,
    driving_sound = data.raw.resource["crude-oil"].driving_sound,
    collision_mask = {layers={water_resource=true}},
    protected_from_tile_building = false,
    --collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    --selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
    collision_box = table.deepcopy(data.raw.resource["crude-oil"].collision_box),
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    autoplace = resource_autoplace.resource_autoplace_settings
    {
      name = "offshore-oil",
      order = "a",
      base_density = 10,          -- amount of stuff, on average, to be placed per tile
      base_spots_per_km2 = 1.8,     -- number of patches per square kilometer near the starting area
      random_probability = 1/400, -- probability of placement at any given tile within a patch (set low to ensure space between deposits for rigs to be placed)
      random_spot_size_minimum = 3,
      random_spot_size_maximum = 4,
      additional_richness = 350000, -- this increases the total everywhere, so base_density needs to be decreased to compensate
      has_starting_area_placement = false,
      regular_rq_factor_multiplier = 1 -- rq_factor is the ratio of the radius of a patch to the cube root of its quantity,
                                       -- i.e. radius of a quantity=1 patch; higher values = fatter, shallower patches
    },
    stage_counts = {0},
    stages =
    {
      sheet = {
        filename = GRAPHICSPATH .. "entity/crude-oil/hr-water-crude-oil.png",
        priority = "extra-high",
        width = 148,
        height = 120,
        frame_count = 4,
        variation_count = 1,
        shift = util.by_pixel(0, -2),
        scale = 0.7
      }
    },
    map_color = {0.8, 0.1, 1},
    map_grid = false
  },
}

if mods["angelspetrochem"] then
  data.raw.resource["offshore-oil"].minable = {
    hardness = 1,
    mining_time = 1,
    results =
    {
      {
        type = "fluid",
        name = "liquid-multi-phase-oil",
        amount_min = 10,
        amount_max = 10,
        probability = 1
      }
    }
  }
end

-- Add to Nauvis planet definition
data.raw.planet.nauvis.map_gen_settings.autoplace_controls["offshore-oil"] = {}
data.raw.planet.nauvis.map_gen_settings.autoplace_settings.entity.settings["offshore-oil"] = {}

if mods["space-age"] then
  resource_autoplace.initialize_patch_set("offshore-oil", false, "aquilo")

  data:extend{
    {
      type = "autoplace-control",
      name = "aquilo_offshore_oil",
      localised_name = {"", "[entity=offshore-oil] ", {"entity-name.offshore-oil"}},
      richness = true,
      order = "e-a-a",
      category = "resource"
    },
    {
      type = "noise-expression",
      name = "aquilo_offshore_oil_spots",
      expression = "aquilo_spot_noise{seed = 568,\z
                                      count = 4,\z
                                      skip_offset = 0,\z
                                      region_size = 600 + 450 / control:aquilo_offshore_oil:frequency,\z
                                      density = 0.75,\z
                                      radius = 1.5 * aquilo_spot_size * sqrt(control:aquilo_offshore_oil:size),\z
                                      favorability = 1}"
    },
    {
      type = "noise-expression",
      name = "aquilo_offshore_oil_probability",
      expression = "(control:aquilo_offshore_oil:size > 0) * -aquilo_min_elevation(-1.5)\z
                    * (min(aquilo_starting_mask,\z
                           aquilo_offshore_oil_spots * random_penalty{x = x, y = y, source = 1, amplitude = 1/aquilo_offshore_oil_random_penalty})\z
                           * 0.015)"
    },
    {
      type = "noise-expression",
      name = "aquilo_offshore_oil_richness",
      expression = "(aquilo_offshore_oil_spots * 1440000) * control:aquilo_offshore_oil:richness\z
                    / aquilo_offshore_oil_random_penalty"
    },
    {
      type = "noise-expression",
      name = "aquilo_offshore_oil_random_penalty",
      expression = 1/4
    },
  }

  data.raw.planet.aquilo.map_gen_settings.property_expression_names["entity:offshore-oil:probability"] = "aquilo_offshore_oil_probability"
  data.raw.planet.aquilo.map_gen_settings.property_expression_names["entity:offshore-oil:richness"] = "aquilo_offshore_oil_richness"
  data.raw.planet.aquilo.map_gen_settings.autoplace_controls["aquilo_offshore_oil"] = {}
  data.raw.planet.aquilo.map_gen_settings.autoplace_settings.entity.settings["offshore-oil"] = {}

end
