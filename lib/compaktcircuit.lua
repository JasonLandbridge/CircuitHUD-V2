local const = require('lib.constants')
local compaktcircuit = {}

function compaktcircuit.is_enabled(active_mods)
    return (active_mods.compaktcircuit or active_mods['compaktcircuit-factorio21']) ~= nil
        and settings.startup[const.COMPAKT_SUPPORT_SETTING].value
end

-- Compakt uses this surface name for every processor variant, including nested circuits.
function compaktcircuit.is_editor_surface(surface)
    return surface.name:match('^proc_%d+$') ~= nil
end

function compaktcircuit.is_visible(entity, player)
    -- Packed entities are implementation details, never navigation targets.
    if entity.name == const.PACKED_COMBINATOR_NAME then return false end
    return not compaktcircuit.is_editor_surface(entity.surface)
        or (player ~= nil and player.surface == entity.surface)
end

return compaktcircuit
