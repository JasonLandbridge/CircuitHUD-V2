local default_gui = data.raw["gui-style"].default
default_gui["bras-scrollpane"] = {
  type = "frame_style",
  --minimal_width = 70,
  --maximal_height = 70,
  top_padding = 0,
  bottom_padding = 0
}

default_gui["green-signal"] = {
  type = "button_style",
  --minimal_width = 70,
  --maximal_height = 70,
  tint = {
    135,
    216,
    139,
    128
  },
  parent = "green_circuit_network_content_slot"
}

--

local hudCombinatorEntity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
hudCombinatorEntity.name = "hud-combinator"
hudCombinatorEntity.sprites = {
  east = {
    layers = {
      {
        filename = "__CircuitHUD__/graphics/entity/combinator/hud-combinator.png",
        frame_count = 1,
        height = 52,
        hr_version = {
          filename = "__CircuitHUD__/graphics/entity/combinator/hr-hud-combinator.png",
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
        filename = "__CircuitHUD__/graphics/entity/combinator/hud-combinator-shadow.png",
        frame_count = 1,
        height = 34,
        hr_version = {
          draw_as_shadow = true,
          filename = "__CircuitHUD__/graphics/entity/combinator/hr-hud-combinator-shadow.png",
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
        filename = "__CircuitHUD__/graphics/entity/combinator/hud-combinator.png",
        frame_count = 1,
        height = 52,
        hr_version = {
          filename = "__CircuitHUD__/graphics/entity/combinator/hr-hud-combinator.png",
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
        filename = "__CircuitHUD__/graphics/entity/combinator/hud-combinator-shadow.png",
        frame_count = 1,
        height = 34,
        hr_version = {
          draw_as_shadow = true,
          filename = "__CircuitHUD__/graphics/entity/combinator/hr-hud-combinator-shadow.png",
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
        filename = "__CircuitHUD__/graphics/entity/combinator/hud-combinator.png",
        frame_count = 1,
        height = 52,
        hr_version = {
          filename = "__CircuitHUD__/graphics/entity/combinator/hr-hud-combinator.png",
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
        filename = "__CircuitHUD__/graphics/entity/combinator/hud-combinator-shadow.png",
        frame_count = 1,
        height = 34,
        hr_version = {
          draw_as_shadow = true,
          filename = "__CircuitHUD__/graphics/entity/combinator/hr-hud-combinator-shadow.png",
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
        filename = "__CircuitHUD__/graphics/entity/combinator/hud-combinator.png",
        frame_count = 1,
        height = 52,
        hr_version = {
          filename = "__CircuitHUD__/graphics/entity/combinator/hr-hud-combinator.png",
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
        filename = "__CircuitHUD__/graphics/entity/combinator/hud-combinator-shadow.png",
        frame_count = 1,
        height = 34,
        hr_version = {
          draw_as_shadow = true,
          filename = "__CircuitHUD__/graphics/entity/combinator/hr-hud-combinator-shadow.png",
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
hudCombinatorEntity.activity_led_light = nil

local hudCombinatorItem = table.deepcopy(data.raw.item["constant-combinator"])
hudCombinatorItem.name = "hud-combinator"
hudCombinatorItem.place_result = "hud-combinator"
hudCombinatorItem.icons = {
  {
    icon = hudCombinatorItem.icon,
    tint = {r = 0.5, g = 0.5, a = 0.3}
  }
}

local hudCombinatorRecipe = table.deepcopy(data.raw.recipe["iron-chest"])
hudCombinatorRecipe.enabled = true
hudCombinatorRecipe.name = "hud-combinator"
hudCombinatorRecipe.ingredients = {{"iron-ore", 1}}
hudCombinatorRecipe.result = "hud-combinator"

data:extend {hudCombinatorEntity, hudCombinatorItem, hudCombinatorRecipe}
