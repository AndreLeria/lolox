return function(name, values)
  local enum, meta = {}, {}
  for _, key in ipairs(values) do
    local symbol = setmetatable({}, {
      __tostring = function() return name .. ":" .. key end
    })
    enum[key] = symbol
    meta[symbol] = key
  end

  function enum.isValid(value) return meta[value] ~= nil end
  function enum.toString(value) return meta[value] or "UNKNOWN" end

  return setmetatable(enum, {
    __newindex = function() error("Enum is immutable") end,
    __metatable = false
  })
end

