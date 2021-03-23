local default_gui = data.raw["gui-style"].default
local const = require("lib.constants")
local function button_graphics(xpos, ypos)
	return {
		filename = "__CircuitHUD-V2__/graphics/buttons/button-sprites.png",
		priority = "extra-high-no-scale",
		width = 16,
		height = 16,
		x = xpos,
		y = ypos
	}
end

default_gui["CircuitHUD_button_with_icon"] = {
	type = "button_style",
	parent = "slot_button",
	scalable = true,
	top_margin = 4,
	bottom_margin = 4,
	right_padding = 1,
	left_padding = 1,
	width = 16,
	height = 16,
	default_graphical_set = button_graphics(0, 0),
	hovered_graphical_set = button_graphics(16, 0),
	clicked_graphical_set = button_graphics(32, 0)
}

default_gui[const.BUTTON_STYLES.go_to_button] = {
	type = "button_style",
	parent = "CircuitHUD_button_with_icon",
	default_graphical_set = button_graphics(0, 0),
	hovered_graphical_set = button_graphics(16, 0),
	clicked_graphical_set = button_graphics(32, 0)
}

default_gui[const.BUTTON_STYLES.edit_button] = {
	type = "button_style",
	parent = "CircuitHUD_button_with_icon",
	default_graphical_set = button_graphics(0, 16),
	hovered_graphical_set = button_graphics(16, 16),
	clicked_graphical_set = button_graphics(32, 16)
}

default_gui[const.BUTTON_STYLES.show_button] = {
	type = "button_style",
	parent = "CircuitHUD_button_with_icon",
	default_graphical_set = button_graphics(0, 80),
	hovered_graphical_set = button_graphics(16, 80),
	clicked_graphical_set = button_graphics(32, 80)
}

default_gui[const.BUTTON_STYLES.hide_button] = {
	type = "button_style",
	parent = "CircuitHUD_button_with_icon",
	default_graphical_set = button_graphics(0, 144),
	hovered_graphical_set = button_graphics(16, 144),
	clicked_graphical_set = button_graphics(32, 144)
}
