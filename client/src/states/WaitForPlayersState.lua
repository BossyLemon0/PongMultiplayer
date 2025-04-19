--[[

    Breakout multiplayer refactor

    -- Wait lobby state--

    Author: Omar Ramirez
    omardramirez2002@gmail.com

    Represents the state to wait for players to join 
]]

-- Shows waiting information after creating a lobby,

WaitForPlayersState = Class{__includes = BaseState}

-- whether we're highlighting "Start" or "High Scores"
local highlighted = 1

function WaitForPlayersState:enter(params,udp)
    self.highScores = params.highScores
    self.lobbyId = params.lobbyId
    self.udp = udp

    -- print(self.udp:getpeername())
end

function WaitForPlayersState:DeleteInfo(udp, lobbyId)
    local deleteLobby = string.format("%s %s %s %d", "lobby", 'update', 'delete', lobbyId)
    udp:send(deleteLobby)
end

function WaitForPlayersState:update(dt)
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
            WaitForPlayersState:DeleteInfo(self.udp, self.lobbyId)
            gStateMachine:change('create-lobby', {
                highScores = self.highScores
            }, self.udp)
        elseif highlighted == 2 then
                gStateMachine:change('paddle-select', {
                    highScores = self.highScores,
                    lobbyId = self.lobbyId
                }, self.udp)
        end
    end

    -- we no longer have this globally, so include here
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function WaitForPlayersState:render()
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("Waiting for players...", 0, VIRTUAL_HEIGHT / 2 - 20,
        VIRTUAL_WIDTH, 'center')

    -- instructions
    love.graphics.setFont(gFonts['medium'])

    -- if we're highlighting 1, render that option blue
    if highlighted == 1 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("Back", 0, VIRTUAL_HEIGHT / 2 + 20,
        VIRTUAL_WIDTH - 100, 'center')

    -- reset the color
    love.graphics.setColor(1, 1, 1, 1)

    if highlighted == 2 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("Start", 0, VIRTUAL_HEIGHT / 2 + 20,
        VIRTUAL_WIDTH + 100, 'center')

    -- reset the color
    love.graphics.setColor(1, 1, 1, 1)
end