local Event = require('stdlib.event.event')
local base_global = require('globals.base-global')
local combinator = require('globals.combinator')
local player_settings = require('globals.player-settings')
local player_data = require('globals.player-data')

local gui_hud = require('gui.hud-gui')


--#region On Configuration Changed
local function run_on_config_changed(config_changed_data)
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
--#endregion

local function register_events()
	Event.on_configuration_changed(run_on_config_changed)
end

Event.on_init(register_events)
Event.on_load(register_events)
