local global_default = {
	hud_collapsed = false,
	hud_size = {width = 250, height = 300}
}

function initialize_global_for_player(player)
	global.players[player.index] = global_default
end

-- Returns the global object for the player with this index
-- @param player_index The index of the player
function get_player_global(player_index)
	return global.players[player_index]
end

function get_hud_combinators()
	return global.hud_combinators
end

function ensure_global_state()
	-- A collection of all players with their individual data
	if (not global.players) then
		global.players = {}
	end

	-- A collection of all HUD Combinators entities in game
	if (not global.hud_combinators) then
		global.hud_combinators = {}
	end

	if (not global.textbox_hud_entity_map) then
		global.textbox_hud_entity_map = {}
	end

	if (not global.hud_position_map) then
		global.hud_position_map = {}
	end

	if (not global.hud_collapsed_map) then
		global.hud_collapsed_map = {}
	end

	if (not global.hud_size) then
		global.hud_size = {width = 250, height = 300}
	end
end
