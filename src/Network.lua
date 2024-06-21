local udp = socket.udp()

udp:settimeout(0)
udp:setsockname('*', 12345)

local peers = {}