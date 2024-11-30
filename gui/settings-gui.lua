local flib_gui = require("__flib__.gui")

local const = require("lib.constants")
local common = require("lib.common")
local player_settings = require("globals.player-settings")
local player_data = require("globals.player-data")
local event_handler = require("events.event-handler")

local gui_hud = require("gui.hud-gui")
local gui_settings = {}
local gui_handlers = {}

local function get_settings_root_frame(player_index)
	return player_data.get_hud_ref(player_index, const.HUD_NAMES.settings_root_frame)
end

function gui_settings.create(player_index)
	if get_settings_root_frame(player_index) then
		return
	end
	local player = common.get_player(player_index)

	local refs =
		flib_gui.add(
		player.gui.screen,
		{
			{
				type = "frame",
				style_mods = {
					minimal_width = 500,
					maximal_width = 500
				},
				name = const.HUD_NAMES.settings_root_frame,
				direction = "vertical",
				children = {
					-- Titlebar
					{
						type = "flow",
						style = "flib_titlebar_flow",
						children = {
							{
								-- add the title label
								type = "label",
								style = "frame_title",
								caption = {"chv2_settings_gui.hud_settings"}
							},
							{
								-- add a pusher (so the close button becomes right-aligned)
								type = "empty-widget",
								style = "flib_titlebar_drag_handle",
								name = "titlebar_flow",
							},
							{
								type = "sprite-button",
								style = "frame_action_button",
								sprite = "utility/close",
								handler = {
									[defines.events.on_gui_click] = gui_handlers[const.SETTINGS.close],
                                    [defines.events.on_gui_closed] = gui_handlers[const.SETTINGS.close],
								}
							}
						}
					},
					{
						type = "frame",
						style = "ch_settings_category_frame",
						direction = "vertical",
						children = {
							-- Hide HUD Header
							{
								type = "flow",
								style = "flib_titlebar_flow",
								children = {
									{
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_settings_name.hide_hud_header"},
										tooltip = {"chv2_settings_gui_tooltips.hide_hud_header"}
									},
									{
										type = "checkbox",
										state = player_settings.get_hide_hud_header_setting(player_index),
										style_mods = {
											top_margin = 8
										},
										handler = {
											[defines.events.on_gui_click] = gui_handlers[const.SETTINGS.hide_hud_header],
										}
									}
								}
							},
							-- HUD Position setting
							{
								type = "flow",
								style = "flib_titlebar_flow",
								children = {
									{
										-- add the title label
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_settings_name.hud_position"},
										tooltip = {"chv2_settings_gui_tooltips.hud_position"}
									},
									{
										type = "drop-down",
										selected_index = player_settings.get_hud_position_index_setting(player_index),
										items = {
											{"chv2_settings_gui_dropdown.hud_position-top"},
											{"chv2_settings_gui_dropdown.hud_position-left"},
											{"chv2_settings_gui_dropdown.hud_position-goal"},
											{"chv2_settings_gui_dropdown.hud_position-bottom-right"},
											{"chv2_settings_gui_dropdown.hud_position-draggable"}
										},
										handler = {
											[defines.events.on_gui_selection_state_changed] = gui_handlers[const.SETTINGS.hud_position],
										}
									}
								}
							},
							-- HUD Header Text
							{
								type = "flow",
								style = "flib_titlebar_flow",
								children = {
									{
										-- add the title label
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_settings_name.hud_title"},
										tooltip = {"chv2_settings_gui_tooltips.hud_title"}
									},
									{
										-- Name Text field
										type = "textfield",
										name = "name_field",
										style = "stretchable_textfield",
										text = player_settings.get_hud_title_setting(player_index),
										handler = {
											[defines.events.on_gui_text_changed] =  gui_handlers[const.SETTINGS.hud_title],
										}
									}
								}
							},
							-- HUD Max Columns setting
							{
								type = "flow",
								style = "flib_titlebar_flow",
								children = {
									{
										-- add the title label
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_settings_name.hud_columns"},
										tooltip = {"chv2_settings_gui_tooltips.hud_columns"}
									},
									{
										type = "flow",
										style = "flib_titlebar_flow",
										style_mods = {
											top_margin = 8,
										},
										children = {
											{
												type = "slider",
												style = const.STYLES.settings_slider,
												style_mods = {
													horizontally_stretchable = true,
													right_padding = 10
												},
												name = const.HUD_NAMES.settings_hud_columns_slider,
												value = player_settings.get_hud_columns_setting(player_index),
												minimum_value = 4,
												maximum_value = 30,
												handler = {
													[defines.events.on_gui_value_changed] = gui_handlers[const.SETTINGS.hud_columns],
												}
											}
										}
									},
									{
										type = "label",
										caption = tostring(player_settings.get_hud_columns_setting(player_index)),
										style = const.STYLES.slider_count_label,
										name = const.HUD_NAMES.settings_hud_columns_value,
									}
								}
							},
							-- HUD Max Height setting
							{
								type = "flow",
								style = "flib_titlebar_flow",
								children = {
									{
										-- add the title label
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_settings_name.hud_height"},
										tooltip = {"chv2_settings_gui_tooltips.hud_height"}
									},
									{
										type = "flow",
										style = "flib_titlebar_flow",
										style_mods = {
											top_margin = 8
										},
										children = {
											{
												type = "slider",
												style = const.STYLES.settings_slider,
												style_mods = {
													horizontally_stretchable = true,
													right_padding = 10
												},
												name = const.HUD_NAMES.settings_hud_height_slider,
												value = player_settings.get_hud_height_setting(player_index),
												minimum_value = 50,
												maximum_value = 2160,
												handler = {
													[defines.events.on_gui_value_changed] = gui_handlers[const.SETTINGS.hud_height],
												}
											}
										}
									},
									{
										type = "label",
										caption = tostring(player_settings.get_hud_height_setting(player_index)),
										style = const.STYLES.slider_count_label,
										name = const.HUD_NAMES.settings_hud_height_value,
									}
								}
							},
							-- HUD Refresh Rate setting
							{
								type = "flow",
								style = "flib_titlebar_flow",
								children = {
									{
										-- add the title label
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_settings_name.hud_refresh_rate"},
										tooltip = {"chv2_settings_gui_tooltips.hud_refresh_rate"}
									},
									{
										type = "flow",
										style = "flib_titlebar_flow",
										style_mods = {
											top_margin = 8
										},
										children = {
											{
												type = "slider",
												style = const.STYLES.settings_slider,
												style_mods = {
													horizontally_stretchable = true,
													right_padding = 10
												},
												name = const.HUD_NAMES.settings_hud_refresh_rate_slider,
												value = player_settings.get_hud_refresh_rate_setting(player_index),
												minimum_value = 1,
												maximum_value = 600,
												handler = {
													[defines.events.on_gui_value_changed] = gui_handlers[const.SETTINGS.hud_refresh_rate],
												}
											}
										}
									},
									{
										type = "label",
										caption = tostring(player_settings.get_hud_refresh_rate_setting(player_index)),
										style = const.STYLES.slider_count_label,
										name = const.HUD_NAMES.settings_hud_refresh_rate_value,
									}
								}
							},
							-- HUD Sort setting
							{
								type = "flow",
								style = "flib_titlebar_flow",
								children = {
									{
										-- add the title label
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_settings_name.hud_sort"},
										tooltip = {"chv2_settings_gui_tooltips.hud_sort"}
									},
									{
										type = "drop-down",
										selected_index = player_settings.get_hud_sort_index_setting(player_index),
										items = {
											{"chv2_settings_gui_dropdown.hud_sort_none"},
											{"chv2_settings_gui_dropdown.hud_sort_name_ascending"},
											{"chv2_settings_gui_dropdown.hud_sort_name_descending"},
											{"chv2_settings_gui_dropdown.hud_sort_priority_ascending"},
											{"chv2_settings_gui_dropdown.hud_sort_priority_descending"},
											{"chv2_settings_gui_dropdown.hud_sort_build_order_ascending"},
											{"chv2_settings_gui_dropdown.hud_sort_build_order_descending"}
										},
										handler = {
											[defines.events.on_gui_selection_state_changed] = gui_handlers[const.SETTINGS.hud_sort],
										}
									}
								}
							},
							-- Uncollapse HUD on new combinator
							{
								type = "flow",
								style = "flib_titlebar_flow",
								children = {
									{
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_settings_name.uncollapse_hud_on_register_combinator"},
										tooltip = {"chv2_settings_gui_tooltips.uncollapse_hud_on_register_combinator"}
									},
									{
										type = "checkbox",
										state = player_settings.get_uncollapse_hud_on_register_combinator_setting(player_index),
										style_mods = {
											top_margin = 8
										},
										handler = {
											[defines.events.on_gui_click] = gui_handlers[const.SETTINGS.uncollapse_hud_on_register_combinator],
										}
									}
								}
							},
							-- Map Zoom
							{
								type = "flow",
								style = "flib_titlebar_flow",
								children = {
									{
										-- add the title label
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_settings_name.map_zoom_factor"},
										tooltip = {"chv2_settings_gui_tooltips.map_zoom_factor"}
									},
									{
										type = "flow",
										style = "flib_titlebar_flow",
										style_mods = {
											top_margin = 8
										},
										children = {
											{
												type = "slider",
												style = const.STYLES.settings_slider,
												style_mods = {
													horizontally_stretchable = true,
													right_padding = 10
												},
												name = const.HUD_NAMES.settings_map_zoom_factor_slider,
												value = player_settings.get_map_zoom_factor_setting(player_index),
												minimum_value = 1,
												maximum_value = 10,
												handler = {
													[defines.events.on_gui_value_changed] = gui_handlers[const.SETTINGS.map_zoom_factor],
												}
											}
										}
									},
									{
										type = "label",
										caption = tostring(player_settings.get_map_zoom_factor_setting(player_index)),
										style = const.STYLES.slider_count_label,
										name = const.HUD_NAMES.settings_map_zoom_factor_value,
									}
								}
							},
							-- Debug mode
							{
								type = "flow",
								style = "flib_titlebar_flow",
								children = {
									{
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_settings_name.debug_mode"},
										tooltip = {"chv2_settings_gui_tooltips.debug_mode"}
									},
									{
										type = "checkbox",
										state = player_settings.get_debug_mode_setting(player_index),
										style_mods = {
											top_margin = 8
										},
										handler = {
											[defines.events.on_gui_click] = gui_handlers[const.SETTINGS.debug_mode],
										}
									}
								}
							},
						}
					}
				}
			}
		}
	)

	local root_frame = refs[const.HUD_NAMES.settings_root_frame]
	refs["titlebar_flow"].drag_target = root_frame

	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.settings_hud_columns_slider, refs[const.HUD_NAMES.settings_hud_columns_slider])
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.settings_hud_columns_value, refs[const.HUD_NAMES.settings_hud_columns_value])

	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.settings_hud_height_slider, refs[const.HUD_NAMES.settings_hud_height_slider])
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.settings_hud_height_value, refs[const.HUD_NAMES.settings_hud_height_value])

	player_data.set_hud_element_ref(
		player_index,
		const.HUD_NAMES.settings_hud_refresh_rate_slider,
		refs[const.HUD_NAMES.settings_hud_refresh_rate_slider]
	)
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.settings_hud_refresh_rate_value, refs[const.HUD_NAMES.settings_hud_refresh_rate_value])

	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.settings_root_frame, root_frame)

	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.settings_map_zoom_factor_slider, refs[const.HUD_NAMES.settings_map_zoom_factor_slider])
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.settings_map_zoom_factor_value, refs[const.HUD_NAMES.settings_map_zoom_factor_value])

	-- We need to overwrite the "to be opened GUI" with our own GUI
	player.opened = root_frame
	player.opened.force_auto_center()
end

function gui_settings.destroy(player_index)
	local root_frame = get_settings_root_frame(player_index)
	if root_frame then
		root_frame.destroy()
		player_data.destroy_hud_ref(player_index, const.HUD_NAMES.settings_root_frame)
	end
end

function gui_settings.reset(player_index)
	gui_settings.destroy(player_index)
	gui_settings.create(player_index)
end

function gui_settings.reset_all_players()
	for _, player in pairs(game.players) do
		gui_settings.reset(player.index)
	end
end

gui_handlers[const.SETTINGS.hide_hud_header] = function(params)
    player_settings.set_hide_hud_header_setting(params.player_index, params.value)
    gui_hud.reset(params.player_index)
    return
end

-- Set HUD Title
gui_handlers[const.SETTINGS.hud_title] = function(params)
    player_settings.set_hud_title_setting(params.player_index, params.value)
    local hud_ref = player_data.get_hud_ref(params.player_index, const.HUD_NAMES.hud_title_label)
    if hud_ref then
        hud_ref.caption = params.value
    end
    return
end

-- Set HUD Position
gui_handlers[const.SETTINGS.hud_position] = function(params)
    player_settings.set_hud_position_setting(params.player_index, const.HUD_POSITION_INDEX[params.value])
    gui_hud.reset(params.player_index)
    event_handler.gui_hud_collapse_switch(params.player_index, false)
    return
end

-- HUD Columns Setting
gui_handlers[const.SETTINGS.hud_columns] = function(params)
    player_settings.set_hud_columns_setting(params.player_index, params.value)
    local value_ref = player_data.get_hud_ref(params.player_index, const.HUD_NAMES.settings_hud_columns_value)
    if value_ref then
        value_ref.caption = tostring(params.value)
    end
    return
end

-- HUD Max Height Setting
gui_handlers[const.SETTINGS.hud_height] = function(params)
    player_settings.set_hud_height_setting(params.player_index, params.value)
    local value_ref = player_data.get_hud_ref(params.player_index, const.HUD_NAMES.settings_hud_height_value)
    if value_ref then
        value_ref.caption = tostring(params.value)
    end

    gui_hud.calculate_hud_size(params.player_index)

    return
end

-- HUD Refresh rate Setting
gui_handlers[const.SETTINGS.hud_refresh_rate] = function(params)
    player_settings.set_hud_refresh_rate_setting(params.player_index, params.value)
    local value_ref = player_data.get_hud_ref(params.player_index, const.HUD_NAMES.settings_hud_refresh_rate_value)
    if value_ref then
        value_ref.caption = tostring(params.value)
    end
    return
end

-- Set HUD Sort
gui_handlers[const.SETTINGS.hud_sort] = function(params)
    player_settings.set_hud_sort_setting(params.player_index, const.HUD_SORT_INDEX[params.value])
    gui_hud.reset(params.player_index)
    return
end

-- Uncollapse HUD on new combinator
gui_handlers[const.SETTINGS.uncollapse_hud_on_register_combinator] = function(params)
    player_settings.set_uncollapse_hud_on_register_combinator_setting(params.player_index, params.value)
    return
end

-- Debug mode
gui_handlers[const.SETTINGS.debug_mode] = function(params)
    player_settings.set_debug_mode_setting(params.player_index, params.value)
    return
end

-- Map Zoom
gui_handlers[const.SETTINGS.map_zoom_factor] = function(params)
	player_settings.set_map_zoom_factor_setting(params.player_index, params.value)
	local value_ref = player_data.get_hud_ref(params.player_index, const.HUD_NAMES.settings_map_zoom_factor_value)
	if value_ref then
		value_ref.caption = tostring(params.value)
	end
	return
end

gui_handlers[const.SETTINGS.close] = function(params)
    gui_settings.destroy(params.player_index)
    return
end

flib_gui.add_handlers(gui_handlers, common.gui_wrapper)

return gui_settings
