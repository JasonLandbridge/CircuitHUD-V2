local const = require("lib.constants")
local player_settings = require("globals.player-settings")
local common = require("lib.common")

local player_data_default = {
	hud_collapsed = false,
	hud_size = {width = 250, height = 300},
	hud_location = {x = 0, y = 0},
	search_text = "",
	elements = {},
	settings = player_settings.default_player_settings(),
	hud_combinators = {}
}
local player_data = {}

-- Returns the global object for the player with this index
-- Will create a global object if the "player_index" is not yet created
-- @param player_index The index of the player
function player_data.get_player_global(player_index)
	if not player_index then
		return
	end

	local global_player = global.players[player_index]
	if not global_player then
		player_data.add_player_global(player_index)
	end
	return global.players[player_index]
end

--#region Get Player Properties

function player_data.get_hud_collapsed(player_index)
	return player_data.get_player_global(player_index).hud_collapsed
end

function player_data.get_hud_location(player_index)
	return player_data.get_player_global(player_index).hud_location
end

function player_data.get_hud_size(player_index)
	return player_data.get_player_global(player_index).hud_size
end

function player_data.get_hud_search_text(player_index)
	return player_data.get_player_global(player_index).search_text
end

--#endregion

--#region Get HUD Helpers

function player_data.get_is_hud_top(player_index)
	return player_settings.get_hud_position_setting(player_index) == const.HUD_POSITION.top
end

function player_data.get_is_hud_left(player_index)
	return player_settings.get_hud_position_setting(player_index) == const.HUD_POSITION.left
end

function player_data.get_is_hud_goal(player_index)
	return player_settings.get_hud_position_setting(player_index) == const.HUD_POSITION.goal
end

function player_data.get_is_hud_draggable(player_index)
	return player_settings.get_hud_position_setting(player_index) == const.HUD_POSITION.draggable
end

function player_data.get_is_hud_bottom_right(player_index)
	return player_settings.get_hud_position_setting(player_index) == const.HUD_POSITION.bottom_right
end

--#endregion

--#region Set Player Properties

function player_data.set_hud_location(player_index, location)
	player_data.get_player_global(player_index).hud_location = location
end

function player_data.set_hud_size(player_index, size)
	player_data.get_player_global(player_index).hud_size = size
end

function player_data.set_hud_collapsed(player_index, state)
	player_data.get_player_global(player_index).hud_collapsed = state
end

function player_data.set_hud_search_text(player_index, text)
	player_data.get_player_global(player_index).search_text = text
end

function player_data.set_hud_element_ref(player_index, key, gui_element)
	player_data.get_player_global(player_index).elements[key] = gui_element
end

--#endregion

--#region

local function get_hud_combinator_data(player_index, unit_number)
	local hud_combinators = player_data.get_player_global(player_index)["hud_combinators"]
	local hud_combinator = hud_combinators[unit_number]
	if not hud_combinator then
		hud_combinators[unit_number] = {visible = true}
	end
	return hud_combinators[unit_number]
end

function player_data.set_hud_combinator_visibilty(player_index, unit_number, state)
	get_hud_combinator_data(player_index, unit_number).visible = state
end

function player_data.get_hud_combinator_visibilty(player_index, unit_number)
	return get_hud_combinator_data(player_index, unit_number).visible
end

--#endregion

--#region Add Properties
function player_data.add_player_global(player_index)
	local player = common.get_player(player_index)
	global.players[player_index] = player_data_default
	common.debug_log(player_index, "initialize global for player" .. player.name)
end
--#endregion

--#region Remove Properties
function player_data.remove_player_global(player_index)
	global.players[player_index] = nil
end

function player_data.destroy_hud_ref(player_index, key)
	local player = player_data.get_player_global(player_index)
	if player.elements[key] then
		player.elements[key].destroy()
		player.elements[key] = nil
	end
end

--#endregion

--#region Get HUD References

function player_data.get_hud_ref(player_index, key)
	return player_data.get_player_global(player_index).elements[key]
end

--#endregion
--#region Get HUD References

function player_data.destroy_hud(player_index)
	local elements = player_data.get_player_global(player_index).elements
	for key, value in pairs(elements) do
		if value.valid then
			value.destroy()
		end
		elements[key] = nil
	end

	local player = common.get_player(player_index)

	-- Ensure we delete any remnants of stray HUD's we created
	local locations = {
		const.HUD_POSITION.top,
		const.HUD_POSITION.left,
		const.HUD_POSITION.center,
		const.HUD_POSITION.goal,
		const.HUD_POSITION.screen,
		const.HUD_POSITION.relative
	}
	for _, location in pairs(locations) do
		for _, child in pairs(player.gui[location].children) do
			if child.name == const.HUD_NAMES.hud_root_frame then
				child.destroy()
			end
		end
	end

	-- Clear all elements for the player
	global.players[player_index].elements = {}
end

return player_data
