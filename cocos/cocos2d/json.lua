local require = _G.require

module("json")

local json_new = require("cocos.cocos2d.json_new")

function encode(v)
    return json_new.encode(v)
end

function decode(str)
  return json_new.decode(str)
end
