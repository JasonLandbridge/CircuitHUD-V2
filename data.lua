local default_gui = data.raw["gui-style"].default
default_gui["bras-scrollpane"] = {
	type = "frame_style",
	--minimal_width = 70,
	--maximal_height = 70,
	top_padding = 0,
	bottom_padding = 0
}

default_gui["hud_scrollpane_style"] = {
	type = "scroll_pane_style",
	maximal_height = 400,
	extra_padding_when_activated = 0
}

default_gui["draggable_space_hud_header"] = {
	type = "empty_widget_style",
	parent = "draggable_space",
	top_margin = 0,
	left_margin = 8,
	right_margin = 8,
	minimal_width = 32,
	minimal_height = 24
}

default_gui["empty_widget_distance"] = {
	type = "empty_widget_style",
	size = {100, 10}
}

local hudCombinatorEntity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
hudCombinatorEntity.name = "hud-combinator"
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
hudCombinatorEntity.item_slot_count = 0
hudCombinatorEntity.minable = {mining_time = 0.1, result = "hud-combinator"}

local hudCombinatorItem = table.deepcopy(data.raw.item["constant-combinator"])
hudCombinatorItem.name = "hud-combinator"
hudCombinatorItem.place_result = "hud-combinator"
hudCombinatorItem.icons = {
	{
		icon = "__CircuitHUD-V2__/graphics/icon/hud-combinator.png"
	}
}

local hudCombinatorRecipe = table.deepcopy(data.raw.recipe["iron-chest"])
hudCombinatorRecipe.name = "hud-combinator"
hudCombinatorRecipe.ingredients = {{"electronic-circuit", 2}, {"copper-cable", 5}}
hudCombinatorRecipe.result = "hud-combinator"

data:extend {hudCombinatorEntity, hudCombinatorItem, hudCombinatorRecipe}

--

--
-- SIGNALS
--

local hud_comparator_signal_subgroup = {
	type = "item-subgroup",
	name = "circuit-hid-signals",
	group = "signals",
	order = "f"
}

local hide_hud_comparator_signal = {
	type = "virtual-signal",
	name = "signal-hide-hud-comparator",
	icon = "__CircuitHUD-V2__/graphics/icon/signal/signal-hide-hud-comparator.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "circuit-hid-signals",
	order = "d[hud-comparator]-[hide]"
}

data:extend {hud_comparator_signal_subgroup, hide_hud_comparator_signal}
