require "waterway-pictures"

-- Support for  Schallfalke's Schall Transport Group mod
local subgroup_shipequip = "water_transport"

if mods["SchallTransportGroup"] then
  subgroup_shipequip = "water_equipment"
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

-----------------------------------------------------------------------------------------

local bridge = table.deepcopy(data.raw["train-stop"]["port"])
bridge.name = "bridge_base"
bridge.icon = GRAPHICSPATH .. "icons/bridge.png"
bridge.icon_size = 64
bridge.localised_description = {"description-template.bridge_base", {"entity-description.bridge_gate"}}
bridge.fast_replaceable_group  = nil
bridge.next_upgrade = nil
bridge.factoriopedia_simulation = nil
bridge.animations = make_4way_animation_from_spritesheet({
  layers = {
    {
      filename = GRAPHICSPATH .. "entity/bridge/bridge-base.png",
      width = 275,
      height = 275,
      direction_count = 4,
      scale = 1.7,
      shift = util.by_pixel(-0.5, 0),
    }
  }
})
data:extend{bridge,
  {
    type = "item",
    name = "bridge_base",
    icon = GRAPHICSPATH .. "icons/bridge.png",
    icon_size = 64,
    subgroup = subgroup_shipequip,
    flags = {},
    order = "a[water-system]-e[bridge_base]",
    place_result = "bridge_base",
    stack_size = 5,
  },
}


----------------------------------------------------------------------------------------------------------------------------------

local invisible_chain_signal = table.deepcopy(data.raw["rail-chain-signal"]["rail-chain-signal"])
invisible_chain_signal.name = "invisible-chain-signal"
invisible_chain_signal.icon = GRAPHICSPATH .. "icons/chain_buoy.png"
invisible_chain_signal.icon_size = 64
invisible_chain_signal.selection_box = nil
invisible_chain_signal.resistances = invincible()
invisible_chain_signal.flags = {"not-blueprintable", "not-deconstructable", "placeable-neutral", "player-creation"}
invisible_chain_signal.hidden = true
invisible_chain_signal.selectable_in_game = false
invisible_chain_signal.collision_mask = {layers = {object = true, rail = true}}  -- waterway added in data-final-fixes
invisible_chain_signal.allow_copy_paste = false
invisible_chain_signal.minable = nil
invisible_chain_signal.ground_picture_set = {
  structure = {
    direction_count = 16,
    filenames = {GRAPHICSPATH .. "blank.png"},
    lines_per_file = 16,
    size = 1,
    frame_count = 1,
  },
  signal_color_to_structure_frame_index = {},
  lights = {},
}
invisible_chain_signal.elevated_picture_set = invisible_chain_signal.ground_picture_set
invisible_chain_signal.rail_piece = nil
invisible_chain_signal.green_light = nil
invisible_chain_signal.orange_light = nil
invisible_chain_signal.red_light = nil
invisible_chain_signal.blue_light = nil
invisible_chain_signal.fast_replaceable_group = nil
invisible_chain_signal.created_smoke = nil

-- tracks used by bridges
local invisible_rail = table.deepcopy(data.raw["straight-rail"]["straight-rail"])
invisible_rail.name = "invisible-rail"
--invisible_rail.icon = GRAPHICSPATH .. "icons/water_rail.png"
--invisible_rail.icon_size = 64
invisible_rail.localised_name = {"entity-name.bridge_base"}
invisible_rail.localised_description = {"entity-description.bridge_base"}

invisible_rail.flags = {"not-blueprintable", "not-deconstructable", "placeable-neutral", "player-creation", "building-direction-8-way"}
invisible_rail.pictures = new_waterway_pictures("straight", true)
invisible_rail.minable = nil
invisible_rail.resistances = invincible()
--invisible_rail.selection_box = nil
--invisible_rail.selectable_in_game = false
invisible_rail.collision_mask = {layers = {object = true}}  -- waterway_layer added in data-final-fixes
invisible_rail.allow_copy_paste = false


-- tracks used by bridges
local legacy_invisible_rail = table.deepcopy(data.raw["legacy-straight-rail"]["legacy-straight-rail"])
legacy_invisible_rail.name = "legacy-invisible-rail"
--legacy_invisible_rail.icon = GRAPHICSPATH .. "icons/water_rail.png"
--legacy_invisible_rail.icon_size = 64
legacy_invisible_rail.flags = {"not-blueprintable", "not-deconstructable", "placeable-neutral", "player-creation", "building-direction-8-way"}
legacy_invisible_rail.pictures = legacy_waterway_pictures("straight_rail", true)
legacy_invisible_rail.minable = nil
legacy_invisible_rail.resistances = invincible()
--legacy_invisible_rail.selection_box = nil
--legacy_invisible_rail.selectable_in_game = false
legacy_invisible_rail.collision_mask = {layers = {object = true}}  -- waterway_layer added in data-final-fixes
legacy_invisible_rail.allow_copy_paste = false


data:extend({invisible_chain_signal, invisible_rail, legacy_invisible_rail})
----------------------------------------------------------------------------------------------------------------------------------


local width_ew = 436
local height_ew = 930
local line_length_ew = 7
local width_ns = 872
local height_ns = 436
local line_length_ns = 3
local bridge_scale = 0.5

local function build_bridge_animation(ori, base_shift, shadow_shift)
  shadow_shift = shadow_shift or {0,0}
  local width = width_ew
  local height = height_ew
  local line_length = line_length_ew
  if ori == "n" or ori == "s" then
    width = width_ns
    height = height_ns
    line_length = line_length_ns
  end

  local anim_speed = 0.38
  return {
    layers = {
      -- This correctly draws the shadow as the bridge is going up (gate closed)
      -- The last frame (fully down) is empty (#1) because otherwise the shadow gets drawn on top of the bridge deck
      {
        filename = GRAPHICSPATH .. "entity/bridge/hr-bridge-" .. ori .. "-shadow.png",
        line_length = line_length,
        animation_speed = anim_speed,
        width = width,
        height = height,
        frame_count = 21,
        frame_sequence = {21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,1},
        draw_as_shadow = true,
        shift = util.by_pixel(base_shift[1] + shadow_shift[1], base_shift[2] + shadow_shift[2]),
        scale = bridge_scale,
      },
      -- This is the lowered bridge shadow, which is empty sprites until the last frame.
      -- With draw_as_shadow=false (and tint serving the same purpose), it will be drawn 
      -- underneath the body sprite for the last frame (normally lowered gates are rendered under shadows)
      {
        filename = GRAPHICSPATH .. "entity/bridge/hr-bridge-" .. ori .. "-shadow.png",
        line_length = line_length,
        animation_speed = anim_speed,
        width = width,
        height = height,
        frame_count = 21,
        frame_sequence = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2},
        shift = util.by_pixel(base_shift[1] + shadow_shift[1], base_shift[2] + shadow_shift[2]),
        scale = bridge_scale,
        tint = {0,0,0,0.5},
      },
      -- This is the bridge body. It goes from fully open (gate closed) to fully flat (gate open)
      {
        filename = GRAPHICSPATH .. "entity/bridge/hr-bridge-" .. ori .. ".png",
        line_length = line_length,
        animation_speed = anim_speed,
        width = width,
        height = height,
        frame_count = 21,
        frame_sequence = {21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2},
        shift = util.by_pixel(base_shift[1], base_shift[2]),
        scale = bridge_scale,
      }
    }
  }
end

local function build_bridge_picture(ori, shiftx, shifty)
  local width = width_ew
  local height = height_ew
  local line_length = line_length_ew
  if ori == "n" or ori == "s" then
    width = width_ns
    height = height_ns
    line_length = line_length_ns
  end

  return {
    layers = {
      -- This is the bridge body in the fully down position for the placement port entity
      {
        filename = GRAPHICSPATH .. "entity/bridge/hr-bridge-" .. ori .. ".png",
        line_length = line_length,
        width = width,
        height = height,
        frame_count = 21,
        frame_sequence = {2},
        shift = util.by_pixel(shiftx, shifty),
        scale = bridge_scale,
      }
    }
  }
end


local shiftX = 53
local shiftY = -17.5

local bridge_gate = {
  type = "gate",
  name = "bridge_gate",
  icon = "__base__/graphics/icons/gate.png",
  localised_name = {"entity-name.bridge_base"},
  localised_description = {"entity-description.bridge_base"},
  flags = {"placeable-neutral","placeable-player", "player-creation"},
  hidden = true,
  minable = {mining_time = 3, result = "bridge_base"},
  max_health = 1000,
  corpse = "straight-rail-remnants",
  dying_explosion = "rail-explosion",
  placeable_by = {item="bridge_base", count=1},
  collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
  collision_mask = {layers={}},
  selection_box = {{-1, -1}, {1, 1}},
  selectable_in_game = true,
  opening_speed = 0.035,
  activation_distance = 5,
  timeout_to_close = 5,
  fadeout_interval = 10,
  resistances =
  {
    {
      type = "physical",
      decrease = 10,
      percent = 50
    },
    {
      type = "impact",
      decrease = 30,
      percent = 60
    },
  },
  
  -- Bridge opens up, wall entity placed on left half of vertical rail adjacent to horizontal waterway
  horizontal_rail_animation_left = build_bridge_animation("w", {40.5, -69}, {0, -17}),
  -- Bridge opens down, wall entity placed on right half of vertical rail adjacent to horizontal waterway
  horizontal_rail_animation_right = build_bridge_animation("e", {8, 36.5}, {0, -21}),
  
  -- Bridge opens to the right, wall entity placed on upper half of horizontal rail adjacent to vertical waterway
  vertical_rail_animation_left = build_bridge_animation("n", {69, -1.5}),
  -- Bridge opens to the left, wall entity placed on lower half of horizontal rail adjacent to vertical waterway
  vertical_rail_animation_right = build_bridge_animation("s", {-22.5, -36}),
  
  -- TODO: Separate the fixed and moving bridge parts, and make the fixed part the rail_base so it doesn't 
  --    accidentally clip over trains. Not very important, also it might break something
  -- vertical_rail_base =
  -- horizontal_rail_base =
  
  -- TODO: Probably not needed, but we could add one or more of the water reflection layers.  
  --    But getting the offsets will be annoying.  The old model has two different reflections for open and closed states.
  
  -- TODO: Figure out why the gate spazzes out and makes so much sound when player walks by
  -- Oh what the heck, now it's not doing it as much?
  opening_sound = {
    filename = "__cargo-ships__/sound/bridge.ogg",
    audible_distance_modifier = 5,
    volume = 0.2,
    aggregation = {max_count=1, progress_threshold=0.75, count_already_playing=true, remove=true},
  },
  closing_sound = {
    filename = "__cargo-ships__/sound/bridge.ogg",
    audible_distance_modifier = 5,
    volume = 0.2,
    aggregation = {max_count=1, progress_threshold=0.75, count_already_playing=true, remove=true},
  },
}

data:extend{ bridge_gate, 
  {
    type = "item",
    name = "bridge_gate",
    icon = GRAPHICSPATH .. "icons/bridge.png",
    icon_size = 64,
    subgroup = subgroup_shipequip,
    flags = {},
    order = "a[water-system]-e[bridge_gate]",
    place_result = "bridge_gate",
    stack_size = 5,
    hidden = true,
  }
}
