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
    self.world = {}
end


function Network:AddPeers(address, peerPort)
    print('added new user')
    self.peers[address .. ":" .. peerPort] = {address = address, port = peerPort}
    print(self.peers)
end



function Network:update(dt)
    self.t = self.t + dt
    if (self.t > 10) then 
        -- print(self.peers)
        self.t = 0
    end
    data, msg_or_ip, port_or_nil = self.udp:receivefrom()
    if data then 
        print(data)
        entity, cmd, parms = data:match("^(%S*) (%S*) (.*)")
        if cmd  == 'move' then
        elseif cmd  == 'at' then
        elseif cmd  == 'update' then
            if entity == 'peer' then
                print(parms .. "type".. type(parms))
                local host, port = string.match(parms, "([^%s]+) (%d+)")
                -- Network.AddPeers()
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