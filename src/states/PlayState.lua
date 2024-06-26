--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params, udp)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.powers = params.powers
    self.keypowers = params.keypowers
    self.key = params.key
    self.levelHasKey = params.levelHasKey
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level

    self.recoverPoints = 5000

    self.balls = {}
    table.insert(self.balls, self.ball)

    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)

    self.ballsInPlay = 1
    self.scoredInLife = 0
    self.timer = 0
    self.multiplier = 1

    self.udp = udp


end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end


    -- update positions based on velocity
    self.paddle:update(dt)

    --set flag to update and render key after a set time
    if self.levelHasKey == true then
        --set a timer
        self.timer = self.timer + dt

        if self.timer > math.random(7,20) then
            self.key[1].inPlay = true
        end
        
    end

    --check if extra powerups.
    if self.paddle.otherPowers == 7 then
        gSounds['shrink']:play()
        --multiply score by 3 and ball speed by 2
        self.multiplier = 3
        for k, balls in pairs(self.balls) do
            while balls.scalex > .5 and balls.scaley >= .5 do
                balls.scalex = balls.scalex - dt*.10
                balls.scaley = balls.scaley - dt*.10
                balls.width = 4
                balls.height = 4
                balls.speed = 2
            end
        end
            
        self.paddle.otherPowers = self.paddle.otherPowers - 7
    
    elseif self.paddle.otherPowers == 8 then
        gSounds['grow']:play()
        -- damage to bricks by 2 
        self.multiplier = 2
        for k, balls in pairs(self.balls) do
            while balls.scalex <= 2 and balls.scaley <= 2 do
                balls.scalex = balls.scalex + dt
                balls.scaley = balls.scaley + dt
                balls.width = 16
                balls.height = 16
            end
        end

        self.paddle.otherPowers =  self.paddle.otherPowers - 7
    end

    --updating the ball only if its in play
    for key, ball in pairs(self.balls) do
        if ball.inPlay == true then
            ball:update(dt)
        end
        if love.keyboard.wasPressed('w') then
            gStateMachine:change('victory', {
                level = self.level,
                paddle = self.paddle,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                ball = ball,
                recoverPoints = self.recoverPoints
            }, self.udp)
        end
    end

    --paddle and ball interactions
    for key, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - ball.height
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            --I want a ball to appear going the oposite/random direction
            --if multiple powers are stored then I want the number of balls multiplied
            --I want all of the number of powers in the paddle set back to 0 
            if self.paddle.powers > 0 then
                gSounds['multiball']:play()
                for i = 1, self.paddle.powers do
                    local newBall = Ball(math.random(7))
                    newBall.x = self.paddle.x + (self.paddle.width / 2) - 4
                    newBall.y = self.paddle.y - 8
                    newBall.dy = ball.dy
                    newBall.dx = -ball.dx + math.random(-20,20)
                    table.insert(self.balls, newBall)
                    self.ballsInPlay = self.ballsInPlay + 1
                    
                end
                self.paddle.powers = 0
            end


            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
        
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        for key, ball in pairs(self.balls) do
        -- only check collision if we're in play
        if brick.inPlay and ball:collides(brick) then

            -- add to score
            self.score = (self.score + (brick.tier * 200 + brick.color * 25) * self.multiplier) 
            self.scoredInLife = (self.scoredInLife + (brick.tier * 200 + brick.color * 25) * self.multiplier) 
            -- trigger the brick's hit function, which removes it from play
            brick:hit(self.paddle.otherPowers, self.paddle.keypower)

            --trigger powerup
            if brick.hasPower == true then 
                self.powers[brick.powNum].inPlay = true
                brick.hasPower = false
            end

            --trigger powerup thats locked in key block
            if brick.isKey == true and self.paddle.keypower > 0 then 
                self.keypowers[1].inPlay = true
                self.paddle.keypower = self.paddle.keypower - 1
            end

            -- if we have enough points, recover a point of health
            if self.score > self.recoverPoints then
                -- can't go above 3 health
                self.health = math.min(3, self.health + 1)

                -- multiply recover points by 2
                self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                -- play recover sound effect
                gSounds['recover']:play()
            end

            -- go to our victory screen if there are no more bricks left
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    ball = ball,
                    recoverPoints = self.recoverPoints
                }, self.udp)
            end

            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            if ball.x + 2 < brick.x and ball.dx > 0 then
                
                -- flip x velocity and reset position outside of brick
                ball.dx = -ball.dx
                ball.x = brick.x - 8
            
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                
                -- flip x velocity and reset position outside of brick
                ball.dx = -ball.dx
                ball.x = brick.x + 32
            
            -- top edge if no X collisions, always check
            elseif ball.y < brick.y then
                
                -- flip y velocity and reset position outside of brick
                ball.dy = -ball.dy
                ball.y = brick.y - 8
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of brick
                ball.dy = -ball.dy
                ball.y = brick.y + 16
            end

            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(ball.dy) < 150 then
                ball.dy = ball.dy * 1.02
            end

            -- only allow colliding with one brick, for corners
            break
        end
        end
    end

    --for multi ball power being in play
    for key, power in pairs(self.powers) do
        if power.inPlay == true then
            power:update(dt)
            
            if power:collides(self.paddle) then
                gSounds['powerup']:play()
                --add another ball with random and opposite direction loaded.
                self.paddle.powers = self.paddle.powers + 1
                power.inPlay = false
            end

            if power.y > VIRTUAL_HEIGHT then
                power.inPlay = false
            end


        end
        
    end

    --for keypower inside block being in play
    for key, power in pairs(self.keypowers) do
        if power.inPlay == true then
            power:update(dt)
            
            if power:collides(self.paddle) then
                gSounds['powerup']:play()
                --add big ball or small ball depending on the power num
                if power.power == 7 then
                    self.paddle.otherPowers = self.paddle.otherPowers + 7
                elseif  power.power == 8 then
                    self.paddle.otherPowers = self.paddle.otherPowers + 8
                end
                power.inPlay = false
            end

            if power.y > VIRTUAL_HEIGHT then
                power.inPlay = false
            end


        end
        
    end

    --for key being in play
    for key, keyPower in pairs(self.key) do
        if keyPower.inPlay == true then
            keyPower:update(dt)
            
            if keyPower:collides(self.paddle) then
                --add another ball with random and opposite direction loaded.
                self.paddle.keypower = self.paddle.keypower + 1
                keyPower.inPlay = false
                self.levelHasKey = false
                gSounds['getkey']:play()
            end

            if keyPower.y > VIRTUAL_HEIGHT then
                keyPower.inPlay = false
                self.levelHasKey = false
            end


        end
        
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    for key, ball in pairs(self.balls) do
        if ball.y >= VIRTUAL_HEIGHT and self.ballsInPlay == 1 then
            self.health = self.health - 1
            gSounds['hurt']:play()
            if self.paddle.size > 1 then
                self.paddle.size = self.paddle.size - 1
                self.paddle.width = PADDLE_WIDTH_DIMENSIONS[self.paddle.size]       
            end
    
            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                }, self.udp)
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    powers = self.powers,
                    key = self.key,
                    keypowers = self.keypowers,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints
                }, self.udp)
            end
        elseif ball.y >= VIRTUAL_HEIGHT and self.ballsInPlay > 1 then
            ball.inPlay = false
            self.ballsInPlay = self.ballsInPlay - 1
            ball.y = 0 
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if self.scoredInLife > 2000 then
        if self.paddle.size < 4 then
            self.paddle.size = self.paddle.size + 1
            self.paddle.width = PADDLE_WIDTH_DIMENSIONS[self.paddle.size]
        end
        self.scoredInLife = 0
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end
    -- renders +1 power ups in play
    for k, power in pairs(self.powers) do
        power:render()
    end
    -- renders balls in play
    for k, ball in pairs(self.balls) do
        if ball.inPlay == true then
            ball:render()   
        end
    end
    -- renders key in play
    for k, keys in pairs(self.key) do
        if keys.inPlay == true then
            keys:render()
        end
    end
    -- renders keyblock powerup when in play
    for k, keyblockpower in pairs(self.keypowers) do
        if keyblockpower.inPlay == true then
            keyblockpower:render()
        end
    end

    
    
    self.paddle:render()


    renderScore(self.score)
    renderHealth(self.health)
    renderBallsInPlay(self.ballsInPlay)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay and brick.isKey == false then
            return false
        end 
    end

    return true
end