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
function Network:AddPeers(peerAddress, peerPort)
    print('added new user: '.. peerAddress.. ":" .. peerPort)
    self.peers[peerAddress .. ":" .. peerPort] = {peerAddress = peerAddress, peerPort = peerPort}
    table.insert(self.peersOrder, peerAddress .. ":" .. peerPort)
    print('peers'..self.peers[peerAddress .. ":" .. peerPort].peerAddress)
    Network:ShowPeers()
end

function Network:ShowPeers()
    for k, peer in pairs(self.peers) do
        print(peer.peerAddress)
    end
end

-- lobby code
-- 
function Network:AddLobby(peerAddress, peerPort, lobbyId)
    self.lobbies[lobbyId] = {peerAddress = peerAddress, peerPort = peerPort, lobbyId = lobbyId}
    self.lobbyStates[lobbyId] = {state = "waiting", playerCount = 1, limit = 4}
    table.insert(self.lobbyOrder, lobbyId)
    print('lobbies: '..self.lobbies[lobbyId].peerPort)
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

function Network:updatePlayersInLobby(playerfunc, lobbystatefun, playerdatagram, lobbystatedatagram, lobbyId)
    for i, players in pairs(self.lobbies[lobbyId]) do
        -- print("datagram to add new lobby sent: "..datagram)
        print(lobbystatedatagram)
        print(playerdatagram)
        -- send the last datagram
        self.udp:sendto(string.format("%s %s", playerfunc, lobbystatefun), players.peerAddress, tonumber(players.peerPort))
        self.udp:sendto(string.format("%s %s", playerdatagram, lobbystatedatagram), players.peerAddress, tonumber(players.peerPort))
    end
end

function Network:JoinLobbyById(lobbyId, peerAddress, peerPort)
    local lobbyDatagram = Network:createDatagram('getLobbyAt',lobbyId)
    local lobbyStateDatagram = Network:createDatagram('getLobbyStateAt',lobbyId)
    table.insert(self.lobbies[lobbyId], {peerAddress = peerAddress, peerPort = peerPort})
    self.lobbyStates[lobbyId].playerCount = self.lobbyStates[lobbyId].playerCount + 1
    Network:updatePlayersInLobby('updateLobby', lobbyDatagram, "updateLobbyState", lobbyStateDatagram, lobbyId)
    
end

function Network:JoinLobbyByIdOriginal(lobbyId, peerAddress, peerPort)
    table.insert(self.lobbies[lobbyId], {peerAddress = peerAddress, peerPort = peerPort})
    
end


function Network:SendLobbiesInOrder(userIp, userPort)
    local lobbyDatagramTable = Network:createDatagram('getAllLobies')
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

function Network:createDatagram(query, payload)


    if query == "getAllLobies" then
        local datagrams = {}
        for orderId, lobbyid in pairs(self.lobbyOrder) do
            local lobbystring = ''
            local lobby = self.lobbies[lobbyid]
            lobbystring = lobbystring .. "lobby:" .. tostring(lobby.lobbyId)
            lobbystring = lobbystring ..
            " {".. lobby.peerAddress.. ','
            .. tostring(lobby.peerPort)..
            "}"
    
            print(lobbystring)
    
            if lobby[1] then
                for _, player in pairs(lobby) do
                    print("this is player:"..player)
                    lobbystring = lobbystring ..
                    " {".. player[1] .. ','
                    .. tostring(player[2]).. ','..
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
            local lobby = self.lobbies[lobbyid]
            local lobbyState = self.lobbyStates[lobbyid]
            lobbystring = lobbystring .. "lobby:" .. tostring(lobby.lobbyId)
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
        print(lobby.lobbyId)
        print(lobby.peerAddress)
        lobbyString = lobbyString .. "lobby:" .. tostring(lobby.lobbyId)

        if lobby[1] then
            for i, player in pairs(lobby) do
                lobbyString = lobbyString ..
                " {".. player.peerAddress.. ','
                .. tostring(player.peerPort)..
                "}"
            end
        else
            lobbyString = lobbyString ..
            " {".. lobby.peerAddress.. ','
            .. tostring(lobby.peerPort)..
            "}"
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

function Network:ShowLobbies()
    if self.lobbies[self.lobbyOrder[1]] then
        for k, lobby in pairs(self.lobbies) do
            print('lobby id is: '..lobby.lobbyId)
            print("lobby looks like".. lobby.peerPort)
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
        if cmd  == 'move' then
        elseif cmd  == 'at' then
        elseif cmd  == 'update' then
            if entitycmd == 'add' then
                if entity == 'peer' then
                    print(parms .. "type".. type(parms))
                    local peerHost, peerPort = string.match(parms, "([^%s]+) (%d+)")
                    print('host has type of: '.. type(peerHost) .."port has type of: ".. type(peerPort))
                    print('host is: '.. peerHost .." port is: ".. peerPort)
                    Network:AddPeers(peerHost, peerPort)
                elseif entity == 'lobby' then
                    local peerHost, peerPort, lobbyId = string.match(parms, "([^%s]+) (%d+) (%d+)")
                    print('host is: '.. peerHost .." port is: ".. peerPort)
                    Network:AddLobby(peerHost, tonumber(peerPort), tonumber(lobbyId))
                elseif entity == 'player' then -- IN PROGRESSS
                    local peerHost, peerPort = string.match(parms, "([^%s]+) (%d+)")
                    -- entity command is the lobbyId in string
                    Network:JoinLobbyById(tonumber(entitycmd), msg_or_ip, port_or_nil)
                end
            elseif entitycmd == 'delete' then
                if entity == 'lobby' then
                    local lobbyId = string.match(parms, "(%d+)")
                    print("lobby being deleted: "..lobbyId)
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
                Network:SendLobbyById(tonumber(entitycmd), msg_or_ip, port_or_nil) --dont touch dumbass
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