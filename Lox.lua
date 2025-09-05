local Scanner = require "Scanner"

local hadError = false

---@param line number
---@param where string
---@param message string
local function report(line, where, message)
  print("[line " .. line .. "] Error" .. where .. ": " .. message)
  hadError = true
end

---@param line number
---@param message string
local function reportError(line, message)
  report(line, "", message)
end

---@param contents string
local function run(contents)
  local scanner = Scanner:new(contents, reportError)
  local tokens = scanner:scanTokens()
  for _, token in ipairs(tokens) do
    print(token)
  end
end

---@param path string
local function runFile(path)
  local file = io.open(path, "r")
  if file == nil then
    return os.exit(64)
  end
  local contents = file:read("*a")
  run(contents)
  if hadError then return os.exit(65) end
end

local function runPrompt()
  print "Lolox REPL. Press ^D to exit."
  while true do
    io.write("> ")
    local line = io.read("*l")
    if line == nil then print "" break end
    run(line)
    hadError = false
  end
end

if (#arg > 1) then
  print("Usage: lolox [script]")
  return os.exit(64)
elseif (#arg == 1) then
  runFile(arg[1])
else
  runPrompt()
end
