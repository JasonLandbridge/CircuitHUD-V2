local Event = require('stdlib.event.event')
local const = require('lib.constants')
local combinator = require('globals.combinator')
local gui_hud = require('gui.hud-gui')
local gui_combinator = require('gui.combinator-gui')

local interface_name = 'CircuitHUD-V2-compaktcircuit'

local function create_entity(name, info, surface, position, force)
    local entity = surface.create_entity{
        name = name,
        position = position,
        direction = info and info.direction,
        force = force,
    }
    if entity then
        if name == const.PACKED_COMBINATOR_NAME then
            entity.destructible = false
            entity.operable = false
        end
        combinator.register_combinator(entity, info)
        gui_hud.check_all_player_hud_visibility()
    end
    return entity
end

remote.add_interface(interface_name, {
    get_info = function(entity)
        return {
            position = entity.position,
            direction = entity.direction,
            [const.COMBINATOR_SETTINGS_TAG] = combinator.get_settings(entity),
        }
    end,
    create_packed_entity = function(info, surface, position, force)
        return create_entity(const.PACKED_COMBINATOR_NAME, info, surface, position, force)
    end,
    create_entity = function(info, surface, force)
        return create_entity(const.HUD_COMBINATOR_NAME, info, surface, info.position, force)
    end,
})

local function register_combinator()
    if remote.interfaces.compaktcircuit and remote.interfaces.compaktcircuit.add_combinator then
        remote.call('compaktcircuit', 'add_combinator', {
            name = const.HUD_COMBINATOR_NAME,
            packed_names = {const.PACKED_COMBINATOR_NAME},
            interface_name = interface_name,
        })
    end
end

-- Compakt's driver registry is local state and must be rebuilt after every load.
Event.on_init(register_combinator)
Event.on_load(register_combinator)
Event.on_configuration_changed(register_combinator)

-- Refresh immediately when entering, leaving or switching between circuit editors.
Event.register(defines.events.on_player_changed_surface, function(event)
    local player = game.get_player(event.player_index)
    local window = gui_combinator.get_combinator_gui(player.index)
    if window then
        local entity = combinator.get_hud_combinator_entity(window.tags.unit_number)
        if not combinator.is_visible_to_player(entity, player) then
            gui_combinator.destroy_all(player.index)
        end
    end
    gui_hud.should_hud_root_exist(player.index)
end)
