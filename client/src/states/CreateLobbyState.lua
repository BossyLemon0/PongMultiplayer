--[[

    Breakout multiplayer refactor

    -- Create lobby class --

    Author: Omar Ramirez
    omardramirez2002@gmail.com

    Represents the state to create a lobby
]]

--Takes user to form to create lobby and then goes to wait once submitted
--For now just a button that creates a new lobby, and attaches a random id to it

CreateLobbyState = Class{__includes = BaseState}

-- whether we're highlighting "Start" or "High Scores"
local highlighted = 1

function CreateLobbyState:enter(params,udp)
    self.highScores = params.highScores
    self.udp = udp
    self.lobbyId = 0
    self.playerId = 0
    self.address, self.port = '', 0
    self.util = NetworkUtil()
    Logger:info("at Createlobby ".. self.udp:getpeername())
end

function CreateLobbyState:CreateInfo(udp)
    -- add checks to see what id's are available from network, for now just random
    -- add username sending
    self.lobbyId = math.random(40)
    self.playerId = math.random(4)
    self.address, self.port = udp:getsockname()
    local addLobby = string.format("%s %s %s %s %d %d %d", "lobby", 'update', 'add' , self.address, self.port, self.lobbyId, self.playerId)
    udp:send(addLobby)
    return self.lobbyId, self.playerId
end

function CreateLobbyState:update(dt)
    -- add naming capture
    -- toggle highlighted option if we press an arrow key up or down
    if love.keyboard.wasPressed('right') then
        if highlighted == 1 then
            highlighted = 2
        else
            highlighted = highlighted - 1
        end
        gSounds['paddle-hit']:play()
    elseif love.keyboard.wasPressed('left') then
        if highlighted == 2 then
            highlighted = 1
        else
            highlighted = highlighted + 1
        end
        gSounds['paddle-hit']:play()
    end

    -- confirm whichever option we have selected to change screens
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()

        if highlighted == 1 then
            -- paddle-select
            -- wait-for-players
            local lobbyId, playerId = CreateLobbyState:CreateInfo(self.udp)
            gStateMachine:change('paddle-select', {
                highScores = self.highScores,
                multi = true,
                lobbyId = lobbyId,
                playerId = playerId
            }, self.udp)
        elseif highlighted == 2 then
            gStateMachine:change('multiplayer-select-menu', {
                highScores = self.highScores
            }, self.udp)
        end
    end

    -- we no longer have this globally, so include here
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function CreateLobbyState:render()

    -- instructions
    love.graphics.setFont(gFonts['medium'])

    -- if we're highlighting 1, render that option blue
    if highlighted == 1 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("Create", 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH + 100, 'center')

    -- reset the color
    love.graphics.setColor(1, 1, 1, 1)

    if highlighted == 2 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("Back", 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH - 100, 'center')

    -- reset the color
    love.graphics.setColor(1, 1, 1, 1)
end