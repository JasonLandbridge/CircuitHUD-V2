require "util/constants"
require "prototypes/signals"
require "prototypes/recipe"
require "prototypes/buttons"

local default_gui = data.raw["gui-style"].default
default_gui["hud-root-frame-style"] = {
	type = "frame_style",
	minimal_width = 34,
	minimal_height = 34,
	top_padding = 4,
	right_padding = 4,
	bottom_padding = 4,
	left_padding = 4,
	header_filler_style = {
		type = "empty_widget_style",
		height = 24
	}
}

default_gui["hud_scrollpane_style"] = {
	type = "scroll_pane_style",
	extra_padding_when_activated = 0
}

default_gui["hud_scrollpane_frame_style"] = {
	type = "vertical_flow_style",
	padding = 0,
	extra_padding_when_activated = 0
}

default_gui["combinator_flow_style"] = {
	type = "vertical_flow_style",
	minimal_height = 50,
	top_padding = 4,
	right_padding = 4,
	bottom_padding = 4,
	left_padding = 4
}

default_gui["draggable_space_hud_header"] = {
	type = "empty_widget_style",
	parent = "draggable_space",
	top_margin = 0,
	left_margin = 8,
	right_margin = 8,
	minimal_width = 32,
	minimal_height = 24
}

default_gui["space_hud_header"] = {
	type = "empty_widget_style",
	top_margin = 0,
	left_margin = 8,
	right_margin = 8,
	minimal_width = 32,
	minimal_height = 24
}

default_gui["hud_combinator_label"] = {
	type = "label_style",
	parent = "label",
	top_margin = 0,
	left_padding = 4,
	right_padding = 4,
	minimal_width = 200,
	minimal_height = 24,
	-- maximal_width = 200,
	maximal_height = 24,
	want_ellipsis = true
}
