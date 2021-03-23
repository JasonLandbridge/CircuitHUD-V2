local stdlib_math = require("__stdlib__/stdlib/utils/math")
local stdlib_string = require("__stdlib__/stdlib/utils/string")
local flib_gui = require("__flib__.gui-beta")

local const = require("lib.constants")
local common = require("lib.common")
local player_settings = require("globals.player-settings")
local combinator = require("globals.combinator")
local player_data = require("globals.player-data")
local event_handler = require("events.event-handler")

local gui_hud = {}

-- Checks if the signal is allowed to be shown based on the filters set for this HUD Combinator
-- @returns if signal is allowed to be shown
local function filter_signal(signals, name)
	if table_size(signals) == 0 then
		return true
	end
	for _, value in pairs(signals) do
		if value.name == name then
			return true
		end
	end
	return false
end

local function sort_hud_combinators(hud_combinators, player_index)
	local sort_mode = player_settings.get_hud_sort_setting(player_index)

	-- Create an array from an indexed table
	-- Source: https://stackoverflow.com/q/24164118/8205497
	local combinator_array = {}
	for _, v in pairs(hud_combinators) do
		table.insert(combinator_array, {name = v.name, unit_number = v.unit_number, priority = v.priority, entity = v.entity})
	end

	-- None
	if sort_mode == const.HUD_SORT.none then
		return combinator_array
	end

	-- Ascending
	if sort_mode == const.HUD_SORT.name_ascending then
		table.sort(
			combinator_array,
			function(a, b)
				return a.name:lower() < b.name:lower()
			end
		)
	end

	-- Descending
	if sort_mode == const.HUD_SORT.name_descending then
		table.sort(
			combinator_array,
			function(a, b)
				return a.name:lower() > b.name:lower()
			end
		)
	end

	-- Priority Ascending
	if sort_mode == const.HUD_SORT.build_order_ascending then
		table.sort(
			combinator_array,
			function(a, b)
				if a.unit_number == b.unit_number then
					return a.name:lower() < b.name:lower()
				end
				return a.unit_number < b.unit_number
			end
		)
	end

	-- Priority Descending
	if sort_mode == const.HUD_SORT.build_order_descending then
		table.sort(
			combinator_array,
			function(a, b)
				if a.unit_number == b.unit_number then
					return a.name:lower() > b.name:lower()
				end
				return a.unit_number > b.unit_number
			end
		)
	end

	-- Priority Ascending
	if sort_mode == const.HUD_SORT.priority_ascending then
		table.sort(
			combinator_array,
			function(a, b)
				if a.priority == b.priority then
					return a.name:lower() < b.name:lower()
				end
				return a.priority < b.priority
			end
		)
	end

	-- Priority Descending
	if sort_mode == const.HUD_SORT.priority_descending then
		table.sort(
			combinator_array,
			function(a, b)
				if a.priority == b.priority then
					return a.name:lower() > b.name:lower()
				end
				return a.priority > b.priority
			end
		)
	end

	return combinator_array
end

function gui_hud.render_signals(hud_combinator, parent_gui, max_columns, signals_filter)
	local unit_number = hud_combinator.unit_number
	local should_filter = combinator.get_hud_combinator_filter_state(unit_number)

	local red_network = hud_combinator.entity.get_circuit_network(defines.wire_type.red)
	local green_network = hud_combinator.entity.get_circuit_network(defines.wire_type.green)

	local networks = {green_network, red_network}
	local network_colors = {"green", "red"}
	local network_styles = {"green_circuit_network_content_slot", "red_circuit_network_content_slot"}

	-- NOTE: This should remain local as it causes desync and save/load issues if moved elsewhere
	local signal_name_map = {
		["item"] = game.item_prototypes,
		["virtual"] = game.virtual_signal_prototypes,
		["fluid"] = game.fluid_prototypes
	}

	local hide_signal_detected = false
	local signal_total_count = 0
	local signal_count = 0
	-- Display the item signals coming from the red and green circuit if any
	for i = 1, 2, 1 do
		-- Check if this color table already exists
		local table_name = "hud_combinator_" .. network_colors[i] .. "_table"
		local table =
			flib_gui.build(
			parent_gui,
			{
				{
					type = "table",
					name = table_name,
					column_count = max_columns,
					ref = {"table"},
					style_mods = {
						top_margin = 4
					}
				}
			}
		)

		-- Check if there are signals
		if networks[i] and networks[i].signals then
			-- Add to total signal count
			signal_total_count = signal_total_count + table_size(networks[i].signals)
			for j, signal in pairs(networks[i].signals) do
				local signal_type = signal.signal.type
				local signal_name = signal.signal.name

				-- Check if any signal is meant to hide everything
				if hide_signal_detected or signal_name == const.HIDE_SIGNAL_NAME then
					hide_signal_detected = true
					break
				end

				-- Check if this signal should be shown based on filtering
				if common.short_if(should_filter, filter_signal(signals_filter, signal_name), true) then
					table["table"].add {
						type = "sprite-button",
						sprite = const.SIGNAL_TYPE_MAP[signal_type] .. "/" .. signal_name,
						number = signal.count,
						style = network_styles[i],
						tooltip = signal_name_map[signal_type][signal_name].localised_name
					}
					signal_count = signal_count + 1
				end
			end
		end
	end

	return {
		hide_signal_detected = hide_signal_detected,
		signal_count = signal_count,
		signal_total_count = signal_total_count
	}
end

-- Takes the data from HUD Combinator and display it in the HUD
-- @param scroll_pane_frame The Root frame
-- @param hud_combinator The HUD Combinator to process
function gui_hud.render_combinator(scroll_pane_frame, player_index, unit_number)
	-- Check flow container for the HUD Combinator category if it doesnt exist
	local hud_combinator = combinator.get_hud_combinator(unit_number)
	local visible = player_data.get_hud_combinator_visibilty(player_index, unit_number)
	local flow_id = "hud_combinator_flow_" .. tostring(unit_number)
	local refs =
		flib_gui.build(
		scroll_pane_frame,
		{
			{
				type = "flow",
				direction = "vertical",
				name = flow_id,
				style = "combinator_flow_style",
				ref = {"hud_combinator_flow"},
				children = {
					{
						type = "flow",
						direction = "horizontal",
						style = "flib_titlebar_flow",
						children = {
							{
								type = "label",
								style = "hud_combinator_label",
								caption = combinator.get_hud_combinator_name(unit_number),
								name = "hud_combinator_title_" .. tostring(unit_number)
							},
							{type = "empty-widget", style = "flib_horizontal_pusher", ignored_by_interaction = true},
							{
								type = "button",
								tooltip = {"chv2_button_tooltips.go_to_combinator"},
								style = const.BUTTON_STYLES.go_to_button,
								actions = {
									on_click = {
										gui = const.GUI_TYPES.hud,
										action = const.GUI_ACTIONS.go_to_combinator,
										unit_number = unit_number
									}
								}
							},
							{
								type = "button",
								tooltip = {"chv2_button_tooltips.open_combinator"},
								style = const.BUTTON_STYLES.edit_button,
								actions = {
									on_click = {
										gui = const.GUI_TYPES.hud,
										action = const.GUI_ACTIONS.open_combinator,
										unit_number = unit_number
									}
								}
							},
							{
								type = "button",
								tooltip = common.short_if(visible, {"chv2_button_tooltips.hide_combinator"}, {"chv2_button_tooltips.show_combinator"}),
								style = common.short_if(visible, const.BUTTON_STYLES.hide_button, const.BUTTON_STYLES.show_button),
								actions = {
									on_click = {
										gui = const.GUI_TYPES.hud,
										action = common.short_if(visible, const.GUI_ACTIONS.hide_combinator, const.GUI_ACTIONS.show_combinator),
										unit_number = unit_number
									}
								}
							}
						}
					}
				}
			}
		}
	)

	if visible then
		local combinator_refs =
			flib_gui.build(
			refs["hud_combinator_flow"],
			{
				{
					type = "flow",
					direction = "vertical",
					style = "packed_vertical_flow",
					ref = {"combinator_content"}
				}
			}
		)

		local combinator_content = combinator_refs.combinator_content
		-- Check if this HUD Combinator has any signals coming in to show in the HUD.
		local max_columns = player_settings.get_hud_columns_setting(scroll_pane_frame.player_index)
		local signals_filter = combinator.get_hud_combinator_filters(unit_number)
		local should_filter = combinator.get_hud_combinator_filter_state(unit_number)

		if should_filter and table_size(signals_filter) == 0 then
			combinator_content.add {type = "label", style = "hud_combinator_label", caption = "Filter is on but no signals have been selected"}
			return
		end

		local result = gui_hud.render_signals(hud_combinator, combinator_content, max_columns, signals_filter)

		if result.hide_signal_detected then
			refs.hud_combinator_flow.destroy()
			return
		end

		-- No signals were shown due to too strict filtering circuit
		if result.signal_count == 0 and result.signal_total_count > 0 then
			combinator_content.clear()
			combinator_content.add {type = "label", style = "hud_combinator_label", caption = "No signals passed filtering"}
			return
		end

		-- No signals were shown due to now signals on the connected circuit
		if result.signal_count == 0 and result.signal_total_count == 0 then
			combinator_content.clear()
			combinator_content.add {type = "label", style = "hud_combinator_label", caption = "No signal"}
			return
		end
	end
end

-- Build the HUD with the signals
-- @param player_index The index of the player
function gui_hud.create(player_index)
	-- First check if there are any existing HUD combinator
	if not combinator.has_hud_combinators() then
		common.debug_log(player_index, "There are no HUD Combinators registered so we can't create the HUD")
		return
	end

	if player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_root_frame) then
		common.debug_log(player_index, "Can't create a new HUD while the old one still exists")
		return
	end

	local player = common.get_player(player_index)

	local hud_position = player_settings.get_hud_position_setting(player_index)
	local parent_ref = nil
	local is_collapsed = player_data.get_hud_collapsed(player_index)
	local is_header_hidden = player_settings.get_hide_hud_header_setting(player_index)

	-- Set HUD on the left or top side of screen
	if player_data.get_is_hud_left(player_index) or player_data.get_is_hud_top(player_index) or player_data.get_is_hud_goal(player_index) then
		parent_ref = player.gui[hud_position]
	end

	-- Set HUD to be draggable
	if player_data.get_is_hud_draggable(player_index) or player_data.get_is_hud_bottom_right(player_index) then
		parent_ref = player.gui.screen
	end

	local root_refs =
		flib_gui.build(
		parent_ref,
		{
			{
				type = "frame",
				direction = "vertical",
				name = const.HUD_NAMES.hud_root_frame,
				style = const.STYLES.hud_root_frame_style,
				ref = {const.HUD_NAMES.hud_root_frame},
				children = {
					{
						type = "flow",
						direction = "horizontal",
						ref = {const.HUD_NAMES.hud_header_flow}
					}
				}
			}
		}
	)

	local root_frame = root_refs[const.HUD_NAMES.hud_root_frame]
	local header_flow = root_refs[const.HUD_NAMES.hud_header_flow]

	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_root_frame, root_frame)
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_header_flow, header_flow)

	-- Set references to root GUI Elements

	-- Only create header when the settings allow for it
	if not is_header_hidden and not is_collapsed then
		-- create a title_flow

		local header_style = "flib_horizontal_pusher"
		if player_data.get_is_hud_draggable(player_index) then
			header_style = "flib_titlebar_drag_handle"
		end

		local header_refs =
			flib_gui.build(
			header_flow,
			{
				-- add the title label
				{
					type = "label",
					style = "frame_title",
					name = const.HUD_NAMES.hud_title_label,
					ref = {const.HUD_NAMES.hud_title_label},
					caption = player_settings.get_hud_title_setting(player_index)
				},
				-- either a draggable frame bar or empty space
				{
					type = "empty-widget",
					style = header_style,
					name = const.HUD_NAMES.hud_header_spacer,
					ref = {const.HUD_NAMES.hud_header_spacer}
				},
				-- Search Text Field
				{
					type = "textfield",
					style = "stretchable_textfield",
					name = const.HUD_NAMES.hud_search_text_field,
					style_mods = {top_margin = -3, bottom_margin = 3},
					visible = false,
					ref = {const.HUD_NAMES.hud_search_text_field},
					actions = {
						on_text_changed = {
							gui = const.GUI_TYPES.hud,
							action = const.GUI_ACTIONS.search_bar_change
						}
					}
				},
				-- Search Button
				{
					type = "sprite-button",
					style = "frame_action_button",
					name = const.HUD_NAMES.hud_search_button,
					ref = {
						const.HUD_NAMES.hud_search_button
					},
					tooltip = {"rcalc-gui.search-instruction"},
					sprite = "utility/search_white",
					hovered_sprite = "utility/search_black",
					clicked_sprite = "utility/search_black",
					mouse_button_filter = {"left"},
					actions = {
						on_click = {
							gui = const.GUI_TYPES.hud,
							action = const.GUI_ACTIONS.toggle_search_bar
						}
					}
				},
				-- Settings Button
				{
					type = "sprite-button",
					style = "frame_action_button",
					name = const.HUD_NAMES.hud_settings_button,
					ref = {
						const.HUD_NAMES.hud_settings_button
					},
					tooltip = {"rb-gui.settings"},
					sprite = "rb_settings_white",
					hovered_sprite = "rb_settings_black",
					clicked_sprite = "rb_settings_black",
					mouse_button_filter = {"left"},
					actions = {
						on_click = {
							gui = const.GUI_TYPES.hud,
							action = const.GUI_ACTIONS.open_settings
						}
					}
				}
			}
		)

		-- Set frame to be draggable
		if player_data.get_is_hud_draggable(player_index) then
			header_refs[const.HUD_NAMES.hud_header_spacer].drag_target = root_frame
		end

		player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_title_label, header_refs[const.HUD_NAMES.hud_title_label])
		player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_header_spacer, header_refs[const.HUD_NAMES.hud_header_spacer])
		player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_search_text_field, header_refs[const.HUD_NAMES.hud_search_text_field])
		player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_search_button, header_refs[const.HUD_NAMES.hud_search_button])
		player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_settings_button, header_refs[const.HUD_NAMES.hud_settings_button])
	end

	-- Add toggle button
	if (is_header_hidden and is_collapsed) or (not is_header_hidden and is_collapsed) or (not is_header_hidden and not is_collapsed) then
		local toggle_refs =
			flib_gui.build(
			header_flow,
			{
				{
					-- Toggle Button
					type = "sprite-button",
					name = const.HUD_NAMES.hud_toggle_button,
					style = "frame_action_button",
					ref = {
						const.HUD_NAMES.hud_toggle_button
					},
					sprite = (player_data.get_hud_collapsed(player_index) == true) and "utility/expand" or "utility/collapse",
					actions = {
						on_click = {
							gui = const.GUI_TYPES.hud,
							action = const.GUI_ACTIONS.toggle
						}
					}
				}
			}
		)
		player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_toggle_button, toggle_refs[const.HUD_NAMES.hud_toggle_button])
	end

	if not is_collapsed then
		local body_refs =
			flib_gui.build(
			root_frame,
			{
				{
					type = "scroll-pane",
					name = const.HUD_NAMES.hud_scroll_pane,
					vertical_scroll_policy = "auto-and-reserve-space",
					style = "flib_naked_scroll_pane_no_padding",
					style_mods = {
						horizontal_align = "center",
						vertically_stretchable = true
					},
					ref = {
						const.HUD_NAMES.hud_scroll_pane
					},
					children = {
						{
							type = "flow",
							name = const.HUD_NAMES.hud_scroll_pane_frame,
							style = "hud_scrollpane_frame_style",
							style_mods = {
								horizontal_align = "center",
								vertically_stretchable = true
							},
							ref = {
								const.HUD_NAMES.hud_scroll_pane_frame
							},
							direction = "vertical"
						}
					}
				}
			}
		)
		player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_scroll_pane, body_refs[const.HUD_NAMES.hud_scroll_pane])
		player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_scroll_pane_frame, body_refs[const.HUD_NAMES.hud_scroll_pane_frame])
	end

	if player_data.get_is_hud_draggable(player_index) then
		root_frame.location = player_data.get_hud_location(player_index)
	end
end

-- Go over each player and ensure that their HUD is either visible or hidden based on the existense of HUD combinators.
function gui_hud.check_all_player_hud_visibility()
	-- go through each player and update their HUD
	for _, player in pairs(game.players) do
		gui_hud.should_hud_root_exist(player.index)
	end
end

-- Check  and ensure if the player has their HUD either visible or hidden based on the existense of HUD combinators.
function gui_hud.should_hud_root_exist(player_index)
	if combinator.has_hud_combinators() then
		-- Ensure we have created the HUD for all players
		if not player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_root_frame) then
			gui_hud.create(player_index)
		end
		gui_hud.update(player_index)
	else
		-- Ensure all HUDS are destroyed
		if player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_root_frame) then
			player_data.destroy_hud(player_index)
		end
	end
end

-- Update the HUD combinator categories and values in the HUD
function gui_hud.update(player_index)
	if not player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_root_frame) then
		common.debug_log(player_index, "Can't update HUD because the HUD root does not exist for player with index: " .. player_index)
		return
	end

	local scroll_pane_frame = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_scroll_pane_frame)
	if not scroll_pane_frame or not scroll_pane_frame.valid then
		common.debug_log(player_index, "Can't update HUD because the scroll_pane_frame does not exist for player with index: " .. player_index)
	end

	if combinator.has_hud_combinators() and not player_data.get_hud_collapsed(player_index) then
		-- Clear the frame which has the signals displayed to start the update
		scroll_pane_frame.clear()

		-- Apply search query if there is any
		local text = stdlib_string.trim(player_data.get_hud_search_text(player_index))
		local hud_combinators = {}
		if text ~= "" then
			for key, hud_combinator in pairs(combinator.get_hud_combinators()) do
				if stdlib_string.contains(hud_combinator.name:lower(), text:lower()) then
					hud_combinators[key] = hud_combinator
				end
			end
		else
			hud_combinators = combinator.get_hud_combinators()
		end

		-- Sort HUD Combinator
		local hud_combinators_unit_numbers = sort_hud_combinators(hud_combinators, player_index)

		-- Check if there were no search results.
		if text ~= "" and table_size(hud_combinators_unit_numbers) == 0 then
			flib_gui.build(
				scroll_pane_frame,
				{
					{
						type = "label",
						style = "hud_combinator_label",
						caption = "No results found!"
					}
				}
			)
		else
			-- loop over every HUD Combinator provided
			for _, hud_combinator in ipairs(hud_combinators_unit_numbers) do
				if hud_combinator.entity.valid then
					gui_hud.render_combinator(scroll_pane_frame, player_index, hud_combinator.unit_number)
				end
			end
		end
	end

	-- Calculate hud size
	gui_hud.calculate_hud_size(player_index)
end

function gui_hud.update_collapse_state(player_index, toggle_state)
	common.debug_log(player_index, "Toggle button clicked! - " .. tostring(toggle_state))
	player_data.set_hud_collapsed(player_index, toggle_state)
	gui_hud.reset(player_index)
end

function gui_hud.destroy(player_index)
	player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_root_frame)
	-- The rest seems unneeded but is used to deregister all stale hud refs
	player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_header_flow)
	player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_title_label)
	player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_header_spacer)
	player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_search_text_field)
	player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_search_button)
	player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_settings_button)
	player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_toggle_button)
	player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_scroll_pane_frame)
end

function gui_hud.reset(player_index)
	gui_hud.destroy(player_index)
	gui_hud.create(player_index)
	gui_hud.update(player_index)
end

function gui_hud.reset_all_players()
	for _, player in pairs(game.players) do
		gui_hud.reset(player.index)
	end
end

-- Calculate the width and height of the HUD due to GUIElement.size not being available
function gui_hud.calculate_hud_size(player_index)
	local player = common.get_player(player_index)

	local width = 0 -- pixel width when scale is 100%
	local height = 0 -- pixel height when scale is 100%
	if player_data.get_hud_collapsed(player_index) then
		-- Set collapsed size
		width = 40
		height = 40
	else
		common.debug_log(player_index, "Start calculating HUD size:")

		local max_columns_allowed = player_settings.get_hud_columns_setting(player_index)
		width = (max_columns_allowed * (36 + 4)) + 40
		height = player_settings.get_hud_height_setting(player_index)
	end

	-- Set max height in style of HUD RootFrame
	local root_frame = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_root_frame)
	if root_frame then
		root_frame.style.minimal_width = width
		root_frame.style.maximal_width = width
		root_frame.style.minimal_height = height
		root_frame.style.maximal_height = height
	end

	-- When setting the HUD Location we need the size adjusted by the display scale to set X and Y
	local new_size = {width = width * player.display_scale, height = height * player.display_scale}

	common.debug_log(player_index, "HUD size, width: " .. tostring(new_size.width) .. ", height: " .. tostring(new_size.height))
	player_data.set_hud_size(player_index, new_size)
	event_handler.gui_hud_size_changed(player_index, new_size)
end

function gui_hud.event_handler(player_index, action)
	local player = common.get_player(player_index)
	local unit_number = action["unit_number"]

	-- Toggle HUD collapse/expand
	if action.action == const.GUI_ACTIONS.toggle then
		local toggle_state = not player_data.get_hud_collapsed(player_index)
		gui_hud.update_collapse_state(player_index, toggle_state)
		return
	end

	if action.action == const.GUI_ACTIONS.go_to_combinator then
		if unit_number then
			-- find the entity
			local hud_combinator = combinator.get_hud_combinator_entity(unit_number)
			if hud_combinator and hud_combinator.valid then
				-- open the map on the coordinates
				player.zoom_to_world(hud_combinator.position, 2)
			end
		end
		return
	end

	-- Open HUD Combinator
	if action.action == const.GUI_ACTIONS.open_combinator then
		event_handler.open_hud_combinator(player_index, unit_number)
		return
	end

	-- Show HUD Combinator
	if action.action == const.GUI_ACTIONS.show_combinator then
		player_data.set_hud_combinator_visibilty(player_index, unit_number, true)
		gui_hud.update(player_index)
		return
	end

	-- Hide HUD Combinator
	if action.action == const.GUI_ACTIONS.hide_combinator then
		player_data.set_hud_combinator_visibilty(player_index, unit_number, false)
		gui_hud.update(player_index)
		return
	end

	-- Toggle Search Bar
	if action.action == const.GUI_ACTIONS.toggle_search_bar then
		-- Show/Hide the search text field
		local text_field = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_search_text_field)
		local state = not text_field.visible
		text_field.visible = state

		-- Hide/Show the following GUI Elements
		local title_label = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_title_label)
		title_label.visible = not state
		local header_spacer = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_header_spacer)
		header_spacer.visible = not state
		return
	end

	-- Search Text Changed
	if action.action == const.GUI_ACTIONS.search_bar_change then
		local text_field = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_search_text_field)
		player_data.set_hud_search_text(player_index, text_field.text)
		gui_hud.update(player_index)
		return
	end

	-- Open Settings page
	if action.action == const.GUI_ACTIONS.open_settings then
		event_handler.gui_settings_create(player_index)
		return
	end
end

function gui_hud.size_changed(player_index, size)
	local root_frame = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_root_frame)
	-- Only change location if rootframe is part of the Screen GUI
	if root_frame and root_frame.parent["name"] == "screen" then
		local player = common.get_player(player_index)

		local x = 0
		local y = 0

		if
			player_data.get_is_hud_bottom_right(player_index) or
				(player_data.get_is_hud_draggable(player_index) and player_data.get_hud_collapsed(player_index))
		 then
			x = player.display_resolution.width - size.width
			y = player.display_resolution.height - size.height

			-- Change location
			if not (x == 0 and y == 0) and x ~= root_frame.location.x or y ~= root_frame.location.y then
				root_frame.location = {x, y}

				if player_settings.get_debug_mode_setting(player_index) then
					player.print("HUD size: width: " .. size.width .. ", height: " .. size.height)
					player.print("HUD location: x: " .. x .. ", y: " .. y)
					player.print("Display Resolution: width: " .. player.display_resolution.width .. ", height: " .. player.display_resolution.height)
					player.print("Display scale: x: " .. player.display_scale)
				end
			end
		end
	end
end

return gui_hud
