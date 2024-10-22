
-- Find all the legacy-straight-waterway entities that used to be bridge_crossing and make them minable
local count = 0
for _, surface in pairs(game.surfaces) do
  for _, entity in pairs(surface.find_entities_filtered{name="legacy-straight-waterway"}) do
    entity.minable = true
    count = count + 1
  end
end
log("Fixed "..tostring(count).." waterways that were unminable.")
