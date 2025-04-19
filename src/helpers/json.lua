Json = Class{}

--[[
    Encodes a Lua value to a JSON string.
    Supports tables, strings, numbers, booleans, and nil.
]]
function Json:encode(value)
    local t = type(value)
    if t == "table" then
        local r = {}
        for k, v in pairs(value) do
            local key = type(k) == "number" and "[" .. k .. "]" or k
            r[#r + 1] = key .. ":" .. self:encode(v)
        end
        return "{" .. table.concat(r, ",") .. "}"
    elseif t == "string" then
        return '"' .. value .. '"'
    elseif t == "number" then
        return tostring(value)
    elseif t == "boolean" then
        return value and "true" or "false"
    elseif t == "nil" then
        return "null"
    else
        error("unsupported type: " .. t)
    end
end
