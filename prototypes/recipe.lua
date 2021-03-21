local flib_data_util = require("__flib__.data-util")
local const = require("lib.constants")
local hud_combinator_name = const.HUD_COMBINATOR_NAME

--#region The HUD Combinator Entity
local hudCombinatorEntity = flib_data_util.copy_prototype(data.raw["constant-combinator"]["constant-combinator"], hud_combinator_name)
hudCombinatorEntity.sprites = {
	east = {
		layers = {
			{
				filename = "__CircuitHUD-V2__/graphics/entity/combinator/hud-combinator.png",
				frame_count = 1,
				height = 52,
				hr_version = {
					filename = "__CircuitHUD-V2__/graphics/entity/combinator/hr-hud-combinator.png",
					frame_count = 1,
					height = 102,
					priority = "high",
					scale = 0.5,
					shift = {
						0,
						0.15625
					},
					width = 114,
					x = 114,
					y = 0
				},
				priority = "high",
				scale = 1,
				shift = {
					0,
					0.15625
				},
				width = 58,
				x = 58,
				y = 0
			},
			{
				draw_as_shadow = true,
				filename = "__CircuitHUD-V2__/graphics/entity/combinator/hud-combinator-shadow.png",
				frame_count = 1,
				height = 34,
				hr_version = {
					draw_as_shadow = true,
					filename = "__CircuitHUD-V2__/graphics/entity/combinator/hr-hud-combinator-shadow.png",
					frame_count = 1,
					height = 66,
					priority = "high",
					scale = 0.5,
					shift = {
						0.265625,
						0.171875
					},
					width = 98,
					x = 98,
					y = 0
				},
				priority = "high",
				scale = 1,
				shift = {
					0.28125,
					0.1875
				},
				width = 50,
				x = 50,
				y = 0
			}
		}
	},
	north = {
		layers = {
			{
				filename = "__CircuitHUD-V2__/graphics/entity/combinator/hud-combinator.png",
				frame_count = 1,
				height = 52,
				hr_version = {
					filename = "__CircuitHUD-V2__/graphics/entity/combinator/hr-hud-combinator.png",
					frame_count = 1,
					height = 102,
					priority = "high",
					scale = 0.5,
					shift = {
						0,
						0.15625
					},
					width = 114,
					x = 0,
					y = 0
				},
				priority = "high",
				scale = 1,
				shift = {
					0,
					0.15625
				},
				width = 58,
				x = 0,
				y = 0
			},
			{
				draw_as_shadow = true,
				filename = "__CircuitHUD-V2__/graphics/entity/combinator/hud-combinator-shadow.png",
				frame_count = 1,
				height = 34,
				hr_version = {
					draw_as_shadow = true,
					filename = "__CircuitHUD-V2__/graphics/entity/combinator/hr-hud-combinator-shadow.png",
					frame_count = 1,
					height = 66,
					priority = "high",
					scale = 0.5,
					shift = {
						0.265625,
						0.171875
					},
					width = 98,
					x = 0,
					y = 0
				},
				priority = "high",
				scale = 1,
				shift = {
					0.28125,
					0.1875
				},
				width = 50,
				x = 0,
				y = 0
			}
		}
	},
	south = {
		layers = {
			{
				filename = "__CircuitHUD-V2__/graphics/entity/combinator/hud-combinator.png",
				frame_count = 1,
				height = 52,
				hr_version = {
					filename = "__CircuitHUD-V2__/graphics/entity/combinator/hr-hud-combinator.png",
					frame_count = 1,
					height = 102,
					priority = "high",
					scale = 0.5,
					shift = {
						0,
						0.15625
					},
					width = 114,
					x = 228,
					y = 0
				},
				priority = "high",
				scale = 1,
				shift = {
					0,
					0.15625
				},
				width = 58,
				x = 116,
				y = 0
			},
			{
				draw_as_shadow = true,
				filename = "__CircuitHUD-V2__/graphics/entity/combinator/hud-combinator-shadow.png",
				frame_count = 1,
				height = 34,
				hr_version = {
					draw_as_shadow = true,
					filename = "__CircuitHUD-V2__/graphics/entity/combinator/hr-hud-combinator-shadow.png",
					frame_count = 1,
					height = 66,
					priority = "high",
					scale = 0.5,
					shift = {
						0.265625,
						0.171875
					},
					width = 98,
					x = 196,
					y = 0
				},
				priority = "high",
				scale = 1,
				shift = {
					0.28125,
					0.1875
				},
				width = 50,
				x = 100,
				y = 0
			}
		}
	},
	west = {
		layers = {
			{
				filename = "__CircuitHUD-V2__/graphics/entity/combinator/hud-combinator.png",
				frame_count = 1,
				height = 52,
				hr_version = {
					filename = "__CircuitHUD-V2__/graphics/entity/combinator/hr-hud-combinator.png",
					frame_count = 1,
					height = 102,
					priority = "high",
					scale = 0.5,
					shift = {
						0,
						0.15625
					},
					width = 114,
					x = 342,
					y = 0
				},
				priority = "high",
				scale = 1,
				shift = {
					0,
					0.15625
				},
				width = 58,
				x = 174,
				y = 0
			},
			{
				draw_as_shadow = true,
				filename = "__CircuitHUD-V2__/graphics/entity/combinator/hud-combinator-shadow.png",
				frame_count = 1,
				height = 34,
				hr_version = {
					draw_as_shadow = true,
					filename = "__CircuitHUD-V2__/graphics/entity/combinator/hr-hud-combinator-shadow.png",
					frame_count = 1,
					height = 66,
					priority = "high",
					scale = 0.5,
					shift = {
						0.265625,
						0.171875
					},
					width = 98,
					x = 294,
					y = 0
				},
				priority = "high",
				scale = 1,
				shift = {
					0.28125,
					0.1875
				},
				width = 50,
				x = 150,
				y = 0
			}
		}
	}
}
hudCombinatorEntity.fast_replaceable_group = "constant-combinator"
hudCombinatorEntity.next_upgrade = nil
hudCombinatorEntity.item_slot_count = 0
hudCombinatorEntity.minable = {mining_time = 3.0, result = hud_combinator_name}

--#endregion

--#region The HUD Combinator as shown in a (crafting) menu
local hudCombinatorItem = flib_data_util.copy_prototype(data.raw["item"]["constant-combinator"], hud_combinator_name)
hudCombinatorItem.place_result = hud_combinator_name
hudCombinatorItem.icon = "__CircuitHUD-V2__/graphics/icon/hud-combinator.png"
hudCombinatorItem.icon_size = 64
--#endregion

--#region  The HUD Combinator Recipe
local hudCombinatorRecipe = flib_data_util.copy_prototype(data.raw.recipe["iron-chest"], hud_combinator_name)
hudCombinatorRecipe.ingredients = {{"electronic-circuit", 2}, {"copper-cable", 5}}
hudCombinatorRecipe.result = hud_combinator_name
--#endregion

data:extend {hudCombinatorEntity, hudCombinatorItem, hudCombinatorRecipe}
