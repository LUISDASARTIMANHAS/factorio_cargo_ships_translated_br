data:extend({
  {
    type = "recipe",
    name = "boat",
    enabled = false,
    energy_required = 3,
    ingredients = {
      {type="item", name="steel-plate", amount=40},
      {type="item", name="engine-unit", amount=15},
      {type="item", name="iron-gear-wheel", amount=15},
      {type="item", name="electronic-circuit", amount=6}
    },
    results = {{type="item", name="boat", amount=1}},
  },
  {
    type = "recipe",
    name = "cargo_ship",
    enabled = false,
    energy_required = 15,
    ingredients = {
      {type="item", name="steel-plate", amount=220},
      {type="item", name="engine-unit", amount=50},
      {type="item", name="iron-gear-wheel", amount=60},
      {type="item", name="electronic-circuit", amount=20}
    },
    results = {{type="item", name="cargo_ship", amount=1}},
  },
  {
    type = "recipe",
    name = "oil_tanker",
    enabled = false,
    energy_required = 15,
    ingredients = {
      {type="item", name="steel-plate", amount=180},
      {type="item", name="engine-unit", amount=50},
      {type="item", name="iron-gear-wheel", amount=60},
      {type="item", name="electronic-circuit", amount=20},
      {type="item", name="storage-tank", amount=6}
    },
    results = {{type="item", name="oil_tanker", amount=1}},
  },
  {
    type = "recipe",
    name = "port",
    enabled = false,
    energy_required = 2,
    ingredients = {
      {type="item", name="electronic-circuit", amount=5},
      {type="item", name="iron-plate", amount=10},
      {type="item", name="steel-plate", amount=5}
    },
    results = {{type="item", name="port", amount=1}},
  },
  {
    type = "recipe",
    name = "floating-electric-pole",
    enabled = false,
    energy_required = 2,
    ingredients = {
      {type="item", name="empty-barrel", amount=4},
      {type="item", name="big-electric-pole", amount=1},
      {type="item", name="iron-plate", amount=5}
    },
    results = {{type="item", name="floating-electric-pole", amount=1}},
  },
  {
    type = "recipe",
    name = "buoy",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type="item", name="empty-barrel", amount=2},
      {type="item", name="electronic-circuit", amount=2},
      {type="item", name="iron-plate", amount=5}
    },
    results = {{type="item", name="buoy", amount=1}},
  },
  {
    type = "recipe",
    name = "chain_buoy",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type="item", name="empty-barrel", amount=2},
      {type="item", name="electronic-circuit", amount=2},
      {type="item", name="iron-plate", amount=5}
    },
    results = {{type="item", name="chain_buoy", amount=1}},
  },
  {
    type = "recipe",
    name = "bridge_base",
    enabled = false,
    energy_required = 15,
    ingredients = {
      {type="item", name="advanced-circuit", amount=15},
      {type="item", name="steel-plate", amount=60},
      {type="item", name="iron-gear-wheel", amount=30},
      {type="item", name="rail", amount=10},
    },
    results = {{type="item", name="bridge_base", amount=1}},
  },

})

if settings.startup["deep_oil"].value then
  data:extend{
    {
      type = "recipe",
      name = "oil_rig",
      enabled = false,
      energy_required = 30,
      ingredients = {
        {type="item", name="pumpjack", amount=5},
        {type="item", name="boiler", amount=1},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="steel-plate", amount=150},
        {type="item", name="electronic-circuit", amount=75},
        {type="item", name="pipe", amount=75}
      },
      results = {{type="item", name="oil_rig", amount=1}},
    },
  }
end
