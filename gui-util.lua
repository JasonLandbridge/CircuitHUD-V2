local Event = require("__stdlib__/stdlib/event/event")

function create_frame(parent, title, close_name)
  -- find a unique event name
  local ui_name = "frame_" .. Event.generate_event_name("frame-event")
  local close_button_name = ui_name .. "_button"

  -- add the frame
  local frame = parent.add {type = "frame", name = ui_name, direction = "vertical"}

  -- create a title_flow
  local title_flow = frame.add {type = "flow"}

  -- add the title label
  local title = title_flow.add {type = "label", caption = title, style = "frame_title"}
  title.drag_target = frame

  -- add a pusher (so the close button becomes right-aligned)
  local pusher = title_flow.add {type = "empty-widget", style = "draggable_space_header"}
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame

  -- add a close button
  title_flow.add {
    type = "sprite-button",
    style = "frame_action_button",
    sprite = "utility/close_white",
    name = close_button_name
  }

  local on_gui_click = nil
  local on_gui_closed = nil

  local function close()
    frame.destroy()
    Event.remove(defines.events.on_gui_click, on_gui_click)
    Event.remove(defines.events.on_gui_closed, on_gui_closed)
  end

  on_gui_click = function(event)
    if (event.element and event.element.name == close_button_name) then
      close()
    end
  end

  on_gui_close = function(event)
    if (event.element and event.element.name == ui_name) then
      close()
    end
  end

  Event.register(defines.events.on_gui_click, on_gui_click)
  Event.register(defines.events.on_gui_closed, on_gui_close)

  -- return the frame and ui_name for further work
  return frame, ui_name
end
