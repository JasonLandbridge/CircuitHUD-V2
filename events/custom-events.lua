local Event = require("__stdlib__/stdlib/event/event")
local const = require("lib.constants")
local gui_combinator = require("gui.hud-gui")
local gui_settings = require("gui.settings-gui")
local gui_hud = require("gui.hud-gui")

local function register_event(event_name, handler)
	Event.register(Event.generate_event_name(event_name), handler)
end

register_event(
	const.EVENTS.collapse_hud,
	function(event)
		gui_hud.update_collapse_state(event.player_index, event.state)
	end
)

register_event(
	const.EVENTS.gui_hud_create,
	function(event)
		gui_hud.create(event.player_index)
	end
)

register_event(
	const.EVENTS.gui_combinator_create,
	function(event)
		gui_combinator.create(event.player_index)
	end
)

register_event(
	const.EVENTS.gui_hud_reset_all_players,
	function()
		gui_hud.reset_all_players()
	end
)

register_event(
	const.EVENTS.gui_settings_create,
	function(event)
		gui_settings.create(event.player_index)
	end
)
