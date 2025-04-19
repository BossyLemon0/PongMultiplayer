Logger = Class{}



function Logger:init()
    -- Log levels
    self.Levels = {
        DEBUG = 1,
        INFO = 2,
        WARN = 3,
        ERROR = 4
    }

    self.currentLevel = self.Levels.INFO

    -- Colors for console output
    self.Colors = {
        DEBUG = "\27[36m", -- Cyan
        INFO = "\27[32m",  -- Green
        WARN = "\27[33m",  -- Yellow
        ERROR = "\27[31m", -- Red
        RESET = "\27[0m"   -- Reset
}
end


-- Get current timestamp
function Logger:getTimestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end


-- Format message with optional data
function Logger:formatMessage(level, message, data)
    local timestamp = self:getTimestamp()
    local levelName = ""
    for name, value in pairs(self.Levels) do
        if value == level then
            levelName = name
            break
        end
    end

    local logEntry = {
        timestamp = timestamp,
        level = levelName,
        message = message
    }

    if data then
        logEntry.data = data
    end

    return logEntry
end

-- Log function
function Logger:log(level, message, data)
    if level >= self.currentLevel then
        local logEntry = self:formatMessage(level, message, data)
        
        -- Console output with colors
        local color = self.Colors[logEntry.level] or self.Colors.RESET
        print(string.format("%s[%s] %s: %s%s", 
            color,
            logEntry.timestamp,
            logEntry.level,
            logEntry.message,
            self.Colors.RESET
        ))
        
        -- If there's data, print it as JSON
        if data then
            print(string.format("            %sData: %s%s", 
                color,
                Json:encode(data), -- Encode the data as JSON
                self.Colors.RESET
            ))
        end
    end
end

-- Convenience methods
function Logger:debug(message, data)
    self:log(self.Levels.DEBUG, message, data)
end

function Logger:info(message, data)
    self:log(self.Levels.INFO, message, data)
end

function Logger:warn(message, data)
    self:log(self.Levels.WARN, message, data)
end

function Logger:error(message, data)
    self:log(self.Levels.ERROR, message, data)
end

-- Set log level
function Logger:setLevel(level)
    self.currentLevel = level
end