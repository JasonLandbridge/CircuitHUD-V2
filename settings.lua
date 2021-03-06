local setting_prefix = "CircuitHUD"

data:extend(
	{
		{
			type = "bool-setting",
			name = setting_prefix .. "_hide_hud_header",
			setting_type = "runtime-per-user",
			default_value = false,
			order = "a-a"
		},
		{
			type = "string-setting",
			name = setting_prefix .. "_hud_title",
			setting_type = "runtime-per-user",
			default_value = "Circuit HUD",
			order = "a-b"
		},
		{
			type = "string-setting",
			name = setting_prefix .. "_hud_position",
			setting_type = "runtime-per-user",
			default_value = "left",
			allowed_values = {"top", "left", "goal", "bottom-right", "draggable"},
			order = "a-c"
		},
		{
			type = "int-setting",
			name = setting_prefix .. "_hud_columns",
			setting_type = "runtime-per-user",
			default_value = 8,
			minimum_value = 1,
			maximum_value = 10,
			order = "a-d"
		},
		{
			type = "int-setting",
			name = setting_prefix .. "_hud_max_height",
			setting_type = "runtime-per-user",
			default_value = 600,
			minimum_value = 200,
			maximum_value = 2160,
			order = "a-e"
		},
		{
			type = "bool-setting",
			name = setting_prefix .. "_uncollapse_hud_on_register_combinator",
			setting_type = "runtime-per-user",
			default_value = true,
			order = "a-f"
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
