--
-- SIGNALS
--
data:extend {
	{
		type = "item-subgroup",
		name = "circuit-hid-signals",
		group = "signals",
		order = "f"
	},
	{
		type = "virtual-signal",
		name = "signal-hide-hud-comparator",
		icon = "__CircuitHUD-V2__/graphics/icon/signal/signal-hide-hud-comparator.png",
		icon_size = 64,
		subgroup = "circuit-hid-signals",
		order = "d[hud-comparator]-[hide]"
	}
}
