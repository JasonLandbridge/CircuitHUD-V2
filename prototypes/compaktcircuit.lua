local util = require('util')
local const = require('lib.constants')

local packed = table.deepcopy(data.raw['constant-combinator'][const.HUD_COMBINATOR_NAME])
packed.name = const.PACKED_COMBINATOR_NAME
packed.localised_name = {'entity-name.hud-combinator'}
packed.hidden = true
packed.hidden_in_factoriopedia = true
packed.minable = nil
packed.selectable_in_game = false
packed.allow_copy_paste = false
packed.fast_replaceable_group = nil
packed.collision_box = {{0, 0}, {0, 0}}
packed.collision_mask = {layers = {}}
packed.selection_box = {{0, 0}, {0, 0}}
packed.flags = {'placeable-off-grid', 'not-on-map', 'not-blueprintable', 'not-deconstructable',
    'not-upgradable', 'hide-alt-info', 'not-in-kill-statistics', 'not-in-made-in'}
packed.sprites = util.empty_sprite()
packed.activity_led_sprites = util.empty_sprite()
packed.activity_led_light = nil
packed.activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}}
local connection = {wire = {red = {0, 0}, green = {0, 0}}, shadow = {red = {0, 0}, green = {0, 0}}}
packed.circuit_wire_connection_points = {connection, connection, connection, connection}
packed.circuit_wire_max_distance = 64
packed.draw_circuit_wires = false
packed.draw_copper_wires = false
data:extend{packed}
