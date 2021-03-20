require "mod-gui"

require "lib/migration.lua"

require "gui/combinator-gui.lua"

require "util/constants"
require "util/log"
require "util/general"
require "util/global"
require "util/settings"
require "util/player"
require "util/gui"
require "util/combinator"

local flib_gui = require("__flib__.gui-beta")
local Event = require("__stdlib__/stdlib/event/event")

-- Enable Lua API global Variable Viewer
-- https://mods.factorio.com/mod/gvv
if script.active_mods["gvv"] then
	require("__gvv__.gvv")()
end

--#region OnInit

Event.on_init(
	function()
		for i, player in pairs(game.players) do
			debug_log(player.index, "On Init")
		end
		-- Ensure the global state has been initialized
		ensure_global_state()
		-- Reset all Combinator HUD references
		check_combinator_registrations()
		-- Ensure we have created the HUD for all players
		check_all_player_hud_visibility()
	end
)
--#endregion

--#region On Nth Tick

Event.register(
	defines.events.on_tick,
	function(event)
		if event.tick % global.refresh_rate == 0 then
			-- go through each player and update their HUD
			for i, player in pairs(game.players) do
				update_hud(player.index)
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
		add_player_global(event.player_index)
		build_interface(event.player_index)
		debug_log(event.player_index, "Circuit HUD created for player " .. player.name)
	end
)

--#endregion

--#region On Player Removed

Event.register(
	defines.events.on_player_removed,
	function(event)
		remove_player_global(event.player_index)
	end
)
--#endregion

--#region On Runtime Mod Setting Changed

Event.register(
	defines.events.on_runtime_mod_setting_changed,
	function(event)
		-- Only update when a CircuitHUD change has been made
		if event.player_index and string.find(event.setting, SETTINGS.prefix) then
			if event.setting == "CircuitHUD_hud_refresh_rate" then
				global.refresh_rate = get_refresh_rate_setting()
			end
			reset_hud(event.player_index)
			-- Ensure the HUD is visible on mod setting change
			update_collapse_state(event.player_index, false)
		end
	end
)
--#endregion

--#region On GUI Opened

Event.register(
	defines.events.on_gui_opened,
	function(event)
		if (not (event.entity == nil)) and (event.entity.name == HUD_COMBINATOR_NAME) then
			local player = game.get_player(event.player_index)

			-- create the new gui
			local root_element = create_combinator_gui(event.player_index, event.entity.unit_number)
			player.opened = root_element
			player.opened.force_auto_center()
		end
	end
)

--#endregion

Event.register(
	defines.events.on_gui_text_changed,
	function(event)
		-- Check if the event is meant for us
		local action = flib_gui.read_action(event)
		if not action then
			return
		end

		if get_hud_combinator(action.unit_number) then
			-- save the reference
			get_hud_combinator(action.unit_number)["name"] = event.text
		end
	end
)

Event.register(
	defines.events.on_gui_location_changed,
	function(event)
		if event.element.name == HUD_NAMES.hud_root_frame then
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
		-- Check if the event is meant for us
		local action = flib_gui.read_action(event)
		if not action then
			return
		end

		if action.gui == GUI_TYPES.combinator then
			handle_combinator_gui_events(event.player_index, action)
		end
	end
)

--#region Register / De-register HUD Combinator

local function set_combinator_registration(entity, state)
	if entity.name == HUD_COMBINATOR_NAME then
		if state then
			register_combinator(entity)
		else
			unregister_combinator(entity)
		end
		check_all_player_hud_visibility()
	end
end

Event.register(
	defines.events.on_built_entity,
	function(event)
		set_combinator_registration(event.created_entity, true)
	end
)

Event.register(
	defines.events.on_robot_built_entity,
	function(event)
		set_combinator_registration(event.created_entity, true)
	end
)

Event.register(
	defines.events.on_player_mined_entity,
	function(event)
		set_combinator_registration(event.entity, false)
	end
)

Event.register(
	defines.events.on_robot_mined_entity,
	function(event)
		set_combinator_registration(event.entity, false)
	end
)
--#endregion

Event.register(
	defines.events.on_gui_click,
	function(event)
		if event.element.name == HUD_NAMES.hud_toggle_button then
			local toggle_state = not get_hud_collapsed(event.player_index)
			update_collapse_state(event.player_index, toggle_state)
		end
	end
)

Event.register(
	defines.events.on_player_display_resolution_changed,
	function(event)
		should_hud_root_exist(event.player_index)
	end
)

Event.register(
	defines.events.on_player_display_scale_changed,
	function(event)
		should_hud_root_exist(event.player_index)
	end
)

--#endregion
