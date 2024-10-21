require "waterway-pictures"

local waterway_8shifts_vector = function(dx, dy)
  return
    {
      {  dx,  dy },
      { -dx,  dy },
      { -dy,  dx },
      { -dy, -dx },
      { -dx, -dy },
      {  dx, -dy },
      {  dy, -dx },
      {  dy,  dx }
    }
end

local function invincible()
  return {
    {
      type = "physical",
      percent = 100
    },
    {
      type = "explosion",
      percent = 100
    },
    {
      type = "acid",
      percent = 100
    },
    {
      type = "fire",
      percent = 100
    }
  }
end

-- mapcolor doesn't work yet on rails for some reason
data:extend({
  {
    type = "legacy-straight-rail",
    name = "legacy-straight-waterway",
    icon = GRAPHICSPATH .. "icons/water_rail.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation", "building-direction-8-way"},
    hidden_in_factoriopedia = true,
    resistances = invincible(),
    minable = {mining_time = 0.2},
    max_health = 200,
    corpse = nil,
    collision_box = {{-1.01, -0.95}, {1.01, 0.95}},
    selection_box = {{-1.7, -0.8}, {1.7, 0.8}},
    collision_mask = {layers = {object = true}},  -- waterway_layer added in data-final-fixes
    pictures = legacy_waterway_pictures("straight_rail"),
    placeable_by = {item = "waterway", count = 1},
    localised_description = {"item-description.waterway"},
  },
  {
    type = "legacy-curved-rail",
    name = "legacy-curved-waterway",
    icon = GRAPHICSPATH .. "icons/water_rail.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation", "building-direction-8-way"},
    hidden_in_factoriopedia = true,
    resistances = invincible(),
    minable = {mining_time = 0.2},
    max_health = 200,
    corpse = nil,
    collision_box = {{-1, -2}, {1, 3.1}},
    selection_box = {{-1.7, -0.8}, {1.7, 0.8}},
    collision_mask = {layers = {object = true}},  -- waterway_layer added in data-final-fixes
    pictures = legacy_waterway_pictures("curved_rail"),
    placeable_by = {item = "waterway", count = 1},
    localised_description = {"item-description.waterway"},
  },
  {
    type = "straight-rail",
    name = "straight-waterway",
    order = "a[ground-rail]-a[straight-rail]",
    icon = GRAPHICSPATH .. "icons/water_rail.png",
    collision_box = {{-1, -1}, {1, 1}}, -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    collision_mask = {layers = {object = true}},  -- waterway_layer added in data-final-fixes
    flags = {"placeable-neutral", "player-creation", "building-direction-8-way"},
    resistances = invincible(),
    minable = {mining_time = 0.2},
    max_health = 200,
    corpse = nil,
    -- collision box is hardcoded for rails as to avoid unexpected changes in the way rail blocks are merged
    selection_box = {{-1.7, -0.8}, {1.7, 0.8}},
    pictures = new_waterway_pictures("straight"),
    placeable_by = {item = "waterway", count = 1},
    extra_planner_goal_penalty = -4,
    factoriopedia_alternative = "straight-waterway"
  },
  {
    type = "half-diagonal-rail",
    name = "half-diagonal-waterway",
    order = "a[ground-rail]-b[half-diagonal-rail]",
    deconstruction_alternative = "straight-waterway",
    icon = GRAPHICSPATH .. "icons/water_rail.png",
    collision_box = {{-0.75, -2.236}, {0.75, 2.236}}, -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    collision_mask = {layers = {object = true}},  -- waterway_layer added in data-final-fixes
    tile_height = 2,
    extra_planner_goal_penalty = -4,
    flags = {"placeable-neutral", "player-creation", "building-direction-8-way"},
    resistances = invincible(),
    minable = {mining_time = 0.2},
    max_health = 200,
    selection_box = {{-1.7, -0.8}, {1.7, 0.8}},
    pictures = new_waterway_pictures("half-diagonal"),
    placeable_by = {item = "waterway", count = 1},
    extra_planner_penalty = 0,
    factoriopedia_alternative = "straight-waterway"
  },
  {
    type = "curved-rail-a",
    name = "curved-waterway-a",
    order = "a[ground-rail]-c[curved-rail-a]",
    deconstruction_alternative = "straight-waterway",
    icon = GRAPHICSPATH .. "icons/water_rail.png",
    collision_box = {{-0.75, -2.516}, {0.75, 2.516}}, -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    collision_mask = {layers = {object = true}},  -- waterway_layer added in data-final-fixes
    flags = {"placeable-neutral", "player-creation", "building-direction-8-way"},
    resistances = invincible(),
    minable = {mining_time = 0.2},
    max_health = 200,
    selection_box = {{-1.7, -0.8}, {1.7, 0.8}},
    pictures = new_waterway_pictures("curved-a"),
    placeable_by = {item = "waterway", count = 2},
    extra_planner_penalty = 0.5,
    deconstruction_marker_positions = waterway_8shifts_vector(-0.248, -0.533),
    factoriopedia_alternative = "straight-waterway"
  },
  {
    type = "curved-rail-b",
    name = "curved-waterway-b",
    order = "a[ground-rail]-d[curved-rail-b]",
    deconstruction_alternative = "straight-waterway",
    icon = GRAPHICSPATH .. "icons/water_rail.png",
    collision_box = {{-0.75, -2.441}, {0.75, 2.441}}, -- has custommly generated box, but the prototype needs something that is used to generate building smokes
    collision_mask = {layers = {object = true}},  -- waterway_layer added in data-final-fixes
    flags = {"placeable-neutral", "player-creation", "building-direction-8-way"},
    resistances = invincible(),
    minable = {mining_time = 0.2},
    max_health = 200,
    selection_box = {{-1.7, -0.8}, {1.7, 0.8}},
    pictures = new_waterway_pictures("curved-b"),
    placeable_by = {item = "waterway", count = 2},
    extra_planner_penalty = 0.5,
    deconstruction_marker_positions = waterway_8shifts_vector(-0.309, -0.155),
    factoriopedia_alternative = "straight-waterway"
  },
})

