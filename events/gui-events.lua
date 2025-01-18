local Event = require("stdlib/event/event")
local flib_gui = require("__flib__.gui")

local const = require("lib.constants")
local player_settings = require("globals.player-settings")
local player_data = require("globals.player-data")

local gui_combinator = require("gui.combinator-gui")
local gui_settings = require("gui.settings-gui")

local function gui_update(event)
	flib_gui.dispatch(event)
end

--#region GUI interaction

-- unused events
-- on_gui_checked_state_changed
-- on_gui_hover
-- on_gui_leave
-- on_gui_location_changed
-- on_gui_selected_tab_changed

local function register_events()
	-- registered events
	Event.register({
		defines.events.on_gui_click,
		defines.events.on_gui_confirmed,
		defines.events.on_gui_elem_changed,
		defines.events.on_gui_selection_state_changed,
		defines.events.on_gui_switch_state_changed,
		defines.events.on_gui_text_changed,
		defines.events.on_gui_value_changed
	}, gui_update)

	--#endregion

	Event.register(defines.events.on_gui_location_changed, function(event)
		if event.element.name == const.HUD_NAMES.hud_root_frame then
			-- save the coordinates if the hud is draggable
			if player_settings.get_hud_position_setting(event.player_index) == "draggable" then
				player_data.set_hud_location(event.player_index, event.element.location)
			end
		end
	end)

	--#region On GUI Opened

	Event.register(defines.events.on_gui_opened, function(event)
		if (not (event.entity == nil)) and (event.entity.name == const.HUD_COMBINATOR_NAME) then
			-- create the HUD Combinator Gui
			gui_combinator.create(event.player_index, event.entity.unit_number)
		end
	end)

	Event.register(defines.events.on_gui_closed, function(event)
		-- check if it's and HUD Combinator GUI and close that
		if (event.element) then
			-- Destroy Settings Gui
			if event.element.name == const.HUD_NAMES.settings_root_frame then
				gui_settings.destroy(event.player_index)
				return
			end

			-- Destroy HUD Combinator Gui
			if event.element.name == const.HUD_NAMES.combinator_root_frame then
				gui_combinator.destroy(event.player_index, event.element.name)
				return
			end
		end
	end)
end

--#endregion

Event.on_init(register_events)
Event.on_load(register_events)
