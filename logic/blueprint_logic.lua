local is_oil_rig = util.list_to_map{"or_pole","or_tank"}

function FixPipette(e)
  -- Pipetting engine, rail boat, or waterway doesn't work
  local item = e.item
  if item and item.valid then
    local player = game.get_player(e.player_index)
    local selected = player.selected
    local cursor = player.cursor_stack
    --game.print("Event.item = "..item.name..", used_cheat_mode = "..tostring(e.used_cheat_mode))
    --game.print(cursor)
    
    if storage.ship_bodies[item.name] or storage.boat_bodies[item.name] or storage.ship_engines[item.name] or is_oil_rig[item.name] then
      -- Get the placing-item of this ship or boat
      local new_item = (storage.boat_bodies[item.name] and storage.boat_bodies[item.name].placing_item) or
                       (storage.ship_bodies[item.name] and storage.ship_bodies[item.name].placing_item) or
                       (is_oil_rig[item.name] and "oil_rig")
      -- See what ship is coupled to this ship_engine
      if not new_item and selected and storage.ship_engines[selected.name] and #selected.train.carriages == 2 then
        for i,c in pairs(selected.train.carriages) do
          if storage.ship_bodies[c.name] then
            new_item = storage.ship_bodies[c.name].placing_item
            break
          end
        end
      end

      if new_item then
        --game.print("New item: " .. new_item)
        -- The following logic copied from Robot256Lib.
        if cursor.valid_for_read == true and e.used_cheat_mode == false then
          -- Give valid items to replace boat/rig parts that player accidentally had in inventory (when not in cheat mode)
          --game.print("cursor valid with "..cursor.name.." and no cheat mode???")
          cursor.set_stack{name=new_item, count=cursor.count}
        else
          -- Check for boat in inventory
          local inventory = player.get_main_inventory()
          if inventory and inventory.valid then
            local new_stack = inventory.find_item_stack(new_item)
            --game.print(new_stack)
            cursor.set_stack(new_stack)  -- Set cursor with inventory contents OR clear it if none available
            if not cursor.valid_for_read then
              if player.cheat_mode==true then
                --game.print("fine you win")
                -- If none in inventory and cheat mode enabled, give stack of correct items
                cursor.set_stack{name=new_item, count=prototypes.item[new_item].stack_size}
              else
                --game.print("no cheating")
                -- Not in cheat mode and couldn't find item, give ghost
                player.clear_cursor()
                player.cursor_ghost = new_item
              end
            else
              -- Found items in inventory. Remove it from inventory now that it is in the cursor.
              inventory.remove(new_stack)
            end
          else
            --game.print("map view")
            -- In map view, give ghost
            player.clear_cursor()
            player.cursor_ghost = new_item
          end
        end
      else
        -- Can't find valid item, this must be an invisible one
        cursor.clear()
      end

    elseif selected and is_waterway[selected.name] then
      -- When the setting "Pick Ghost if no items are available" is not enabled then
      -- it's never possible to pipette a waterway. There's no way to check if this
      -- setting already put the correct item in the cursor though
      -- so instead we will set the cursor everytime.
      if player.clear_cursor() then
        -- The cursor is always clear when this event is fired due to the
        -- nature of the pipette function. But make sure it's clear anyway.
        player.cursor_ghost = "waterway"
      end

    elseif selected and is_oil_rig[selected.name] then
      if player.clear_cursor() then
        -- The cursor is always clear when this event is fired due to the
        -- nature of the pipette function. But make sure it's clear anyway.
        player.cursor_ghost = "oil_rig"
      end
    
    end
  end
end
