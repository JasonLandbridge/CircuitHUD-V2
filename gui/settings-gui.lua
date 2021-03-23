local flib_gui = require("__flib__.gui-beta")

local const = require("lib.constants")
local common = require("lib.common")
local player_settings = require("globals.player-settings")
local player_data = require("globals.player-data")
local event_handler = require("events.event-handler")

local gui_hud = require("gui.hud-gui")
local gui_settings = {}

local function get_settings_root_frame(player_index)
	return player_data.get_hud_ref(player_index, const.HUD_NAMES.settings_root_frame)
end

function gui_settings.create(player_index)
	if get_settings_root_frame(player_index) then
		return
	end
	local player = common.get_player(player_index)

	local refs =
		flib_gui.build(
		player.gui.screen,
		{
			{
				type = "frame",
				style_mods = {
					minimal_width = 500,
					maximal_width = 500
				},
				name = const.HUD_NAMES.settings_root_frame,
				ref = {
					const.HUD_NAMES.settings_root_frame
				},
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
								ref = {"titlebar_flow"}
							},
							{
								type = "sprite-button",
								style = "frame_action_button",
								sprite = "utility/close_white",
								actions = {
									on_click = {
										gui = const.GUI_TYPES.settings,
										action = const.GUI_ACTIONS.close
									}
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
										actions = {
											on_click = {
												gui = const.GUI_TYPES.settings,
												action = const.GUI_ACTIONS.update_settings,
												name = const.SETTINGS.hide_hud_header
											}
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
										actions = {
											on_selection_state_changed = {
												gui = const.GUI_TYPES.settings,
												action = const.GUI_ACTIONS.update_settings,
												name = const.SETTINGS.hud_position
											}
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
										ref = {
											"name_field"
										},
										style = "stretchable_textfield",
										text = player_settings.get_hud_title_setting(player_index),
										actions = {
											on_text_changed = {
												gui = const.GUI_TYPES.settings,
												action = const.GUI_ACTIONS.update_settings,
												name = const.SETTINGS.hud_title
											}
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
												ref = {const.HUD_NAMES.settings_hud_columns_slider},
												value = player_settings.get_hud_columns_setting(player_index),
												minimum_value = 4,
												maximum_value = 30,
												actions = {
													on_value_changed = {
														gui = const.GUI_TYPES.settings,
														action = const.GUI_ACTIONS.update_settings,
														name = const.SETTINGS.hud_columns
													}
												}
											}
										}
									},
									{
										type = "label",
										caption = tostring(player_settings.get_hud_columns_setting(player_index)),
										style = const.STYLES.slider_count_label,
										ref = {const.HUD_NAMES.settings_hud_columns_value}
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
												ref = {const.HUD_NAMES.settings_hud_height_slider},
												value = player_settings.get_hud_height_setting(player_index),
												minimum_value = 50,
												maximum_value = 2160,
												actions = {
													on_value_changed = {
														gui = const.GUI_TYPES.settings,
														action = const.GUI_ACTIONS.update_settings,
														name = const.SETTINGS.hud_height
													}
												}
											}
										}
									},
									{
										type = "label",
										caption = tostring(player_settings.get_hud_height_setting(player_index)),
										style = const.STYLES.slider_count_label,
										ref = {const.HUD_NAMES.settings_hud_height_value}
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
												ref = {const.HUD_NAMES.settings_hud_refresh_rate_slider},
												value = player_settings.get_hud_refresh_rate_setting(player_index),
												minimum_value = 1,
												maximum_value = 600,
												actions = {
													on_value_changed = {
														gui = const.GUI_TYPES.settings,
														action = const.GUI_ACTIONS.update_settings,
														name = const.SETTINGS.hud_refresh_rate
													}
												}
											}
										}
									},
									{
										type = "label",
										caption = tostring(player_settings.get_hud_refresh_rate_setting(player_index)),
										style = const.STYLES.slider_count_label,
										ref = {const.HUD_NAMES.settings_hud_refresh_rate_value}
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
										actions = {
											on_selection_state_changed = {
												gui = const.GUI_TYPES.settings,
												action = const.GUI_ACTIONS.update_settings,
												name = const.SETTINGS.hud_sort
											}
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
										actions = {
											on_click = {
												gui = const.GUI_TYPES.settings,
												action = const.GUI_ACTIONS.update_settings,
												name = const.SETTINGS.uncollapse_hud_on_register_combinator
											}
										}
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
										actions = {
											on_click = {
												gui = const.GUI_TYPES.settings,
												action = const.GUI_ACTIONS.update_settings,
												name = const.SETTINGS.debug_mode
											}
										}
									}
								}
							}
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
	-- We need to overwrite the "to be opened GUI" with our own GUI
	player.opened = root_frame
	player.opened.force_auto_center()
end

function gui_settings.event_handler(player_index, action)
	local value = action["value"]
	-- Setting update
	if action.action == const.GUI_ACTIONS.update_settings then
		-- Hide HUD Setting
		if action.name == const.SETTINGS.hide_hud_header then
			player_settings.set_hide_hud_header_setting(player_index, value)
			gui_hud.reset(player_index)
			return
		end

		-- Set HUD Title
		if action.name == const.SETTINGS.hud_title then
			player_settings.set_hud_title_setting(player_index, value)
			local hud_ref = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_title_label)
			if hud_ref then
				hud_ref.caption = value
			end
			return
		end

		-- Set HUD Position
		if action.name == const.SETTINGS.hud_position then
			player_settings.set_hud_position_setting(player_index, const.HUD_POSITION_INDEX[value])
			gui_hud.reset(player_index)
			event_handler.gui_hud_collapse_switch(player_index, false)
			return
		end

		-- HUD Columns Setting
		if action.name == const.SETTINGS.hud_columns then
			player_settings.set_hud_columns_setting(player_index, value)
			local value_ref = player_data.get_hud_ref(player_index, const.HUD_NAMES.settings_hud_columns_value)
			if value_ref then
				value_ref.caption = tostring(value)
			end
			return
		end

		-- HUD Max Height Setting
		if action.name == const.SETTINGS.hud_height then
			player_settings.set_hud_height_setting(player_index, value)
			local value_ref = player_data.get_hud_ref(player_index, const.HUD_NAMES.settings_hud_height_value)
			if value_ref then
				value_ref.caption = tostring(value)
			end

			gui_hud.calculate_hud_size(player_index)

			return
		end

		-- HUD Refresh rate Setting
		if action.name == const.SETTINGS.hud_refresh_rate then
			player_settings.set_hud_refresh_rate_setting(player_index, value)
			local value_ref = player_data.get_hud_ref(player_index, const.HUD_NAMES.settings_hud_refresh_rate_value)
			if value_ref then
				value_ref.caption = tostring(value)
			end
			return
		end

		-- Set HUD Sort
		if action.name == const.SETTINGS.hud_sort then
			player_settings.set_hud_sort_setting(player_index, const.HUD_SORT_INDEX[value])
			gui_hud.reset(player_index)
			return
		end

		-- Uncollapse HUD on new combinator
		if action.name == const.SETTINGS.uncollapse_hud_on_register_combinator then
			player_settings.set_uncollapse_hud_on_register_combinator_setting(player_index, value)
			return
		end

		-- Debug mode
		if action.name == const.SETTINGS.debug_mode then
			player_settings.set_debug_mode_setting(player_index, value)
			return
		end
	end

	if action.action == const.GUI_ACTIONS.close then
		gui_settings.destroy(player_index)
		return
	end
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

return gui_settings
