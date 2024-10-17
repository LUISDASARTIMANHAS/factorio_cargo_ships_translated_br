local is_oil_rig_part = util.list_to_map{"or_pole","or_tank"}

function FixPipette(event)
  -- Pipetting engine, rail boat, or waterway doesn't work
  local player = game.players[event.player_index]
  local cursor = player.cursor_stack
  local selected = player.selected
  local item = event.item
  game.print("pipetted "..item.name)
  local newItemWithQuality
  if is_oil_rig_part[item.name] then
    --cursor.clear()
    if selected then
      local oil_rig = selected.surface.find_entities_filtered{name="oil_rig", position=selected.position, radius = 0.5, limit=1}[1]
      if oil_rig then
        -- Pipette the oil rig instead
        player.pipette_entity(oil_rig)
      end
    end
  elseif storage.ship_engines[item.name] then
    --cursor.clear()
    if selected then
      local otherstock = selected.get_connected_rolling_stock(defines.rail_direction.front) or 
                         selected.get_connected_rolling_stock(defines.rail_direction.back)
      if otherstock then
        -- Pipette the ship body instead
        player.pipette_entity(otherstock)
      end
    end
  elseif is_waterway[item.name] then
    -- When the setting "Pick Ghost if no items are available" is not enabled then
    -- it's never possible to pipette a waterway. There's no way to check if this
    -- setting already put the correct item in the cursor though
    -- so instead we will set the cursor everytime.
    if player.clear_cursor() then
      -- The cursor is always clear when this event is fired due to the
      -- nature of the pipette function. But make sure it's clear anyway.
      player.cursor_ghost = {name="waterway"}
    end
  end
end
