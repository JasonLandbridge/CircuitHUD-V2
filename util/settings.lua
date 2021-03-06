local setting_prefix = "CircuitHUD"

function get_hud_position_setting(player)
	return settings.get_player_settings(player)[setting_prefix .. "_hud_position"].value
end

function get_hud_columns_setting(player)
	return settings.get_player_settings(player)[setting_prefix .. "_hud_columns"].value
end
