require "util/constants"

-- Per Player Settings
data:extend(
	{
		{
			type = "bool-setting",
			name = SETTINGS.prefix .. SETTINGS.hide_hud_header,
			setting_type = "runtime-per-user",
			default_value = false,
			order = "a-a"
		},
		{
			type = "string-setting",
			name = SETTINGS.prefix .. SETTINGS.hud_title,
			setting_type = "runtime-per-user",
			default_value = "Circuit HUD V2",
			order = "a-b"
		},
		{
			type = "string-setting",
			name = SETTINGS.prefix .. SETTINGS.hud_position,
			setting_type = "runtime-per-user",
			default_value = HUD_POSITION.bottom_right,
			allowed_values = {
				HUD_POSITION.top,
				HUD_POSITION.left,
				HUD_POSITION.goal,
				HUD_POSITION.bottom_right,
				HUD_POSITION.draggable
			},
			order = "a-c"
		},
		{
			type = "int-setting",
			name = SETTINGS.prefix .. SETTINGS.hud_columns,
			setting_type = "runtime-per-user",
			default_value = 8,
			minimum_value = 1,
			maximum_value = 20,
			order = "a-d"
		},
		{
			type = "int-setting",
			name = SETTINGS.prefix .. SETTINGS.hud_max_height,
			setting_type = "runtime-per-user",
			default_value = 600,
			minimum_value = 200,
			maximum_value = 2160,
			order = "a-e"
		},
		{
			type = "int-setting",
			name = SETTINGS.prefix .. SETTINGS.hud_refresh_rate,
			setting_type = "runtime-per-user",
			default_value = 60,
			minimum_value = 1,
			maximum_value = 3600,
			order = "a-e"
		},
		{
			type = "bool-setting",
			name = SETTINGS.prefix .. SETTINGS.uncollapse_hud_on_register_combinator,
			setting_type = "runtime-per-user",
			default_value = true,
			order = "a-f"
		},
		{
			type = "string-setting",
			name = SETTINGS.prefix .. SETTINGS.debug_mode,
			setting_type = "runtime-per-user",
			default_value = "off",
			allowed_values = {"off", "debug"},
			order = "b-a"
		}
	}
)
-- Runtime Global Settings
data:extend(
	{
		{
			type = "int-setting",
			name = SETTINGS.prefix .. SETTINGS.hud_refresh_rate,
			setting_type = "runtime-global",
			default_value = 60,
			minimum_value = 1,
			maximum_value = 3600,
			order = "a-e"
		}
	}
)
