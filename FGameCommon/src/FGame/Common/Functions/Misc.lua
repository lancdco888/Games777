


-- @brief try
-- @example:
--  try {
--      function()
--          local s = "a"
--          print(s + 1)
--      end,
--      catch = function(err)
--          print("catch err:", err)
--      end
--  }
function try (params)
    local tryBlock = params[1]
    local catch    = params.catch

    local status, err = xpcall(tryBlock, __G__TRACKBACK__ or function(msg) return debug.traceback(msg, 3) end)
    if not status then
        if type(catch) == "function" then catch(err) end
    end
end


-- @brief vec2
function vec2(_x, _y)
    _x = _x or 0
    _y = _y or 0

    return {x = _x, y = _y}
end


-- @brief vec3
function vec3(_x, _y, _z)
    _x = _x or 0
    _y = _y or 0
    _z = _z or 0
    
    return {x = _x, y = _y, z = _z}
end

-- @brief margin
function margin(_left, _right, _top, _bottom)
    _left   = _left or 0
    _right  = _right or 0
    _top    = _top or 0
    _bottom = _bottom or 0
    
    return {left = _left, right = _right, top = _top, bottom = _bottom}
end

function ObjectRetain(obj)
    if obj == nil then return end
    if RUNTIME_IN_COCOS then obj:retain() end
end

function ObjectRelease(obj)
    if obj == nil then return end
    if RUNTIME_IN_COCOS then obj:release() end
end