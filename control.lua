require "mod-gui"
require "gui-util"
require "commands/reload"
require "util/reset_hud"
require "util/ensure_global_state"
local Event = require("__stdlib__/stdlib/event/event")

--#region Constants

local setting_prefix = "CircuitHUD"

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

--#region Globals

global.did_initial_render = false
global.toggle_button = nil
global.did_cleanup_and_discovery = false

--#endregion

--#region Get Settings
local function get_hud_position_setting(player)
	return settings.get_player_settings(player)[setting_prefix .. "_hud_position"].value
end

local function get_hud_columns_setting(player)
	return settings.get_player_settings(player)[setting_prefix .. "_hud_columns"].value
end
--#endregion

-- Checks if the signal coming into our HUD-Combinator contains our custom "Hide HUD Combinator Signal" and should therefore not show.
-- Will return true if this network should show  and false if the "Hide HUD Combinator Signal" is found.
-- @param entity The HUD Combinator
local function should_show_network(entity)
	-- Get both the red and green circuit networks
	local red_network = entity.get_circuit_network(defines.wire_type.red)
	local green_network = entity.get_circuit_network(defines.wire_type.green)

	if red_network and red_network.signals then
		for _, signal in pairs(red_network.signals) do
			if signal.signal.name == "signal-hide-hud-comparator" then
				return false
			end
		end
	end

	if green_network and green_network.signals then
		for _, signal in pairs(green_network.signals) do
			if signal.signal.name == "signal-hide-hud-comparator" then
				return false
			end
		end
	end

	-- No "Hide HUD Combinator Signal" found
	return true
end

local function has_network_signals(entity)
	local red_network = entity.get_circuit_network(defines.wire_type.red)
	local green_network = entity.get_circuit_network(defines.wire_type.green)

	if not (red_network == nil or red_network.signals == nil) then
		return true
	end

	if not (green_network == nil or green_network.signals == nil) then
		return true
	end

	return false
end

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

local function render_combinators(parent, meta_entities)
	local child = parent.add {type = "flow", direction = "vertical"}
	local did_render_any_combinator = false

	-- loop over every entity provided
	for i, meta_entity in pairs(meta_entities) do
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

local function update_collapse_button(player_index)
	if global.toggle_button then
		if global.hud_collapsed_map[player_index] then
			global.toggle_button.sprite = "utility/expand"
		else
			global.toggle_button.sprite = "utility/collapse"
		end
	end
end

local function get_hud(player)
	for index, value in ipairs(player.gui.screen.children) do
		if value.name == "hud-root-frame" then
			return value
		end
	end
	return nil
end

local function set_hud_position(player)
	local root_frame = get_hud(player)
	if root_frame then
		local x = player.display_resolution.width - 250
		local y = root_frame.location.y
		root_frame.location = {x, y}
		player.print("gui location: x: " .. x)
	end
end

-- Build the HUD with the signals
local function create_hud(player)
	-- Create frame in which to put the other GUI elements
	local hud_position = get_hud_position_setting(player)
	local root_frame = nil

	-- Set HUD on the left or top side of screen
	if hud_position == "left" or hud_position == "top" then
		root_frame = player.gui[hud_position].add {type = "frame", direction = "vertical", name = "hud-root-frame"}
	end

	-- Set HUD on the left side of screen
	if hud_position == "bottom-right" then
		root_frame = player.gui.screen.add {type = "frame", direction = "vertical", name = "hud-root-frame"}
		local x = player.display_resolution.width - 250
		local y = player.display_resolution.height - 250
		root_frame.location = {x, y}
		player.print("gui location: x: " .. x)
	end

	-- if global.hud_position_map[player.index] then
	-- 	local new_location = global.hud_position_map[player.index]
	-- 	root_frame.location = new_location
	-- end

	-- local title_flow = create_frame_title(root_frame, "Circuit HUD")

	-- add a "toggle" button
	global.toggle_button =
		root_frame.add {
		type = "sprite-button",
		style = "frame_action_button",
		sprite = (global.hud_collapsed_map[player.index] == true) and "utility/expand" or "utility/collapse",
		name = "toggle-circuit-hud"
	}

	local scroll_pane =
		root_frame.add {
		type = "scroll-pane",
		vertical_scroll_policy = "auto",
		style = "hud_scrollpane_style"
	}

	local inner_frame =
		scroll_pane.add {
		type = "frame",
		style = "inside_shallow_frame_with_padding",
		direction = "vertical"
	}

	global["last_frame"][player.index] = root_frame
	global["inner_frame"][player.index] = inner_frame
end

local function register_entity(entity, maybe_player_index)
	ensure_global_state()

	global.hud_combinators[entity.unit_number] = {
		["entity"] = entity,
		name = "HUD Comparator #" .. entity.unit_number -- todo: use backer names here
	}

	if maybe_player_index then
		global.hud_collapsed_map[maybe_player_index] = false
		update_collapse_button(maybe_player_index)
	end
end

local function unregister_entity(entity)
	ensure_global_state()

	global.hud_combinators[entity.unit_number] = nil
end

--#region Event Registrations

Event.register(
	defines.events.on_tick,
	function(event)
		if not global.did_cleanup_and_discovery then
			return -- wait for cleanup and discovery
		end

		-- go through each player
		for i, player in pairs(game.players) do
			local outer_frame = global["last_frame"][player.index]
			local inner_frame = global["inner_frame"][player.index]

			if global.hud_collapsed_map[player.index] and outer_frame then
				inner_frame.visible = false
				return
			else
				inner_frame.visible = true
			end

			if inner_frame and outer_frame then
				inner_frame.clear()

				local did_render_any_combinator = false

				if global.hud_combinators then
					did_render_any_combinator = render_combinators(inner_frame, global.hud_combinators)
				end

				outer_frame.visible = did_render_any_combinator
			end
		end
	end
)

Event.register(
	defines.events.on_tick,
	function(event)
		if not global.did_cleanup_and_discovery then
			global.did_cleanup_and_discovery = true
			ensure_global_state()

			-- clean the map for invalid entities
			for i, meta_entity in pairs(global.hud_combinators) do
				if (not meta_entity.entity) or (not meta_entity.entity.valid) then
					global.hud_combinators[i] = nil
				end
			end

			-- find entities not discovered
			for i, surface in pairs(game.surfaces) do
				-- find all hud combinator
				local hud_combinators = surface.find_entities_filtered {name = "hud-combinator"}

				if hud_combinators then
					for i, hud_combinator in pairs(hud_combinators) do
						if not global.hud_combinators[hud_combinator.unit_number] then
							global.hud_combinators[hud_combinator.unit_number] = {
								["entity"] = hud_combinator,
								["name"] = "HUD Combinator #" .. hud_combinator.unit_number -- todo: use backer names here
							}
						end
					end
				end
			end
		end
	end
)

Event.register(
	defines.events.on_tick,
	function()
		if not global.did_initial_render then
			ensure_global_state()
			reset_hud()
			global.did_initial_render = true
		end

		if (global["last_frame"] == nil) then
			global["last_frame"] = {}
		end

		if (global["inner_frame"] == nil) then
			global["inner_frame"] = {}
		end

		-- go through each player
		for i, player in pairs(game.players) do
			if global["last_frame"][player.index] == nil then
				create_hud(player)
			end
		end
	end
)

Event.register(
	defines.events.on_gui_opened,
	function(event)
		if (not (event.entity == nil)) and (event.entity.name == "hud-combinator") then
			local player = game.get_player(event.player_index)

			-- create the new gui
			local root_element = create_frame(player.gui.screen, "HUD Comparator")
			player.opened = root_element
			player.opened.force_auto_center()

			local inner_frame = root_element.add {type = "frame", style = "inside_shallow_frame_with_padding"}
			local vertical_flow = inner_frame.add {type = "flow", direction = "vertical"}

			local preview_frame = vertical_flow.add {type = "frame", style = "deep_frame_in_shallow_frame"}
			local preview = preview_frame.add {type = "entity-preview"}
			preview.style.width = 100
			preview.style.height = 100
			preview.visible = true
			preview.entity = event.entity

			local space = vertical_flow.add {type = "empty-widget"}

			local frame = vertical_flow.add {type = "frame", style = "invisible_frame_with_title_for_inventory"}
			local label = frame.add({type = "label", caption = "Name", style = "heading_2_label"})

			local textbox = vertical_flow.add {type = "textfield", style = "production_gui_search_textfield"}
			ensure_global_state()
			textbox.text = global.hud_combinators[event.entity.unit_number]["name"]
			textbox.select(0, 0)

			-- save the reference
			global.textbox_hud_entity_map[textbox.index] = event.entity
		end
	end
)

Event.register(
	defines.events.on_gui_text_changed,
	function(event)
		ensure_global_state()
		local entity = global.textbox_hud_entity_map[event.element.index]
		if entity and (global.textbox_hud_entity_map[event.element.index]) then
			-- save the reference
			global.hud_combinators[entity.unit_number]["name"] = event.text
		end
	end
)

Event.register(
	defines.events.on_gui_location_changed,
	function(event)
		if event.element.name == "hud-root-frame" then
			ensure_global_state()

			-- save the state
			global.hud_position_map[event.player_index] = event.element.location
		end
	end
)

Event.register(
	defines.events.on_gui_click,
	function(event)
		if not event.element.name then
			return -- skip this one
		end

		local unit_number = string.match(event.element.name, "hudcombinatortitle%-%-(%d+)")

		if unit_number then
			-- find the entity
			local hud_combinator = global.hud_combinators[tonumber(unit_number)]
			if hud_combinator and hud_combinator.entity.valid then
				-- open the map on the coordinates
				local player = game.players[event.player_index]
				player.zoom_to_world(hud_combinator.entity.position, 2)
			end
		end
		-- find the related HUD combinator
		local bras = 2
	end
)

Event.register(
	defines.events.on_built_entity,
	function(event)
		if event.created_entity.name == "hud-combinator" then
			register_entity(event.created_entity, event.player_index)
		end
	end
)

Event.register(
	defines.events.on_robot_built_entity,
	function(event)
		if event.created_entity.name == "hud-combinator" then
			register_entity(event.created_entity, event.player_index)
		end
	end
)

Event.register(
	defines.events.on_player_mined_entity,
	function(event)
		if event.entity.name == "hud-combinator" then
			unregister_entity(event.entity)
		end
	end
)

Event.register(
	defines.events.on_robot_mined_entity,
	function(event)
		if event.entity.name == "hud-combinator" then
			unregister_entity(event.entity)
		end
	end
)

Event.register(
	defines.events.on_gui_click,
	function(event)
		if global.toggle_button and event.element.name == "toggle-circuit-hud" then
			ensure_global_state()
			global.hud_collapsed_map[event.player_index] = not global.hud_collapsed_map[event.player_index]
			update_collapse_button(event.player_index)

			set_hud_position(game.get_player(event.player_index))
		end
	end
)

Event.register(
	defines.events.on_runtime_mod_setting_changed,
	function(event)
		local player = game.get_player(event.player_index)
		local hud_position = get_hud_position_setting(event.player_index)
		player.print("postion: " .. hud_position)
		global.did_initial_render = false
	end
)

--#endregion
