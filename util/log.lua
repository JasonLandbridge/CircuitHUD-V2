local Is = require("__stdlib__/stdlib/utils/is")

-- Logs the message to the player in the console.
-- @param player LuaPlayer
function log(player, message)
	player.print(message)
end

function debug_log(player, message)
	-- TODO check if debugging is enabled
	if Is.UInt(player) then
		get_player(player).print(message)
		return
	end

	player.print(message)
end
