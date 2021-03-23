local Event = require("__stdlib__/stdlib/event/event")
local const = require("lib.constants")

local player_data = require("globals.player-data")
local gui_combinator = require("gui.combinator-gui")
local gui_settings = require("gui.settings-gui")
local gui_hud = require("gui.hud-gui")

local function register_event(event_name, handler)
	Event.register(Event.generate_event_name(event_name), handler)
end

--#region GUI HUD
register_event(
	const.EVENTS.gui_hud_create,
	function(event)
		gui_hud.create(event.player_index)
	end
)

register_event(
	const.EVENTS.gui_hud_collapse_switch,
	function(event)
		gui_hud.update_collapse_state(event.player_index, event.state)
	end
)

register_event(
	const.EVENTS.gui_hud_toggle,
	function(event)
		local toggle_state = not player_data.get_hud_collapsed(event.player_index)
		gui_hud.update_collapse_state(event.player_index, toggle_state)
	end
)

register_event(
	const.EVENTS.gui_hud_reset_all_players,
	function()
		gui_hud.reset_all_players()
	end
)

register_event(
	const.EVENTS.gui_hud_size_changed,
	function(event)
		gui_hud.size_changed(event.player_index, event.size)
	end
)
--#endregion

--#region GUI Combinator
register_event(
	const.EVENTS.open_hud_combinator,
	function(event)
		gui_combinator.reset(event.player_index, event.unit_number)
	end
)
--#endregion

--#region GUI Settings
register_event(
	const.EVENTS.gui_settings_create,
	function(event)
		gui_settings.create(event.player_index)
	end
)

register_event(
	const.EVENTS.gui_settings_open,
	function(event)
		gui_settings.create(event.player_index)
	end
)
--#endregion

Event.register(
	const.EVENTS.gui_hud_toggle,
	function(event)
		local toggle_state = not player_data.get_hud_collapsed(event.player_index)
		gui_hud.update_collapse_state(event.player_index, toggle_state)
	end
)

Event.register(
	const.EVENTS.gui_settings_open,
	function(event)
		gui_settings.create(event.player_index)
	end
)
