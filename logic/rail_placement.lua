
-- Find the up to six different rails that can be connected to this one
local function get_connected_rails(rail)
  local connected_rails = {}
  for _, d in pairs({defines.rail_direction.front, defines.rail_direction.back}) do
    for _, c in pairs({defines.rail_connection_direction.straight, defines.rail_connection_direction.left, defines.rail_connection_direction.right}) do
      local r = rail.get_connected_rail{rail_direction = d, rail_connection_direction = c}
      if r then
        table.insert(connected_rails, r)
      end
    end
  end
  return connected_rails
end

function CheckRailPlacement(entity, player, robot)
  if is_waterway[entity.name] then
    -- Check if this waterway is connected to a non-waterway
    if settings.global["prevent_waterway_rail_connections"].value then
      for _, rail in pairs(get_connected_rails(entity)) do
        if not string.find(rail.name, "%-waterway") then
          if player then
            player.create_local_flying_text{text={"cargo-ship-message.error-connect-rails", "__ENTITY__"..entity.name.."__", "__ENTITY__"..rail.name.."__"}, create_at_cursor=true}
          else
            game.print{"cargo-ship-message.error-connect-rails", "__ENTITY__"..entity.name.."__", "__ENTITY__"..rail.name.."__"}
          end
          entity.destroy()
          return
        end
      end
    end
    entity.destructible = false

  -- Handle non-waterway rail entities
  elseif settings.global["prevent_waterway_rail_connections"].value then
    -- Check if this rail is connected to a waterway
    for _, rail in pairs(get_connected_rails(entity)) do
      if string.find(rail.name, "%-waterway") then
        local refund = entity.prototype.items_to_place_this[1]
        if player then
          player.insert(refund)
          player.create_local_flying_text{text={"cargo-ship-message.error-connect-rails", "__ENTITY__"..entity.name.."__", "__ENTITY__"..rail.name.."__"}, create_at_cursor=true}
        else
          if robot then
            robot.get_inventory(defines.inventory.robot_cargo).insert(refund)
          end
          game.print{"cargo-ship-message.error-connect-rails", "__ENTITY__"..entity.name.."__", "__ENTITY__"..rail.name.."__"}
        end
        entity.destroy()
      return
      end
    end
  end
end
