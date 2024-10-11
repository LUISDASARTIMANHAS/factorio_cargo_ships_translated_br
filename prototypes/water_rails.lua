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

local ground_rail_render_layers =
{
  stone_path_lower = "rail-stone-path-lower",
  stone_path = "rail-stone-path",
  tie = "rail-tie",
  screw = "rail-screw",
  metal = "rail-metal"
}

local rail_segment_visualisation_endings =
{
  filename = "__base__/graphics/entity/rails/rail/rail-segment-visualisations-endings.png",
  priority = "extra-high",
  flags = { "low-object" },
  width = 64,
  height = 64,
  scale = 0.5,
  direction_count = 16,
  frame_count = 6,
}


railpictures = function(invisible)
  return railpicturesinternal({
    {"metals",                                  "metals"},
    {"backplates",                              "backplates"},
    {"ties",                                    "ties"},
    {"stone_path",                              "stone-path"},
    {"segment_visualisation_middle",            "segment-visualisation-middle"},
    {"segment_visualisation_ending_front",      "segment-visualisation-ending-1"},
    {"segment_visualisation_ending_back",       "segment-visualisation-ending-2"},
    {"segment_visualisation_continuing_front",  "segment-visualisation-continuing-1"},
    {"segment_visualisation_continuing_back",   "segment-visualisation-continuing-2"}
  },
  invisible)
end

railpicturesinternal = function(elems, invisible)
  local railBlockKeys = {
    segment_visualisation_middle = true,
    segment_visualisation_ending_front = true,
    segment_visualisation_ending_back = true,
    segment_visualisation_continuing_front = true,
    segment_visualisation_continuing_back = true
  }

  local keys = {
    {"straight_rail", "horizontal",             128, 128},
    {"straight_rail", "vertical",               128, 128},

    {"straight_rail", "diagonal-left-top",      128, 128},
    {"straight_rail", "diagonal-right-top",     128, 128},
    {"straight_rail", "diagonal-right-bottom",  128, 128},
    {"straight_rail", "diagonal-left-bottom",   128, 128},

    {"curved_rail",   "vertical-left-top",      256, 512},
    {"curved_rail",   "vertical-right-top",     256, 512},
    {"curved_rail",   "vertical-right-bottom",  256, 512},
    {"curved_rail",   "vertical-left-bottom",   256, 512},

    {"curved_rail",   "horizontal-left-top",    512, 256},
    {"curved_rail",   "horizontal-right-top",   512, 256},
    {"curved_rail",   "horizontal-right-bottom",512, 256},
    {"curved_rail",   "horizontal-left-bottom", 512, 256}
  }
  local res = {}

  --postfix = ""
  local tint = {1, 1, 1, 1}
  local blend_mode = "additive"
  if settings.startup["use_dark_blue_waterways"].value then
    --tint = {1, 1, 1, 1}
    blend_mode = "normal"
    --tint = {1, 1, 1, 0.5}
    --postfix = "-dark"
  end

  for _ , key in ipairs(keys) do
    local part = {}
    local dashkey = key[1]:gsub("_", "-")
    for _ , elem in ipairs(elems) do
      if(elem[1] == "metals" and not invisible) then
        part[elem[1]] = {
          layers = {
            --[[{
              filename = string.format(GRAPHICSPATH .. "entity/%s/%s-%s-%s.png", dashkey, dashkey, key[2], elem[2]),
              priority = "low",
              width = key[3],
              height = key[4],
              variation_count = 1,
              --tint = {0, 0, 0, 0.2},
              shift = util.by_pixel(1,1),
              scale = 0.5,
              draw_as_shadow = true,
            },]]
            {
              filename = string.format(GRAPHICSPATH .. "entity/%s/%s-%s-%s.png", dashkey, dashkey, key[2], elem[2]),
              priority = "extra-high",
              width = key[3],
              height = key[4],
              variation_count = 1,
              tint = tint,
              blend_mode = blend_mode,
              scale = 0.5,
            },
          }
        }
      elseif(railBlockKeys[elem[1]] ~= nil) then
        part[elem[1]] = {
          filename = string.format(GRAPHICSPATH .. "entity/%s/%s-%s-%s.png", dashkey, dashkey, key[2], elem[2]),
          priority = "extra-high",
          width = key[3],
          height = key[4],
          variation_count = 1,
          scale = 0.5,
        }
      else
        part[elem[1]] = emptypic
      end
    end

    dashkey2 = key[2]:gsub("-", "_")
    res[key[1] .. "_" .. dashkey2] = part
  end
  res["rail_endings"] = {
    sheets = {
      emptypic,
      emptypic
    }
  }
  return res
end


-- mapcolor doesn't work yet on rails for some reason
data:extend({
  {
    type = "legacy-straight-rail",
    name = "legacy-straight-waterway",
    icon = GRAPHICSPATH .. "icons/water_rail.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation", "building-direction-8-way"},
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

