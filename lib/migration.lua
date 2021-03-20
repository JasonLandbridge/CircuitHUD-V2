local Event = require("__stdlib__/stdlib/event/event")

local migration = require("__flib__.migration")

-- each function will be run when upgrading from a version older than it
-- for example, if we were upgraing from 1.0.3 to 1.1.0, the last two functions would run, but not the first
local migrations = {
	["1.0.1"] = function()
		-- clear global and recreate
		reset_global_state()
		-- recreate all global state for players
		for _, player in pairs(game.players) do
			add_player_global(player.index)
		end
	end,
	["1.1.0"] = function()
		-- Migrate to elements system instead of seperate HUD references
		for _, player in pairs(game.players) do
			local player_global = global.players[player.index]
			if player_global then
				if not player_global.elements then
					player_global.elements = {}
				end
				-- Move the toggle_button ref
				if player_global["toggle_button"] then
					set_hud_element_ref(player.index, HUD_NAMES.hud_toggle_button, player_global["toggle_button"])
					player_global["toggle_button"] = nil
				end
				-- Move the root_frame ref
				if player_global["root_frame"] then
					set_hud_element_ref(player.index, HUD_NAMES.hud_root_frame, player_global["root_frame"])
					player_global["root_frame"] = nil
				end
				-- Move the inner_frame ref
				if player_global["inner_frame"] then
					set_hud_element_ref(player.index, HUD_NAMES.hud_scroll_pane_frame, player_global["inner_frame"])
					player_global["inner_frame"] = nil
				end
			end
		end
	end,
	["1.2.1"] = function()
		-- remove textbox_hud_entity_map as it became obsolete.
		for key, value in pairs(global.textbox_hud_entity_map) do
			if value then
				value.destroy()
			end
		end
		global.textbox_hud_entity_map = nil
	end
}

--#region On Configuration Changed
Event.on_configuration_changed(
	function(config_changed_data)
		-- migrate save to current config
		if migration.on_config_changed(config_changed_data, migrations) then
			-- Run a refresh which will always be done after any migration
			-- Original version had a fuck-ton of unneeded on_tick events, which are now refactored away
			Event.remove(defines.events.on_tick)

			ensure_global_state()

			-- Reset all Combinator HUD references
			check_combinator_registrations()

			for _, player in pairs(game.players) do
				-- Ensure all HUDS are visible
				if get_hide_hud_header_setting(player.index) then
					update_collapse_state(player.index, false)
				end
				-- Reset the HUD for all players
				reset_hud(player.index)
			end
		end
	end
)
--#endregion
