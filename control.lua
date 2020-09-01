require "mod-gui"
require "gui-util"
require "commands/reload"
local Event = require("__stdlib__/stdlib/event/event")

--

local function has_network_signals(entity)
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

local SIGNAL_TYPE_MAP = {
   ["item"] = "item",
   ["virtual"] = "virtual-signal",
   ["fluid"] = "fluid"
}

local function render_network(parent, network, signal_style)
   -- skip this one, if the network has no signals
   if network == nil or network.signals == nil then
      return
   end

   local table = parent.add {type = "table", column_count = 4}

   for i, signal in ipairs(network.signals) do
      table.add {
         type = "sprite-button",
         sprite = SIGNAL_TYPE_MAP[signal.signal.type] .. "/" .. signal.signal.name,
         number = signal.count,
         style = signal_style
      }
   end
end

local function render_combinator(parent, entity)
   local child = parent.add {type = "flow", direction = "vertical"}

   if (global.hud_entity_data[entity.unit_number]) then
      child.add {
         type = "label",
         caption = global.hud_entity_data[entity.unit_number]["name"],
         style = "heading_2_label"
      }
   end

   if has_network_signals(entity) then
      local red_network = entity.get_circuit_network(defines.wire_type.red)
      local green_network = entity.get_circuit_network(defines.wire_type.green)

      render_network(child, green_network, "green_circuit_network_content_slot")
      render_network(child, red_network, "red_circuit_network_content_slot")
   else
      child.add {type = "label", caption = "No signal"}
   end
end

local function render_combinators(parent, entities)
   local child = parent.add {type = "flow", direction = "vertical"}

   -- loop over every entity provided
   for i, entity in ipairs(entities) do
      if i > 1 then
         child.add {type = "empty-widget", style = "empty_widget_distance"} -- todo: correctly add some space
      end

      render_combinator(child, entity)
   end
end

local function render_surfaces(parent)
   -- loop over every surface in the game
   for i, surface in pairs(game.surfaces) do
      -- find all hud combinator
      local hud_combinators = surface.find_entities_filtered {name = "hud-combinator"}

      if not (hud_combinators == nil) then
         render_combinators(parent, hud_combinators)
      end
   end
end

Event.register(
   defines.events.on_tick,
   function()
      if (global["last_frame"] == nil) then
         global["last_frame"] = {}
      end

      if (global["inner_frame"] == nil) then
         global["inner_frame"] = {}
      end

      -- go through each player
      for i, player in pairs(game.players) do
         if global["last_frame"][player.index] == nil then
            local root_frame = player.gui.screen.add {type = "frame", direction = "vertical"}
            local title_flow = create_frame_title(root_frame, "Circuit HUD")
            local inner_frame =
               root_frame.add {
               type = "frame",
               style = "inside_shallow_frame_with_padding",
               direction = "vertical"
            }

            root_frame.force_auto_center()

            global["last_frame"][player.index] = root_frame
            global["inner_frame"][player.index] = inner_frame
         else
            if global.hud_entity_data and next(global.hud_entity_data) then
               global["last_frame"][player.index].visible = true
            else
               global["last_frame"][player.index].visible = false
            end
         end
      end
   end
)

Event.register(
   defines.events.on_tick,
   function()
      -- go through each player
      for i, player in pairs(game.players) do
         local root = global["inner_frame"][player.index]
         if root then
            root.clear()
            render_surfaces(root)
         end
      end
   end
)

--
--
--

local function ensure_global_state()
   if (not global.hud_entity_data) then
      global.hud_entity_data = {}
   end

   if (not global.textbox_hud_entity_map) then
      global.textbox_hud_entity_map = {}
   end
end

--
-- UI HANDLING
--

Event.register(
   defines.events.on_gui_opened,
   function(event)
      if (not (event.entity == nil)) and (event.entity.name == "hud-combinator") then
         local player = game.players[event.player_index]

         -- cleanup
         -- if player.gui.screen.test then
         --    player.gui.screen.test.destroy()
         -- end

         -- create the new gui
         local root_element = create_frame(player.gui.screen, "HUD Comparator")
         player.opened = root_element
         player.opened.force_auto_center()

         local inner_frame = root_element.add {type = "frame", style = "inside_shallow_frame_with_padding"}
         local vertical_flow = inner_frame.add {type = "flow", direction = "vertical"}

         local preview_frame = vertical_flow.add {type = "frame", style = "deep_frame_in_shallow_frame"}
         local preview = preview_frame.add {type = "entity-preview"}
         preview.style.width = 100
         preview.style.height = 100
         preview.visible = true
         preview.entity = event.entity

         local space = vertical_flow.add {type = "empty-widget"}

         local frame = vertical_flow.add {type = "frame", style = "invisible_frame_with_title_for_inventory"}
         local label = frame.add({type = "label", caption = "Name", style = "heading_2_label"})

         local textbox = vertical_flow.add {type = "textfield", style = "production_gui_search_textfield"}
         ensure_global_state()
         if (global.hud_entity_data[event.entity.unit_number] == nil) then
            textbox.text = ""
         else
            textbox.text = global.hud_entity_data[event.entity.unit_number]["name"]
         end

         textbox.select(0, 0)

         -- save the reference
         global.textbox_hud_entity_map[textbox.index] = event.entity
      end
   end
)

Event.register(
   defines.events.on_gui_text_changed,
   function(event)
      local entity = global.textbox_hud_entity_map[event.element.index]
      if (global.textbox_hud_entity_map[event.element.index]) then
         -- save the reference
         global.hud_entity_data[entity.unit_number] = {name = event.text}
      end
   end
)

local function register_entity(entity)
   ensure_global_state()

   global.hud_entity_data[entity.unit_number] = {
      name = "HUD Comparator #" .. entity.unit_number
   }
end

local function unregister_entity(entity)
   ensure_global_state()

   global.hud_entity_data[entity.unit_number] = nil
   global.textbox_hud_entity_map[entity.unit_number] = nil
end

Event.register(
   defines.events.on_built_entity,
   function(event)
      if event.created_entity.name == "hud-combinator" then
         register_entity(event.created_entity)
      end
   end
)

Event.register(
   defines.events.on_robot_built_entity,
   function(event)
      if event.created_entity.name == "hud-combinator" then
         register_entity(event.created_entity)
      end
   end
)

Event.register(
   defines.events.on_player_mined_entity,
   function(event)
      if event.entity.name == "hud-combinator" then
         unregister_entity(event.entity)
      end
   end
)

Event.register(
   defines.events.on_robot_mined_entity,
   function(event)
      if event.entity.name == "hud-combinator" then
         unregister_entity(event.entity)
      end
   end
)
