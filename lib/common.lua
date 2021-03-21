local player_settings = require("globals.player-settings")
local stdlib_Is = require("__stdlib__/stdlib/utils/is")

local common = {}
-- Gets the player object by player reference
-- @param player_index The index of the player ref
function common.get_player(player_index)
	return game.get_player(player_index)
end

-- Logs the message to the player in the console only if debug_mode is enabled.
-- @param player_index LuaPlayer
function common.debug_log(player_index, message)
	if player_settings.get_debug_mode_setting(player_index) then
		common.get_player(player_index).print(message)
	end
end

function common.min(array)
	local min = 0
	for key, value in pairs(array) do
		if min == 0 or value < min then
			min = value
		end
	end
	return min
end

function common.max(array)
	local max = 0
	for key, value in pairs(array) do
		if value > max then
			max = value
		end
	end
	return max
end

function common.valid(object)
	if object == nil then
		return false
	end
	if object == {} then
		return false
	end
	return stdlib_Is(object)
end

function common.short_if(condition, true_result, false_result)
	if condition then
		return true_result
	end
	return false_result
end

return common
