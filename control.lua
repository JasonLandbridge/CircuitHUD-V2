local mod_gui = require "mod-gui"
local Event = require("__stdlib__/stdlib/event/event")

local const = require("lib.constants")
local common = require("lib.common")

local player_settings = require("globals.player-settings")
local combinator = require("globals.combinator")
local player_data = require("globals.player-data")
local base_global = require("globals.base-global")

require "lib.migration"

local gui_hud = require("gui.hud-gui")

require "events.gui-events"
require "events.custom-events"

-- Enable Lua API global Variable Viewer
-- https://mods.factorio.com/mod/gvv
if script.active_mods["gvv"] then
	require("__gvv__.gvv")()
end

--#region OnInit

Event.on_init(
	function()
		for _, player in pairs(game.players) do
			common.debug_log(player.index, "On Init")
		end
		-- Ensure the global state has been initialized
		base_global.ensure_global_state()
		-- Check all Combinator HUD references
		combinator.check_combinator_registrations()
		-- Ensure we have created the HUD for all players
		gui_hud.check_all_player_hud_visibility()
	end
)
--#endregion

--#region On Nth Tick
Event.on_nth_tick(
	1,
	function(event)
		-- go through each player and update their HUD based on the HUD Refresh rate
		for _, player in pairs(game.players) do
			if event.tick % player_settings.get_hud_refresh_rate_setting(player.index) == 0 then
				gui_hud.update(player.index)
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
		local player = common.get_player(event.player_index)
		player_data.add_player_global(event.player_index)
		gui_hud.create(event.player_index)
		common.debug_log(event.player_index, "Circuit HUD created for player " .. player.name)
	end
)

--#endregion

--#region On Player Removed

Event.register(
	defines.events.on_player_removed,
	function(event)
		player_data.remove_player_global(event.player_index)
	end
)
--#endregion

--#region On Runtime Mod Setting Changed

Event.register(
	defines.events.on_runtime_mod_setting_changed,
	function(event)
		-- Only update when a CircuitHUD change has been made
		if event.player_index and string.find(event.setting, const.SETTINGS.prefix) then
			gui_hud.reset(event.player_index)
			-- Ensure the HUD is visible on mod setting change
			gui_hud.update_collapse_state(event.player_index, false)
		end
	end
)
--#endregion

--#region Register / De-register HUD Combinator

local function set_combinator_registration(entity, state)
	if entity.name == const.HUD_COMBINATOR_NAME then
		if state then
			combinator.register_combinator(entity)
		else
			combinator.unregister_combinator(entity)
		end
		gui_hud.check_all_player_hud_visibility()
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
	defines.events.on_player_display_resolution_changed,
	function(event)
		gui_hud.reset(event.player_index)
	end
)

Event.register(
	defines.events.on_player_display_scale_changed,
	function(event)
		gui_hud.reset(event.player_index)
	end
)

--#endregion
