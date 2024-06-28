NetworkUtil = Class{}

function NetworkUtil:init()

end


function NetworkUtil:parseLobbyData(data, command)
    local lobbyId = NetworkUtil:parseLobbyId(data)
    if command == "addNewLobby" or command == "initLobbies" or command == "initLobby" or command == 'addNewPlayer' then
        local playersTable = NetworkUtil:parsePlayerInfo(data)
        return tonumber(lobbyId), playersTable
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
    local players = {}
    local id_pattern = "lobby:(%d+)"
    local lobbyId =  string:match(id_pattern)

    local lobby_info_pattern = "Info:{%s*(%w+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*}"
    local lobbyInfo =  string:match(lobby_info_pattern)

    local lobby_player_pattern = "Player:{%s*(%d+)%s*,%s*([^,]+)%s*,%s*(%d+)%s*,%s*(%d+)%s*}"
    local lobbyInfo =  string:match(lobby_player_pattern)
end