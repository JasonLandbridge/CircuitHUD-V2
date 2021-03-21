local const = require("lib.constants")

data:extend {
	{
		type = "custom-input",
		name = const.SHORT_PREFIX .. "toggle_hud",
		key_sequence = "CONTROL + SHIFT + S"
	},
	{
		type = "custom-input",
		name = const.SHORT_PREFIX .. "open_settings_gui",
		key_sequence = "CONTROL + ALT + S"
	}
}
