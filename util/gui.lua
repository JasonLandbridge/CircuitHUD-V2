--#region Constants

local root_frame_name = "hud-root-frame"
local inner_frame_name = "inner_frame"
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

	local child = parent.add {type = "flow", direction = "vertical"}

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

	return true
end

-- Create frame in which to put the other GUI elements

local function create_root_frame(player_index)
	local player = get_player(player_index)

	local root_frame = nil
	local frame_template = {type = "frame", direction = "vertical", name = "hud-root-frame"}
	local hud_position = get_hud_position_setting(player_index)

	-- Set HUD on the left or top side of screen
	if hud_position == "left" or hud_position == "top" then
		root_frame = player.gui[hud_position].add(frame_template)
	end

	-- Set HUD to be draggable
	if hud_position == "draggable" then
		root_frame = player.gui.screen.add(frame_template)
		root_frame.location = get_hud_location(player_index)
	end

	-- Set HUD on the left side of screen
	if hud_position == "bottom-right" then
		root_frame = player.gui.screen.add(frame_template)
		local x = player.display_resolution.width - 250
		local y = player.display_resolution.height - 250
		root_frame.location = {x, y}
		player.print("gui location: x: " .. x .. ", y: " .. y)
	end

	-- Only create header when the settings allow for it
	if not get_hide_hud_header_setting(player_index) then
		-- create a title_flow
		local title_flow = root_frame.add {type = "flow"}

		-- add the title label
		local title = title_flow.add {type = "label", caption = get_hud_title_setting(player_index), style = "frame_title"}

		-- Set frame to be draggable
		if get_hud_position_setting(player_index) == "draggable" then
			local pusher = title_flow.add {type = "empty-widget", style = "draggable_space_hud_header"}
			pusher.style.horizontally_stretchable = true
			pusher.drag_target = root_frame
			title.drag_target = root_frame
		else
			title_flow.add {type = "empty-widget", style = "frame_style"}
		end

		-- add a "toggle" button
		local toggle_button =
			title_flow.add {
			type = "sprite-button",
			style = "frame_action_button",
			sprite = (get_hud_collapsed(player_index) == true) and "utility/expand" or "utility/collapse",
			name = "toggle-circuit-hud"
		}
		set_toggle_ref(player_index, toggle_button)
	end

	return root_frame
end

-- Build the HUD with the signals
-- @param player_index The index of the player
function build_interface(player_index)
	local root_frame = create_root_frame(player_index)

	-- if global.hud_position_map[player.index] then
	-- 	local new_location = global.hud_position_map[player.index]
	-- 	root_frame.location = new_location
	-- end

	-- local title_flow = create_frame_title(root_frame, "Circuit HUD")

	local scroll_pane =
		root_frame.add {
		type = "scroll-pane",
		vertical_scroll_policy = "auto",
		style = "hud_scrollpane_style"
	}

	local inner_frame =
		scroll_pane.add {
		name = "inner_frame",
		type = "frame",
		style = "inside_shallow_frame_with_padding",
		direction = "vertical"
	}

	set_hud_refs(player_index, root_frame, inner_frame)
end

function update_hud(player)
	local inner_frame = get_hud_inner(player.index)
	if inner_frame then
		inner_frame.clear()
	end

	local child = inner_frame.add {type = "flow", direction = "vertical"}

	-- loop over every HUD Combinator provided
	for i, meta_entity in pairs(get_hud_combinators()) do
		local entity = meta_entity.entity

		if not entity.valid then
			-- the entity has probably just been deconstructed
			break
		end

		local spacer = nil
		if i > 1 and did_render_any_combinator then
			spacer = child.add {type = "empty-widget", style = "empty_widget_distance"} -- todo: correctly add some space
		end

		local did_render_combinator = render_combinator(child, entity)
		did_render_any_combinator = did_render_any_combinator or did_render_combinator

		if spacer and (not did_render_combinator) then
			spacer.destroy()
		end
	end

	if not did_render_any_combinator then
		child.destroy()
	end

	return did_render_any_combinator
end

function update_collapse_button(player_index)
	local toggle_ref = get_hud_toggle(player_index)
	if toggle_ref then
		if get_hud_collapsed(player_index) then
			toggle_ref.sprite = "utility/expand"
		else
			toggle_ref.sprite = "utility/collapse"
		end
	end
end

function reset_hud(player_index)
	destroy_hud(player_index)
	build_interface(player_index)
end
