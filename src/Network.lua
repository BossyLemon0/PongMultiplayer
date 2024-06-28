--[[

    Breakout multiplayer refactor

    -- Network class --

    Author: Omar Ramirez
    omardramirez2002@gmail.com

    Represents the network module to handle client requests
]]

Network = Class{}

local host = "*" -- listen for all addresses
local port = 12345  -- Allocate a random port for this instance

local data, msg_or_ip, port_or_nil
local entity, cmd, params
-- local udp = socket.udp()

function Network:Init()
    self.t = 0
    self.udp = socket.udp()
    self.udp:setsockname(host, port)
    -- print(self.udp:getsockname())
    self.udp:settimeout(0)
    self.peers = {}
    self.peersOrder = {}
    self.lobbies = {}
    self.lobbyStates = {}
    self.lobbyOrder = {}
end

-- peer code
-- SOLID
function Network:AddPeers(peerAddress, peerPort)
    print('added new user: '.. peerAddress.. ":" .. peerPort)
    self.peers[peerAddress .. ":" .. peerPort] = {peerAddress = peerAddress, peerPort = peerPort}
    table.insert(self.peersOrder, peerAddress .. ":" .. peerPort)
    print('peers'..self.peers[peerAddress .. ":" .. peerPort].peerAddress)
    Network:ShowPeers()
end
-- SOLID
function Network:ShowPeers()
    for k, peer in pairs(self.peers) do
        print(peer.peerAddress)
    end
end

-- lobby code
-- SOLID REDACTED
function Network:AddLobby(peerAddress, peerPort, lobbyId)
    self.lobbies[lobbyId] = {}
    table.insert(self.lobbies[lobbyId], {peerAddress = peerAddress, peerPort = peerPort})
    self.lobbyStates[lobbyId] = {state = "waiting", playerCount = 1, limit = 4}
    table.insert(self.lobbyOrder, lobbyId)
    print('lobbies: '..self.lobbies[lobbyId][1].peerPort)
    Network:ShowLobbies()
    local lobbyDatagram = 'lobby:' .. tostring(lobbyId) .. " {".. peerAddress ..','.. tostring(peerPort) .."}"
    local lobbyStateDatagram = 'lobby:' .. tostring(lobbyId) ..
    " {".. self.lobbyStates[lobbyId].state ..','
    .. self.lobbyStates[lobbyId].playerCount..","
    ..self.lobbyStates[lobbyId].limit.."}"
    Network:updateLobbies("addNewLobby", lobbyDatagram)
    Network:updateLobbies("addLobbyStates", lobbyStateDatagram)
    -- Maybe add code to push lobby information to all players on creation
end
-- IN PROGRESS
function Network:AddLobby2(peerAddress, peerPort, lobbyId, playerId)
    --serialize id for players
    --make player limit a constant
    self.lobbies[lobbyId] = {
        gameState = {
            players = {},
            entities = {
                balls = {},
            },
            world = {
                bricks = {},
            }
        },
        state = 'waiting',
        playerCount = 0,
        playerLimit = 4,
        createdAt = os.time(),
        updatedAt = os.time()
    }
    if self.lobbies[lobbyId].playerCount ~= self.lobbies[lobbyId].limit then
        self.lobbies[lobbyId].playerCount = self.lobbies[lobbyId].playerCount + 1
        self.lobbies[lobbyId].updatedAt = os.time()
        self.lobbies[lobbyId].gameState.players[playerId] = {
            playerId = playerId,
            peerAddress = peerAddress,
            peerPort = peerPort,
            lastUpdate = os.time(),
        }
        table.insert(self.lobbyOrder, lobbyId) --indexing
        -- Network:ShowLobbies2()
        local lobbyDatagram = 'lobby:' .. tostring(lobbyId) .. " {".. self.lobbies[lobbyId].state ..','
        .. tostring(self.lobbies[lobbyId].playerCount) ..','
        .. tostring(self.lobbies[lobbyId].playerLimit)..','
        .. tostring(self.lobbies[lobbyId].createdAt)..','
        .. tostring(self.lobbies[lobbyId].updatedAt)..
        "} "
        .."{ "
        .. tostring(self.lobbies[lobbyId].gameState.players[playerId].playerId) ..','
        .. tostring(self.lobbies[lobbyId].gameState.players[playerId].peerAddress)..','
        .. tostring(self.lobbies[lobbyId].gameState.players[playerId].peerPort)..','
        .. tostring(self.lobbies[lobbyId].gameState.players[playerId].lastUpdate)..','
        .."}"
        Network:updateLobbies2("addNewLobby", lobbyDatagram)
    else
        Network:updateLobbies2("lobbyFull", "ERROR:full")
    end

    -- Maybe add code to push lobby information to all players on creation
end
-- SOLID REDACTED
function Network:updateLobbies(func, datagram) 
    for i, players in pairs(self.peers) do
        print("datagram to add new lobby sent: "..datagram)
        print('New lobby address type')
        print(type(players.peerAddress))
        print("at address: "..players.peerAddress)
        print('New lobby ip type')
        print(type(players.peerPort))
        print("at port: "..players.peerPort)
        -- send the last datagram
        self.udp:sendto(string.format("%s %s", func, datagram), players.peerAddress, tonumber(players.peerPort))
    end
end
-- IN PROGRESS
function Network:updateLobbies2(func, datagram)
    for i, players in pairs(self.peers) do
        self.udp:sendto(string.format("%s %s", func, datagram), players.peerAddress, tonumber(players.peerPort))
    end
end
-- SOLID REDACTED
function Network:DeleteLobby(lobbyId)
    -- print("lobby being deleted: "..lobbyId)
    self.lobbies[lobbyId] = nil
    self.lobbyStates[lobbyId] = nil
    for i, id in pairs(self.lobbyOrder) do
        if id == lobbyId then
            table.remove(self.lobbyOrder, i)
        end
    end
    Network:ShowLobbies()
    Network:updateLobbies("deleteLobby",tostring(lobbyId))

end
-- IN PROGRESS
function Network:DeleteLobby2(lobbyId)
    self.lobbies[lobbyId] = nil
    for i, id in pairs(self.lobbyOrder) do
        if id == lobbyId then
            table.remove(self.lobbyOrder, i)
        end
    end
    Network:updateLobbies2("deleteLobby",tostring(lobbyId))
end
-- IN PROGRESS
function Network:DeletePlayer(lobbyId, playerId)
    self.Lobbies[lobbyId].gameState.players[playerId] = nil
    for x, player in pairs(self.NetLobbies[lobbyId].gameState.players) do
        print('Remaing player Id: '..player.playerId)
    end
    self.Lobbies[lobbyId].playerCount = self.Lobbies[lobbyId].playerCount - 1
    self.Lobbies[lobbyId].updatedAt = os.time()
    --update all in lobbies menu about playerCount
    --update all players in the lobby about: player and count
end

-- SOLID REDACTED
function Network:updatePlayersInLobby(playerfunc, playerdatagram, lobbystatefunc, lobbystatedatagram, lobbyId)
    for i, players in pairs(self.lobbies[lobbyId]) do
        -- print("datagram to add new lobby sent: "..datagram)
        print(lobbystatedatagram)
        print(playerdatagram)
        -- send the current state and players
        self.udp:sendto(string.format("%s %s", playerfunc, playerdatagram), players.peerAddress, tonumber(players.peerPort))
        self.udp:sendto(string.format("%s %s", lobbystatefunc, lobbystatedatagram), players.peerAddress, tonumber(players.peerPort))
    end
end
-----------------------------------------HEREE---------------------------------------------------
-- IN PROGRESS
function Network:updatePlayersInLobby2(playerfunc, playerdatagram,lobbyId)
    for i, player in pairs(self.lobbies[lobbyId].gameState.players) do
        self.udp:sendto(string.format("%s %s", playerfunc, playerdatagram), player.peerAddress, tonumber(player.peerPort))
    end
end
-- SOLID REDACTED
function Network:AddPlayerToLobbyByID(lobbyId, peerAddress, peerPort)
    table.insert(self.lobbies[lobbyId], {peerAddress = peerAddress, peerPort = peerPort})
    self.lobbyStates[lobbyId].playerCount = self.lobbyStates[lobbyId].playerCount + 1
    local lobbyDatagram = Network:createDatagram('getLobbyAt',lobbyId)
    local lobbyStateDatagram = Network:createDatagram('getLobbyStateAt',lobbyId)

    print('about to update')
    Network:updatePlayersInLobby('addNewPlayer', lobbyDatagram, "updateLobbyState", lobbyStateDatagram, lobbyId)
    
end
-- IN PROGRESS
function Network:AddPlayerToLobbyByID2(lobbyId, playerId, peerAddress, peerPort)
    self.lobbies[lobbyId].gamestate.players[playerId] = {
        playerId = playerId,
        peerAddress = peerAddress,
        peerPort = peerPort,
        lastUpdate = os.time()
    }
    self.lobbies[lobbyId].playerCount = self.lobbies[lobbyId].playerCount + 1
    self.lobbies[lobbyId].lastUpdate = os.time()
    --added it as a table just to know what exactly we are getting through payload.WTV
    local lobbyDatagram = Network:createDatagram2('getLobbyAt',{lobbyId = tonumber(lobbyId)})
    Network:updatePlayersInLobby2('addNewPlayer', lobbyDatagram, lobbyId)
    
end
-- SOLID REDACTED
function Network:SendLobbiesInOrder(userIp, userPort)
    local lobbyDatagramTable = Network:createDatagram('getAllLobbies')
    local lobbyStateDatagramTable = Network:createDatagram('getAllLobbyStates')
    print('ip type')
    print(type(userIp))
    print(userIp)
    print('port type')
    print(type(userPort))
    print(userPort)

    for i, lobdatagram in pairs(lobbyDatagramTable) do
        print("datagram sent: "..lobdatagram)
        self.udp:sendto(string.format("%s %s", "initLobbies", lobdatagram), userIp, userPort)
    end
    for i, lobstatedatagram in pairs(lobbyStateDatagramTable) do
        print("datagram sent: "..lobstatedatagram)
        self.udp:sendto(string.format("%s %s", "initLobbyStates", lobstatedatagram), userIp, userPort)
    end
end
-- IN PROGRESS
function Network:SendLobbiesInOrder2(userIp, userPort)
    local lobbiesDatagramTable = Network:createDatagram2('getAllLobbies')
    for i, lobby in pairs(lobbiesDatagramTable) do
        self.udp:sendto(string.format("%s %s", "initLobbies", lobbiesDatagramTable), userIp, userPort)
    end
end
-- SOLID REDACTED
function Network:SendLobbyById(lobbyId, userIp, userPort)
    local lobbyDatagram = Network:createDatagram('getLobbyAt',lobbyId)
    local lobbyStateDatagram = Network:createDatagram('getLobbyStateAt',lobbyId)
    print('ip type')
    print(type(userIp))
    print(userIp)
    print('port type')
    print(type(userPort))
    print(userPort)

        print("datagram sent for 1 ID:"..lobbyDatagram)
        self.udp:sendto(string.format("%s %s", "initLobby", lobbyDatagram), userIp, userPort)
        print("datagram sent for 1 ID: "..lobbyStateDatagram)
        self.udp:sendto(string.format("%s %s", "initLobbyState", lobbyStateDatagram), userIp, userPort)
end
-- IN PROGRESS
function Network:SendLobbyById2(lobbyId, userIp, userPort)
    local lobbyDatagram = Network:createDatagram2('getLobbyAt',{lobbyId = tonumber(lobbyId)})
    self.udp:sendto(string.format("%s %s", "initLobby", lobbyDatagram), userIp, userPort)
end

-- SOLID REDACTED
function Network:createDatagram(query, payload)


    if query == "getAllLobbies" then
        local datagrams = {}
        for orderId, lobbyid in pairs(self.lobbyOrder) do

            local lobbystring = ''
            local lobby = self.lobbies[lobbyid]
            lobbystring = lobbystring .. "lobby:" .. tostring(lobbyid)
            print(lobbystring)
    
            if lobby[1] then
                for _, player in pairs(lobby) do
                    print("this is player:"..player.peerAddress)
                    lobbystring = lobbystring ..
                    " {".. player.peerAddress .. ','
                    .. tostring(player.peerPort)..
                    "}"
                end
            end
    
            table.insert(datagrams, lobbystring)
            -- lobby = ''
        end
        return datagrams
    elseif query == "getAllLobbyStates" then
        local datagrams = {}
        for orderId, lobbyid in pairs(self.lobbyOrder) do
            local lobbystring = ''
            local lobbyState = self.lobbyStates[lobbyid]
            lobbystring = lobbystring .. "lobby:" .. tostring(lobbyid)
            lobbystring = lobbystring ..
            " {".. lobbyState.state.. ','
            .. tostring(lobbyState.playerCount)..','
            .. tostring(lobbyState.limit)..
            "}"
    
            table.insert(datagrams, lobbystring)
            -- lobby = ''
        end
        return datagrams
    elseif query == "getLobbyAt" then
        local lobbyString =  ''

        print(self.lobbies[payload])
        print(self.lobbies[tonumber(payload)])
        local lobby = self.lobbies[tonumber(payload)]
        lobbyString = lobbyString .. "lobby:" .. tostring(payload)

        if lobby[1] then
            for i, player in pairs(lobby) do
                lobbyString = lobbyString ..
                " {".. player.peerAddress.. ','
                .. tostring(player.peerPort)..
                "}"
            end
        else
        end
        return lobbyString
    elseif query == "getLobbyStateAt" then
        local lobbyId = tonumber(payload)
        local lobbyStateString = ''
        lobbyStateString = lobbyStateString .. "lobby:" .. payload
        lobbyStateString = lobbyStateString ..
        " {"..self.lobbyStates[lobbyId].state.. ','
        .. tostring(self.lobbyStates[lobbyId].playerCount)..','
        .. tostring(self.lobbyStates[lobbyId].limit)..
        "}"

        return lobbyStateString
    end

end
-- IN PROGESS
function Network:createDatagram2(query, payload)

    if query == "getAllLobbies" then
        local datagrams = {}
        for orderId, lobbyid in pairs(self.lobbyOrder) do
            local lobbystring = ''
            local lobby = self.lobbies[lobbyid]
            lobbystring = lobbystring .. "lobby:" .. tostring(lobbyid) .. ' '
            lobbystring = lobbystring .. "Info: " .."{"
            .. tostring(lobby.state) ..','
            .. tostring(lobby.playerCount) ..','
            .. tostring(lobby.playerLimit)..','
            .. tostring(lobby.createdAt)..','
            .. tostring(lobby.updatedAt)
            .."}"
            table.insert(datagrams, lobbystring)
        end
        return datagrams
    elseif query == "getLobbyAt" then
        local lobbyString =  ''
        local lobby = self.lobbies[payload.lobbyId]
        lobbyString = lobbyString .. "lobbyId=" .. tostring(payload.lobbyId)..";"
        lobbyString = lobbyString .. "info="
        .. tostring(lobby.state) ..','
        .. tostring(lobby.playerCount) ..','
        .. tostring(lobby.playerLimit)..','
        .. tostring(lobby.createdAt)..','
        .. tostring(lobby.updatedAt)
        ..";"
        lobbyString = lobbyString .. "players="
        for i, player in pairs(lobby.gameState.players) do
            lobbyString = lobbyString
            ..player.playerId ..","
            .. player.peerAddress ..","
            .. player.peerPort ..","
            .. player.lastUpdate
            .. "} "
        end

        return lobbyString
    elseif query == "getGameStateAt" then
        local lobbyString =  ''
        local lobby = self.lobbies[payload]
        lobbyString = lobbyString .. "Players: " .."{"
        for i, player in pairs(lobby.gameState.players) do
            lobbyString = lobbyString
            .. player.position.x ..","
            .. player.position.y ..","
            .. player.health ..","
            .. player.score ..","
            .. player.peerPort ..","
            .. player.peerAddress ..","
            .. player.playerId ..","
            .. player.lastUpdate
        end
        lobbyString = lobbyString .. "Balls: " .."{"
        for i, ball in pairs(lobby.gameState.entities.balls) do
            lobbyString = lobbyString
            .. ball.position.x ..","
            .. ball.position.y ..","
            .. ball.lastHit ..","
            .. ball.lastUpdate
        end
        lobbyString = lobbyString .. "Bricks: " .."{"
        for i, brick in pairs(lobby.gameState.world.bricks) do
            lobbyString = lobbyString
            .. brick.position.x ..","
            .. brick.position.y ..","
            .. brick.lastHit ..","
            .. brick.lastHit ..","
            .. brick.lastUpdate
        end
        lobbyString = lobbyString .. "}"

        return lobbyString
    elseif query == "getPlayersAt" then
        local lobbyString =  ''
        local lobby = self.lobbies[payload]
        lobbyString = lobbyString .. "Players: " .."{"
        for i, player in pairs(lobby.gameState.players) do
            lobbyString = lobbyString
            .. player.position.x ..","
            .. player.position.y ..","
            .. player.health ..","
            .. player.score ..","
            .. player.peerPort ..","
            .. player.peerAddress ..","
            .. player.playerId ..","
            .. player.lastUpdate
        end
        return lobbyString
    elseif query == "getBallsAt" then
        local lobbyString =  ''
        local lobby = self.lobbies[payload]
        lobbyString = lobbyString .. "Balls: " .."{"
        for i, ball in pairs(lobby.gameState.entities.balls) do
            lobbyString = lobbyString
            .. ball.position.x ..","
            .. ball.position.y ..","
            .. ball.lastHit ..","
            .. ball.isActive ..","
            .. ball.lastUpdate
        end
        lobbyString = lobbyString .."}"
        return lobbyString
    elseif query == "getBricksAt" then
        local lobbyString =  ''
        local lobby = self.lobbies[payload]
        lobbyString = lobbyString .. "Bricks: " .."{"
        for i, brick in pairs(lobby.gameState.world.bricks) do
            lobbyString = lobbyString
            .. brick.position.x ..","
            .. brick.position.y ..","
            .. brick.lastHit ..","
            .. brick.isActive ..","
            .. brick.lastUpdate
        end
        lobbyString = lobbyString .. "}"

        return lobbyString
    end

end
-----------------------------------------END---------------------------------------------------
-- SOLID REDACTED
function Network:ShowLobbies()
    if self.lobbies[self.lobbyOrder[1]] then
        for i,x in pairs(self.lobbyOrder) do
            print('Lobby:'..self.lobbyOrder[i].." ".."Owner Port:"..self.lobbies[self.lobbyOrder[i]][1].peerPort)
        end
    else
        print('no lobbies')
    end

end

--updating the network
function Network:update(dt)
    self.t = self.t + dt
    if (self.t > 10) then
        -- print(self.peers)
        self.t = 0
    end

    data, msg_or_ip, port_or_nil = self.udp:receivefrom()
    if data then
        print(data)
        entity, cmd, entitycmd, parms = data:match("^(%S*) (%S*) (%S*) (.*)")
        print("|"..entity.."|")
        print("|"..cmd.."|")
        print("|"..entitycmd.."|")
        print("|"..parms.."|")
        if cmd  == 'move' then
        elseif cmd  == 'at' then
        elseif cmd  == 'update' then
            if entitycmd == 'add' then
                print('newadd')
                if entity == 'peer' then
                    local peerHost, peerPort = string.match(parms, "([^%s]+) (%d+)")
                    Network:AddPeers(peerHost, peerPort)
                elseif entity == 'lobby' then
                    local peerHost, peerPort, lobbyId, playerId = string.match(parms, "([^%s]+) (%d+) (%d+) (%d+)")
                    -- Network:AddLobby(peerHost, tonumber(peerPort), tonumber(lobbyId))
                    Network:AddLobby2(peerHost, tonumber(peerPort), tonumber(lobbyId), tonumber(playerId))
                elseif entity == 'player' then -- IN PROGRESSS
                    local lobbyId, peerHost, peerPort = string.match(parms, "(%d+) ([^%s]+) (%d+)")
                    -- entity command is the lobbyId in string
                    Network:AddPlayerToLobbyByID(tonumber(lobbyId), msg_or_ip, port_or_nil)
                end
            elseif entitycmd == 'delete' then
                if entity == 'lobby' then
                    local lobbyId = string.match(parms, "(%d+)")
                    Network:DeleteLobby(lobbyId)
                end
            end
        elseif cmd  == 'request' then
            --send lobbies to user
            if entity == 'lobbies' then
                if entitycmd == 'order_by_when_created' then
                    Network:SendLobbiesInOrder(msg_or_ip, port_or_nil)
                end
            elseif entity =='lobby' then
                Network:SendLobbyById2(tonumber(entitycmd), msg_or_ip, port_or_nil) --touch lol
            end
        end
    -- elseif msg_or_ip ~= 'timeout' then
    --     error("Unknown network error: "..tostring(msg))
    end
    socket.sleep(0.01)
end
-- while running do

-- end
print "Thank you."


--iterations of structing data
-- 1. self.lobbies[lobbyid] = {peeraddress = peerAddress, peerPort}


-- 2. self.lobbies[lobbyid] = {}
--    table.insert(self.lobbies[lobbyid], {peeraddress = peerAddress, peerPort})


-- 3. self.lobbies[lobbyid] = {
--   gamestate = {
--          players = {},
--          entities = {},
--          world = {}
--      }
--   state = 'waiting'
--}