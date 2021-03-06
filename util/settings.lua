local setting_prefix = "CircuitHUD"

function get_hud_position_setting(player_index)
	return settings.get_player_settings(player_index)[setting_prefix .. "_hud_position"].value
end

function get_hud_columns_setting(player_index)
	return settings.get_player_settings(player_index)[setting_prefix .. "_hud_columns"].value
end

function get_hide_hud_header_setting(player_index)
	return settings.get_player_settings(player_index)[setting_prefix .. "_hide_hud_header"].value
end

function get_hud_title_setting(player_index)
	return settings.get_player_settings(player_index)[setting_prefix .. "_hud_title"].value
end

-- Returns true if mod is in Debug mode
function get_debug_mode_setting(player_index)
	return settings.get_player_settings(player_index)[setting_prefix .. "_debug_mode"].value == "debug"
end
