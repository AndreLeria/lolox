---@class Scanner
---@field source string
---@field reportError fun(line: number, message: string): nil
---@field start number
---@field current number
---@field line number
---@field tokens Token[]
---@field cases table<string, TokenType | function>
---@field keywords table<string, TokenType>
local Scanner = {}

local Token = require "Token"
local TokenType = require "TokenType"


---@param source string
---@param reportError fun(line: number, message: string): nil
function Scanner:new(source, reportError)
  local this = {
    source = source,
    reportError = reportError,

    start = 1,
    current = 1,
    line = 1,
    tokens = {},
  }

  this.cases = {
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
    ["!"] = function() this:addToken(this:match("=") and TokenType.BANG_EQUAL or TokenType.BANG) end,
    ["="] = function() this:addToken(this:match("=") and TokenType.EQUAL_EQUAL or TokenType.EQUAL) end,
    ["<"] = function() this:addToken(this:match("=") and TokenType.LESS_EQUAL or TokenType.LESS) end,
    [">"] = function() this:addToken(this:match("=") and TokenType.GREATER_EQUAL or TokenType.GREATER) end,
    ["/"] = function()
      if this:match('/') then
        while this:peek() ~= "\n" and not this:isAtEnd() do this:advance() end
      else
        this:addToken(TokenType.SLASH)
      end
    end,
    [" "] = function() end,
    ["\r"] = function() end,
    ["\t"] = function() end,
    ["\n"] = function() this.line = this.line + 1 end,
    ['"'] = function() this:handleString() end,
  }

  setmetatable(this.cases, {
    __index = function(_t, key)
      if this:isDigit(key) then
        return function() this:handleNumber() end
      elseif this:isAlpha(key) then
        return function() this:handleIdentifier() end
      else
        this.reportError(this.line, "Unexpected character: " .. key)
      end
    end
  })

  this.keywords = {
    ["and"] = TokenType.AND,
    ["class"] = TokenType.CLASS,
    ["else"] = TokenType.ELSE,
    ["false"] = TokenType.FALSE,
    ["for"] = TokenType.FOR,
    ["fun"] = TokenType.FUN,
    ["if"] = TokenType.IF,
    ["nil"] = TokenType.NIL,
    ["or"] = TokenType.OR,
    ["print"] = TokenType.PRINT,
    ["return"] = TokenType.RETURN,
    ["super"] = TokenType.SUPER,
    ["this"] = TokenType.THIS,
    ["true"] = TokenType.TRUE,
    ["var"] = TokenType.VAR,
    ["while"] = TokenType.WHILE,
  }

  setmetatable(this, self)
  self.__index = self
  return this
end


function Scanner:isAtEnd()
  return self.current >= #self.source
end


function Scanner:advance()
  local currentChar = self.source[self.current]
  self.current = self.current + 1
  return currentChar
end


---@param expected string
function Scanner:match(expected)
  if self:isAtEnd() or self.source[self.current] ~= expected then return false end
  self.current = self.current + 1
  return true
end


function Scanner:peek()
  if self:isAtEnd() then return "\0"
  else return self.source[self.current]
  end
end


function Scanner:peekNext()
  if self.current + 1 >= #self.source then return "\0" end
  return self.source[self.current + 1]
end


---@param key string
function Scanner:isDigit(key)
  return key:match("^%d$")
end


---@param c string
function Scanner:isAlpha(c)
  return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_'
end


---@param c string
function Scanner:isAlphaNumeric(c)
  return self:isAlpha(c) or self:isDigit(c)
end


function Scanner:addToken(type, literal)
  local text = string.sub(self.source, self.start, self.current)
  self.tokens[#self.tokens+1] = Token:new(type, text, literal, self.line)
end


function Scanner:scanToken()
  ---@type string
  local c = self:advance()
  local case = self.cases[c]
  if case == nil then
    self.reportError(self.line, "Unexpected character: " .. c)
  elseif type(case) == "function" then
    case()
  else
    self:addToken(case)
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


function Scanner:handleString()
  while self:peek() ~= '"' and not self:isAtEnd() do
    if self:peek() == "\n" then
      self.line = self.line + 1
    end
    self:advance()
  end
  if self:isAtEnd() then
    self.reportError(self.line, "Unterminated string.")
    return
  end
  self:advance()
  local value = string.sub(self.source, self.start + 1, self.current - 1)
  self:addToken(TokenType.STRING, value)
end


function Scanner:handleNumber()
  while self:isDigit(self:peek()) do self:advance() end
  if self:peek() == '.' and self:isDigit(self:peekNext()) then
    self:advance()
    while self:isDigit(self:peek()) do self:advance() end
  end
  self:addToken(TokenType.NUMBER, tonumber(string.sub(self.source, self.start, self.current)))
end


function Scanner:handleIdentifier()
  while self:isAlphaNumeric(self:peek()) do self:advance() end
  local text = string.sub(self.source, self.start, self.current)
  local type = self.keywords[text] or TokenType.IDENTIFIER
  self:addToken(type)
end


return Scanner
