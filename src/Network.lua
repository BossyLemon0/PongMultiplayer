Network = Class{}

local host = "*" -- listen for all addresses
local port = 12345  -- Allocate a random port for this instance

local data, msg_or_ip, port_or_nil
local entity, cmd, params
-- local udp = socket.udp()

function Network:Init()

    self.udp = socket.udp()
    self.udp:settimeout(0)
    self.udp:setsockname(host, port)
    self.peers = {}
    self.world = {}
end


function Network:AddPeers(address, peerPort)
    print('added new user')
    print(address)
    print(peerPort)
    self.peers[address .. ":" .. peerPort] = {address = address, port = peerPort}
end



function Network:update(dt)
    data, msg_or_ip, port_or_nil = self.udp:receivefrom()
    if data then 
        entity, cmd, parms = data:match("^(%S*) (%S*) (.*)")
        if cmd  == 'move' then
        elseif cmd  == 'at' then
        elseif cmd  == 'update' then
        end
    -- elseif msg_or_ip ~= 'timeout' then
    --     error("Unknown network error: "..tostring(msg))
    end
    socket.sleep(0.01)
end
-- while running do

-- end
print "Thank you."