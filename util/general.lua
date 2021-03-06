local Is = require("__stdlib__/stdlib/utils/is")

function is_player_index(player_index)
	return Is.Assert.UInt(player_index).True(player_index > 0)
end

function array_length(array)
	local count = 0
	for i, v in pairs(array) do
		count = count + 1
	end
	return count
end
