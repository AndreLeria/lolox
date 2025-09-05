---@class Token
---@field type TokenType
---@field lexeme string
---@field literal any
---@field line number
local Token = {}

---@param type TokenType
---@param lexeme string
---@param literal any
---@param line number
function Token:new(type, lexeme, literal, line)
  local instance = {
    type = type,
    lexeme = lexeme,
    literal = literal,
    line = line,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Token:toString()
  return self.type .. " " .. self.lexeme .. " " .. self.literal
end

return Token
