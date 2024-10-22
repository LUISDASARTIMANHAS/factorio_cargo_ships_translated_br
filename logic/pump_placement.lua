local PUMP_NTH_TICK = 120

local function PlaceVisuals(position, horizontal, mult, player)
  local surface = player.surface
  local markers = {}
  if horizontal ~= 0 then
    for x = 5, 9, 2 do
      for y = -4, 0, 4 do
        local pos = {position.x+x*mult, position.y-y*mult}
        local m = surface.create_entity{name="pump_marker", position=pos}
        m.render_player = player
        markers[#markers+1] = m
      end
    end
  else
    for y = 5, 9, 2 do
      for x = -4, 0, 4 do
        local pos = {position.x+x*mult, position.y+y*mult}
        local m = surface.create_entity {name="pump_marker", position=pos}
        m.render_player = player
        markers[#markers+1] = m
      end
    end
  end
  return markers
end

local function AddVisuals(player)
  local new_markers = {}
  local pos = player.position
  local a = {{pos.x-100, pos.y-100}, {pos.x+100, pos.y+100}}
  local ports = player.surface.find_entities_filtered{area=a, name="port"}
  local ltnports = (prototypes.entity["ltn-port"] and player.surface.find_entities_filtered{area=a, name="ltn-port"}) or {}
  for _, ltnport in pairs(ltnports) do
    ports[#ports+1] = ltnport
  end
  -- initalize marker array if necessarry
  storage.pump_markers[player.index] = storage.pump_markers[player.index] or {}
  for _, port in pairs(ports) do
    local dir = port.direction
    if dir == defines.direction.north then
      new_markers = PlaceVisuals(port.position, 0, 1, player)
    elseif dir == defines.direction.south then
      new_markers = PlaceVisuals(port.position, 0, -1, player)
    elseif dir == defines.direction.east then
      new_markers = PlaceVisuals(port.position, 1, -1, player)
    elseif dir == defines.direction.west then
      new_markers = PlaceVisuals(port.position, 1, 1, player)
    end
    table.insert(storage.pump_markers[player.index], new_markers)
  end
end

local function RemoveVisuals(player_index)
  for _, marker_set in pairs(storage.pump_markers[player_index]) do
    for _, marker in pairs(marker_set) do
      marker.destroy()
    end
  end
  -- reset gloabl to remove remenant empty marker sets
  storage.pump_markers[player_index] = nil
end

function UpdateVisuals(e)
  for pidx,_ in pairs(storage.ship_pump_selected) do
    local player = game.players[pidx]
    RemoveVisuals(pidx)
    if player then
      AddVisuals(player)
    end
  end
  RegisterVisualsNthTick()
end


local function check_blueprint_for_pumps(blueprint)
  local blueprint_entities = blueprint.get_blueprint_entities()
  if blueprint_entities then
    for _, bp_entity in pairs(blueprint_entities) do
      if bp_entity.name == "pump" then
        return true
      end
    end
  end
  return false
end

local function is_holding_pump(player)
  -- Check for pump in blueprint player is holding
  if player.is_cursor_blueprint() then
    local blueprint = player.cursor_record
    if blueprint then
      if blueprint.type == "blueprint-book" then
        -- Check all blueprints in this library book, since we can't know which print player selected
        -- Don't check nested books
        for _,record in pairs(blueprint.contents) do
          if record.type == "blueprint" and not blueprint.is_blueprint_preview and check_blueprint_for_pumps(record) then
            return true
          end
        end
        return false
      elseif blueprint.type == "blueprint" and not blueprint.is_blueprint_preview then
        return check_blueprint_for_pumps(blueprint)
      else
        return false
      end
    else
      -- No library book or blueprint, so check cursor item
      blueprint = player.cursor_stack
      if not (blueprint and blueprint.valid_for_read) then
        -- Cursor stack is not present for some reason
        return false
      end
      -- Check item blueprint book recursively
      while blueprint.is_blueprint_book do
        -- Get active blueprint from this book item
        blueprint = blueprint.get_inventory(defines.inventory.item_main)[blueprint.active_index]
      end
      if blueprint.is_blueprint then
        -- Check the blueprint for pumps
        return check_blueprint_for_pumps(blueprint)
      end
      -- Cursor is not a blueprint, or entry from book was not a blueprint
      return false
    end
  end
  
  -- Check for actual pump item in cursor
  local stack = player.cursor_stack
  if stack and stack.valid_for_read and stack.name == "pump" then
    return true
  end
  
  -- Check for pump ghost in cursor
  local ghost = player.cursor_ghost
  if ghost and ghost.name.name == "pump" then
    return true
  end
end

function PumpVisualisation(e)
  local player = game.get_player(e.player_index)

  local holding_pump = is_holding_pump(player)

  if (not storage.ship_pump_selected[e.player_index]) and holding_pump then
    -- if current is pump and last was not
    AddVisuals(player)
    storage.ship_pump_selected[e.player_index] = true

  elseif storage.ship_pump_selected[e.player_index] and not holding_pump then
    -- if last was pump, current is not
    RemoveVisuals(e.player_index)
    storage.ship_pump_selected[e.player_index] = nil
  end
  RegisterVisualsNthTick()
end

function RegisterVisualsNthTick()
  if storage.ship_pump_selected and next(storage.ship_pump_selected) then
    script.on_nth_tick(PUMP_NTH_TICK, UpdateVisuals)
  else
    script.on_nth_tick(PUMP_NTH_TICK, nil)
  end
end
