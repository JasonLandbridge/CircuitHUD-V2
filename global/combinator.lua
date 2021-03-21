local const = require("lib.constants")

local function add_hud_combinator_ref(hud_combinator)
	global.hud_combinators[hud_combinator.unit_number] = {
		["entity"] = hud_combinator,
		["name"] = "HUD Combinator #" .. hud_combinator.unit_number,
		["temp_name"] = "",
		["filters"] = {},
		["should_filter"] = false,
		["unit_number"] = hud_combinator.unit_number
	}
end

local function remove_hud_combinator_ref(unit_number)
	global.hud_combinators[unit_number] = nil
end

function register_combinator(entity)
	add_hud_combinator_ref(entity)

	for k, player in pairs(game.players) do
		-- Uncollapse the HUD when a new combinator is registered
		if get_uncollapse_hud_on_register_combinator_setting(player.index) then
			update_collapse_state(player.index, false)
		end
	end
end

function unregister_combinator(entity)
	remove_hud_combinator_ref(entity.unit_number)
end

--#region Get Combinator Helpers
function get_hud_combinator(unit_number)
	return global.hud_combinators[unit_number]
end

function get_hud_combinator_entity(unit_number)
	local hud_combinator = get_hud_combinator(unit_number)
	if hud_combinator then
		return hud_combinator["entity"]
	end
	return nil
end

function get_hud_combinator_name(unit_number)
	local hud_combinator = get_hud_combinator(unit_number)
	if hud_combinator then
		return hud_combinator["name"]
	end
	return nil
end

function get_hud_combinator_temp_name(unit_number)
	local hud_combinator = get_hud_combinator(unit_number)
	if hud_combinator then
		return hud_combinator["temp_name"]
	end
	return nil
end

function get_hud_combinator_filters(unit_number)
	local hud_combinator = get_hud_combinator(unit_number)
	if hud_combinator then
		return hud_combinator["filters"]
	end
end

function get_hud_combinator_filter_state(unit_number)
	local hud_combinator = get_hud_combinator(unit_number)
	if hud_combinator then
		return hud_combinator["should_filter"]
	end
	return nil
end

--#endregion

--#region Set Combinator Helpers

function set_hud_combinator_name(unit_number, name)
	local hud_combinator = get_hud_combinator(unit_number)
	if hud_combinator then
		hud_combinator["name"] = name
	end
end

function set_hud_combinator_temp_name(unit_number, name)
	local hud_combinator = get_hud_combinator(unit_number)
	if hud_combinator then
		hud_combinator["temp_name"] = name
	end
end

function set_hud_combinator_filter(unit_number, index, filter_signal)
	local hud_combinator = get_hud_combinator(unit_number)
	if hud_combinator then
		hud_combinator["filters"][index] = filter_signal
	end
end

function set_hud_combinator_filter_state(unit_number, state)
	local hud_combinator = get_hud_combinator(unit_number)
	if hud_combinator then
		hud_combinator["should_filter"] = state
	end
end

--#endregion

function check_combinator_registrations()
	-- clean the map for invalid entities
	for key, meta_entity in pairs(global.hud_combinators) do
		if (not meta_entity.entity) or (not meta_entity.entity.valid) then
			remove_hud_combinator_ref(key)
		end
	end

	-- find entities not discovered
	for i, surface in pairs(game.surfaces) do
		-- find all hud combinator
		local hud_combinators = surface.find_entities_filtered {name = const.HUD_COMBINATOR_NAME}

		if hud_combinators then
			for _, hud_combinator in pairs(hud_combinators) do
				if not global.hud_combinators[hud_combinator.unit_number] then
					add_hud_combinator_ref(hud_combinator)
				end
			end
		end
	end
end
