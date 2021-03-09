local math = require("__stdlib__/stdlib/utils/math")

-- Takes the data from HUD Combinator and display it in the HUD
-- @param parent The Root frame
-- @param entity The HUD Combinator to process
local function render_combinator(scroll_pane_frame, hud_combinator)
	-- Check if this HUD Combinator should be shown in the HUD
	if not should_show_network(hud_combinator) then
		return false -- skip rendering this combinator
	end

	-- Check flow container for the HUD Combinator category if it doesnt exist
	local flow_id = "hud_combinator_flow_" .. tostring(hud_combinator.unit_number)
	local hud_combinator_flow = scroll_pane_frame.add {type = "flow", direction = "vertical", name = flow_id, style = "combinator_flow_style"}

	-- Check HUD Combinator title to HUD category
	local title_label_id = "hud_combinator_title_" .. tostring(hud_combinator.unit_number)
	hud_combinator_flow.add {
		type = "label",
		style = "hud_combinator_label",
		caption = global.hud_combinators[hud_combinator.unit_number]["name"],
		name = title_label_id
	}

	-- NOTE: This should remain local as it causes desync and save/load issues if moved elsewhere
	local signal_name_map = {
		["item"] = game.item_prototypes,
		["virtual"] = game.virtual_signal_prototypes,
		["fluid"] = game.fluid_prototypes
	}

	-- Check if this HUD Combinator has any signals coming in to show in the HUD.
	if has_network_signals(hud_combinator) then
		local max_columns = get_hud_columns_setting(scroll_pane_frame.player_index)

		local red_network = hud_combinator.get_circuit_network(defines.wire_type.red)
		local green_network = hud_combinator.get_circuit_network(defines.wire_type.green)

		local networks = {green_network, red_network}
		local network_colors = {"green", "red"}
		local network_styles = {"green_circuit_network_content_slot", "red_circuit_network_content_slot"}

		-- Display the item signals coming from the red and green circuit if any
		for i = 1, 2, 1 do
			-- Check if this color table already exists
			local table_name = "hud_combinator_" .. network_colors[i] .. "_table"
			local table = hud_combinator_flow.add {type = "table", name = table_name, column_count = max_columns}

			-- Check if there are signals
			if networks[i] and networks[i].signals then
				for j, signal in pairs(networks[i].signals) do
					local signal_type = signal.signal.type
					local signal_name = signal.signal.name
					-- Check if the signal already exist
					table.add {
						type = "sprite-button",
						sprite = SIGNAL_TYPE_MAP[signal_type] .. "/" .. signal_name,
						number = signal.count,
						style = network_styles[i],
						tooltip = signal_name_map[signal_type][signal_name].localised_name
					}
				end
			end
		end
	else
		hud_combinator_flow.add {type = "label", style = "hud_combinator_label", caption = "No signal"}
	end
end

-- Create frame in which to put the other GUI elements

local function create_root_frame(player_index)
	local player = get_player(player_index)

	local root_frame = nil
	local frame_template = {
		type = "frame",
		direction = "vertical",
		name = HUD_NAMES.hud_root_frame,
		style = "hud-root-frame-style"
	}

	local hud_position = get_hud_position_setting(player_index)

	-- Set HUD on the left or top side of screen
	if hud_position == HUD_POSITION.left or hud_position == HUD_POSITION.top or hud_position == HUD_POSITION.goal then
		root_frame = player.gui[hud_position].add(frame_template)
	end

	-- Set HUD to be draggable
	if hud_position == HUD_POSITION.draggable then
		root_frame = player.gui.screen.add(frame_template)
		root_frame.location = get_hud_location(player_index)
	end

	-- Set HUD on the bottom-right corner of the screen
	if hud_position == HUD_POSITION.bottom_right then
		root_frame = player.gui.screen.add(frame_template)
		calculate_hud_size(player_index)
		move_hud_bottom_right(player_index)
	end

	-- Only create header when the settings allow for it
	if not get_hide_hud_header_setting(player_index) then
		-- create a title_flow
		local header_flow = root_frame.add {type = "flow", direction = "horizontal"}

		-- add the title label
		local title = header_flow.add {type = "label", caption = get_hud_title_setting(player_index), style = "frame_title"}

		-- Set frame to be draggable
		if get_hud_position_setting(player_index) == HUD_POSITION.draggable then
			local pusher = header_flow.add({type = "empty-widget", name = HUD_NAMES.hud_header_spacer, style = "draggable_space_hud_header"})
			pusher.style.horizontally_stretchable = true
			pusher.drag_target = root_frame
			title.drag_target = root_frame
			set_hud_element_ref(player_index, HUD_NAMES.hud_header_spacer, pusher)
		else
			local pusher = header_flow.add({type = "empty-widget", name = HUD_NAMES.hud_header_spacer, style = "space_hud_header"})
			pusher.style.horizontally_stretchable = true
			set_hud_element_ref(player_index, HUD_NAMES.hud_header_spacer, pusher)
		end

		-- add a "toggle" button
		local toggle_button =
			header_flow.add {
			type = "sprite-button",
			style = "frame_action_button",
			sprite = (get_hud_collapsed(player_index) == true) and "utility/expand" or "utility/collapse",
			name = HUD_NAMES.hud_toggle_button
		}

		set_hud_element_ref(player_index, HUD_NAMES.hud_title_label, title)
		set_hud_element_ref(player_index, HUD_NAMES.hud_toggle_button, toggle_button)
	end

	root_frame.style.maximal_height = get_hud_max_height_setting(player_index)

	return root_frame
end

-- Build the HUD with the signals
-- @param player_index The index of the player
function build_interface(player_index)
	-- First check if there are any existing HUD combinator
	if not has_hud_combinators() then
		debug_log(player_index, "There are no HUD Combinators registered so we can't create the HUD")
		return
	end

	if get_hud_ref(player_index, HUD_NAMES.hud_root_frame) then
		debug_log(player_index, "Can't create a new HUD while the old one still exists")
		return
	end

	local root_frame = create_root_frame(player_index)

	local scroll_pane =
		root_frame.add {
		name = HUD_NAMES.hud_scroll_pane,
		type = "scroll-pane",
		vertical_scroll_policy = "auto",
		style = "hud_scrollpane_style"
	}

	local scroll_pane_frame =
		scroll_pane.add {
		name = HUD_NAMES.hud_scroll_pane_frame,
		type = "frame",
		style = "inside_shallow_frame_with_padding",
		direction = "vertical"
	}

	set_hud_element_ref(player_index, HUD_NAMES.hud_root_frame, root_frame)
	set_hud_element_ref(player_index, HUD_NAMES.hud_scroll_pane, scroll_pane)
	set_hud_element_ref(player_index, HUD_NAMES.hud_scroll_pane_frame, scroll_pane_frame)
end

-- Go over each player and ensure that their HUD is either visible or hidden based on the existense of HUD combinators.
function check_all_player_hud_visibility()
	-- go through each player and update their HUD
	for i, player in pairs(game.players) do
		should_hud_root_exist(player.index)
	end
end

-- Check  and ensure if the player has their HUD either visible or hidden based on the existense of HUD combinators.
function should_hud_root_exist(player_index)
	if has_hud_combinators() then
		-- Ensure we have created the HUD for all players
		if not get_hud_ref(player_index, HUD_NAMES.hud_root_frame) then
			build_interface(player_index)
		end
		update_hud(player_index)
	else
		-- Ensure all HUDS are destroyed
		if get_hud_ref(player_index, HUD_NAMES.hud_root_frame) then
			destroy_hud(player_index)
		end
	end
end

-- Update the HUD combinator categories and values in the HUD
function update_hud(player_index)
	if not has_hud_combinators() or get_hud_collapsed(player_index) then
		return
	end

	if not get_hud_ref(player_index, HUD_NAMES.hud_root_frame) then
		debug_log(player_index, "Can't update HUD because the HUD root does not exist for player with index: " .. player_index)
		return
	end

	local scroll_pane_frame = get_hud_ref(player_index, HUD_NAMES.hud_scroll_pane_frame)
	if not scroll_pane_frame or not scroll_pane_frame.valid then
		debug_log(player_index, "Can't update HUD because the scroll_pane_frame does not exist for player with index: " .. player_index)
	end

	-- Clear the frame which has the signals displayed to start the update
	scroll_pane_frame.clear()

	-- loop over every HUD Combinator provided
	for i, meta_entity in pairs(get_hud_combinators()) do
		local hud_combinator = meta_entity.entity

		if not hud_combinator.valid then
			-- the entity has probably just been deconstructed
			break
		end

		render_combinator(scroll_pane_frame, hud_combinator)
	end

	local hud_position = get_hud_position_setting(player_index)
	if hud_position == HUD_POSITION.bottom_right then
		calculate_hud_size(player_index)
		move_hud_bottom_right(player_index)
	end
end

function update_collapse_state(player_index, toggle_state)
	set_hud_collapsed(player_index, toggle_state)

	local toggle_ref = get_hud_ref(player_index, HUD_NAMES.hud_toggle_button)
	if toggle_ref then
		if get_hud_collapsed(player_index) then
			toggle_ref.sprite = "utility/expand"
		else
			toggle_ref.sprite = "utility/collapse"
		end
	end

	-- true is collapsed, false is visible
	if toggle_state then
		destroy_hud_ref(player_index, HUD_NAMES.hud_scroll_pane)
		destroy_hud_ref(player_index, HUD_NAMES.hud_title_label)
		destroy_hud_ref(player_index, HUD_NAMES.hud_header_spacer)
	else
		reset_hud(player_index)
	end

	-- If bottom-right fixed than align
	if get_hud_position_setting(player_index) == HUD_POSITION.bottom_right then
		calculate_hud_size(player_index)
		move_hud_bottom_right(player_index)
	end

	debug_log(player_index, "Toggle button clicked! - " .. tostring(toggle_state))
end

function reset_hud(player_index)
	destroy_hud(player_index)
	build_interface(player_index)
	update_hud(player_index)
end

-- Calculate the width and height of the HUD due to GUIElement.size not being available
function calculate_hud_size(player_index)
	if get_hud_collapsed(player_index) then
		set_hud_size(player_index, {width = 40, height = 40})
		return size
	end

	debug_log(player_index, "Start calculating HUD size:")

	local max_columns_allowed = get_hud_columns_setting(player_index)
	local combinator_count = 0

	local combinator_cat_width = {}
	local combinator_cat_height = {}
	local i = 0
	-- loop over every HUD Combinator provided
	for k, meta_entity in pairs(get_hud_combinators()) do
		local entity = meta_entity.entity

		if not entity.valid then
			-- the entity has probably just been deconstructed
			break
		end

		debug_log(player_index, " - Combinator (" .. meta_entity.name .. "):")

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
				network_rows = math.floor(signal_count / max_columns_allowed) + math.clamp(signal_count % max_columns_allowed, 0, 1)
			elseif signal_count > 0 and signal_count <= max_columns_allowed then
				-- if less than 1 row, then simplify
				network_columns = signal_count
				-- with signal_count > 0 && <= max_columns_allowed we know its always 1 row
				network_rows = 1
			end

			-- Debug summary
			debug_log(
				player_index,
				" - - " .. network_types[j] .. " Network has " .. signal_count .. " signals " .. network_rows .. " rows  and " .. network_columns .. " columns."
			)
			-- Process result
			total_row_count = total_row_count + network_rows
			if max_columns_found < network_columns then
				max_columns_found = math.clamp(network_columns, 0, max_columns_allowed)
			end
		end

		-- count as empty if HUD combinator has no signals
		if counts[1] == 0 and counts[2] == 0 then
			-- Max width and height of empty HUD combinator category
			combinator_cat_width[i] = 208
			combinator_cat_height[i] = 60
			debug_log(player_index, " - - Combinator (" .. meta_entity.name .. ") has no signals")
		else
			-- else count as a combinator with at least 1 signal
			combinator_count = combinator_count + 1
			combinator_cat_width[i] = (36 + 4) * max_columns_found + 4
			combinator_cat_height[i] = (36 + 4) * total_row_count + 24 + 8 -- 24 = label height, 8 = padding
		end

		local summary_string = " - - Summary: width: " .. tostring(combinator_cat_width[i]) .. ", height: " .. tostring(combinator_cat_height[i])
		summary_string = summary_string .. ", max_columns_found is " .. tostring(max_columns_found) .. ", total_row_count is " .. tostring(total_row_count)
		debug_log(player_index, summary_string)
		i = i + 1
	end

	local player = get_player(player_index)
	-- Width Formula => (<button-size> + <padding>) * (<max_number_of_columns>) + <remainder_padding>
	local width = max(combinator_cat_width) + 16
	-- Height Formula => ((<button-size> + <padding>) * <total button rows>) + (<combinator count> * <label-height>)
	local height = sum(combinator_cat_height) + 24

	-- get the max height of the HUD based on the user setting or display resolution
	local max_height = math.min(get_hud_max_height_setting(player_index), player.display_resolution.height)

	-- Add header height if enabled
	if not get_hide_hud_header_setting(player_index) then
		height = height + 28 + 4
	end

	-- check if there is a scrollbar and add that width
	if height > max_height then
		width = width + 12
	end

	width = math.clamp(width, 200, 1000)
	-- clamp height at the max-height setting, or if lower the height of the screen resolution
	height = math.clamp(height, 30, max_height)

	local size = {width = math.round(width * player.display_scale), height = math.round(height * player.display_scale)}
	debug_log(player_index, "HUD size, width: " .. tostring(size.width) .. ", height: " .. tostring(size.height))
	set_hud_size(player_index, size)
	return size
end

function move_hud_bottom_right(player_index)
	local root_frame = get_hud_ref(player_index, HUD_NAMES.hud_root_frame)
	if root_frame then
		local player = get_player(player_index)
		local size = get_hud_size(player_index)
		local x = player.display_resolution.width - size.width
		local y = player.display_resolution.height - size.height

		if x ~= root_frame.location.x or y ~= root_frame.location.y then
			root_frame.location = {x, y}

			if get_debug_mode_setting(player_index) then
				player.print("HUD size: width: " .. size.width .. ", height: " .. size.height)
				player.print("HUD location: x: " .. x .. ", y: " .. y)
				player.print("Display Resolution: width: " .. player.display_resolution.width .. ", height: " .. player.display_resolution.height)
				player.print("Display scale: x: " .. player.display_scale)
			end
		end
	end
end
