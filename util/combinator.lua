local function add_hud_combinator_ref(hud_combinator)
	global.hud_combinators[hud_combinator.unit_number] = {
		["entity"] = hud_combinator,
		-- todo: use backer names here
		["name"] = "HUD Comparator #" .. hud_combinator.unit_number
	}
end

local function remove_hud_combinator_ref(hud_combinator)
	global.hud_combinators[hud_combinator.unit_number] = nil
end

local function reset_hud_combinator_refs()
	global.hud_combinators = {}
end

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

function reset_combinator_registrations()
	reset_hud_combinator_refs()

	-- find entities not discovered
	for i, surface in pairs(game.surfaces) do
		-- find all hud combinator
		local hud_combinators = surface.find_entities_filtered {name = HUD_COMBINATOR_NAME}

		if hud_combinators then
			for i, hud_combinator in pairs(hud_combinators) do
				if not global.hud_combinators[hud_combinator.unit_number] then
					add_hud_combinator_ref(hud_combinator)
				end
			end
		end
	end
end

function register_combinator(entity, player_index)
	add_hud_combinator_ref(entity)
	-- Uncollapse the HUD when a new combinator is registered
	if player_index and get_uncollapse_hud_on_register_combinator_setting(player_index) then
		update_collapse_state(player_index, false)
	end
end

function unregister_combinator(entity)
	remove_hud_combinator_ref(entity)
end
