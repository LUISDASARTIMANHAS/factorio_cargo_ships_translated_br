local floating_pole = table.deepcopy(data.raw["electric-pole"]["big-electric-pole"])
floating_pole.name = "floating-electric-pole"
floating_pole.icon = GRAPHICSPATH .. "icons/floating_pole.png"
floating_pole.icon_size = 64
floating_pole.minable = {mining_time = 0.5, result = "floating-electric-pole"}
floating_pole.collision_mask = {layers = {ground_tile = true, object = true}}
floating_pole.maximum_wire_distance = 48
floating_pole.supply_area_distance = 0
floating_pole.fast_replaceable_group = nil
floating_pole.next_upgrade = nil
floating_pole.pictures = {
  layers = {
    {
      filename = GRAPHICSPATH .. "entity/floating_electric_pole/hr-floating-electric-pole.png",
      priority = "high",
      width = 336,
      height = 330,
      scale = 0.5,
      direction_count = 4,
      shift = util.by_pixel(51, -58),
    },
    {
      filename = GRAPHICSPATH .. "entity/floating_electric_pole/hr-floating-electric-pole-shadows.png",
      priority = "high",
      width = 336,
      height = 330,
      scale = 0.5,
      direction_count = 4,
      shift = util.by_pixel(51, -58),
      draw_as_shadow = true,
    },
  }
}
floating_pole.water_reflection =
  {
    pictures = {
      {
        filename = GRAPHICSPATH .. "entity/floating_electric_pole/floating-electric-pole_water_reflection.png",
        width = 34,
        height = 33,
        shift = util.by_pixel(0, 58),
        scale = 5
      },
      {
        filename = GRAPHICSPATH .. "entity/floating_electric_pole/floating-electric-pole_water_reflection.png",
        width = 34,
        height = 33,
        x = 34,
        shift = util.by_pixel(0, 58),
        scale = 5
      },
      {
        filename = GRAPHICSPATH .. "entity/floating_electric_pole/floating-electric-pole_water_reflection.png",
        width = 34,
        height = 33,
        x = 68,
        shift = util.by_pixel(0, 58),
        scale = 5
      },
      {
        filename = GRAPHICSPATH .. "entity/floating_electric_pole/floating-electric-pole_water_reflection.png",
        width = 34,
        height = 33,
        x = 102,
        shift = util.by_pixel(0, 58),
        scale = 5
      },

    },
    rotate = false,
    orientation_to_variation = true,
  }
floating_pole.connection_points = {
  { -- Vertical
    shadow = {
      copper = {2.78, -0.5},
      green = {1.875, -0.5},
      red = {3.69, -0.5}
    },
    wire = {
      copper = {0, -4.05},
      green = {-0.59375, -4.05},
      red = {0.625, -4.05}
    }
  },
  { -- Turned right
    shadow = {
      copper = {3.1, -0.648},
      green = {2.3, -1.144},
      red = {3.8, -0.136}
    },
    wire = {
      copper = {-0.0525, -3.906},
      green = {-0.48, -4.179},
      red = {0.36375, -3.601}
    }
  },
  { -- Horizontal
    shadow = {
      copper = {2.9, -0.564},
      green = {3.0, -1.316},
      red = {3.0, 0.152}
    },
    wire = {
      copper = {-0.09375, -3.901},
      green = {-0.09375, -4.331},
      red = {-0.09375, -3.420}
    }
  },
  { -- Turned left
    shadow = {
      copper = {3.3, -0.542},
      green = {3.1, -1.058},
      red = {2.35, -0.035}
    },
    wire = {
      copper = {-0.0625, -3.980},
      green = {0.375, -4.273},
      red = {-0.46875, -3.656}
    }
  }
}
for _,v in pairs(floating_pole.connection_points) do
  v.shadow.copper[1] = v.shadow.copper[1] + 0.74
  v.shadow.green[1] = v.shadow.green[1] + 0.74
  v.shadow.red[1] = v.shadow.red[1] + 0.74
  v.shadow.copper[2] = v.shadow.copper[2] + 0.5
  v.shadow.green[2] = v.shadow.green[2] + 0.5
  v.shadow.red[2] = v.shadow.red[2] + 0.5
end

---------------------------------------------------------------------------------------------------------------
local buoy = {
  type = "rail-signal",
  name = "buoy",
  icon = GRAPHICSPATH .. "icons/buoy.png",
  collision_mask = {layers = {object = true, rail = true}},  -- waterway_layer added in data-final-fixes
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
    circuit_connector = circuit_connector_definitions["rail-signal"],
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
  collision_mask = {layers = {object = true, rail = true}},  -- waterway_layer will be added in final-fixes
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
          filename = GRAPHICSPATH .. "entity/chain_buoy/hr-chain-buoys-base_tlc-16.png",
          width = 230,
          height = 230,
          frame_count = 1,
          repeat_count = 4,
          direction_count = 16,
          scale = 0.5
        },
        {
          filename = GRAPHICSPATH .. "entity/chain_buoy/hr-chain-buoys-shadow_tlc-16.png",
          width = 230,
          height = 230,
          frame_count = 1,
          repeat_count = 4,
          direction_count = 16,
          scale = 0.5,
          draw_as_shadow = true,
        },
        {
          filename = GRAPHICSPATH .. "entity/chain_buoy/hr-chain-buoys-lights_tlc-16.png",
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
    circuit_connector = circuit_connector_definitions["rail-chain-signal"],
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

data:extend({floating_pole, buoy, chain_buoy, port})
