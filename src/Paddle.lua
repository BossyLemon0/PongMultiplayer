--[[
    GD50
    Breakout Remake

    -- Paddle Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a paddle that can move left and right. Used in the main
    program to deflect the ball toward the bricks; if the ball passes
    the paddle, the player loses one heart. The Paddle can have a skin,
    which the player gets to choose upon starting the game.
]]

Paddle = Class{}

--[[
    Our Paddle will initialize at the same spot every time, in the middle
    of the world horizontally, toward the bottom.
]]
function Paddle:init(skin, isMulti, playerOrder)
    -- x is placed in the middle
    self.x = VIRTUAL_WIDTH / 2 - 32

    -- y is placed a little above the bottom edge of the screen
    self.y = VIRTUAL_HEIGHT - 32

    -- start us off with no velocity
    self.dx = 0

    -- starting dimensions
    self.width = 64
    self.height = 16
    self.isMulti = isMulti
    self.playerOrder = playerOrder
    print('---------------------------------------Initializing------------------------------------------------')
    if isMulti then
        print('---------------------------------------IS MULTI------------------------------------------------')
        if playerOrder == 1 or playerOrder == 2 then
            self.width = 64
            self.height = 16
            self.x = VIRTUAL_WIDTH / 2 - 32
        else
            self.width = 16
            self.height = 64
            self.y = VIRTUAL_WIDTH / 2 - 32
        end

        if playerOrder == 1 then
            self.y = VIRTUAL_HEIGHT - 32
        elseif playerOrder == 2 then
            self.y =  32
        elseif playerOrder == 3 then
            self.x = VIRTUAL_WIDTH - 32
        elseif playerOrder == 4 then
            self.x = 32
        end



    
        self.dx = 0
        self.dy = 0
    end

    -- the skin only has the effect of changing our color, used to offset us
    -- into the gPaddleSkins table later
    self.skin = skin

    -- the variant is which of the four paddle sizes we currently are; 2
    -- is the starting size, as the smallest is too tough to start with
    self.size = 2

    self.powers = 0

    self.keypower = 0

    --I didnt structure this right
    self.otherPowers = 0

end

--IN PROGRESS

function Paddle:update(dt)
    -- keyboard input
    if self.isMulti then
        --defines how the paddle should move based on which player
            if love.keyboard.isDown('left') then
                if self.playerOrder == 1 then
                    self.dx = -PADDLE_SPEED
                elseif self.playerOrder == 2 then
                    self.dx = PADDLE_SPEED
                elseif self.playerOrder == 3 then
                    self.dy = PADDLE_SPEED
                elseif self.playerOrder == 4 then
                    self.dy = -PADDLE_SPEED
                end
                self.dx = -PADDLE_SPEED
            elseif love.keyboard.isDown('right') then
                if self.playerOrder == 1 then
                    self.dx = PADDLE_SPEED
                elseif self.playerOrder == 2 then
                    self.dx = -PADDLE_SPEED
                elseif self.playerOrder == 3 then
                    self.dy = -PADDLE_SPEED
                elseif self.playerOrder == 4 then
                    self.dy = PADDLE_SPEED
                end
                self.dx = PADDLE_SPEED
            else
                self.dx = 0
            end
        --defines the boundaries of each paddle
        if self.playerOrder == 1 or self.playerOrder == 2 then
            if self.dx < 0 then
                --keeps paddle from going too far left
                self.x = math.max(0, self.x + self.dx * dt)
            else
                --keeps paddle from going too far right
                self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
            end
        else
            if self.dy < 0 then
                --keeps paddle from going too far up
                self.y = math.max(0, self.y + self.dy * dt)
            else
                --keeps paddle from going too far down
                self.y = math.min(VIRTUAL_HEIGHT - self.width, self.y + self.dy * dt)
            end
        end

    else
        if love.keyboard.isDown('left') then
            self.dx = -PADDLE_SPEED
        elseif love.keyboard.isDown('right') then
            self.dx = PADDLE_SPEED
        else
            self.dx = 0
        end
        if self.dx < 0 then
            --keeps paddle from going too far left
            self.x = math.max(0, self.x + self.dx * dt)
        else
            --keeps paddle from going too far right
            self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
        end
    end

end

--[[
    Render the paddle by drawing the main texture, passing in the quad
    that corresponds to the proper skin and size.
]]
function Paddle:render()
    love.graphics.draw(gTextures['main'], gFrames['paddles'][self.size + 4 * (self.skin - 1)],
        self.x, self.y)
end