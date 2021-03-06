require "mod-gui"
require "gui-util"
require "commands/reload"
require "util/reset_hud"

require "util/log"
require "util/general"
require "util/global"
require "util/settings"
require "util/player"
require "util/gui"
require "util/combinator"

local Event = require("__stdlib__/stdlib/event/event")

-- Enable Lua API global Variable Viewer
-- https://mods.factorio.com/mod/gvv
if script.active_mods["gvv"] then
	require("__gvv__.gvv")()
end

--#region OnInit

Event.on_init(
	function()
		ensure_global_state()

		-- ensure we have created the HUD for all players
		for _, player in pairs(game.players) do
			debug_log(player, "On Init")
			build_interface(player.index)
		end
	end
)
--#endregion

--#region On Configuration Changed
Event.on_configuration_changed(
	function(config_changed_data)
		if config_changed_data.mod_changes["CircuitHUD-V2"] then
			for _, player in pairs(game.players) do
				reset_hud(player.index)
			end
		end
	end
)
--#endregion

--#region Event Registrations

--#region On Player Created

Event.register(
	defines.events.on_player_created,
	function(event)
		local player = get_player(event.player_index)
		initialize_global_for_player(player)
		build_interface(event.player_index)
		debug_log(player, "HUD Created on player created")
	end
)

--#endregion

--#region On Player Removed

Event.register(
	defines.events.on_player_removed,
	function(event)
		global.players[event.player_index] = nil
	end
)
--#endregion

--#region On Runtime Mod Setting Changed

Event.register(
	defines.events.on_runtime_mod_setting_changed,
	function(event)
		reset_hud(event.player_index)
	end
)
--#endregion

--#region On Tick

Event.register(
	defines.events.on_tick,
	function(event)
		-- go through each player
		for i, player in pairs(game.players) do
			local player_global = get_player_global(player.index)
			if not player_global.hud_collapsed_map and get_hud_combinators then
				update_hud(player.index)
			end
		end
	end
)

--#endregion

-- Event.register(
-- 	defines.events.on_tick,
-- 	function(event)
-- 		if not global.did_cleanup_and_discovery then
-- 			global.did_cleanup_and_discovery = true
-- 			ensure_global_state()

-- 			-- clean the map for invalid entities
-- 			for i, meta_entity in pairs(global.hud_combinators) do
-- 				if (not meta_entity.entity) or (not meta_entity.entity.valid) then
-- 					global.hud_combinators[i] = nil
-- 				end
-- 			end

-- 			-- find entities not discovered
-- 			for i, surface in pairs(game.surfaces) do
-- 				-- find all hud combinator
-- 				local hud_combinators = surface.find_entities_filtered {name = "hud-combinator"}

-- 				if hud_combinators then
-- 					for i, hud_combinator in pairs(hud_combinators) do
-- 						if not global.hud_combinators[hud_combinator.unit_number] then
-- 							global.hud_combinators[hud_combinator.unit_number] = {
-- 								["entity"] = hud_combinator,
-- 								["name"] = "HUD Combinator #" .. hud_combinator.unit_number -- todo: use backer names here
-- 							}
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- )

--#region On GUI Opened

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

			textbox.text = global.hud_combinators[event.entity.unit_number]["name"]
			textbox.select(0, 0)

			-- save the reference
			global.textbox_hud_entity_map[textbox.index] = event.entity
		end
	end
)

--#endregion

Event.register(
	defines.events.on_gui_text_changed,
	function(event)
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
			-- save the coordinates if the hud is draggable
			if get_hud_position_setting(event.player_index) == "draggable" then
				set_hud_location(event.player_index, event.element.location)
			end
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
			register_combinator(event.created_entity, event.player_index)
		end
	end
)

Event.register(
	defines.events.on_robot_built_entity,
	function(event)
		if event.created_entity.name == "hud-combinator" then
			register_combinator(event.created_entity, event.player_index)
		end
	end
)

Event.register(
	defines.events.on_player_mined_entity,
	function(event)
		if event.entity.name == "hud-combinator" then
			unregister_combinator(event.entity)
		end
	end
)

Event.register(
	defines.events.on_robot_mined_entity,
	function(event)
		if event.entity.name == "hud-combinator" then
			unregister_combinator(event.entity)
		end
	end
)

Event.register(
	defines.events.on_gui_click,
	function(event)
		if event.element.name == "toggle-circuit-hud" then
			local toggle_state = not get_hud_collapsed(event.player_index)
			update_collapse_button(event.player_index, toggle_state)
		end
	end
)

--#endregion
