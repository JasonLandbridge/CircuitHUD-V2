local flib_gui = require("__flib__.gui-beta")
local std_string = require("__stdlib__/stdlib/utils/string")

local const = require("lib.constants")
local combinator = require("globals.combinator")
local common = require("lib.common")

local gui_hud = require("gui.hud-gui")
local combinator_gui = {}

-- Generates the GUI Elements to be placed in children = {} property of a parent
local function generate_signal_filter_table(unit_number)
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

function combinator_gui.create(player_index, unit_number)
	-- Check if it doesn't exist already
	local player = common.get_player(player_index)
	local combinator_gui = combinator_gui.get_combinator_gui(player_index, unit_number)
	if combinator_gui then
		common.debug_log(player_index, "HUD Combinator GUI with unit_number " .. tostring(unit_number) .. " already has a GUI open/created.")
		-- We need to overwrite the "to be opened GUI" with our own GUI
		player.opened = combinator_gui
		player.opened.force_auto_center()
		return
	end

	-- add the frame
	local ui_name = const.HUD_NAMES.combinator_root_frame .. "_" .. tostring(unit_number)
	local refs =
		flib_gui.build(
		player.gui.screen,
		{
			{
				type = "frame",
				name = ui_name,
				style_mods = {
					minimal_width = 500,
					maximal_width = 500
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
								caption = "HUD Combinator",
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
								caption = "Name",
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
										caption = {"hud_combinator_gui.filter_label"}
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
												left_label_caption = {"hud_combinator_gui.switch_off"},
												right_label_caption = {"hud_combinator_gui.switch_on"},
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
							-- Divider
							{type = "line", style_mods = {top_margin = 5}},
							-- Signal Table
							{
								type = "flow",
								direction = "vertical",
								style_mods = {horizontal_align = "center"},
								children = {
									-- Filters Label
									{
										type = "label",
										style = "heading_2_label",
										style_mods = {top_margin = 5},
										caption = {"hud_combinator_gui.filter_signals_label"}
									},
									-- Filters Signals
									{
										type = "frame",
										direction = "vertical",
										style = "slot_button_deep_frame",
										children = {
											{
												ref = {"signal_table"},
												type = "table",
												style = "slot_table",
												save_as = "signal_table",
												style_mods = {width = 400},
												column_count = 10,
												children = generate_signal_filter_table(unit_number)
											}
										}
									},
									{
										type = "flow",
										direction = "horizontal",
										style_mods = {vertical_align = "center", top_padding = 10},
										children = {
											{
												type = "slider",
												save_as = "signal_value_slider",
												style_mods = {
													horizontally_stretchable = true,
													right_padding = 10
												},
												minimum_value = -1,
												maximum_value = 100
											},
											{
												type = "textfield",
												style = "short_number_textfield",
												save_as = "signal_value_text",
												elem_mods = {numeric = true, text = "0", allow_negative = false}
											},
											{
												type = "sprite-button",
												sprite = "utility/check_mark",
												style_mods = {left_padding = 5},
												save_as = "signal_value_confirm"
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

	refs.hud_preview.visible = true
	refs.hud_preview.entity = combinator.get_hud_combinator_entity(unit_number)

	-- We need to overwrite the "to be opened GUI" with our own GUI
	player.opened = root_frame
	player.opened.force_auto_center()
end

function combinator_gui.update(player_index, unit_number)
	local tmp_name = combinator.get_hud_combinator_temp_name(unit_number)
	if tmp_name ~= "" then
		for _, player in pairs(game.players) do
			local combinator_gui = combinator_gui.get_combinator_gui(player.index)
			if combinator_gui then
				flib_gui.update(
					combinator_gui,
					{
						-- Root Frame
						{
							children = {
								-- Entity preview
								{},
								-- Combinator Name Label
								{},
								-- Name Text field flow
								{
									children = {
										-- Name Text field
										{
											text = tmp_name
										}
									}
								}
							}
						}
					}
				)
			end
		end
	end
end

function combinator_gui.get_combinator_gui(player_index, unit_number)
	local player = common.get_player(player_index)
	if player then
		local gui_windows = player.gui.screen.children
		for _, value in pairs(gui_windows) do
			if std_string.ends_with(value.name, tostring(unit_number)) then
				return value
			end
		end
	end
	return nil
end

function combinator_gui.get_combinator_gui_by_name(player_index, name)
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

function combinator_gui.destroy(player_index, name)
	local combinator_gui = combinator_gui.get_combinator_gui_by_name(player_index, name)
	if combinator_gui then
		combinator_gui.destroy()
	end
end

function combinator_gui.event_handler(player_index, action)
	local unit_number = action["unit_number"]
	local combinator_gui = combinator_gui.get_combinator_gui(player_index, unit_number)
	if not combinator_gui then
		return
	end

	if action.action == const.GUI_ACTIONS.close then
		combinator.set_hud_combinator_temp_name(unit_number, "")
		combinator_gui.destroy()
		return
	end

	if action.action == const.GUI_ACTIONS.switch_filter_state then
		combinator.set_hud_combinator_filter_state(unit_number, action["value"])
		-- Reset HUD all players on update
		gui_hud.reset_all_players()
		return
	end

	if action.action == const.GUI_ACTIONS.filter_signal_update then
		combinator.set_hud_combinator_filter(unit_number, action.index, action["value"])
		-- Reset HUD all players on update
		gui_hud.reset_all_players()
		return
	end

	if action.action == const.GUI_ACTIONS.name_change then
		combinator.set_hud_combinator_temp_name(unit_number, action["value"])
		combinator_gui.update(player_index, unit_number)
		return
	end

	if action.action == const.GUI_ACTIONS.name_change_confirm then
		-- Set the confirmed name from the temp name
		local tmp_name = combinator.get_hud_combinator_temp_name(unit_number)
		combinator.set_hud_combinator_name(unit_number, tmp_name)
		-- Reset the temp name again
		combinator.set_hud_combinator_temp_name(unit_number, "")
		-- Reset HUD all players on update
		gui_hud.reset_all_players()
		return
	end
end

return combinator_gui
