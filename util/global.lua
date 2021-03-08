local global_default = {
	hud_collapsed = false,
	hud_size = {width = 250, height = 300},
	hud_location = {x = 0, y = 0},
	elements = {}
}

-- Returns the global object for the player with this index
-- Will create a global object if the "player_index" is not yet created
-- @param player_index The index of the player
function get_player_global(player_index)
	if not player_index then
		return
	end

	local global_player = global.players[player_index]
	if not global_player then
		add_player_global(player_index)
	end
	return global.players[player_index]
end

function get_hud_combinators()
	return global.hud_combinators
end

function has_hud_combinators()
	return array_length(get_hud_combinators()) > 0
end

--#region Get Player Properties

function get_hud_collapsed(player_index)
	return get_player_global(player_index).hud_collapsed
end

function get_hud_location(player_index)
	return get_player_global(player_index).hud_location
end

function get_hud_size(player_index)
	return get_player_global(player_index).hud_size
end

--#endregion

--#region Get HUD References

function get_hud_ref(player_index, key)
	return get_player_global(player_index).elements[key]
end

--#endregion

--#region Set Player Properties

function set_hud_location(player_index, location)
	get_player_global(player_index).hud_location = location
end

function set_hud_size(player_index, size)
	get_player_global(player_index).hud_size = size
end

function set_hud_collapsed(player_index, state)
	get_player_global(player_index).hud_collapsed = state
end

function set_hud_element_ref(player_index, key, gui_element)
	get_player_global(player_index).elements[key] = gui_element
end

--#endregion

--#region Add Properties
function add_player_global(player_index)
	local player = get_player(player_index)
	global.players[player_index] = global_default
	debug_log(player_index, "initialize global for player" .. player.name)
end
--#endregion

--#region Remove Properties
function remove_player_global(player_index)
	global.players[player_index] = nil
end

function destroy_hud_ref(player_index, key)
	local player = get_player_global(player_index)
	if player.elements[key] then
		player.elements[key].destroy()
		player.elements[key] = nil
	end
end

--#endregion

function destroy_hud(player_index)
	local elements = get_player_global(player_index).elements
	for key, value in pairs(elements) do
		if value.valid then
			value.destroy()
		end
		elements[key] = nil
	end

	local player = get_player(player_index)

	-- Ensure we delete any remnants of stray HUD's we created
	local locations = {"top", "left", "center", "goal", "screen", "relative"}
	for i, location in ipairs(locations) do
		for j, child in ipairs(player.gui[location].children) do
			if child.name == HUD_NAMES.hud_root_frame then
				child.destroy()
			end
		end
	end

	-- Clear all elements for the player
	global.players[player_index].elements = {}
end

function ensure_global_state()
	-- A collection of all players with their individual data
	if not valid(global.players) then
		global.players = {}
	end

	-- A collection of all HUD Combinators entities in game
	if not valid(global.hud_combinators) then
		global.hud_combinators = {}
	end

	if not valid(global.textbox_hud_entity_map) then
		global.textbox_hud_entity_map = {}
	end
end

function reset_global_state()
	global = {}
	ensure_global_state()
end
