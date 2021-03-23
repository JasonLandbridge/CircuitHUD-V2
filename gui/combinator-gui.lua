local flib_gui = require("__flib__.gui-beta")
local std_string = require("__stdlib__/stdlib/utils/string")

local const = require("lib.constants")
local combinator = require("globals.combinator")
local common = require("lib.common")
local event_handler = require("events.event-handler")
local player_data = require("globals.player-data")
local gui_hud = require("gui.hud-gui")
local gui_combinator = {}

-- Generates the GUI Elements to be placed in children = {} property of a parent
local function generate_signal_filter_table(unit_number)
	if not unit_number then
		return
	end

	local result = {}
	local filters = combinator.get_hud_combinator_filters(unit_number)
	for i = 1, 50, 1 do
		result[i] = {
			name = "circuit_hud_signal_button__" .. i,
			type = "choose-elem-button",
			style = "flib_slot_button_default",
			elem_type = "signal",
			signal = filters[i], -- If this slot has a signal assigned, than set this signal here
			actions = {
				on_elem_changed = {
					gui = const.GUI_TYPES.combinator,
					action = const.GUI_ACTIONS.filter_signal_update,
					index = i,
					unit_number = unit_number
				}
			}
		}
	end

	return result
end

function gui_combinator.create(player_index, unit_number)
	-- Check if it doesn't exist already
	local player = common.get_player(player_index)
	local combinator_gui = gui_combinator.get_combinator_gui(player_index, unit_number)
	if combinator_gui then
		common.debug_log(player_index, "HUD Combinator GUI with unit_number " .. tostring(unit_number) .. " already has a GUI open/created.")
		-- We need to overwrite the "to be opened GUI" with our own GUI
		player.opened = combinator_gui
		player.opened.force_auto_center()
		return
	end

	-- add the frame
	local hud_combinator = combinator.get_hud_combinator(unit_number)
	local refs =
		flib_gui.build(
		player.gui.screen,
		{
			{
				type = "frame",
				name = const.HUD_NAMES.combinator_root_frame,
				style_mods = {
					minimal_width = 456,
					maximal_width = 456
				},
				ref = {
					const.HUD_NAMES.combinator_root_frame
				},
				direction = "vertical",
				children = {
					-- Titlebar
					{
						type = "flow",
						ref = {"titlebar_flow"},
						style = "flib_titlebar_flow",
						children = {
							{
								-- add the title label
								type = "label",
								style = "frame_title",
								ref = {const.HUD_NAMES.combinator_title_label},
								caption = hud_combinator.name,
								ignored_by_interaction = true
							},
							{
								-- add a pusher (so the close button becomes right-aligned)
								type = "empty-widget",
								style = "flib_titlebar_drag_handle",
								ignored_by_interaction = true
							},
							{
								type = "sprite-button",
								style = "frame_action_button",
								sprite = "utility/close_white",
								actions = {
									on_click = {
										gui = const.GUI_TYPES.combinator,
										action = const.GUI_ACTIONS.close,
										unit_number = unit_number
									}
								}
							}
						}
					},
					-- GUI Layout
					{
						type = "frame",
						style = "inside_shallow_frame_with_padding",
						direction = "vertical",
						ref = {"inner_frame"},
						-- Combinator Main Pane
						children = {
							-- Entity preview
							{
								type = "frame",
								style = "container_inside_shallow_frame",
								style_mods = {bottom_margin = 8},
								children = {
									{
										type = "entity-preview",
										ref = {"hud_preview"},
										style_mods = {
											height = 140,
											horizontally_stretchable = true
										}
									}
								}
							},
							-- Combinator Name
							{
								type = "label",
								caption = {"chv2_combinator_gui.name"},
								style = "heading_2_label"
							},
							-- Name Text field flow
							{
								type = "flow",
								direction = "horizontal",
								style = "flib_titlebar_flow",
								children = {
									{
										-- Name Text field
										type = "textfield",
										ref = {
											"name_field"
										},
										style = "stretchable_textfield",
										text = combinator.get_hud_combinator_name(unit_number),
										actions = {
											on_text_changed = {
												gui = const.GUI_TYPES.combinator,
												action = const.GUI_ACTIONS.name_change,
												unit_number = unit_number
											}
										}
									},
									-- confirm button
									{
										type = "sprite-button",
										style = "item_and_count_select_confirm",
										sprite = "utility/check_mark",
										actions = {
											on_click = {
												gui = const.GUI_TYPES.combinator,
												action = const.GUI_ACTIONS.name_change_confirm,
												unit_number = unit_number
											}
										}
									}
								}
							},
							-- Divider
							{type = "line", style_mods = {top_margin = 5}},
							-- Incoming signals label
							{
								type = "label",
								caption = {"chv2_combinator_gui.incoming_signals"},
								style = "heading_2_label"
							},
							-- Signal Preview
							{
								type = "scroll-pane",
								direction = "vertical",
								vertical_scroll_policy = "auto-and-reserve-space",
								horizontal_scroll_policy = "never",
								style = "flib_naked_scroll_pane_no_padding",
								style_mods = {
									minimal_height = 100,
									maximal_height = 250,
									horizontally_stretchable = true
								},
								ref = {
									const.HUD_NAMES.combinator_signal_preview
								}
							},
							-- Divider
							{type = "line", style_mods = {top_margin = 5}},
							{
								type = "flow",
								direction = "vertical",
								children = {
									-- On/Off filter switch
									{
										type = "flow",
										direction = "horizontal",
										style = "flib_titlebar_flow",
										children = {
											{
												type = "label",
												style = "heading_2_label",
												style_mods = {top_margin = 4, bottom_margin = 4},
												caption = {"chv2_combinator_gui.filter_signals_label"}
											},
											{
												type = "flow",
												direction = "horizontal",
												style = "flib_titlebar_flow",
												style_mods = {top_margin = 6, bottom_margin = 4},
												children = {
													{
														type = "switch",
														switch_state = common.short_if(combinator.get_hud_combinator_filter_state(unit_number), "right", "left"),
														left_label_caption = {"chv2_combinator_gui.switch_off"},
														right_label_caption = {"chv2_combinator_gui.switch_on"},
														actions = {
															on_switch_state_changed = {
																gui = const.GUI_TYPES.combinator,
																action = const.GUI_ACTIONS.switch_filter_state,
																unit_number = unit_number
															}
														}
													}
												}
											}
										}
									},
									-- Filters Signals table
									{
										type = "frame",
										direction = "vertical",
										style = "slot_button_deep_frame",
										children = {
											{
												ref = {"signal_table"},
												type = "table",
												style = "slot_table",
												style_mods = {width = 400},
												column_count = 10,
												children = generate_signal_filter_table(unit_number)
											}
										}
									}
								}
							},
							-- Divider
							{type = "line", style_mods = {top_margin = 5}},
							{
								type = "flow",
								direction = "horizontal",
								style_mods = {vertical_align = "center", top_padding = 10},
								children = {
									-- add the priority order label
									{
										type = "label",
										style = const.STYLES.settings_title_label,
										caption = {"chv2_combinator_gui.priority_label"},
										tooltip = {"chv2_combinator_gui_tooltips.priority_label"}
									},
									-- priority change slider
									{
										type = "slider",
										style = const.STYLES.settings_slider,
										style_mods = {
											horizontally_stretchable = true,
											right_padding = 10
										},
										ref = {const.HUD_NAMES.combinator_priority_slider},
										value = hud_combinator.priority,
										minimum_value = -100,
										maximum_value = 100,
										actions = {
											on_value_changed = {
												gui = const.GUI_TYPES.combinator,
												action = const.GUI_ACTIONS.priority_change,
												unit_number = unit_number
											}
										}
									},
									-- priority change label
									{
										type = "label",
										caption = tostring(hud_combinator.priority),
										style = const.STYLES.slider_count_label,
										ref = {const.HUD_NAMES.combinator_priority_value}
									},
									-- priority change confirm button
									{
										type = "sprite-button",
										style = "item_and_count_select_confirm",
										sprite = "utility/check_mark",
										actions = {
											on_click = {
												gui = const.GUI_TYPES.combinator,
												action = const.GUI_ACTIONS.priority_change_confirm,
												unit_number = unit_number
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

	local root_frame = refs[const.HUD_NAMES.combinator_root_frame]
	refs.titlebar_flow.drag_target = root_frame
	refs.name_field.select(0, 0)

	refs.hud_preview.entity = hud_combinator.entity

	-- Render the preview signals
	gui_hud.render_signals(hud_combinator, refs[const.HUD_NAMES.combinator_signal_preview], 10, {})

	-- We need to overwrite the "to be opened GUI" with our own GUI
	player.opened = root_frame
	player.opened.force_auto_center()

	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.combinator_title_label, refs[const.HUD_NAMES.combinator_title_label])
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.combinator_priority_slider, refs[const.HUD_NAMES.combinator_priority_slider])
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.combinator_priority_value, refs[const.HUD_NAMES.combinator_priority_value])
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.combinator_signal_preview, refs[const.HUD_NAMES.combinator_signal_preview])

	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.combinator_name_textfield, refs[const.HUD_NAMES.combinator_name_textfield])
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.combinator_root_frame, root_frame)
end

function gui_combinator.update(player_index, unit_number)
	local tmp_name = combinator.get_hud_combinator_temp_name(unit_number)
	if tmp_name ~= "" then
		local combinator_name_textfield_ref = player_data.get_hud_ref(player_index, const.HUD_NAMES.combinator_name_textfield)
		if combinator_name_textfield_ref then
			combinator_name_textfield_ref.text = tmp_name
		end
	end
end

function gui_combinator.get_combinator_gui(player_index, unit_number)
	local player = common.get_player(player_index)
	if player then
		local gui_windows = player.gui.screen.children
		for _, value in pairs(gui_windows) do
			if value.name == const.HUD_NAMES.combinator_root_frame then
				return value
			end
		end
	end
	return nil
end

function gui_combinator.get_combinator_gui_by_name(player_index, name)
	local player = common.get_player(player_index)
	if player then
		local gui_windows = player.gui.screen.children
		for _, value in pairs(gui_windows) do
			if value.name == name then
				return value
			end
		end
	end
	return nil
end

function gui_combinator.destroy(player_index, name)
	local combinator_gui = gui_combinator.get_combinator_gui_by_name(player_index, name)
	if combinator_gui then
		combinator_gui.destroy()
	end
end

function gui_combinator.destroy_all(player_index)
	local player = common.get_player(player_index)
	if player then
		local gui_windows = player.gui.screen.children
		for _, value in pairs(gui_windows) do
			if value.name == const.HUD_NAMES.combinator_root_frame then
				return value.destroy()
			end
		end
	end
end

function gui_combinator.reset(player_index, unit_number)
	gui_combinator.destroy_all(player_index)
	gui_combinator.create(player_index, unit_number)
	gui_combinator.update(player_index, unit_number)
end

function gui_combinator.reset_all_players()
	for _, player in pairs(game.players) do
		gui_combinator.reset(player.index)
	end
end

function gui_combinator.event_handler(player_index, action)
	local unit_number = action["unit_number"]
	local value = action["value"]

	if action.action == const.GUI_ACTIONS.close then
		combinator.set_hud_combinator_temp_name(unit_number, "")
		local combinator_gui_ref = gui_combinator.get_combinator_gui(player_index, unit_number)
		if combinator_gui_ref then
			combinator_gui_ref.destroy()
		end
		return
	end

	if action.action == const.GUI_ACTIONS.switch_filter_state then
		combinator.set_hud_combinator_filter_state(unit_number, value)
		-- Reset HUD all players on update
		event_handler.gui_hud_reset_all_players()
		return
	end

	if action.action == const.GUI_ACTIONS.filter_signal_update then
		combinator.set_hud_combinator_filter(unit_number, action.index, value)
		-- Reset HUD all players on update
		event_handler.gui_hud_reset_all_players()
		return
	end

	if action.action == const.GUI_ACTIONS.name_change then
		combinator.set_hud_combinator_temp_name(unit_number, value)
		return
	end

	if action.action == const.GUI_ACTIONS.name_change_confirm then
		-- Set the confirmed name from the temp name
		local tmp_name = combinator.get_hud_combinator_temp_name(unit_number)
		combinator.set_hud_combinator_name(unit_number, tmp_name)

		local title_ref = player_data.get_hud_ref(player_index, const.HUD_NAMES.combinator_title_label)
		if title_ref then
			title_ref.caption = tmp_name
		end
		-- Reset the temp name again
		combinator.set_hud_combinator_temp_name(unit_number, "")
		-- Reset HUD all players on update
		event_handler.gui_hud_reset_all_players()
		return
	end

	if action.action == const.GUI_ACTIONS.priority_change then
		local label_ref = player_data.get_hud_ref(player_index, const.HUD_NAMES.combinator_priority_value)
		if label_ref then
			label_ref.caption = tostring(value)
		end
		return
	end

	if action.action == const.GUI_ACTIONS.priority_change_confirm then
		local slider_ref = player_data.get_hud_ref(player_index, const.HUD_NAMES.combinator_priority_slider)
		if slider_ref then
			combinator.set_hud_combinator_priority(unit_number, slider_ref.slider_value)
			event_handler.gui_hud_reset_all_players()
		end
		return
	end
end

return gui_combinator
