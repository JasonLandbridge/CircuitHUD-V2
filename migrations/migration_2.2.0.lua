local player_settings = require("globals.player-settings")
local const = require("lib.constants")

local defaults = player_settings.default_player_settings()
for player_index in pairs(storage.players) do
   if not player_settings.get_map_zoom_factor_setting(player_index) then
      player_settings.set_map_zoom_factor_setting(player_index, defaults[const.SETTINGS.map_zoom_factor])
   end
end
