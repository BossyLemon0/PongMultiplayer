
Test = Class{}


-- local udp = socket.udp()

function Test:Init()
    print('hello')
    self.NetPeers = {}
    self.NetLeersOrder = {}
    self.NetLobbies = {}
    self.NetLobbyOrder = {}



    self.ClientPeers = {}
    self.ClientPeersOrder = {}
    self.ClientLobbies = {}
    self.LobbyOrder = {}

    local lobbyId = 42
    local playerId = 88
    local peerPort = 3023
    local peerAddress = "::0"
    local secondPlayerId = 34


    Test:CreateLobby(peerPort, peerAddress, lobbyId, playerId)

    Test:AddPlayer(1302, "1:00:23", lobbyId, secondPlayerId)
    print("----------------------Testing--------------------------")
    Test:AddPlayerInfo(lobbyId, playerId)
    print("----------------------Testing--------------------------")
    -- Test:DeletePlayer(lobbyId, secondPlayerId)
end



function Test:CreateLobby(peerPort, peerAddress, lobbyId, playerId)
    self.NetLobbies[lobbyId] = {
        gameState = {
            players = {},
            entities = {
                balls = {},
                bricks = {}
            },
        },
        state = 'waiting',
        playerCount = 0,
        playerLimit = 4,
        createdAt = os.time(),
        updatedAt = os.time()
    }
    if self.NetLobbies[lobbyId].playerCount ~= self.NetLobbies[lobbyId].limit then
        self.NetLobbies[lobbyId].playerCount = self.NetLobbies[lobbyId].playerCount + 1
        self.NetLobbies[lobbyId].updatedAt = os.time()
        --might need to change from creating
        self.NetLobbies[lobbyId].gameState.players[playerId] = {
            playerId = playerId,
            peerAddress = peerAddress,
            peerPort = peerPort,
            lastUpdate = os.time(),
        }
        table.insert(self.NetLobbyOrder, lobbyId) --indexing
        local lobbyDatagram = 'lobby:' .. tostring(lobbyId) .. " {".. self.NetLobbies [lobbyId].state ..','
        .. tostring(self.NetLobbies[lobbyId].playerCount) ..','
        .. tostring(self.NetLobbies[lobbyId].playerLimit)..','
        .. tostring(self.NetLobbies[lobbyId].createdAt)..','
        .. tostring(self.NetLobbies[lobbyId].updatedAt)
        .."}"..
        " {".. tostring(self.NetLobbies[lobbyId].gameState.players[playerId].playerId)..','
        .. self.NetLobbies[lobbyId].gameState.players[playerId].peerAddress ..','
        .. tostring(self.NetLobbies[lobbyId].gameState.players[playerId].peerPort)
        .."}"

        print(lobbyDatagram)
    end
end


function Test:AddPlayer(peerPort, peerAddress, lobbyId, playerId)

    local playerListString = ''

    if self.NetLobbies[lobbyId].playerCount ~= self.NetLobbies[lobbyId].limit then
        self.NetLobbies[lobbyId].playerCount = self.NetLobbies[lobbyId].playerCount + 1
        self.NetLobbies[lobbyId].updatedAt = os.time()
        --might need to change from creating
        self.NetLobbies[lobbyId].gameState.players[playerId] = {
            playerId = playerId,
            peerAddress = peerAddress,
            peerPort = peerPort,
            lastUpdate = os.time(),
        }
        for x, player in pairs(self.NetLobbies[lobbyId].gameState.players) do
            print('playerId: '..player.playerId)
        end
    end
end

function Test:AddPlayerInfo(lobbyId, playerId)

    local playerListString = ''

        self.NetLobbies[lobbyId].updatedAt = os.time()
        self.NetLobbies[lobbyId].gameState.players[playerId].position = {x = 12, y = 234}
        self.NetLobbies[lobbyId].gameState.players[playerId].lastUpdate = os.time()

        for x, player in pairs(self.NetLobbies[lobbyId].gameState.players) do
            if player.position then
                print('playerx: '..player.position.x)
                print('lastUpdate: '..player.lastUpdate)
            end
        end

end


function Test:DeletePlayer(lobbyId, playerId)
    self.NetLobbies[lobbyId].gameState.players[playerId] = nil
    for x, player in pairs(self.NetLobbies[lobbyId].gameState.players) do
        print('playerId: '..player.playerId)
    end
end




