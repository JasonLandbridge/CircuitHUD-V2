local Event = require("__stdlib__/stdlib/event/event")
local const = require("lib.constants")

local event_handler = {}

--#region GUI HUD
function event_handler.gui_hud_create(player_index)
	Event.dispatch(
		{
			input_name = Event.generate_event_name(const.EVENTS.gui_hud_create),
			player_index = player_index
		}
	)
end

-- Fires an event to collapse/uncollapse the HUD
function event_handler.gui_hud_collapse_switch(player_index, state)
	Event.dispatch(
		{
			input_name = Event.generate_event_name(const.EVENTS.gui_hud_collapse_switch),
			player_index = player_index,
			state = state
		}
	)
end

function event_handler.gui_hud_collapse_toggle(player_index, state)
	Event.dispatch(
		{
			input_name = Event.generate_event_name(const.EVENTS.gui_hud_collapse_switch),
			player_index = player_index,
			state = state
		}
	)
end

function event_handler.gui_hud_reset_all_players()
	Event.dispatch(
		{
			input_name = Event.generate_event_name(const.EVENTS.gui_hud_reset_all_players)
		}
	)
end

function event_handler.gui_hud_size_changed(player_index, size)
	Event.dispatch(
		{
			input_name = Event.generate_event_name(const.EVENTS.gui_hud_size_changed),
			player_index = player_index,
			size = size
		}
	)
end
--#endregion

--#region GUI Combinator

function event_handler.open_hud_combinator(player_index, unit_number)
	Event.dispatch(
		{
			input_name = Event.generate_event_name(const.EVENTS.open_hud_combinator),
			player_index = player_index,
			unit_number = unit_number
		}
	)
end

--#endregion

--#region GUI Settings

function event_handler.gui_settings_create(player_index)
	Event.dispatch(
		{
			input_name = Event.generate_event_name(const.EVENTS.gui_settings_create),
			player_index = player_index
		}
	)
end

function event_handler.gui_settings_open(player_index)
	Event.dispatch(
		{
			input_name = Event.generate_event_name(const.EVENTS.gui_settings_open),
			player_index = player_index
		}
	)
end

--#endregion

return event_handler
