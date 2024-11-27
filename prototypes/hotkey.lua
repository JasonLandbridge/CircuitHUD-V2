local const = require("lib.constants")

data:extend {
	{
		type = "custom-input",
		name = const.EVENTS.gui_hud_toggle,
		localised_name = {"controls.chv2_toggle_hud"},
		key_sequence = "CONTROL + SHIFT + S"
	},
	{
		type = "custom-input",
		name = const.EVENTS.gui_settings_open,
		localised_name = {"controls.chv2_open_settings_gui"},
		key_sequence = "CONTROL + ALT + S"
	}
}
