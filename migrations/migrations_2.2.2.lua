-- every player needs its own object, otherwise multi player will not work

local util = require('util')

local players = {}
for player_index, data in pairs(storage.players) do
    players[player_index] = util.copy(data)
end

storage.players = players
