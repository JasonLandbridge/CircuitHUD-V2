local common = require("lib.common")

local base_global = {}

function base_global.ensure_global_state()
	-- A collection of all players with their individual data
	if not common.valid(storage.players) then
		storage.players = {}
	end

	-- A collection of all HUD Combinators entities in game
	if not common.valid(storage.hud_combinators) then
		storage.hud_combinators = {}
	end
end

function base_global.reset_global_state()
	storage = {}
	base_global.ensure_global_state()
end

return base_global
