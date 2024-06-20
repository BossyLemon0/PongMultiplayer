--[[
    GD50
    Breakout Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

-- global patterns (used to make the entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1           -- all colors the same in this row
ALTERNATE = 2       -- alternate colors
SKIP = 3            -- skip every other block
NONE = 4            -- no blocks this row

LevelMaker = Class{}

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]
function LevelMaker.createMap(level)
    local bricks = {}
    local powers = {}
    local keypowers = {}
    local key = {}
    local keyPowerUp = -1

    -- randomly choose the number of rows
    local numRows = math.random(1, 5)

    -- randomly choose the number of columns, ensuring odd
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    -- highest possible spawned brick color in this level; ensure we
    -- don't go above 3
    local highestTier = math.min(3, math.floor(level / 5))

    -- highest color of the highest tier, no higher than 5
    local highestColor = math.min(5, level % 5 + 3)

    --how many powerUps per level
    local totPow = math.random(1,4)

    local keynum = 0 

    local hasKey = false

    --choose if the level is going to have a key brick
    if level > 1 and level < 5 then
        keynum = math.random(1,10)
    elseif level >= 5 and level < 10 then
        keynum = math.random(1,6)
    elseif level >= 10 and level < 15 then
        keynum = math.random(1,4)
    elseif level >= 15 and level < 20 then
        keynum = math.random(1,3)
    elseif level >= 20 then
        keynum = math.random(1,2)
        --testing purposes
        keynum = 1
    end

    if keynum == 1 then
        hasKey = true
    end

    -- lay out bricks such that they touch each other and fill the space
    for y = 1, numRows do
        -- whether we want to enable skipping for this row
        local skipPattern = math.random(1, 2) == 1 and true or false

        -- whether we want to enable alternating colors for this row
        local alternatePattern = math.random(1, 2) == 1 and true or false
        
        -- choose two colors to alternate between
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)
        
        -- used only when we want to skip a block, for skip pattern
        local skipFlag = math.random(2) == 1 and true or false

        -- used only when we want to alternate a block, for alternate pattern
        local alternateFlag = math.random(2) == 1 and true or false

        -- solid color we'll use if we're not skipping or alternating
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do
            -- if skipping is turned on and we're on a skip iteration...
            if skipPattern and skipFlag then
                -- turn skipping off for the next iteration
                skipFlag = not skipFlag

                -- Lua doesn't have a continue statement, so this is the workaround
                goto continue
            else
                -- flip the flag to true on an iteration we don't use it
                skipFlag = not skipFlag
            end


                -- Access gTextures here
                b = Brick(
                    -- x-coordinate
                    (x-1)                   -- decrement x by 1 because tables are 1-indexed, coords are 0
                    * 32                    -- multiply by 32, the brick width
                    + 8                     -- the screen should have 8 pixels of padding; we can fit 13 cols + 16 pixels total
                    + (13 - numCols) * 16,  -- left-side padding for when there are fewer than 13 columns
                    
                    -- y-coordinate
                    y * 16                  -- just use y * 16, since we need top padding anyway
                )


            -- if we're alternating, figure out which color/tier we're on
            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            -- if not alternating and we made it here, use the solid color/tier
            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end 

            table.insert(bricks, b)

            -- Lua's version of the 'continue' statement
            ::continue::
        end
    end 

    --flag keyBrick and set powerUps positon
    if hasKey == true then
        local bricki = math.random(1, #bricks)
        bricks[bricki].isKey = true
        keyPowerUp = math.random(7,8)
        local keypow = PowerUp(bricks[bricki].x,bricks[bricki].y, bricki)
        keypow.power = keyPowerUp
        table.insert(keypowers, keypow)
    end

    --choose random bricks based on how many powerups in level
    local powBricks = {}
    --check if table has value
    function tableContains(table, value)
        for _, v in pairs(table) do
            if v == value then
                return true
            end
        end
        return false
    end

    --pick random bricks to have powerups
    while #powBricks < totPow do 
        local genBrick = math.random(1,#bricks)
        if tableContains(powBricks, genBrick) == false then
            table.insert(powBricks, genBrick)
        end
    end

    --flag powBricks and set powerUps positon
    for i = 1, #powBricks do
        bricks[powBricks[i]].hasPower = true
        bricks[powBricks[i]].powNum = i
        table.insert(powers,PowerUp(bricks[i].x,bricks[i].y, powBricks[i]))
    end

    table.insert(key, PowerUp(math.random(1,VIRTUAL_WIDTH - 16), math.random(1,32)))


    -- in the event we didn't generate any bricks, try again
    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks, powers, keypowers, hasKey, key
    end
end