local player_settings = require("globals.player-settings")
local stdlib_Is = require("stdlib/utils/is")

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

function common.gui_wrapper(event, handler)
    local element = event.element
    if not stdlib_Is.Valid(element) then return false end

    local params = {
        player_index = event.player_index,
        gui = element.tags['gui'],
        unit_number = element.tags['unit_number'],
        index = element.tags['index'],
    }

    if event.define_name == 'on_gui_click' and event.element.type == 'checkbox' and event.element.state ~= nil then
        -- Checkbox
        params.value = event.element.state
    elseif event.define_name == 'on_gui_text_changed' and event.text ~= nil then
        -- Text Field
        params.value = event.text
    elseif event.define_name == 'on_gui_elem_changed' and event.element.elem_value ~= nil then
        -- Element select
        params.value = event.element.elem_value
    elseif event.define_name == 'on_gui_value_changed' and event.element.slider_value ~= nil then
        -- Sliders
        params.value = event.element.slider_value
    elseif event.define_name == 'on_gui_selection_state_changed' and event.element.selected_index ~= nil then
        -- Dropdowns
        params.value = event.element.selected_index
    elseif event.define_name == 'on_gui_switch_state_changed' and event.element.switch_state ~= nil then
        -- Switches, Right/On is true, Left/Off is false
        params.value = event.element.switch_state == 'right'
    end

    return handler(params)
end


return common
