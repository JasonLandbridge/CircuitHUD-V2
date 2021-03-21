local default_gui = data.raw["gui-style"].default

local function button_graphics(xpos, ypos)
	return {
		filename = "__CircuitHUD-V2__/graphics/buttons/gui.png",
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
	top_padding = 1,
	right_padding = 1,
	bottom_padding = 1,
	left_padding = 1,
	width = 16,
	height = 16,
	default_graphical_set = button_graphics(0, 0),
	hovered_graphical_set = button_graphics(16, 0),
	clicked_graphical_set = button_graphics(32, 0)
}

default_gui["CircuitHUD_goto_site"] = {
	type = "button_style",
	parent = "CircuitHUD_button_with_icon",
	default_graphical_set = button_graphics(0, 80),
	hovered_graphical_set = button_graphics(16, 80),
	clicked_graphical_set = button_graphics(32, 80)
}

default_gui["CircuitHUD_open_combinator"] = {
	type = "button_style",
	parent = "CircuitHUD_button_with_icon",
	default_graphical_set = button_graphics(0, 112),
	hovered_graphical_set = button_graphics(16, 112),
	clicked_graphical_set = button_graphics(32, 112)
}
