
require("Lua/Monster")
require("Lua/Effect")
require("Lua/Tower")
module("GameScene",package.seeall) 
--怪物运行路径数组
local PointArray = {}
--怪物数组
local MonsterArrays = {}
--效果数组
local EffectArrays = {}
--炮塔数组
local TowerArrays = {}
local GameMap=nil
local GameUI=nil 
local CurSkillEffect=nil 
local CurTower=nil 
local GameScene=nil
--增加怪物
 function AddMonster()
     local monster = Monster:create()
	 monster:initMonster(PointArray)
	  if GameMap ~= nil then
	      if monster.spineboy ~= nil then
		    GameMap:addChild(monster.spineboy)
		end
	  end
	  table.insert(MonsterArrays,monster)
 end  
--创建地图物件方法测试
 function createMapObject(map,group,tag)
        local  objects = group:getObjects()
		local  dict    = nil
		local  i       = 0
		local  len     = table.getn(objects)
		 for i = 0, len-1, 1 do
			  dict = objects[i + 1]
			 if dict == nil then
			   break
			end
			--local key = "x"
			local x = dict["x"]
			--key = "y"
			local y = dict["y"]
			if tag == 0 then
			  local emitter = cc.ParticleFire:create()
              emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage("res/fire.png"))
              emitter:setPosition(x, y)
              emitter:setScale(0.3)
              emitter:setPositionType(cc.POSITION_TYPE_GROUPED)
			  map:addChild(emitter)
			  cclog("创建效果成功,位置: %0.2f, %0.2f", x,y)
			  	      
		   elseif tag == 1 then
				    local spineboy =sp.SkeletonAnimation:create("res/spine/spineboy.json", "res/spine/spineboy.atlas", 0.8)
				    if spineboy ~= nil then
					      spineboy:setAnimation(0, 'walk', true)
						  spineboy:setPosition(x,y)
						  map:addChild(spineboy)
						 cclog("创建动画成功: %0.2f, %0.2f", x,y)
					 end
			elseif tag == 2 then
		           
				       local pointdict    = nil
				       local polyline_points = dict["polylinePoints"]
		               local  len     = table.getn(polyline_points)
					    for i = 0, len-1, 1 do
			               pointdict = polyline_points[i + 1]
			               if pointdict ~= nil then
						      local Pointx = x+pointdict["x"]
			                  local Pointy = y-pointdict["y"]
							  table.insert(PointArray,cc.p(Pointx,Pointy))
						       cclog("创建路径点成功: %d %d, %d", i,Pointx,Pointy)
			               end
						end	
				--创建炮塔
            elseif tag ==3 then
		         local tower = Tower:create()
			     tower:initTower(map,x,y)
	             table.insert(TowerArrays,tower) 				
		    end
	 end
end

 local function createGameUI()
      local gameUI = ccs.GUIReader:getInstance():widgetFromJsonFile("res/GameSceneUI/NewUI_1.ExportJson");
	  if gameUI ~= nil then
	      
		    local skillEffect = Effect:create()
	           skillEffect:initEffect(gameUI,200,100)
	        if skillEffect ~= nil then
			    table.insert(EffectArrays,skillEffect)
	        end	 
	   gameUI:setPosition(0, 0)
	  cclog("加载游戏场景界面成功")
	 end
	  GameUI=gameUI
	  return gameUI
  end
 -- 创建地图测试
    local function createGameMap()
     local map = cc.TMXTiledMap:create("res/Game.tmx")
     local effectGroup = map:getObjectGroup("场景效果层")
	    if effectGroup ~= nil then
	     createMapObject(map,effectGroup,0)
	    end
	local SpineAnimationGroup = map:getObjectGroup("场景骨骼动画层")
	    if SpineAnimationGroup ~= nil then
	     createMapObject(map,SpineAnimationGroup,1)
	    end
	local PathGroup = map:getObjectGroup("场景怪物路线")
	    if PathGroup ~= nil then
		 cclog("怪物路线解析进行")
	     createMapObject(map,PathGroup,2)
	    end
	local   towerLayer = map:getObjectGroup("游戏炮塔层")
	    if towerLayer ~= nil then
	      createMapObject(map,towerLayer,3);
	    end
     map:setPosition(0, 0)
     local touchBeginPoint = nil
     local function onTouchBegan(touch, event)
            local location = touch:getLocation()
            --cclog("触摸开始: %0.2f, %0.2f", location.x, location.y)
            touchBeginPoint = {x = location.x, y = location.y}
            -- CCTOUCHBEGAN event must return true
			--检测触摸炮塔
			local  len     = table.getn(TowerArrays)
			local cx, cy = map:getPosition()
			cclog("%d", len)
		    for i = 0, len-1, 1 do
			    if   TowerArrays[i+1]:containsTouchLocation(location.x-cx ,location.y-cy) then 
			        cclog("触摸到塔了")
					CurSkillTower=TowerArrays[i+1]
					
			    end
		    end
			local  len   = table.getn(EffectArrays)
			cclog("%d", len)
		    for i = 0, len-1, 1 do
			    if   EffectArrays[i+1]:containsTouchLocation(location.x ,location.y) then 
			          cclog("触摸到技能图标")
					  CurSkillEffect=EffectArrays[i+1]
					  local magicspr=GameScene:getChildByTag(100)
					   if magicspr ~= nil then
					      magicspr:setVisible(true);
						  magicspr:setPosition(location.x ,location.y)
					   else 
					       local texture = cc.Director:getInstance():getTextureCache():addImage("res/MagicMatrix.png")
		                    magicspr =cc.Sprite:createWithTexture(texture)
		                    magicspr:setPosition(location.x ,location.y)
						    magicspr:setAnchorPoint(cc.p(0.5,0.5));
			                magicspr:setOpacity(190);
			                GameScene:addChild(magicspr,10,100);
							magicspr:setVisible(true);
					   end
			    end
		    end
            return true
        end

     local function onTouchMoved(touch, event)
            local location = touch:getLocation()
            cclog("触摸移动: %0.2f, %0.2f", location.x, location.y)
            if touchBeginPoint then
                local cx, cy = map:getPosition()
				   if CurSkillEffect ~= nil then
				        local magicspr=GameScene:getChildByTag(100)
					    if magicspr ~= nil then
					       magicspr:setPosition(location)
					    end 
						
				   elseif CurTower ~= nil then
				       cclog("塔建造中") 
	               else 
				      map:setPosition(cx + location.x - touchBeginPoint.x,
                                       cy + location.y - touchBeginPoint.y)
	               end
                touchBeginPoint = {x = location.x, y = location.y}
            end
        end

       local function onTouchEnded(touch, event)
            local location = touch:getLocation()
			 if CurSkillEffect ~= nil then
				     cclog("释放技能") 
					 
					  local magicspr=GameScene:getChildByTag(100)
					    if magicspr ~= nil then
					       magicspr:setVisible(false)
					    end 
					CurSkillEffect:PlaySkillEffect(GameScene,location.x, location.y);
				 CurSkillEffect=nil
			  elseif CurSkillTower ~= nil then
					CurSkillTower:buildTower()
					CurSkillTower=nil
			
			 end
            --cclog("触摸结束: %0.2f, %0.2f", location.x, location.y)
            touchBeginPoint = nil
        end
        GameMap=map
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = map:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, map)
		 cc.Director:getInstance():getScheduler():scheduleScriptFunc(updae, 0, false)
		return map
    end
	
function updae()

  
end	
--创建
function createGameScene()
	local gameScene = cc.Scene:create()
	gameScene:addChild(createGameMap())
	cclog("创建游戏地图成功")
	gameScene:addChild(createGameUI())
	cclog("创建游戏界面成功")
	AddMonster()
	cclog("创建游戏怪物成功")
	GameScene=gameScene
	return gameScene
end