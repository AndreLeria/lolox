---@class Scanner
---@field source string
---@field reportError fun(line: number, message: string): nil
---@field start number
---@field current number
---@field line number
---@field tokens Token[]
---@field cases TokenType[]
local Scanner = {}

local Token = require "Token"
local TokenType = require "TokenType"


---@param source string
---@param reportError fun(line: number, message: string): nil
function Scanner:new(source, reportError)
  local instance = {
    source = source,
    reportError = reportError,

    start = 1,
    current = 1,
    line = 1,
    tokens = {},

    cases = {
      ["("] = TokenType.LEFT_PAREN,
      [")"] = TokenType.RIGHT_PAREN,
      ["{"] = TokenType.LEFT_BRACE,
      ["}"] = TokenType.RIGHT_BRACE,
      [","] = TokenType.COMMA,
      ["."] = TokenType.DOT,
      ["-"] = TokenType.MINUS,
      ["+"] = TokenType.PLUS,
      [";"] = TokenType.SEMICOLON,
      ["*"] = TokenType.STAR,
    },
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end


function Scanner:isAtEnd()
  return self.current >= #self.source
end


function Scanner:advance()
  local currentChar = self.source[self.current]
  self.current = self.current + 1
  return currentChar
end


function Scanner:addToken(type, literal)
  local text = string.sub(self.source, self.start, self.current)
  self.tokens[#self.tokens+1] = Token:new(type, text, literal, self.line)
end


function Scanner:scanToken()
  ---@type string
  local c = self:advance()
  local case = self.cases[c]
  if case then
    self:addToken(case)
  else
    self.reportError(self.line, "Unexpected character: " .. c)
  end
end


function Scanner:scanTokens()
  while not self:isAtEnd() do
    self.start = self.current
    self:scanToken()
  end
  self.tokens[#self.tokens+1] = Token:new(TokenType.EOF, "", nil, self.line)
  return self.tokens
end


return Scanner
