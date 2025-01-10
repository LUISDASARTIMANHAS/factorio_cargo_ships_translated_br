
if not settings.startup["floating_pole_enabled"].value then return end

local floating_pole = table.deepcopy(data.raw["electric-pole"]["big-electric-pole"])
floating_pole.name = "floating-electric-pole"
floating_pole.icon = GRAPHICSPATH .. "icons/floating_pole.png"
floating_pole.icon_size = 64
floating_pole.minable = {mining_time = 0.5, result = "floating-electric-pole"}
floating_pole.collision_mask = {layers = {ground_tile = true, object = true, rail_support = true}}
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
floating_pole.water_reflection = {
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

data:extend{floating_pole}
