local common = require("lib.common")

local base_global = {}

function base_global.ensure_global_state()
	-- A collection of all players with their individual data
	if not common.valid(global.players) then
		global.players = {}
	end

	-- A collection of all HUD Combinators entities in game
	if not common.valid(global.hud_combinators) then
		global.hud_combinators = {}
	end
end

function base_global.reset_global_state()
	global = {}
	base_global.ensure_global_state()
end

return base_global
