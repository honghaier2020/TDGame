require "Cocos2d"
require "Cocos2dConstants"
require "Lua/GameScene"
-- cclog
cclog = function(...)
    print(string.format(...))
end
-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
end
--启动游戏
local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
	cclog("启动游戏")
    cc.Director:getInstance():runWithScene(GameScene.createGameScene())
	
	
end

xpcall(main, __G__TRACKBACK__)
