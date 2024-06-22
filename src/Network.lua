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
    self.lobbies = {}
end

-- peer code
function Network:AddPeers(peerAddress, peerPort)
    print('added new user: '.. peerAddress.. ":" .. peerPort)
    self.peers[peerAddress .. ":" .. peerPort] = {peerAddress = peerAddress, peerPort = peerPort}
    print('peers'..self.peers[peerAddress .. ":" .. peerPort].peerAddress)
    Network:ShowPeers()
end

function Network:ShowPeers()
    for k, peer in pairs(self.peers) do
        print(peer.peerPort)
    end
end

-- lobby code
function Network:AddLobby(peerAddress, peerPort, lobbyId)
    self.lobbies[lobbyId] = {peerAddress = peerAddress, peerPort = peerPort, lobbyId = lobbyId}
    print('lobbies: '..self.lobbies[lobbyId].peerPort)
    Network:ShowLobbies()
end

function Network:JoinLobbies(peerAddress, peerPort, lobbyId)
    table.insert(self.lobbies[lobbyId], {peerAddress = peerAddress, peerPort = peerPort})
end

function Network:ShowLobbies()
    for k, lobby in pairs(self.lobbies) do
        print('lobby id is: '..lobby.lobbyId)
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
                    Network:AddLobby(peerHost, peerPort, lobbyId)
                end
            end
        elseif cmd  == 'request' then
            --send lobbies to user
            if entity == 'lobbies' then
                if entitycmd == 'order_by_when_created' then
                    for i, lobby in pairs(self.lobbies) do
                        self.udp:sendto(string.format("%s", lobby.lobbyId), msg_or_ip,  port_or_nil)
                        for index, data in pairs(lobby) do
                            self.udp:sendto(string.format("%s %s %d %d", lobby.x, lobby.y), msg_or_ip,  port_or_nil)
                        end
                    end
                end
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