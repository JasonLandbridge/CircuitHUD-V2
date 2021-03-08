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

function sum(array)
	local sum = 0
	for key, value in pairs(array) do
		sum = sum + value
	end
	return sum
end

function min(array)
	local min = 0
	for key, value in pairs(array) do
		if min == 0 or value < min then
			min = value
		end
	end
	return min
end

function max(array)
	local max = 0
	for key, value in pairs(array) do
		if value > max then
			max = value
		end
	end
	return max
end
