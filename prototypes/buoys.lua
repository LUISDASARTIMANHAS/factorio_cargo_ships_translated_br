-------
-- Copied from __core__/lualib/circuit-connector-generated-definitions.lua
local function get_variation_with_shifting(variation, offset_x, offset_y)
  return {
    variation = variation,
    main_offset = util.by_pixel(offset_x, offset_y),
    shadow_offset = util.by_pixel(offset_x, offset_y),
    show_shadow = true
  }
end
-------

---------------------------------------------------------------------------------------------------------------
local buoy_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        get_variation_with_shifting(19, -27, -4),  -- North
        get_variation_with_shifting(19, -24, -16),
        get_variation_with_shifting(19, -18, -26),
        get_variation_with_shifting(19, -7, -33),
        get_variation_with_shifting(19, 5, -36),  -- East
        get_variation_with_shifting(19, 17, -33),
        get_variation_with_shifting(19, 27, -26),
        get_variation_with_shifting(19, 35, -16),
        get_variation_with_shifting(19, 37, -4),  -- South
        get_variation_with_shifting(19, 34, 8),
        get_variation_with_shifting(19, 27, 19),
        get_variation_with_shifting(19, 17, 26),
        get_variation_with_shifting(19, 5, 28),  -- West
        get_variation_with_shifting(19, -7, 26),
        get_variation_with_shifting(19, -18, 19),
        get_variation_with_shifting(19, -25, 8),
      }
    )

local buoy = {
  type = "rail-signal",
  name = "buoy",
  icon = GRAPHICSPATH .. "icons/buoy.png",
  collision_mask = {layers = {object = true, is_lower_object = true}},  -- waterway_layer added in data-final-fixes
  flags = {"placeable-neutral", "player-creation", "building-direction-16-way", "filter-directions"},
  fast_replaceable_group = "buoy-signal",
  minable = {mining_time = 0.5, result = "buoy"},
  max_health = 100,
  dying_explosion = "rail-signal-explosion",
  damaged_trigger_effect = data.raw["rail-signal"]["rail-signal"].damaged_trigger_effect,
  collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
  selection_box = {{-1.5, -0.5}, {-0.5, 0.5}},
  --selection_box = {{-1.35, -0.65}, {-0.35, 0.35}}  -- This one doesn't work and ends up shifted oddly
  --selection_box = {{-0.5, 0.5}, {-0.5, 0.5}}  -- This makes selection break completely, don't know why

  open_sound = data.raw["rail-signal"]["rail-signal"].open_sound,
  close_sound = data.raw["rail-signal"]["rail-signal"].close_sound,
  
  ground_picture_set = {
    structure = {
      layers = {
        {
          filename = GRAPHICSPATH .. "entity/buoy/hr-buoy-base-16.png",
          width = 230,
          height = 230,
          frame_count = 1,
          repeat_count = 3,
          direction_count = 16,
          scale = 0.5
        },
        {
          filename = GRAPHICSPATH .. "entity/buoy/hr-buoy-shadow-16.png",
          width = 230,
          height = 230,
          frame_count = 1,
          repeat_count = 3,
          direction_count = 16,
          scale = 0.5,
          draw_as_shadow = true,
        },
        {
          filename = GRAPHICSPATH .. "entity/buoy/hr-buoy-lights-16.png",
          width = 230,
          height = 230,
          frame_count = 3,
          direction_count = 16,
          shift = {0, -0.5},
          scale = 0.5,
          draw_as_glow = true,
        },
      }
    },
    structure_align_to_animation_index =
    {
      --  X0Y0, X1Y0, X0Y1, X1Y1
      --  Left turn  | Straight/Multi |  Right turn
       0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0, -- North
       1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
       2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
       3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
       4,  4,  4,  4,   4,  4,  4,  4,   4,  4,  4,  4, -- East
       5,  5,  5,  5,   5,  5,  5,  5,   5,  5,  5,  5,
       6,  6,  6,  6,   6,  6,  6,  6,   6,  6,  6,  6,
       7,  7,  7,  7,   7,  7,  7,  7,   7,  7,  7,  7,
       8,  8,  8,  8,   8,  8,  8,  8,   8,  8,  8,  8, -- South
       9,  9,  9,  9,   9,  9,  9,  9,   9,  9,  9,  9,
      10, 10, 10, 10,  10, 10, 10, 10,  10, 10, 10, 10,
      11, 11, 11, 11,  11, 11, 11, 11,  11, 11, 11, 11,
      12, 12, 12, 12,  12, 12, 12, 12,  12, 12, 12, 12, -- West
      13, 13, 13, 13,  13, 13, 13, 13,  13, 13, 13, 13,
      14, 14, 14, 14,  14, 14, 14, 14,  14, 14, 14, 14,
      15, 15, 15, 15,  15, 15, 15, 15,  15, 15, 15, 15,
    },
    signal_color_to_structure_frame_index =
    {
      green  = 0,
      yellow = 1,
      red    = 2,
    },
    selection_box_shift =
    {
      -- Given this affects SelectionBox, it is part of game state.
      -- NOTE: Those shifts are not processed (yet) by PrototypeAggregateValues::calculateBoxExtensionForSelectionBoxSearch()
      --    so if you exceed some reasonable values, a signal may become unselectable
      -- NOTE: only applies to normal selection box. It is ignored for chart selection box
      --
      --  X0Y0, X1Y0, X0Y1, X1Y1
      -- North -- 0
      {0,0},{0,0},{0,0},{0,0}, --  Left turn
      {0,0},{0,0},{0,0},{0,0}, --  Straight/Multi
      {0,0},{0,0},{0,0},{0,0}, --  Right turn

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      -- East
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      -- South
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      -- West
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
    },
    lights =
    {
      green  = { light = {intensity = 0.2, size = 4, color={r=0, g=1,   b=0 }, shift = {0, -0.65}}, shift = { -1, 0 }},
      yellow = { light = {intensity = 0.3, size = 4, color={r=1, g=0.5, b=0 }, shift = {0, -0.65}}, shift = { -1, 0 }},
      red    = { light = {intensity = 0.3, size = 4, color={r=1, g=0,   b=0 }, shift = {0, -0.65}}, shift = { -1, 0 }},
    },
    circuit_connector = buoy_connector
  },
  elevated_picture_set = data.raw["rail-signal"]["rail-signal"].elevated_picture_set,
  circuit_wire_max_distance = default_circuit_wire_max_distance,

  default_red_output_signal = {type = "virtual", name = "signal-red"},
  default_orange_output_signal = {type = "virtual", name = "signal-yellow"},
  default_green_output_signal = {type = "virtual", name = "signal-green"},
  
  water_reflection = 
  {
    pictures =
    {
      filename = GRAPHICSPATH .. "entity/buoy/buoy_water_reflection-16.png",
      width = 23,
      height = 23,
      variation_count = 16,
      line_length = 1,
      scale = 5
    },
    rotate = false,
    orientation_to_variation = true
  }
}

---------------------------------------------------------------------------------------------------------------


local chain_buoy = {
  type = "rail-chain-signal",
  name = "chain_buoy",
  icon = GRAPHICSPATH .. "icons/chain_buoy.png",
  flags = {"placeable-neutral", "player-creation", "building-direction-16-way", "filter-directions"},
  collision_mask = {layers = {object = true, is_lower_object = true}},  -- waterway_layer will be added in data-final-fixes
  fast_replaceable_group = "buoy-signal",
  minable = {mining_time = 0.5, result = "chain_buoy"},
  max_health = 100,
  dying_explosion = "rail-chain-signal-explosion",
  collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
  selection_box = {{-1.5, -0.5}, {-0.5, 0.5}},
  damaged_trigger_effect = data.raw["rail-chain-signal"]["rail-chain-signal"].damaged_trigger_effect,
  open_sound = data.raw["rail-chain-signal"]["rail-chain-signal"].open_sound,
  close_sound = data.raw["rail-chain-signal"]["rail-chain-signal"].close_sound,
  ground_picture_set = 
  {
    structure =
    {
      layers = {
        {
          filename = GRAPHICSPATH .. "entity/chain_buoy/hr-chain-buoys-base-16.png",
          width = 230,
          height = 230,
          frame_count = 1,
          repeat_count = 4,
          direction_count = 16,
          scale = 0.5
        },
        {
          filename = GRAPHICSPATH .. "entity/chain_buoy/hr-chain-buoys-shadow-16.png",
          width = 230,
          height = 230,
          frame_count = 1,
          repeat_count = 4,
          direction_count = 16,
          scale = 0.5,
          draw_as_shadow = true,
        },
        {
          filename = GRAPHICSPATH .. "entity/chain_buoy/hr-chain-buoys-lights-16.png",
          width = 230,
          height = 230,
          frame_count = 4,
          direction_count = 16,
          scale = 0.5,
          draw_as_glow = true,
        },
      }
    },
    structure_render_layer = "floor-mechanics",
    structure_align_to_animation_index =
    {
      --  X0Y0, X1Y0, X0Y1, X1Y1
      --  Left turn  | Straight/Multi |  Right turn
       0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0, -- North
       1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
       2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
       3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
       4,  4,  4,  4,   4,  4,  4,  4,   4,  4,  4,  4, -- East
       5,  5,  5,  5,   5,  5,  5,  5,   5,  5,  5,  5,
       6,  6,  6,  6,   6,  6,  6,  6,   6,  6,  6,  6,
       7,  7,  7,  7,   7,  7,  7,  7,   7,  7,  7,  7,
       8,  8,  8,  8,   8,  8,  8,  8,   8,  8,  8,  8, -- South
       9,  9,  9,  9,   9,  9,  9,  9,   9,  9,  9,  9,
      10, 10, 10, 10,  10, 10, 10, 10,  10, 10, 10, 10,
      11, 11, 11, 11,  11, 11, 11, 11,  11, 11, 11, 11,
      12, 12, 12, 12,  12, 12, 12, 12,  12, 12, 12, 12, -- West
      13, 13, 13, 13,  13, 13, 13, 13,  13, 13, 13, 13,
      14, 14, 14, 14,  14, 14, 14, 14,  14, 14, 14, 14,
      15, 15, 15, 15,  15, 15, 15, 15,  15, 15, 15, 15,
    },
    signal_color_to_structure_frame_index =
    {
      none   = 0,
      red    = 0,
      yellow = 1,
      green  = 2,
      blue   = 3,
    },
    selection_box_shift =
    {
      -- Given this affects SelectionBox, it is part of game state.
      -- NOTE: Those shifts are not processed (yet) by PrototypeAggregateValues::calculateBoxExtensionForSelectionBoxSearch()
      --    so if you exceed some reasonable values, a signal may become unselectable
      -- NOTE: only applies to normal selection box. It is ignored for chart selection box
      --
      --  X0Y0, X1Y0, X0Y1, X1Y1
      -- North -- 0
      {0,0},{0,0},{0,0},{0,0}, --  Left turn
      {0,0},{0,0},{0,0},{0,0}, --  Straight/Multi
      {0,0},{0,0},{0,0},{0,0}, --  Right turn

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      -- East
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      -- South
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      -- West
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},

      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
      {0,0},{0,0},{0,0},{0,0},
    },
    lights =
    {
      green  = { light = {intensity = 0.2, size = 4, color={r=0,   g=1,   b=0 }, shift = {0, -0.5}}, shift = { -1, 0 }},
      yellow = { light = {intensity = 0.3, size = 4, color={r=1,   g=0.5, b=0 }, shift = {0, -0.5}}, shift = { -1, 0 }},
      red    = { light = {intensity = 0.3, size = 4, color={r=1,   g=0,   b=0 }, shift = {0, -0.5}}, shift = { -1, 0 }},
      blue   = { light = {intensity = 0.2, size = 4, color={r=0.4, g=0.4, b=1 }, shift = {0, -0.5}}, shift = { -1, 0 }},
    },
    circuit_connector = buoy_connector
  },

  elevated_picture_set = data.raw["rail-chain-signal"]["rail-chain-signal"].elevated_picture_set,
  circuit_wire_max_distance = default_circuit_wire_max_distance,

  default_red_output_signal = {type = "virtual", name = "signal-red"},
  default_orange_output_signal = {type = "virtual", name = "signal-yellow"},
  default_green_output_signal = {type = "virtual", name = "signal-green"},
  default_blue_output_signal = {type = "virtual", name = "signal-blue"},
  
  water_reflection = 
  {
    pictures =
    {
      filename = GRAPHICSPATH .. "entity/chain_buoy/chain-buoys-water-reflection-16.png",
      width = 52,
      height = 41,
      variation_count = 16,
      line_length = 1,
      scale = 5
    },
    rotate = false,
    orientation_to_variation = true
  }
}

---------------------------------------------------------------------------------------------------------------

local port = table.deepcopy(data.raw["train-stop"]["train-stop"])
port.name = "port"
port.icon = GRAPHICSPATH .. "icons/port.png"
port.icon_size = 64
port.minable = {mining_time = 1, result = "port"}
port.rail_overlay_animations = nil
port.collision_mask = {layers = {object = true}}
port.collision_box = {{-0.01, -0.9}, {1.9, 0.9}}
port.selection_box = {{-0.01, -0.9}, {1.9, 0.9}}

local function maker_layer_port(xshift, yshift)
  return {
    layers = {
      {
        filename = GRAPHICSPATH .. "entity/port/hr-port.png",
        width = 80,
        height = 300,
        shift = util.by_pixel(xshift, yshift),
        scale = 0.5,
      },
      {
        filename = GRAPHICSPATH .. "entity/port/hr-port-shadow.png",
        width = 300,
        height = 80,
        shift = util.by_pixel(xshift, yshift),
        scale = 0.5,
        draw_as_shadow = true,
      },
    }
  }
end
port.animations = {
  north = maker_layer_port(30,0),
  east = maker_layer_port(0,30),
  south = maker_layer_port(-30,0),
  west = maker_layer_port(0,-30),
}

local function portwaterref(xshift, yshift)
  return {
    filename = GRAPHICSPATH .. "entity/port/port_water_reflection.png",
    width = 30,
    height = 30,
    shift = util.by_pixel(xshift, yshift),
    scale = 5
  }
end
port.water_reflection = {
  pictures = {
    portwaterref(30, 0),
    portwaterref(0, 30),
    portwaterref(-30, 0),
    portwaterref(0, -30),
  },
  rotate = false,
  orientation_to_variation = true
}
port.top_animations = nil
port.light1 =
{
  light = {intensity = 0.4, size = 4, color = {r = 1.0, g = 1.0, b = 1.0}},
  picture = {
    north = {
      filename = GRAPHICSPATH .. "entity/port/hr-port-light.png",
      width = 44,
      height = 24,
      scale = 0.5,
      tint = {1, 0.95, 0},
      shift = util.by_pixel(30, -69),
    },
    east = {
      filename = GRAPHICSPATH .. "entity/port/hr-port-light.png",
      width = 44,
      height = 24,
      scale = 0.5,
      tint = {1, 0.95, 0},
      shift = util.by_pixel(0, -39),
    },
    south = {
      filename = GRAPHICSPATH .. "entity/port/hr-port-light.png",
      width = 44,
      height = 24,
      scale = 0.5,
      tint = {1, 0.95, 0},
      shift = util.by_pixel(-30, -69),
    },
    west = {
      filename = GRAPHICSPATH .. "entity/port/hr-port-light.png",
      width = 44,
      height = 24,
      scale = 0.5,
      tint = {1, 0.95, 0},
      shift = util.by_pixel(0, -99),
    },
  },
  red_picture = {
    north = {
      filename = GRAPHICSPATH .. "entity/port/hr-port-light.png",
      width = 44,
      height = 24,
      scale = 0.5,
      tint = {1, 0.2, 0.2},
      shift = util.by_pixel(30, -69),
    },
    east = {
      filename = GRAPHICSPATH .. "entity/port/hr-port-light.png",
      width = 44,
      height = 24,
      scale = 0.5,
      tint = {1, 0.2, 0.2},
      shift = util.by_pixel(0, -39),
    },
    south = {
      filename = GRAPHICSPATH .. "entity/port/hr-port-light.png",
      width = 44,
      height = 24,
      scale = 0.5,
      tint = {1, 0.2, 0.2},
      shift = util.by_pixel(-30, -69),
    },
    west = {
      filename = GRAPHICSPATH .. "entity/port/hr-port-light.png",
      width = 44,
      height = 24,
      scale = 0.5,
      tint = {1, 0.2, 0.2},
      shift = util.by_pixel(0, -99),
    },
  }
}
port.light2 = nil
port.working_sound = nil
port.factoriopedia_simulation = nil

-- build a new 4 way definition for port
-- show_shadow=false prevents floating circuit box shadows, but wire shadows end nowhere
-- once port shadows are done set show_shadow=true and tweak shadow_offset, should be around (-30, 10) from  main_offset
circuit_connector_definitions["cargo-ships-port"] = circuit_connector_definitions.create_vector(
  universal_connector_template,
  {
    { variation = 18, main_offset = util.by_pixel(37, -61), shadow_offset = util.by_pixel(37, -61), show_shadow = false },
    { variation = 18, main_offset = util.by_pixel(-1.5, -20), shadow_offset = util.by_pixel(-1.5, -20), show_shadow = false },
    { variation = 18, main_offset = util.by_pixel(-39, -59), shadow_offset = util.by_pixel(-39, -59), show_shadow = false },
    { variation = 18, main_offset = util.by_pixel(-1.5, -98), shadow_offset = util.by_pixel(-1.5, -98), show_shadow = false }
  }
)
-- let factorio generate sprite connector offset per wire from definition
port.circuit_wire_connection_points = circuit_connector_definitions["cargo-ships-port"].points
port.circuit_connector_sprites = circuit_connector_definitions["cargo-ships-port"].sprites

data:extend({buoy, chain_buoy, port})
