local const = {}

const.PREFIX = "CIRCUIT_HUD_"
const.SHORT_PREFIX = "chv2_"
const.HUD_COMBINATOR_NAME = "hud-combinator"
const.HIDE_SIGNAL_NAME = "signal-hide-hud-comparator"

const.HUD_NAMES = {
	hud_root_frame = const.PREFIX .. "hud_root_frame",
	hud_scroll_pane = const.PREFIX .. "hud_scroll_pane",
	hud_scroll_pane_frame = const.PREFIX .. "hud_scroll_pane_frame",
	hud_toggle_button = const.PREFIX .. "hud_toggle_button",
	hud_settings_button = const.PREFIX .. "hud_settings_button",
	hud_title_label = const.PREFIX .. "hud_title_label",
	hud_header_spacer = const.PREFIX .. "hud_header_spacer",
	hud_search_text_field = const.PREFIX .. "hud_search_textfield",
	hud_search_button = const.PREFIX .. "hud_search_button",
	combinator_root_frame = const.PREFIX .. "combinator_root_frame",
	settings_root_frame = const.PREFIX .. "settings_root_frame",
	settings_hud_columns_slider = const.PREFIX .. "settings_hud_columns_vslider",
	settings_hud_columns_value = const.PREFIX .. "settings_hud_columns_value"
}

const.GUI_TYPES = {
	combinator = "COMBINATOR_GUI",
	hud = "HUD_GUI",
	settings = "SETTINGS_GUI"
}

const.SETTINGS = {
	prefix = "CircuitHUD_",
	hide_hud_header = "hide_hud_header",
	hud_title = "hud_title",
	hud_position = "hud_position",
	hud_columns = "hud_columns",
	hud_refresh_rate = "hud_refresh_rate",
	hud_max_height = "hud_max_height",
	uncollapse_hud_on_register_combinator = "uncollapse_hud_on_register_combinator",
	debug_mode = "debug_mode"
}

const.HUD_POSITION_INDEX = {
	[1] = "top",
	[2] = "left",
	[3] = "goal",
	[4] = "bottom-right",
	[5] = "draggable"
}

const.HUD_POSITION = {
	top = const.HUD_POSITION_INDEX[1],
	left = const.HUD_POSITION_INDEX[2],
	goal = const.HUD_POSITION_INDEX[3],
	bottom_right = const.HUD_POSITION_INDEX[4],
	draggable = const.HUD_POSITION_INDEX[5]
}

const.SIGNAL_TYPE_MAP = {
	["item"] = "item",
	["virtual"] = "virtual-signal",
	["fluid"] = "fluid"
}

const.GUI_ACTIONS = {
	toggle = "TOGGLE",
	toggle_search_bar = "TOGGLE_SEARCH_BAR",
	close = "CLOSE",
	name_change = "NAME_CHANGED",
	search_bar_change = "SEARCH_BAR_CHANGED",
	open_combinator = "OPEN_COMBINATOR",
	open_settings = "OPEN_SETTINGS",
	update_settings = "UPDATE_SETTING",
	go_to_combinator = "GO_TO_COMBINATOR",
	filter_signal_update = "FILTER_SIGNAL_UPDATE",
	switch_filter_state = "SWITCH_FILTER_STATE",
	name_change_confirm = "NAME_CHANGE_CONFIRM"
}

const.STYLES = {
	settings_title_label = const.SHORT_PREFIX .. "settings_title_label",
	settings_slider = const.SHORT_PREFIX .. "settings_slider_style"
}

const.EVENTS = {
	collapse_hud = const.SHORT_PREFIX .. "collapse_hud",
	gui_hud_create = const.SHORT_PREFIX .. "gui_hud_create",
	gui_settings_create = const.SHORT_PREFIX .. "gui_settings_create",
	gui_combinator_create = const.SHORT_PREFIX .. "gui_combinator_create",
	gui_hud_reset_all_players = const.SHORT_PREFIX .. "gui_hud_reset_all_players"
}

return const
