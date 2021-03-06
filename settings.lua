local setting_prefix = "CircuitHUD"

data:extend(
	{
		{
			type = "string-setting",
			name = setting_prefix .. "_hud_position",
			setting_type = "runtime-per-user",
			default_value = "left",
			allowed_values = {"top", "left", "goal", "bottom-right", "draggable"},
			order = "a-a"
		},
		{
			type = "int-setting",
			name = setting_prefix .. "_hud_columns",
			setting_type = "runtime-per-user",
			default_value = 8,
			minimum_value = 1,
			maximum_value = 10,
			order = "a-b"
		},
		{
			type = "bool-setting",
			name = setting_prefix .. "_hide_hud_header",
			setting_type = "runtime-per-user",
			default_value = false,
			order = "a-d"
		},
		{
			type = "string-setting",
			name = setting_prefix .. "_hud_title",
			setting_type = "runtime-per-user",
			default_value = "Circuit HUD",
			order = "a-c"
		},
		{
			type = "string-setting",
			name = setting_prefix .. "_debug_mode",
			setting_type = "runtime-per-user",
			default_value = "off",
			allowed_values = {"off", "debug"},
			order = "b-a"
		}
	}
)
