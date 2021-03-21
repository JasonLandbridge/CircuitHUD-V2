local data_util = require("__flib__.data-util")

local frame_action_icons = "__CircuitHUD-V2__/graphics/buttons/frame-action-icons.png"



data:extend {
	-- frame action icons
	data_util.build_sprite("rb_settings_black", {0, 96}, frame_action_icons, 32),
	data_util.build_sprite("rb_settings_white", {32, 96}, frame_action_icons, 32),
	data_util.build_sprite("rb_expand_black", {0, 128}, frame_action_icons, 32),
	data_util.build_sprite("rb_expand_white", {32, 128}, frame_action_icons, 32),
	data_util.build_sprite("rc_pin_black", {0, 0}, frame_action_icons, 32),
	data_util.build_sprite("rc_pin_white", {32, 0}, frame_action_icons, 32),
}
