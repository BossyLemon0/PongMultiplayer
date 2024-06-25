--[[

    Breakout multiplayer refactor

    -- Join Lobby state--

    Author: Omar Ramirez
    omardramirez2002@gmail.com

    Represents the state to choose to join or create a lobby
]]

-- Shows list of lobbies available

JoinLobbyState = Class{__includes = BaseState}

-- whether we're highlighting "Start" or "High Scores"
local highlighted = 1

function JoinLobbyState:enter(params,udp)
    self.highScores = params.highScores
    -- self.lobbies = params.lobbies  Getting lobbies should be done by recieving a call from the network
    self.udp = udp
    self.lobbies = {}
    self.lobbyOrder = {}
    self.menuCursor = -1
    self.menulistcount = 0
    JoinLobbyState:requestLobbies(self, self.udp)
    -- print(self.udp:getpeername())
    self.testTimer = 0
end

function JoinLobbyState:requestLobbies(self,udp)
    local address, port = udp:getsockname()
    local requestLobbies = string.format("%s %s %s %s %d", "lobbies", 'request', 'order_by_when_created' , address, port)
    udp:send(requestLobbies)

    -- repeat
    --     local data, msg = udp:receive()

    --     if data then
    --         print('theres data'.. data)
    --         local lobbyId, playerTable  = JoinLobbyState:parseLobbyData(data)
    --         print("Now create table: "..lobbyId)
    --         print("Found in table: "..playerTable[1].peerPort)
    --         -- reconstruct lobby and lobby order
    --         self.lobbies[lobbyId] =  playerTable
    --         table.insert(self.lobbyOrder,lobbyId)
    --         -- for i, player in pairs(playerTable) do
    --         --     table.insert(self.lobbies[lobbyId], playerTable)
    --         -- end
    --     end
    -- until not data

end

function JoinLobbyState:parseLobbyData(data)
    local lobbyId = JoinLobbyState:parseLobbyId(data)
    local playersTable = JoinLobbyState:parsePlayerInfo(data)

    -- print('lobby working here '..lobbyId)
    print(playersTable[1].peerAddress)
    -- print('player table has port: '..playersTable)
    return tonumber(lobbyId), playersTable
end

function JoinLobbyState:parseLobbyId(string)
    print(string)
    local id_pattern = "lobby:(%d+)"
    return string:match(id_pattern)
end

function JoinLobbyState:parsePlayerInfo(string)
    print ("this is string in paseplayer"..string)
    local players = {}
    local player_pattern1 = "{%s*(%w+)%s*,%s*(%d+)%s*}" --first pattern to just for words
    local player_pattern2 = "{%s*([^,]+)%s*,%s*(%d+)%s*}" --second pattern to account for colons
    for address, port in string:gmatch(player_pattern2) do
        print("parseplayer address:"..address)
        print("parseplayer port:"..port)
        table.insert(players, {peerAddress = address, peerPort = port})
    end
    return players
end


function JoinLobbyState:update(dt)

    self.testTimer = self.testTimer + dt
    if (self.testTimer > 3) then

        -- JoinLobbyState:requestLobbies(self.udp) Ba
        self.testTimer = 0
    end
    

    local data, msg = udp:receive()

    if data then
        -- ^(%S+): Matches one or more non-whitespace characters at the start of the string and captures them in command.
        -- (.+)$: Matches one or more characters until the end of the string and captures them in datastring. 
        print('you received the data')
        print(data)
        local command, datastring = data:match("^(%S+) (.+)$")
        print(command)

            if command == 'initLobbies' then
                
                local lobbyId, playerTable  = JoinLobbyState:parseLobbyData(datastring)
                print("Now create table: "..lobbyId)
                print("Found in table: "..playerTable[1].peerPort)
                -- reconstruct lobby and lobby order
                self.lobbies[lobbyId] =  playerTable
                table.insert(self.lobbyOrder,lobbyId)
                -- for i, player in pairs(playerTable) do
                --     table.insert(self.lobbies[lobbyId], playerTable)
                -- end
            elseif command == 'addNewLobby' then
                print('should add')
                local lobbyId, playerTable  = JoinLobbyState:parseLobbyData(datastring)
                print("Now create table: "..lobbyId)
                print("Found in table: "..playerTable[1].peerPort)
                -- reconstruct lobby and lobby order
                self.lobbies[lobbyId] =  playerTable
                table.insert(self.lobbyOrder,lobbyId)

            elseif command == 'deleteLobby' then
                print('delete lobby:')
                print(type(datastring))
                self.lobbies[tonumber(datastring)] = nil
                for i, id in pairs(self.lobbyOrder) do
                    if id == tonumber(datastring) then
                        table.remove(self.lobbyOrder, i)
                    end
                end

            end
    end



    if #self.lobbies > 0 then
        if love.keyboard.wasPressed('up') then
            if self.menuCursor == 1 then
                self.menuCursor = #self.lobbies
            else
                self.menuCursor = self.menuCursor - 1
            end
            gSounds['paddle-hit']:play()
        elseif love.keyboard.wasPressed('down') then
            if self.menuCursor == #self.lobbies then
                self.menuCursor = 1
            else
                self.menuCursor = self.menuCursor + 1
            end
            gSounds['paddle-hit']:play()
        elseif love.keyboard.wasPressed('left') then
            if self.menuCursor > 0 then
                self.menuCursor = -1
            else
                self.menuCursor = 1
            end
        elseif love.keyboard.wasPressed('right') then
            if self.menuCursor == -1 then
                self.menuCursor = 1
            else
                self.menuCursor = -1
            end
        end
    end

    -- confirm whichever option we have selected to change screens
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()

        if highlighted == 1 then
            gStateMachine:change('paddle-select', {
                highScores = self.highScores
            }, self.udp)
        elseif highlighted == 2 then
                gStateMachine:change('paddle-select', {
                    highScores = self.highScores
                }, self.udp)
        end
    end

    -- we no longer have this globally, so include here
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function JoinLobbyState:render()
    -- _________finish loop to account for an overabundance_____________

    love.graphics.setFont(gFonts['medium'])
    local spacing = 0

    if self.menuCursor == -1 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("back", 0, VIRTUAL_HEIGHT / 2 + 40, VIRTUAL_WIDTH - 150, 'center')

    love.graphics.setColor(1, 1, 1, 1)



    -- if #self.lobbyOrder then
        for i, lobbyId in pairs(self.lobbyOrder) do
            if self.menuCursor == i then
                love.graphics.setColor(103/255, 1, 1, 1)
            end
            love.graphics.printf("lobby: ".. lobbyId, 0, VIRTUAL_HEIGHT / 2 - 40 + spacing, VIRTUAL_WIDTH, 'center')
            -- add player info later
            spacing = spacing + 20
        end
    -- else 
    --     love.graphics.printf("Wow, so empty", 0, VIRTUAL_HEIGHT / 2 + spacing, VIRTUAL_WIDTH, 'center')
    -- end


    -- reset the color
    love.graphics.setColor(1, 1, 1, 1)
end