NetworkUtil = Class{}

function NetworkUtil:init()

end


function NetworkUtil:parseLobbyData(data, command)
    if command == "addNewLobby" or command == "initLobbies" or command == "initLobby" or command == 'addNewPlayer' then
        local lobbyId, playersTable, lobbyInfoTable, newPlayer = NetworkUtil:parseLobbyInfo2(data)
        return lobbyId, playersTable, lobbyInfoTable, newPlayer
    elseif command == "addLobbyStates" or command == "initLobbyStates" or command == "initLobbyState" or command == "updateLobbyState" then
        local statesTable = NetworkUtil:parseLobbyInfo(data)
        return tonumber(lobbyId), statesTable
    end
end

function NetworkUtil:parseLobbyId(string)
    print(string)
    local id_pattern = "lobby:(%d+)"
    return string:match(id_pattern)
end

function NetworkUtil:parsePlayerInfo(string)
    print ("this is string in paseplayer"..string)
    local players = {}
    local player_pattern1 = "{%s*(%w+)%s*,%s*(%d+)%s*}" --first pattern to just for words
    local player_pattern2 = "{%s*([^,]+)%s*,%s*(%d+)%s*}" --second pattern to account for colons
    for address, port in string:gmatch(player_pattern2) do
        print("parseplayer address:"..address)
        print("parseplayer port:"..port)
        table.insert(players, {peerAddress = address, peerPort = tonumber(port)})
    end
    return players
end

function NetworkUtil:parseLobbyInfo(string)
    print ("this is string in paseLobby"..string)
    local lobbyState = {}
    local player_pattern2 = "{([^,]+),(%d+),(%d+)}" --second pattern to account for colons
    for state, playerCount, limit  in string:gmatch(player_pattern2) do
        print("parse lobby state:"..state)
        print("parse lobby player count:"..playerCount)
        print("parse lobby player limit:"..limit)
        table.insert(lobbyState, {state = state, playerCount = tonumber(playerCount), limit = tonumber(limit)})
    end
    return lobbyState
end

function NetworkUtil:parseLobbyInfo2(string)
    local sections = {}
    for section in string.gmatch(string, "([^;]+)") do
        table.insert(sections, section)
    end
    local players = {}
    local newPlayer = {}
    local lobbyInfo = {}
    local lobbyId = nil

    for _, section in ipairs(sections) do
        local key, value = string.match(section, "(%w+)=(.+)")
        if key == "players" then
            -- Split player data using semicolons
            for player in string.gmatch(value, "([^;]+)") do
                local playerId, playerAddress, playerPort, lastUpdatedAt = string.match(player, "(%d+),([^,]+),(%d+),(%d+)")
                table.insert(players, {
                    playerId = tonumber(playerId),
                    playerAddress = playerAddress,
                    playerPort = tonumber(playerPort),
                    lastUpdatedAt = tonumber(lastUpdatedAt),
                })
            end
        elseif key == "lobbyInfo" then
            local lobbyState, playerCount, playerLimit, createdAt, lastUpdatedAt = string.match(value, "([^,]+),(%d+),(%d+),(%d+),(%d+)")
            lobbyInfo = {
                lobbyState = lobbyState,
                playerCount = tonumber(playerCount),
                playerLimit = tonumber(playerLimit),
                createdAt = tonumber(createdAt),
                lastUpdatedAt = tonumber(lastUpdatedAt),
            }
        elseif key == "newPlayer" then
            local playerId, playerAddress, playerPort, lastUpdatedAt = string.match(value, "(%d+),([^,]+),(%d+),(%d+)")
            newPlayer = {
                playerId = tonumber(playerId),
                playerAddress = playerAddress,
                playerPort = tonumber(playerPort),
                lastUpdatedAt = tonumber(lastUpdatedAt),
            }
        elseif key == "lobbyId" then
            lobbyId = tonumber(value)
        end
    end
        return lobbyId, players, lobbyInfo, newPlayer


end