--[[
    GD50
    Breakout Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state the game is in when we've just started; should
    simply display "Breakout" in large text, as well as a message to press
    Enter to begin.
]]

PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:enter(params, udp)
    self.highScores = params.highScores
    self.isMulti = params.multi
    self.lobbyId = params.lobbyId
    self.lobby = {}
    self.lobbyState = {}
    self.lobbyOrder = {}
    self.udp = udp
    PaddleSelectState:requestLobbyInfo(self, self.udp)
    self.NetworkUtil = NetworkUtil()
end

function PaddleSelectState:init()
    -- the paddle we're highlighting; will be passed to the ServeState
    -- when we press Enter
    self.currentPaddle = 1
end

function PaddleSelectState:requestLobbyInfo(self,udp)
    print('sending')
    local address, port = udp:getsockname()
    local requestLobby = string.format("%s %s %d %s %d", "lobby", 'request', self.lobbyId , address, port)
    udp:send(requestLobby)
end

function PaddleSelectState:update(dt)

    local data, msg = self.udp:receive()

    if data then
        -- ^(%S+): Matches one or more non-whitespace characters at the start of the string and captures them in command.
        -- (.+)$: Matches one or more characters until the end of the string and captures them in datastring. 
        print('you received the data')
        print(data)
        local command, datastring = data:match("^(%S+) (.+)$")
        print(command)

            if command == 'initLobby' then
                local lobbyId, playerTable  = self.NetworkUtil:parseLobbyData(datastring,command)
                print("Now create table: "..lobbyId)
                print("Found in table: "..playerTable[1].peerPort)
                -- reconstruct lobby and lobby order
                self.lobby =  playerTable
            elseif command == 'initLobbyState' then
                print("from Init Lobbystate"..datastring)
                local lobbyId, lobbyStateTable  = self.NetworkUtil:parseLobbyData(datastring,command)
                self.lobbyState =  lobbyStateTable
            elseif command == 'addNewPlayer' then
                print('should add new player')
                local lobbyId, playerTable  = self.NetworkUtil:parseLobbyData(datastring,command)
                print("Now create table: "..lobbyId)
                print("Found in table: "..playerTable[1].peerPort)
                -- reconstruct lobby and lobby order
                self.lobbies[lobbyId] =  playerTable
                table.insert(self.lobbyOrder,lobbyId)
            elseif command == 'updateLobbyState' then
                local lobbyId, lobbyStateTable  = self.NetworkUtil:parseLobbyData(datastring,command)
                -- reconstruct lobby and lobby order
                self.lobbyStates[lobbyId] =  lobbyStateTable
            elseif command == 'disconnectPlayer' then
                print('disconnected player:')
                print(type(datastring))
                self.lobbies[tonumber(datastring)] = nil
                self.lobbyStates[tonumber(datastring)] = nil
                for i, id in pairs(self.lobbyOrder) do
                    if id == tonumber(datastring) then
                        table.remove(self.lobbyOrder, i)
                    end
                end

            end
    end


    if love.keyboard.wasPressed('left') then
        if self.currentPaddle == 1 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle - 1
        end
    elseif love.keyboard.wasPressed('right') then
        if self.currentPaddle == 4 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle + 1
        end
    end

    -- select paddle and move on to the serve state, passing in the selection
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        gSounds['confirm']:play()

        local bricks, powers, keypowers, hasKey, key = LevelMaker.createMap(INIT_LEVEL)

        gStateMachine:change('serve', {
            paddle = Paddle(self.currentPaddle),
            bricks = bricks,
            powers = powers,
            keypowers = keypowers,
            hasKey = hasKey,
            key = key,
            health = 3,
            score = 0,
            highScores = self.highScores,
            level = INIT_LEVEL,
            recoverPoints = 5000,
            isMulti = self.multi,
            lobbyId = self.lobbyId,
            lobby = self.lobby ,
            lobbyState = self.lobbyState,
        }, self.udp)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PaddleSelectState:render()
    -- lobby state
    if self.isMulti and self.lobbyState[1] then
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("Waiting...", 0, VIRTUAL_HEIGHT / 7,
            VIRTUAL_WIDTH - 200, 'center')

            love.graphics.setFont(gFonts['small'])
            love.graphics.printf(self.lobbyState[1].playerCount.."/"..self.lobbyState[1].limit , 0, VIRTUAL_HEIGHT / 7,
                VIRTUAL_WIDTH + 200, 'center')
    end
    -- instructions
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("Select your paddle with left and right!", 0, VIRTUAL_HEIGHT / 4,
        VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("(Press Enter to continue!)", 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')
        
    -- left arrow; should render normally if we're higher than 1, else
    -- in a shadowy form to let us know we're as far left as we can go
    if self.currentPaddle == 1 then
        -- tint; give it a dark gray with half opacity
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    end
    
    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24,
        VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
   
    -- reset drawing color to full white for proper rendering
    love.graphics.setColor(1, 1, 1, 1)

    -- right arrow; should render normally if we're less than 4, else
    -- in a shadowy form to let us know we're as far right as we can go
    if self.currentPaddle == 4 then
        -- tint; give it a dark gray with half opacity
        love.graphics.setColor(40/255, 40/255, 40/255, 128)
    end
    
    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
        VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    
    -- reset drawing color to full white for proper rendering
    love.graphics.setColor(1, 1, 1, 1)

    -- draw the paddle itself, based on which we have selected
    love.graphics.draw(gTextures['main'], gFrames['paddles'][2 + 4 * (self.currentPaddle - 1)],
        VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
end