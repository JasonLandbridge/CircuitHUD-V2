local const = require('lib.constants')
local groups = {}

-- The first member determines the group's position in the player's selected sort order.
function groups.build(sorted_combinators)
    local result, by_name = {}, {}
    for _, member in ipairs(sorted_combinators) do
        if member.entity.valid then
            local group = by_name[member.name]
            if not group then
                group = {name = member.name, members = {}}
                by_name[member.name] = group
                result[#result + 1] = group
            end
            group.members[#group.members + 1] = member
        end
    end
    return result
end

local function signal_key(signal)
    return (signal.type or 'item') .. '/' .. signal.name .. '/' .. (signal.quality or 'normal')
end

local function read_network(entity, connector, cache)
    local network = entity.get_circuit_network(connector)
    if not network then return end
    local key = entity.surface.index .. ':' .. connector .. ':' .. network.network_id
    local snapshot = cache[key]
    if not snapshot then
        snapshot = {signals = network.signals or {}, hidden = false}
        for _, signal in ipairs(snapshot.signals) do
            if signal.signal.type == 'virtual' and signal.signal.name == const.HIDE_SIGNAL_NAME then
                snapshot.hidden = true
                break
            end
        end
        cache[key] = snapshot
    end
    return snapshot
end

-- Cache only within a HUD refresh: network IDs and values may change on the next tick.
-- A shared network can have different filters on its readers. Deduplicate each
-- accepted signal, rather than discarding the second reader's entire network.
function groups.collect(members, is_visible, cache)
    cache = cache or {}
    local result = {
        networks = {{signals = {}}, {signals = {}}},
        signal_count = 0,
        hidden_members = 0,
    }
    local totals, seen = {{}, {}}, {}
    for _, member in ipairs(members) do
        if member.entity.valid and is_visible(member.unit_number) then
            local green = read_network(member.entity, defines.wire_connector_id.circuit_green, cache)
            local red = read_network(member.entity, defines.wire_connector_id.circuit_red, cache)
            if (green and green.hidden) or (red and red.hidden) then
                result.hidden_members = result.hidden_members + 1
            else
                local filters
                if member.should_filter then
                    filters = {}
                    for _, signal in pairs(member.filters) do filters[signal_key(signal)] = true end
                end
                local networks = {green, red}
                for color = 1, 2 do
                    local network = networks[color]
                    if network then
                        local accepted = seen[network]
                        if not accepted then accepted = {}; seen[network] = accepted end
                        for _, signal in ipairs(network.signals) do
                            local key = signal_key(signal.signal)
                            if not accepted[key] and (not filters or filters[key]) then
                                accepted[key] = true
                                local total = totals[color][key]
                                if total then
                                    total.count = total.count + signal.count
                                else
                                    total = {signal = signal.signal, count = signal.count}
                                    totals[color][key] = total
                                    local signals = result.networks[color].signals
                                    signals[#signals + 1] = total
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Opposite signed inputs may cancel; omit their zero total from the HUD.
    for _, network in ipairs(result.networks) do
        local signals = {}
        for _, signal in ipairs(network.signals) do
            if signal.count ~= 0 then signals[#signals + 1] = signal end
        end
        network.signals = signals
        result.signal_count = result.signal_count + #signals
    end
    return result
end

return groups
