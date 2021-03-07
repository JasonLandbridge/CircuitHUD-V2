local math = require("__stdlib__/stdlib/utils/math")

--#region Constants

local SIGNAL_TYPE_MAP = {
	["item"] = "item",
	["virtual"] = "virtual-signal",
	["fluid"] = "fluid"
}

local GET_SIGNAL_NAME_MAP = function()
	return {
		["item"] = game.item_prototypes,
		["virtual"] = game.virtual_signal_prototypes,
		["fluid"] = game.fluid_prototypes
	}
end

--#endregion

-- Converts all circuit signals to icons displayed in the HUD under that network
-- @param parent The parent GUI Element
local function render_network_in_HUD(parent, network, signal_style)
	-- skip this one, if the network has no signals
	if network == nil or network.signals == nil then
		return
	end

	local table = parent.add {type = "table", column_count = get_hud_columns_setting(parent.player_index)}

	local signal_name_map = GET_SIGNAL_NAME_MAP()
	for i, signal in ipairs(network.signals) do
		table.add {
			type = "sprite-button",
			sprite = SIGNAL_TYPE_MAP[signal.signal.type] .. "/" .. signal.signal.name,
			number = signal.count,
			style = signal_style,
			tooltip = signal_name_map[signal.signal.type][signal.signal.name].localised_name
		}
	end
end

-- Takes the data from HUD Combinator and display it in the HUD
-- @param parent The Root frame
-- @param entity The HUD Combinator to process
local function render_combinator(parent, entity)
	-- Check if this HUD Combinator should be shown in the HUD
	if not should_show_network(entity) then
		return false -- skip rendering this combinator
	end

	local child = parent.add {type = "flow", direction = "vertical", style = "combinator_flow_style"}

	-- Add HUD Combinator title to HUD category
	local title =
		child.add {
		type = "label",
		caption = global.hud_combinators[entity.unit_number]["name"],
		style = "heading_3_label",
		name = "hudcombinatortitle--" .. entity.unit_number
	}

	-- Check if this HUD Combinator has any signals coming in to show in the HUD.
	if has_network_signals(entity) then
		local red_network = entity.get_circuit_network(defines.wire_type.red)
		local green_network = entity.get_circuit_network(defines.wire_type.green)

		-- Display the item signals coming from the red and green circuit if any
		render_network_in_HUD(child, green_network, "green_circuit_network_content_slot")
		render_network_in_HUD(child, red_network, "red_circuit_network_content_slot")
	else
		child.add {type = "label", caption = "No signal"}
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
	if hud_position == "left" or hud_position == "top" or hud_position == "goal" then
		root_frame = player.gui[hud_position].add(frame_template)
	end

	-- Set HUD to be draggable
	if hud_position == "draggable" then
		root_frame = player.gui.screen.add(frame_template)
		root_frame.location = get_hud_location(player_index)
	end

	-- Set HUD on the bottom-right corner of the screen
	if hud_position == "bottom-right" then
		root_frame = player.gui.screen.add(frame_template)
		calculate_hud_size(player_index)
		move_hud_bottom_right(player_index)
	end

	-- Only create header when the settings allow for it
	if not get_hide_hud_header_setting(player_index) then
		-- create a title_flow
		local title_flow = root_frame.add {type = "flow"}

		-- add the title label
		local title = title_flow.add {type = "label", caption = get_hud_title_setting(player_index), style = "frame_title"}

		-- Set frame to be draggable
		if get_hud_position_setting(player_index) == "draggable" then
			local pusher =
				title_flow.add({type = "empty-widget", name = HUD_NAMES.hud_header_spacer, style = "draggable_space_hud_header"})
			pusher.style.horizontally_stretchable = true
			pusher.drag_target = root_frame
			title.drag_target = root_frame
			set_hud_element_ref(player_index, HUD_NAMES.hud_header_spacer, pusher)
		else
			local pusher =
				title_flow.add({type = "empty-widget", name = HUD_NAMES.hud_header_spacer, style = "draggable_space_hud_header"})
			pusher.style.horizontally_stretchable = true
			set_hud_element_ref(player_index, HUD_NAMES.hud_header_spacer, pusher)
		end

		-- add a "toggle" button
		local toggle_button =
			title_flow.add {
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

function clear_hud_display(player_index)
	local scroll_pane = get_hud_ref(player_index, HUD_NAMES.hud_scroll_pane)
	if scroll_pane then
		scroll_pane.clear()
	end
	return scroll_pane
end

-- Build the HUD with the signals
-- @param player_index The index of the player
function build_interface(player_index)
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

function update_hud(player_index)
	if get_hud_collapsed(player_index) then
		return
	end

	-- Clear the frame which has the signals displayed to start the update
	local inner_frame = clear_hud_display(player_index)
	if not inner_frame.valid then
		return
	end

	local combinator_flow = inner_frame.add({type = "flow", direction = "vertical"})

	-- loop over every HUD Combinator provided
	for i, meta_entity in pairs(get_hud_combinators()) do
		local entity = meta_entity.entity

		if not entity.valid then
			-- the entity has probably just been deconstructed
			break
		end

		render_combinator(combinator_flow, entity)
	end

	local hud_position = get_hud_position_setting(player_index)
	if hud_position == "bottom-right" then
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
	if get_hud_position_setting(player_index) == "bottom-right" then
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

function calculate_hud_size(player_index)
	if get_hud_collapsed(player_index) then
		set_hud_size(player_index, {width = 40, height = 40})
		return size
	end

	local max_columns_allowed = get_hud_columns_setting(player_index)
	local max_columns_found = 0
	local row_count = 0
	local combinator_count = 0
	local empty_combinators = 0
	-- loop over every HUD Combinator provided
	for i, meta_entity in pairs(get_hud_combinators()) do
		local entity = meta_entity.entity

		if not entity.valid then
			-- the entity has probably just been deconstructed
			break
		end

		-- Calculate size when hud position is bottom-right
		local red_network = entity.get_circuit_network(defines.wire_type.red)
		local green_network = entity.get_circuit_network(defines.wire_type.green)

		local counts = {0, 0}

		if red_network and red_network.signals then
			counts[1] = array_length(red_network.signals)
		end

		if green_network and green_network.signals then
			counts[2] = array_length(green_network.signals)
		end

		-- loop and calculate the green and red signals highest column width and total row count
		for j = 1, 2, 1 do
			local signal_count = counts[j]
			if signal_count > max_columns_allowed then
				-- we know its at least 1 row, and the max column width has been reached
				max_columns_found = max_columns_allowed
				-- divide by max_columns_allowed and round down, add 1 to row_cound if the remainder is > 0
				local x = math.floor(signal_count / max_columns_allowed) + math.clamp(signal_count % max_columns_allowed, 0, 1)
				row_count = row_count + x
			elseif signal_count > 0 and signal_count <= max_columns_allowed then
				-- if less than 1 row, then simplify
				if signal_count > max_columns_found then
					max_columns_found = signal_count
				end
				-- with signal_count > 0 && <= max_columns_allowed we know its always 1 row
				row_count = row_count + 1
			end
		end

		-- count as empty if HUD combinator has no signals
		if counts[1] == 0 and counts[2] == 0 then
			empty_combinators = empty_combinators + 1
		else
			-- else count as a combinator with at least 1 signal
			combinator_count = combinator_count + 1
		end
	end

	local player = get_player(player_index)
	-- Width Formula => (<button-size> + <padding>) * (<max_number_of_columns>) + <remainder_padding>
	local width = (36 + 4) * math.min(get_hud_columns_setting(player_index), max_columns_found) + 32
	-- Height Formula => ((<button-size> + <padding>) * <total button rows>) + (<combinator count> * <label-height>)
	local height = ((36 + 4) * row_count) + (combinator_count * 20) + (empty_combinators * 50) + 48

	-- Add header height if enabled
	if not get_hide_hud_header_setting(player_index) then
		height = height + 28
	end

	width = math.clamp(width, 250, 1000)
	-- clamp height at the max-height setting, or if lower the height of the screen resolution
	height = math.clamp(height, 30, math.min(get_hud_max_height_setting(player_index), player.display_resolution.height))

	local size = {width = math.round(width * player.display_scale), height = math.round(height * player.display_scale)}
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
				player.print(
					"Display Resolution: width: " ..
						player.display_resolution.width .. ", height: " .. player.display_resolution.height
				)
				player.print("Display scale: x: " .. player.display_scale)
			end
		end
	end
end
