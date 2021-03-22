local const = require("lib.constants")

data:extend {
	{
		type = "custom-input",
		name = const.EVENTS.gui_hud_toggle,
		key_sequence = "CONTROL + SHIFT + S"
	},
	{
		type = "custom-input",
		name = const.EVENTS.gui_settings_open,
		key_sequence = "CONTROL + ALT + S"
	}
}
