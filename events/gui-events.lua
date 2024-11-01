local Event = require("__kry_stdlib__/stdlib/event/event")
local flib_gui = require("__flib__.gui")

local const = require("lib.constants")
local player_settings = require("globals.player-settings")
local player_data = require("globals.player-data")

local gui_combinator = require("gui.combinator-gui")
local gui_settings = require("gui.settings-gui")
local gui_hud = require("gui.hud-gui")


-- Legacy flib GUI functions, though they don't work properly as I don't understand what read_action is trying to do.
-- All the .tags are empty so it bails out early

local mod_name = script.mod_name
local gui_event_defines = {}
local event_id_to_string_mapping = {}
for name, id in pairs(defines.events) do
	if string.find(name, "^on_gui") then
		gui_event_defines[name] = id
		event_id_to_string_mapping[id] = string.gsub(name, "^on_gui", "on")
	end
end

local function read_action_legacy(event_data)
	local elem = event_data.element
	if not elem or not elem.valid then
		return
	end

	local mod_tags = elem.tags[mod_name]
	if not mod_tags then
		return
	end

	local elem_actions = mod_tags.flib
	if not elem_actions then
		return
	end

	local event_name = event_id_to_string_mapping[event_data.name]
	local msg = elem_actions[event_name]

	return msg
end

local function gui_update(event)
	-- Check if the event is meant for us
	local action = read_action_legacy(event)
	if not action then
		return
	end

	if event.define_name == "on_click" and event.element.type == "checkbox" and event.element.state ~= nil then
		-- Checkbox
		action["value"] = event.element.state
	elseif event.define_name == "on_text_changed" and event.text ~= nil then
		-- Text Field
		action["value"] = event.text
	elseif event.define_name == "on_elem_changed" and event.element.elem_value ~= nil then
		--
		action["value"] = event.element.elem_value
	elseif event.define_name == "on_value_changed" and event.element.slider_value ~= nil then
		-- Sliders
		action["value"] = event.element.slider_value
	elseif event.define_name == "on_selection_state_changed" and event.element.selected_index ~= nil then
		-- Dropdowns
		action["value"] = event.element.selected_index
	elseif event.define_name == "on_switch_state_changed" and event.element.switch_state ~= nil then
		-- Switches, Right/On is true, Left/Off is false
		action["value"] = event.element.switch_state == "right"
	end

	if action.gui == const.GUI_TYPES.combinator then
		gui_combinator.event_handler(event.player_index, action)
	end

	if action.gui == const.GUI_TYPES.hud then
		gui_hud.event_handler(event.player_index, action)
	end

	if action.gui == const.GUI_TYPES.settings then
		gui_settings.event_handler(event.player_index, action)
	end
end

--#region GUI interaction

Event.register(defines.events.on_gui_click, gui_update)
Event.register(defines.events.on_gui_text_changed, gui_update)
Event.register(defines.events.on_gui_elem_changed, gui_update)
Event.register(defines.events.on_gui_value_changed, gui_update)
Event.register(defines.events.on_gui_selection_state_changed, gui_update)
Event.register(defines.events.on_gui_switch_state_changed, gui_update)

--#endregion

Event.register(
	defines.events.on_gui_location_changed,
	function(event)
		if event.element.name == const.HUD_NAMES.hud_root_frame then
			-- save the coordinates if the hud is draggable
			if player_settings.get_hud_position_setting(event.player_index) == "draggable" then
				player_data.set_hud_location(event.player_index, event.element.location)
			end
		end
	end
)

--#region On GUI Opened

Event.register(
	defines.events.on_gui_opened,
	function(event)
		if (not (event.entity == nil)) and (event.entity.name == const.HUD_COMBINATOR_NAME) then
			-- create the HUD Combinator Gui
			gui_combinator.create(event.player_index, event.entity.unit_number)
		end
	end
)

Event.register(
	defines.events.on_gui_closed,
	function(event)
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
	end
)

--#endregion
