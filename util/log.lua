local Is = require("__stdlib__/stdlib/utils/is")

-- Logs the message to the player in the console.
-- @param player_index LuaPlayer
function log(player_index, message)
	get_player(player_index).print(message)
end

-- Logs the message to the player in the console only if debug_mode is enabled.
-- @param player_index LuaPlayer
function debug_log(player_index, message)
	if get_debug_mode_setting(player_index) then
		get_player(player_index).print(message)
	end
end
