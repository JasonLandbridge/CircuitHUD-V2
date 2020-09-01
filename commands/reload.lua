local function reload()
  game.reload_mods()
end

commands.add_command("reload", "game.reload_mods()", reload)
