

PowerUp = Class{}

function PowerUp:init(x, y, brickNum)
    self.x = x

    -- y is placed a little above the bottom edge of the screen
    self.y = y

    -- start us off with no velocity
    self.dx = 0
    self.dy = 0

    -- starting dimensions
    self.width = 16
    self.height = 16
    self.speed = PUSPEED
    self.power = 9
    self.inPlay = false
    self.brick = brickNum
end

function PowerUp:update(dt) 
    self.dy = PUSPEED
    self.y = self.y + self.dy * dt

end

function PowerUp:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function PowerUp:render() 
    if self.inPlay == true then
        love.graphics.draw(gTextures['main'], gFrames['powers'][self.power],
        self.x, self.y)
    end
end