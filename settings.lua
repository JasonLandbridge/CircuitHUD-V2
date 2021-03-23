local const = require("lib.constants")
-- DEPRECATED: EVERYTHING HERE SHOULD BE DELETED AFTER V1.3 HAS BEEN LAUNCHED
-- Only still here to migrate any player settings to the in-game settings menu
-- Per Player SETTINGS
data:extend(
	{
		{
			type = "bool-setting",
			name = const.SETTINGS.prefix .. const.SETTINGS.hide_hud_header,
			setting_type = "runtime-per-user",
			default_value = false,
			order = "a-a",
			hidden = true
		},
		{
			type = "string-setting",
			name = const.SETTINGS.prefix .. const.SETTINGS.hud_title,
			setting_type = "runtime-per-user",
			default_value = "Circuit HUD V2",
			order = "a-b",
			hidden = true
		},
		{
			type = "string-setting",
			name = const.SETTINGS.prefix .. const.SETTINGS.hud_position,
			setting_type = "runtime-per-user",
			default_value = const.HUD_POSITION.bottom_right,
			allowed_values = {
				const.HUD_POSITION.top,
				const.HUD_POSITION.left,
				const.HUD_POSITION.goal,
				const.HUD_POSITION.bottom_right,
				const.HUD_POSITION.draggable
			},
			order = "a-c",
			hidden = true
		},
		{
			type = "int-setting",
			name = const.SETTINGS.prefix .. const.SETTINGS.hud_columns,
			setting_type = "runtime-per-user",
			default_value = 8,
			minimum_value = 1,
			maximum_value = 20,
			order = "a-d",
			hidden = true
		},
		{
			type = "int-setting",
			name = const.SETTINGS.prefix .. const.SETTINGS.hud_height,
			setting_type = "runtime-per-user",
			default_value = 600,
			minimum_value = 200,
			maximum_value = 2160,
			order = "a-e",
			hidden = true
		},
		{
			type = "int-setting",
			name = const.SETTINGS.prefix .. const.SETTINGS.hud_refresh_rate,
			setting_type = "runtime-per-user",
			default_value = 60,
			minimum_value = 1,
			maximum_value = 3600,
			order = "a-e",
			hidden = true
		},
		{
			type = "bool-setting",
			name = const.SETTINGS.prefix .. const.SETTINGS.uncollapse_hud_on_register_combinator,
			setting_type = "runtime-per-user",
			default_value = true,
			order = "a-f",
			hidden = true
		},
		{
			type = "string-setting",
			name = const.SETTINGS.prefix .. const.SETTINGS.debug_mode,
			setting_type = "runtime-per-user",
			default_value = "off",
			allowed_values = {"off", "debug"},
			order = "b-a",
			hidden = true
		}
	}
)
