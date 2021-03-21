PREFIX = "CIRCUIT_HUD_"
HUD_NAMES = {
	hud_root_frame = PREFIX .. "hud_root_frame",
	hud_scroll_pane = PREFIX .. "hud_scroll_pane",
	hud_scroll_pane_frame = PREFIX .. "hud_scroll_pane_frame",
	hud_toggle_button = PREFIX .. "hud_toggle_button",
	hud_settings_button = PREFIX .. "hud_settings_button",
	hud_title_label = PREFIX .. "hud_title_label",
	hud_header_spacer = PREFIX .. "hud_header_spacer",
	hud_search_text_field = PREFIX .. "hud_search_textfield",
	hud_search_button = PREFIX .. "hud_search_button",
	combinator_root_frame = PREFIX .. "combinator_frame_root_frame"
}

GUI_TYPES = {
	combinator = "COMBINATOR_GUI",
	hud = "HUD_GUI",
	settings = "SETTINGS_GUI",
	textbox_hud_entity_map = "textbox_hud_entity_map"
}

HUD_COMBINATOR_NAME = "hud-combinator"
HIDE_SIGNAL_NAME = "signal-hide-hud-comparator"

SETTINGS = {
	prefix = "CircuitHUD",
	hide_hud_header = "_hide_hud_header",
	hud_title = "_hud_title",
	hud_position = "_hud_position",
	hud_columns = "_hud_columns",
	hud_refresh_rate = "_hud_refresh_rate",
	hud_max_height = "_hud_max_height",
	uncollapse_hud_on_register_combinator = "_uncollapse_hud_on_register_combinator",
	debug_mode = "_debug_mode"
}

HUD_POSITION = {
	top = "top",
	left = "left",
	goal = "goal",
	bottom_right = "bottom-right",
	draggable = "draggable"
}

SIGNAL_TYPE_MAP = {
	["item"] = "item",
	["virtual"] = "virtual-signal",
	["fluid"] = "fluid"
}

GUI_ACTIONS = {
	toggle = "TOGGLE",
	toggle_search_bar = "TOGGLE_SEARCH_BAR",
	close = "CLOSE",
	name_change = "NAME_CHANGED",
	search_bar_change = "SEARCH_BAR_CHANGED",
	open_combinator = "OPEN_COMBINATOR",
	open_settings = "OPEN_SETTINGS",
	go_to_combinator = "GO_TO_COMBINATOR",
	filter_signal_update = "FILTER_SIGNAL_UPDATE",
	switch_filter_state = "SWITCH_FILTER_STATE",
	name_change_confirm = "NAME_CHANGE_CONFIRM"
}
