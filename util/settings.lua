local setting_prefix = "CircuitHUD"

function get_hud_position_setting(player_index)
	return settings.get_player_settings(player_index)[setting_prefix .. "_hud_position"].value
end

function get_hud_columns_setting(player_index)
	return settings.get_player_settings(player_index)[setting_prefix .. "_hud_columns"].value
end
