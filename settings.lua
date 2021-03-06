local setting_prefix = "CircuitHUD"

data:extend(
	{
		{
			type = "string-setting",
			name = setting_prefix .. "_hud_position",
			setting_type = "runtime-per-user",
			default_value = "left",
			allowed_values = {"top", "left", "goal", "bottom-right", "draggable"}
		},
		{
			type = "int-setting",
			name = setting_prefix .. "_hud_columns",
			setting_type = "runtime-per-user",
			default_value = 8,
			minimum_value = 1,
			maximum_value = 10,
		}
	}
)
