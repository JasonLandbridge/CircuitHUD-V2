-- Check if this HUD Combinator has any signals coming in to show in the HUD.
-- @param entity The HUD Combinator
function has_network_signals(entity)
	local red_network = entity.get_circuit_network(defines.wire_type.red)
	local green_network = entity.get_circuit_network(defines.wire_type.green)

	if not (red_network == nil or red_network.signals == nil) then
		return true
	end

	if not (green_network == nil or green_network.signals == nil) then
		return true
	end

	return false
end

-- Checks if the signal coming into our HUD-Combinator contains our custom "Hide HUD Combinator Signal" and should therefore not show.
-- Will return true if this network should show  and false if the "Hide HUD Combinator Signal" is found.
-- @param entity The HUD Combinator
function should_show_network(entity)
	-- Get both the red and green circuit networks
	local red_network = entity.get_circuit_network(defines.wire_type.red)
	local green_network = entity.get_circuit_network(defines.wire_type.green)

	if red_network and red_network.signals then
		for _, signal in pairs(red_network.signals) do
			if signal.signal.name == "signal-hide-hud-comparator" then
				return false
			end
		end
	end

	if green_network and green_network.signals then
		for _, signal in pairs(green_network.signals) do
			if signal.signal.name == "signal-hide-hud-comparator" then
				return false
			end
		end
	end

	-- No "Hide HUD Combinator Signal" found
	return true
end
