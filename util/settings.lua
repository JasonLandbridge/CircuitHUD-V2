--#region Per User Settings
local function get_setting(player_index, string_path)
	return settings.get_player_settings(player_index)[SETTINGS.prefix .. string_path].value
end

function get_hud_position_setting(player_index)
	return get_setting(player_index, SETTINGS.hud_position)
end

function get_hud_columns_setting(player_index)
	return get_setting(player_index, SETTINGS.hud_columns)
end

function get_hud_max_height_setting(player_index)
	return get_setting(player_index, SETTINGS.hud_max_height)
end

function get_hide_hud_header_setting(player_index)
	return get_setting(player_index, SETTINGS.hide_hud_header)
end

function get_hud_title_setting(player_index)
	return get_setting(player_index, SETTINGS.hud_title)
end

function get_uncollapse_hud_on_register_combinator_setting(player_index)
	return get_setting(player_index, SETTINGS.uncollapse_hud_on_register_combinator)
end

-- Returns true if mod is in Debug mode
function get_debug_mode_setting(player_index)
	return get_setting(player_index, SETTINGS.debug_mode) == "debug"
end

--#endregion

--#region Map Settings

function get_refresh_rate_setting()
	return settings.global[SETTINGS.prefix .. SETTINGS.hud_refresh_rate].value
end

--#endregion
