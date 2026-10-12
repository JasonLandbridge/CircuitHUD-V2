local Event = require("stdlib.event.event")
local const = require("lib.constants")
local combinator = require("globals.combinator")
local gui_hud = require("gui.hud-gui")
local gui_combinator = require("gui.combinator-gui")

local handlers = {}

local function refresh_guis(entity)
	gui_hud.reset_all_players()
	for player_index in pairs(game.players) do
		local gui = gui_combinator.get_combinator_gui(player_index)
		if gui and gui.tags.unit_number == entity.unit_number then
			gui_combinator.reset(player_index, entity.unit_number)
		end
	end
end

function handlers.on_entity_settings_pasted(event)
	if combinator.copy_settings(event.source, event.destination) then
		refresh_guis(event.destination)
	end
end

function handlers.on_blueprint_settings_pasted(event)
	if event.tags and combinator.apply_settings(event.entity, event.tags[const.COMBINATOR_SETTINGS_TAG]) then
		refresh_guis(event.entity)
	end
end

function handlers.on_player_setup_blueprint(event)
	-- The event record is writable even when it comes from the personal blueprint library.
	-- Never substitute a cursor blueprint for a different blueprint supplied by the event.
	local blueprint = event.record
	if not blueprint then
		blueprint = event.stack
		if not blueprint then
			local player = game.get_player(event.player_index)
			blueprint = player and player.blueprint_to_setup
		end
		if not (blueprint and blueprint.valid_for_read and blueprint.is_blueprint) then return end
	end
	if not (blueprint.valid and blueprint.is_blueprint_setup()) then return end

	-- Check indexes before writing: another mod may have removed blueprint entities.
	local hud_indexes = {}
	for _, entity in pairs(blueprint.get_blueprint_entities() or {}) do
		if entity.name == const.HUD_COMBINATOR_NAME then
			hud_indexes[entity.entity_number] = true
		end
	end
	for index, entity in pairs(event.mapping.get()) do
		if hud_indexes[index] then
			local settings = combinator.get_settings(entity)
			if settings then
				blueprint.set_blueprint_entity_tag(index, const.COMBINATOR_SETTINGS_TAG, settings)
			end
		end
	end
end

local function register_events()
	Event.register(defines.events.on_entity_settings_pasted, handlers.on_entity_settings_pasted)
	Event.register(defines.events.on_blueprint_settings_pasted, handlers.on_blueprint_settings_pasted)
	Event.register(defines.events.on_player_setup_blueprint, handlers.on_player_setup_blueprint)
end

Event.on_init(register_events)
Event.on_load(register_events)

return handlers
