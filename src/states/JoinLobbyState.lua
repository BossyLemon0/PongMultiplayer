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
    JoinLobbyState:requestLobbies(self.udp)
    -- print(self.udp:getpeername())
end

function JoinLobbyState:requestLobbies(udp)
    local requestLobbies = string.format("%s %s %s %s %d", "lobbies", 'request', 'order_by_when_created' , self.address, self.port)
    udp:send(requestLobbies)
end


function JoinLobbyState:update(dt)
    -- toggle highlighted option if we press an arrow key up or down
    if love.keyboard.wasPressed('up') then
        if highlighted == 1 then
            highlighted = 2
        else
            highlighted = highlighted - 1
        end
        gSounds['paddle-hit']:play()
    elseif love.keyboard.wasPressed('down') then
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
    -- _________Create loop for back button lobbies open_____________

    -- instructions
    love.graphics.setFont(gFonts['medium'])

    -- if we're highlighting 1, render that option blue
    if highlighted == 1 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("Create lobby", 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(1, 1, 1, 1)

    if highlighted == 2 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("Join lobby", 0, VIRTUAL_HEIGHT / 2 + 20,
        VIRTUAL_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(1, 1, 1, 1)
end