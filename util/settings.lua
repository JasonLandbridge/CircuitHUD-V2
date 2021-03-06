local setting_prefix = "CircuitHUD"

local function get_setting(player_index, string_path)
	return settings.get_player_settings(player_index)[setting_prefix .. string_path].value
end

function get_hud_position_setting(player_index)
	return get_setting(player_index, "_hud_position")
end

function get_hud_columns_setting(player_index)
	return get_setting(player_index, "_hud_columns")
end

function get_hud_max_height_setting(player_index)
	return get_setting(player_index, "_hud_max_height")
end

function get_hide_hud_header_setting(player_index)
	return get_setting(player_index, "_hide_hud_header")
end

function get_hud_title_setting(player_index)
	return get_setting(player_index, "_hud_title")
end

function get_uncollapse_hud_on_register_combinator_setting(player_index)
	return get_setting(player_index, "_uncollapse_hud_on_register_combinator")
end

-- Returns true if mod is in Debug mode
function get_debug_mode_setting(player_index)
	return get_setting(player_index, "_debug_mode") == "debug"
end
