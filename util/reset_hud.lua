function reset_hud()
  -- todo: remember frame positioning
  -- force re-initialization every game load
  if (global["last_frame"]) then
    for _, frame in pairs(global["last_frame"]) do
      frame.destroy()
    end
    global["last_frame"] = {}
  end
end
