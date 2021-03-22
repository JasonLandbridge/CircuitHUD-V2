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

	-- Ascending
	if sort_mode == const.HUD_SORT.ascending then
		hud_combinators =
			table.sort(
			hud_combinators,
			function(a, b)
				return a.name:lower() < b.name:lower()
			end
		)
	end

	-- Descending
	if sort_mode == const.HUD_SORT.descending then
		hud_combinators =
			table.sort(
			hud_combinators,
			function(a, b)
				return a.name:lower() > b.name:lower()
			end
		)
	end

	-- Build Order Ascending
	if sort_mode == const.HUD_SORT.build_order_ascending then
		hud_combinators =
			table.sort(
			hud_combinators,
			function(a, b)
				return a.unit_number:lower() < b.unit_number:lower()
			end
		)
	end

	-- Build Order Descending
	if sort_mode == const.HUD_SORT.build_order_descending then
		hud_combinators =
			table.sort(
			hud_combinators,
			function(a, b)
				return a.unit_number:lower() > b.unit_number:lower()
			end
		)
	end

	return hud_combinators
end

-- Takes the data from HUD Combinator and display it in the HUD
-- @param scroll_pane_frame The Root frame
-- @param hud_combinator The HUD Combinator to process
local function render_combinator(scroll_pane_frame, hud_combinator)
	-- Check flow container for the HUD Combinator category if it doesnt exist
	local unit_number = hud_combinator.unit_number
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
								name = "CircuitHUD_goto_site_" .. flow_id,
								tooltip = {"button-tooltips.goto-combinator"},
								style = "CircuitHUD_goto_site",
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
								name = "CircuitHUD_open_combinator_" .. flow_id,
								tooltip = {"button-tooltips.open-combinator"},
								style = "CircuitHUD_open_combinator",
								actions = {
									on_click = {
										gui = const.GUI_TYPES.hud,
										action = const.GUI_ACTIONS.open_combinator,
										unit_number = unit_number
									}
								}
							}
						}
					},
					{
						type = "flow",
						direction = "vertical",
						style = "packed_vertical_flow",
						ref = {"combinator_content"}
					}
				}
			}
		}
	)

	-- NOTE: This should remain local as it causes desync and save/load issues if moved elsewhere
	local signal_name_map = {
		["item"] = game.item_prototypes,
		["virtual"] = game.virtual_signal_prototypes,
		["fluid"] = game.fluid_prototypes
	}

	local combinator_content = refs.combinator_content
	-- Check if this HUD Combinator has any signals coming in to show in the HUD.
	local max_columns = player_settings.get_hud_columns_setting(scroll_pane_frame.player_index)

	local red_network = hud_combinator.entity.get_circuit_network(defines.wire_type.red)
	local green_network = hud_combinator.entity.get_circuit_network(defines.wire_type.green)

	local networks = {green_network, red_network}
	local network_colors = {"green", "red"}
	local network_styles = {"green_circuit_network_content_slot", "red_circuit_network_content_slot"}
	local signals_filter = combinator.get_hud_combinator_filters(unit_number)
	local should_filter = combinator.get_hud_combinator_filter_state(unit_number)

	if should_filter and table_size(signals_filter) == 0 then
		combinator_content.add {type = "label", style = "hud_combinator_label", caption = "Filter is on but no signals have been selected"}
		return
	end

	local hide_signal_detected = false
	local signal_total_count = 0
	local signal_count = 0
	-- Display the item signals coming from the red and green circuit if any
	for i = 1, 2, 1 do
		-- Check if this color table already exists
		local table_name = "hud_combinator_" .. network_colors[i] .. "_table"
		local table = combinator_content.add {type = "table", name = table_name, column_count = max_columns}

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
					table.add {
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

	if hide_signal_detected then
		refs.hud_combinator_flow.destroy()
		return
	end

	-- No signals were shown due to too strict filtering circuit
	if signal_count == 0 and signal_total_count > 0 then
		combinator_content.clear()
		combinator_content.add {type = "label", style = "hud_combinator_label", caption = "No signals passed filtering"}
		return
	end

	-- No signals were shown due to now signals on the connected circuit
	if signal_count == 0 and signal_total_count == 0 then
		combinator_content.clear()
		combinator_content.add {type = "label", style = "hud_combinator_label", caption = "No signal"}
		return
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
				style = "hud-root-frame-style",
				ref = {
					const.HUD_NAMES.hud_root_frame
				}
			}
		}
	)

	local root_frame = root_refs[const.HUD_NAMES.hud_root_frame]
	-- Set references to root GUI Elements

	-- Only create header when the settings allow for it
	if not player_settings.get_hide_hud_header_setting(player_index) then
		-- create a title_flow

		local header_style = "flib_horizontal_pusher"
		if player_data.get_is_hud_draggable(player_index) then
			header_style = "flib_titlebar_drag_handle"
		end

		local header_refs =
			flib_gui.build(
			root_frame,
			{
				{
					type = "flow",
					direction = "horizontal",
					children = {
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
						},
						-- Toggle Button
						{
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
		player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_toggle_button, header_refs[const.HUD_NAMES.hud_toggle_button])
	end
	local body_refs =
		flib_gui.build(
		root_frame,
		{
			{
				type = "scroll-pane",
				name = const.HUD_NAMES.hud_scroll_pane,
				vertical_scroll_policy = "auto",
				style = "hud_scrollpane_style",
				ref = {
					const.HUD_NAMES.hud_scroll_pane
				},
				children = {
					{
						type = "flow",
						name = const.HUD_NAMES.hud_scroll_pane_frame,
						style = "hud_scrollpane_frame_style",
						ref = {
							const.HUD_NAMES.hud_scroll_pane_frame
						},
						direction = "vertical"
					}
				}
			}
		}
	)
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_root_frame, root_refs[const.HUD_NAMES.hud_root_frame])
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_scroll_pane, body_refs[const.HUD_NAMES.hud_scroll_pane])
	player_data.set_hud_element_ref(player_index, const.HUD_NAMES.hud_scroll_pane_frame, body_refs[const.HUD_NAMES.hud_scroll_pane_frame])

	if player_data.get_is_hud_draggable(player_index) then
		location = player_data.get_hud_location(player_index)
	end

	-- Set HUD on the bottom-right corner of the screen
	if player_data.get_is_hud_bottom_right(player_index) then
		gui_hud.calculate_hud_size(player_index)
		gui_hud.move_hud_bottom_right(player_index)
	end

	root_frame.style.maximal_height = player_settings.get_hud_max_height_setting(player_index)
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
	if not combinator.has_hud_combinators() or player_data.get_hud_collapsed(player_index) then
		return
	end

	if not player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_root_frame) then
		common.debug_log(player_index, "Can't update HUD because the HUD root does not exist for player with index: " .. player_index)
		return
	end

	local scroll_pane_frame = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_scroll_pane_frame)
	if not scroll_pane_frame or not scroll_pane_frame.valid then
		common.debug_log(player_index, "Can't update HUD because the scroll_pane_frame does not exist for player with index: " .. player_index)
	end

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
	hud_combinators = sort_hud_combinators(hud_combinators, player_index)

	-- Check if there were no search results.
	if text ~= "" and table_size(hud_combinators) == 0 then
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
		for _, hud_combinator in pairs(hud_combinators) do
			if not hud_combinator.entity.valid then
				-- the entity has probably just been deconstructed
				break
			end

			render_combinator(scroll_pane_frame, hud_combinator)
		end
	end

	local hud_position = player_settings.get_hud_position_setting(player_index)
	if hud_position == const.HUD_POSITION.bottom_right then
		gui_hud.calculate_hud_size(player_index)
		gui_hud.move_hud_bottom_right(player_index)
	end
end

function gui_hud.update_collapse_state(player_index, toggle_state)
	player_data.set_hud_collapsed(player_index, toggle_state)

	local toggle_ref = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_toggle_button)
	if toggle_ref then
		if player_data.get_hud_collapsed(player_index) then
			toggle_ref.sprite = "utility/expand"
		else
			toggle_ref.sprite = "utility/collapse"
		end
	end

	-- true is collapsed, false is visible
	if toggle_state then
		player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_title_label)
		player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_header_spacer)
		player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_search_text_field)
		player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_search_button)
		player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_settings_button)

		player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_scroll_pane)
		player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_scroll_pane_frame)
	else
		gui_hud.reset(player_index)
	end

	-- If bottom-right fixed than align
	if player_settings.get_hud_position_setting(player_index) == const.HUD_POSITION.bottom_right then
		gui_hud.calculate_hud_size(player_index)
		gui_hud.move_hud_bottom_right(player_index)
	end

	common.debug_log(player_index, "Toggle button clicked! - " .. tostring(toggle_state))
end

function gui_hud.destroy(player_index)
	player_data.destroy_hud_ref(player_index, const.HUD_NAMES.hud_root_frame)
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

	local function adjust_size_scale(size)
		return {width = stdlib_math.round(size.width * player.display_scale), height = stdlib_math.round(size.height * player.display_scale)}
	end

	if player_data.get_hud_collapsed(player_index) then
		local size = adjust_size_scale({width = 40, height = 40})
		player_data.set_hud_size(player_index, size)
		return size
	end

	common.debug_log(player_index, "Start calculating HUD size:")

	local max_columns_allowed = player_settings.get_hud_columns_setting(player_index)
	local combinator_count = 0

	local combinator_cat_width = {}
	local combinator_cat_height = {}
	local i = 0
	-- loop over every HUD Combinator provided
	for k, meta_entity in pairs(combinator.get_hud_combinators()) do
		local entity = meta_entity.entity

		if not entity.valid then
			-- the entity has probably just been deconstructed
			break
		end

		common.debug_log(player_index, " - Combinator (" .. meta_entity.name .. "):")

		local total_row_count = 0
		local max_columns_found = 0
		local red_network = entity.get_circuit_network(defines.wire_type.red)
		local green_network = entity.get_circuit_network(defines.wire_type.green)

		local network_types = {"Green", "Red"}
		local counts = {0, 0}

		if green_network and green_network.signals then
			counts[1] = table_size(green_network.signals)
		end

		if red_network and red_network.signals then
			counts[2] = table_size(red_network.signals)
		end

		-- loop and calculate the green and red signals highest column width and total row count
		for j = 1, 2, 1 do
			local signal_count = counts[j]
			local network_rows = 0
			local network_columns = 0
			if signal_count > max_columns_allowed then
				-- we know its at least 1 row, and the max column width has been reached
				network_columns = max_columns_allowed
				-- divide by max_columns_allowed and round down, add 1 to row_cound if the remainder is > 0
				network_rows = stdlib_math.floor(signal_count / max_columns_allowed) + stdlib_math.clamp(signal_count % max_columns_allowed, 0, 1)
			elseif signal_count > 0 and signal_count <= max_columns_allowed then
				-- if less than 1 row, then simplify
				network_columns = signal_count
				-- with signal_count > 0 && <= max_columns_allowed we know its always 1 row
				network_rows = 1
			end

			-- Debug summary
			common.debug_log(
				player_index,
				" - - " .. network_types[j] .. " Network has " .. signal_count .. " signals " .. network_rows .. " rows  and " .. network_columns .. " columns."
			)
			-- Process result
			total_row_count = total_row_count + network_rows
			if max_columns_found < network_columns then
				max_columns_found = stdlib_math.clamp(network_columns, 0, max_columns_allowed)
			end
		end

		-- count as empty if HUD combinator has no signals
		if counts[1] == 0 and counts[2] == 0 then
			-- Max width and height of empty HUD combinator category
			combinator_cat_width[i] = 208
			combinator_cat_height[i] = 60
			common.debug_log(player_index, " - - Combinator (" .. meta_entity.name .. ") has no signals")
		else
			-- else count as a combinator with at least 1 signal
			combinator_count = combinator_count + 1
			combinator_cat_width[i] = (36 + 4) * max_columns_found + 4
			combinator_cat_height[i] = (36 + 4) * total_row_count + 24 + 8 -- 24 = label height, 8 = padding
		end

		local summary_string = " - - Summary: width: " .. tostring(combinator_cat_width[i]) .. ", height: " .. tostring(combinator_cat_height[i])
		summary_string = summary_string .. ", max_columns_found is " .. tostring(max_columns_found) .. ", total_row_count is " .. tostring(total_row_count)
		common.debug_log(player_index, summary_string)
		i = i + 1
	end

	-- Width Formula => (<button-size> + <padding>) * (<max_number_of_columns>) + <remainder_padding>
	local width = common.max(combinator_cat_width) + 24
	-- Height Formula => ((<button-size> + <padding>) * <total button rows>) + (<combinator count> * <label-height>)
	local height = stdlib_math.sum(combinator_cat_height) + 24

	-- get the max height of the HUD based on the user setting or display resolution
	local max_height = stdlib_math.min(player_settings.get_hud_max_height_setting(player_index), player.display_resolution.height)

	-- Add header height if enabled
	if not player_settings.get_hide_hud_header_setting(player_index) then
		height = height + 28 + 4
	end

	-- check if there is a scrollbar and add that width
	if height > max_height then
		width = width + 12
	end

	width = stdlib_math.clamp(width, 240, 1000)
	-- clamp height at the max-height setting, or if lower the height of the screen resolution
	height = stdlib_math.clamp(height, 30, max_height)

	local size = adjust_size_scale({width = width, height = height})
	common.debug_log(player_index, "HUD size, width: " .. tostring(size.width) .. ", height: " .. tostring(size.height))
	player_data.set_hud_size(player_index, size)
	return size
end

function gui_hud.move_hud_bottom_right(player_index)
	local root_frame = player_data.get_hud_ref(player_index, const.HUD_NAMES.hud_root_frame)
	if root_frame then
		local player = common.get_player(player_index)
		local size = player_data.get_hud_size(player_index)
		local x = player.display_resolution.width - size.width
		local y = player.display_resolution.height - size.height

		if x ~= root_frame.location.x or y ~= root_frame.location.y then
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

function gui_hud.event_handler(player_index, action)
	local player = common.get_player(player_index)
	local unit_number = action["unit_number"]
	local value = action["value"]

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
		event_handler.gui_combinator_create(player_index, unit_number)
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

return gui_hud
