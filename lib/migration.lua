local Event = require("__stdlib__/stdlib/event/event")
local migration = require("__flib__.migration")
local const = require("lib.constants")
local base_global = require("globals.base-global")
local combinator = require("globals.combinator")
local player_settings = require("globals.player-settings")
local player_data = require("globals.player-data")

local gui_hud = require "gui.hud-gui"
local gui_combinator = require "gui.combinator-gui"
local gui_settings = require "gui.settings-gui"

-- each function will be run when upgrading from a version older than it
-- for example, if we were upgraing from 1.0.3 to 1.1.0, the last two functions would run, but not the first
local migrations = {
	["1.0.1"] = function()
		-- clear global and recreate
		base_global.ensure_global_state()
		-- recreate all global state for players
		for _, player in pairs(game.players) do
			player_data.add_player_global(player.index)
		end
	end,
	["1.2.0"] = function()
		base_global.ensure_global_state()
		-- Migrate to elements system instead of seperate HUD references
		for _, player in pairs(game.players) do
			local player_global = global.players[player.index]
			if player_global then
				if not player_global.elements then
					player_global.elements = {}
				end
				-- Move the toggle_button ref
				if player_global["toggle_button"] then
					player_data.set_hud_element_ref(player.index, const.HUD_NAMES.hud_toggle_button, player_global["toggle_button"])
					player_global["toggle_button"] = nil
				end
				-- Move the root_frame ref
				if player_global["root_frame"] then
					player_data.set_hud_element_ref(player.index, const.HUD_NAMES.hud_root_frame, player_global["root_frame"])
					player_global["root_frame"] = nil
				end
				-- Move the inner_frame ref
				if player_global["inner_frame"] then
					player_data.set_hud_element_ref(player.index, const.HUD_NAMES.hud_scroll_pane_frame, player_global["inner_frame"])
					player_global["inner_frame"] = nil
				end
			end
		end
	end,
	["1.3.0"] = function()
		-- clean-up pre v1.3.0 global references and destroy what is not needed anymore
		-- remove textbox_hud_entity_map as it became obsolete.
		global["textbox_hud_entity_map"] = nil
		global["did_cleanup_and_discovery"] = nil
		global["refresh_rate"] = nil
		global["did_initial_render"] = nil
		global["hud_position_map"] = nil
		global["hud_collapsed_map"] = nil

		if global["last_frame"] and table_size(global["last_frame"]) > 0 then
			for _, value in pairs(global["last_frame"]) do
				if value and value.valid then
					value.destroy()
				end
			end
			global["last_frame"] = nil
		end

		if global["inner_frame"] and table_size(global["inner_frame"]) > 0 then
			for _, value in pairs(global["inner_frame"]) do
				if value and value.valid then
					value.destroy()
				end
			end
			global["inner_frame"] = nil
		end

		if global["toggle_button"] and global["toggle_button"].valid then
			global["toggle_button"].destroy()
		end
		global["toggle_button"] = nil

		global["hud_collapsed_map"] = nil

		-- Create new filters property for each HUD Combinator
		for _, value in pairs(global.hud_combinators) do
			if value.entity.valid and not value["filters"] then
				if value["filters"] == nil then
					value["filters"] = {}
				end
				if value["unit_number"] == nil then
					value["unit_number"] = value.entity.unit_number
				end
				if value["should_filter"] == nil then
					value["should_filter"] = false
				end
				if value["priority"] == nil then
					value["priority"] = 0
				end
			end
		end

		-- Update players global and settings
		local setting_prefix = "CircuitHUD_"
		for player_index, player in pairs(global.players) do
			if not player["search_text"] then
				player["search_text"] = ""
			end

			if not player["hud_combinators"] then
				player["hud_combinators"] = {}
			end

			-- Migrate settings to new system
			if not player["settings"] then
				player["settings"] = player_settings.default_player_settings()
				local settings = settings.get_player_settings(player_index)
				-- set_hud_position_setting
				local value = settings[setting_prefix .. "hud_position"].value
				player_settings.set_hud_position_setting(value)

				-- set_hud_columns_setting
				value = settings[setting_prefix .. "hud_columns"].value
				player_settings.set_hud_columns_setting(value)

				-- set_hud_max_height_setting
				value = settings[setting_prefix .. "hud_height"].value
				player_settings.set_hud_height_setting(value)

				-- set_hide_hud_header_setting
				value = settings[setting_prefix .. "hide_hud_header"].value
				player_settings.set_hide_hud_header_setting(value)

				-- set_hud_title_setting
				value = settings[setting_prefix .. "hud_title"].value
				player_settings.set_hud_title_setting(value)

				-- set_uncollapse_hud_on_register_combinator_setting
				value = settings[setting_prefix .. "uncollapse_hud_on_register_combinator"].value
				player_settings.set_uncollapse_hud_on_register_combinator_setting(value)

				-- set_debug_mode_setting
				value = settings[setting_prefix .. "debug_mode"].value
				player_settings.set_debug_mode_setting(value)
			end
		end
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

			base_global.ensure_global_state()

			-- Reset all Combinator HUD references
			combinator.check_combinator_registrations()

			for _, player in pairs(game.players) do
				local player_index = player.index
				-- Ensure all HUDS are visible
				if player_settings.get_hide_hud_header_setting(player.index) then
					gui_hud.update_collapse_state(player.index, false)
				end

				-- Clean up any GUI Elements
				player_data.destroy_hud(player_index)

				-- Reset everything
				gui_hud.reset(player_index)
			end
		end
	end
)
--#endregion
