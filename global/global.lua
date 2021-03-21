require "./player.lua"

function get_hud_combinators()
	return global.hud_combinators
end

function has_hud_combinators()
	return table_size(get_hud_combinators()) > 0
end

--#region Get HUD References

function get_hud_ref(player_index, key)
	return get_player_global(player_index).elements[key]
end

--#endregion

function ensure_global_state()
	-- A collection of all players with their individual data
	if not valid(global.players) then
		global.players = {}
	end

	-- A collection of all HUD Combinators entities in game
	if not valid(global.hud_combinators) then
		global.hud_combinators = {}
	end

	if not global.refresh_rate then
		global.refresh_rate = 60
	end
end

function reset_global_state()
	global = {}
	ensure_global_state()
end
