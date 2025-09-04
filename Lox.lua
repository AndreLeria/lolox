---@param contents string
local function run(contents)
end

---@param path string
local function runFile(path)
  local file = io.open(path, "r")
  if (file == nil) then
    return os.exit(64)
  end
  local contents = file:read("*a")
  run(contents)
end

local function runPrompt()
  print "Lolox REPL. Press ^D to exit."
  while true do
    io.write("> ")
    local line = io.read("*l")
    if (line == nil) then print "" break end
    run(line)
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
