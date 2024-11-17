data:extend{
  {
    type = "custom-input",
    name = "enter-vehicle",
    enabled_while_spectating = true,
    order = "a",
    key_sequence = "",
    linked_game_control = "toggle-driving",
  },
  {
    type = "custom-input",
    name = "give-waterway",
    localised_name = {"item-name.waterway"},
    key_sequence = "ALT + W",
    consuming = "none",
  },
  {
    type = "shortcut",
    name = "give-waterway",
    localised_name = {"item-name.waterway"},
    order = "",
    action = "lua",
    associated_control_input = "give-waterway",
    technology_to_unlock = "automated_water_transport",
    --style = "blue",
    icon = GRAPHICSPATH .. "icons/waterway-shortcut-x56.png",
    icon_size = 56,
    small_icon = GRAPHICSPATH .. "icons/waterway-shortcut-x24.png",
    small_icon_size = 24,
  }
}
