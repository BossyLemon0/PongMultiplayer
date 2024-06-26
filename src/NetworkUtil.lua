NetworkUtil = Class{}

function NetworkUtil:init()

end


function NetworkUtil:parseLobbyData(data, command)
    local lobbyId = NetworkUtil:parseLobbyId(data)
    if command == "addNewLobby" or command == "initLobbies" then
        local playersTable = NetworkUtil:parsePlayerInfo(data)
        return tonumber(lobbyId), playersTable
    elseif command == "addLobbyState" or command == "initLobbyStates" then
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
    print ("this is string in paseplayer"..string)
    local lobbyState = {}
    local player_pattern2 = "{([^,]+),(%d+),(%d+)}" --second pattern to account for colons
    for state, playerCount, limit  in string:gmatch(player_pattern2) do
        print("parse lobby state:"..state)
        print("parse lobby player count:"..playerCount)
        print("parse lobby player count:"..limit)
        table.insert(lobbyState, {state = state, playerCount = tonumber(playerCount), limit = tonumber(limit)})
    end
    return lobbyState
end