local Is = require("__stdlib__/stdlib/utils/is")

function is_player_index(player_index)
	return Is.Assert.UInt(player_index).True(player_index > 0)
end

function has_value(table, value)
	for k, v in pairs(table) do
		if v == value then
			return k
		end
	end
	return nil
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

function valid(object)
	if object == nil then
		return false
	end
	if object == {} then
		return false
	end
	return Is(object)
end

function find_child(table, name)
	if table == {} then
		return nil
	end

	for key, value in pairs(table) do
		if value.name == name then
			return value
		end
	end
end

function short_if(condition, true_result, false_result)
	if condition then
		return true_result
	end
	return false_result
end
