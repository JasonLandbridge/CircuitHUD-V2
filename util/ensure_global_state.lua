function ensure_global_state()
  if (not global.hud_combinators) then
    global.hud_combinators = {}
  end

  if (not global.textbox_hud_entity_map) then
    global.textbox_hud_entity_map = {}
  end
end
