
require "Lua/GamePlayer" 
require "Lua/SoldiersUI" 
module("GameScene",package.seeall) 
local CurSkillEffect=nil 
local CurSelectTower=nil 
local touchBeginPoint=nil
local touchBeginDown=false
local winSize = cc.Director:getInstance():getWinSize()
local mapsize =nil
local MoveMap=true
local buildTimer=10
local BuildTimerEntry = nil
local SelectTowerEffect=nil
--游戏状态   0  建造状态  1怪物进攻战斗序列编辑状态  2战斗状态 3战斗结束状态
local GameState=0
local GameMap=nil 
--游戏主界面
local GameMainUI=nil
--游戏主场景
local GameMainScene=nil 
--游戏选择怪物战斗序列UI
local GameSoldiersUI=nil 

WinSize = cc.Director:getInstance():getWinSize()
local Play1Hp=20
local Play2Hp=20
local play1HpUI=nil
local play2HpUI=nil
--效果数组
local EffectArray = {}
 --炮塔数组
local BuildTowerPosArray = {}  
--怪物运行路径数组
local PointArray = {}   
 --选择箭塔的类型       
local selectBulidTowType=0 
--选择箭塔的位置     
local selectBulidTowPos=cc.p(0,0) 
--子弹数组
local  GamePlayer1=nil   --游戏玩家1
local  GamePlayer2=nil   --游戏玩家2
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
		        -- local tower = TowerObject:create()
				 --tower:init(map)
			      --tower:initTower(x,y)
				  local initTowerTexture = cc.Director:getInstance():getTextureCache():addImage("res/battle_0003s_0001_skill-resource-counter.png")
	              local initTower =cc.Sprite:createWithTexture(initTowerTexture)
				  initTower:setPosition(x, y)
				  map:addChild(initTower)
	              table.insert(BuildTowerPosArray,initTower) 				
		    end
	 end
end
--显示时间
function ShowTimer()
			buildTimer=buildTimer-1
			local BuildTimeText = GameMainUI:getChildByTag(107)
			local BuildTime = BuildTimeText:getChildByTag(108)
			 if BuildTime ~= nil then
				 BuildTime:setStringValue(string.format("%d",buildTimer))
				if buildTimer==0 then
					  SetGameState(1)
				end	
             end					
end 	
function  SelectBuildTowerType(sender, eventType) 
		  if eventType == ccui.TouchEventType.ended then
				  if SelectTowerEffect ~= nil then
				     SelectTowerEffect:removeOblect()
				     SelectTowerEffect:PlaySkillEffect( sender:getWorldPosition().x,sender:getWorldPosition().y-sender:getSize().height/2,true)
					 if "金系"==sender:getName() then
					    selectBulidTowType=1
						 cclog("选择金系塔")
					 elseif "木系"==sender:getName() then
					    selectBulidTowType=2
						 cclog("选择木系塔")
					 elseif "水系"==sender:getName() then
					    selectBulidTowType=3
						 cclog("选择水系塔")
					 elseif "火系"==sender:getName() then
					    selectBulidTowType=4
						 cclog("选择火系塔")
					 else
					     selectBulidTowType=5
						 cclog("选择土系塔")
					 end
					 
				  end
		   end  
	 end
--确定建造塔
 function  StartBuildTower(sender, eventType) 
		  if eventType == ccui.TouchEventType.ended then
			 if selectBulidTowType ~= 0 then
				 GamePlayer1:buildTower(TowerConfig[1],selectBulidTowPos)
                 removeUI(304)	
                 if SelectTowerEffect ~= nil then
			       SelectTowerEffect:removeOblect()
				   SelectTowerEffect=nil
				    cclog("移除选择塔效果") 
			     end				 
				 selectBulidTowType	=0			 
			 end    
		   end  
 end
--检测触摸炮塔
function TouchTower(touchpos)
      
	 --当前游戏状态不是建造状态
	 if GameState~=0 then
	    return
	 end
     local cx, cy = GameMap:getPosition()
	   --检测触摸炮塔
				local  len     = table.getn(BuildTowerPosArray)
				for i = 0, len-1, 1 do
				    local rect = BuildTowerPosArray[i+1]:getBoundingBox()
					local buildTowerPosX, buildTowerPosY= BuildTowerPosArray[i+1]:getPosition()
					if  cc.rectContainsPoint(rect,cc.p(touchpos.x-cx,touchpos.y-cy)) then 
						ShowBuildTowerUI(cc.p(buildTowerPosX+cx,buildTowerPosY+cy))
						selectBulidTowPos=cc.p(buildTowerPosX,buildTowerPosY)
						return 
					end
				end
end
function TouchSkillEffect(touchpos)
   
    	     -- local  len   = table.getn(EffectArray)
				-- for i = 0, len-1, 1 do
					-- if   EffectArray[i+1]:containsTouchLocation(touchpos.x ,touchpos.y) then 
					     -- if  GameState~=2 then
						    -- MoveMap=false
                            -- return 
                         -- end
						  -- cclog("触摸到技能图标")
						  -- CurSkillEffect=EffectArrays[i+1]
						  -- local magicspr=GameMap:getChildByTag(100)
						   -- if magicspr ~= nil then
							  -- magicspr:setVisible(true);
							  -- magicspr:setPosition(location.x-cx ,location.y-cy)
						   -- else 
							   -- local texture = cc.Director:getInstance():getTextureCache():addImage("res/MagicMatrix.png")
								-- magicspr =cc.Sprite:createWithTexture(texture)
								-- magicspr:setPosition(location.x-cx ,location.y-cy)
								-- magicspr:setAnchorPoint(cc.p(0.5,0.5));
								-- magicspr:setOpacity(190);
								-- GameMap:addChild(magicspr,10,100);
								-- magicspr:setVisible(true);
						   -- end
						   -- return
					-- end
				-- end
end
--触摸按下
function onTouchBegan(touch, event)

				local location = touch:getLocation()
				touchBeginDown=true
				touchBeginPoint = location
				TouchSkillEffect(location)
				return true
			end
function onTouchMoved(touch, event)
				local location = touch:getLocation()
				touchBeginDown=false
				if touchBeginPoint then
					local cx, cy = GameMap:getPosition()
					   -- if CurSkillEffect ~= nil then
							-- local magicspr=GameMap:getChildByTag(100)
							-- if magicspr ~= nil then
							   -- magicspr:setPosition(location.x-cx ,location.y-cy)
							-- end 	
					   -- else 
						  if MoveMap == true then
							   local moveMapX=cx + location.x - touchBeginPoint.x
							  -- moveMapX = math.min(moveMapX, 0)
							   --moveMapX = math.max(moveMapX, -mapsize.width+winSize.width)
							   local moveMapY=cy + location.y - touchBeginPoint.y
							  -- moveMapY = math.min(0, moveMapY)
							  -- moveMapY = math.max(-mapsize.height+winSize.height,moveMapY)
							   GameMap:setPosition(moveMapX,moveMapY)
							end
						 
					   --end
					touchBeginPoint = location
				end
			end
function onTouchEnded(touch, event)
				local location = touch:getLocation()
				  touchBeginPoint = nil	
				  if  touchBeginDown ==true then
				     removeUI(302)
				     removeUI(303)
					 removeUI(304)
					 TouchTower(location)
				  else 
					   -- if CurSkillEffect ~= nil then
						 -- -- cclog("释放技能") 
						   -- local magicspr=GameMap:getChildByTag(100)
							 -- if magicspr ~= nil then
							   -- magicspr:setVisible(false)
							 -- end 
						 -- CurSkillEffect:PlaySkillEffect(GameMap,location.x, location.y);
						 -- CurSkillEffect=nil
					  -- end
				 end       
	end
-- 创建地图测试
function createGameMap()
		 GameMap = cc.TMXTiledMap:create("res/Game.tmx")
		
		 mapsize = GameMap:getContentSize()
		 local effectGroup = GameMap:getObjectGroup("场景效果层")
			if effectGroup ~= nil then
			 createMapObject(GameMap,effectGroup,0)
			end
		local SpineAnimationGroup = GameMap:getObjectGroup("场景骨骼动画层")
			if SpineAnimationGroup ~= nil then
			 createMapObject(GameMap,SpineAnimationGroup,1)
			end
		local PathGroup = GameMap:getObjectGroup("场景怪物路线")
			if PathGroup ~= nil then
			 cclog("怪物路线解析进行")
			 createMapObject(GameMap,PathGroup,2)
			end
		local   towerLayer = GameMap:getObjectGroup("游戏炮塔层")
			if towerLayer ~= nil then
			  createMapObject(GameMap,towerLayer,3);
			end
		 GameMap:setPosition(0, 0)
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = GameMap:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, GameMap)
		
		GameMainScene:addChild(GameMap)
    end
					   
         
	   
		-- bulletNeedToDeleteArray={}
--界面上显示对战玩家信息数据
function updaePlayerInfoUI()
       local play1NameBK = GameMainUI:getChildByTag(22)
	   local play1Name = play1NameBK:getChildByTag(23)
	   if play1Name ~= nil then
			play1Name:setText("快乐王子")  			 
	   end 
	   local play2NameBK = GameMainUI:getChildByTag(15)
	   local play2Name = play2NameBK:getChildByTag(24)
	   if play2Name ~= nil then
			play2Name:setText("黑暗幽灵")  			 
	   end 
	   local play1HpBK = GameMainUI:getChildByTag(16)
	   play1HpUI = play1HpBK:getChildByTag(20)
	   if play1HpUI ~= nil then
			play1HpUI:setStringValue("20")  			 
	   end 
	   local play2HpBK = GameMainUI:getChildByTag(17)
	   play2HpUI = play2HpBK:getChildByTag(21)
	   if play2HpUI ~= nil then
			play2HpUI:setStringValue("20")  			 
	   end
	   --钻石
	   local diamondBK = GameMainUI:getChildByTag(13)
	   local diamondNum = diamondBK:getChildByTag(25)
	   if diamondNum ~= nil then
			diamondNum:setStringValue("100")  			 
	   end
	   --金币
	   local goldBK = GameMainUI:getChildByTag(14)
	   local goldNum = goldBK:getChildByTag(26)
	   if goldNum ~= nil then
			goldNum:setStringValue("1000")  			 
	   end
end
--更新玩家血条
function updaePlayerHpUI()
		play1HpUI:setStringValue(string.format("%d",GamePlayer1.Hp))  
		play2HpUI:setStringValue(string.format("%d",GamePlayer2.Hp)) 
 end
 --显示建造塔界面
function  ShowBuildTowerUI(pos) 
			local buildTowerUI = ccs.GUIReader:getInstance():widgetFromJsonFile("res/GameBuildTowerUI/GameBuildTowerUI.json")
			local TowerIconRoot = buildTowerUI:getChildByTag(4)
			local TowerIcon1 = TowerIconRoot:getChildByTag(50)
			if TowerIcon1 ~= nil then
				 TowerIcon1:addTouchEventListener(SelectBuildTowerType) 
			end
            local TowerIcon2 = TowerIconRoot:getChildByTag(53)
			if TowerIcon2 ~= nil then
				 TowerIcon2:addTouchEventListener(SelectBuildTowerType)				 
			end 
			local TowerIcon3 = TowerIconRoot:getChildByTag(55)
			if TowerIcon3 ~= nil then
				 TowerIcon3:addTouchEventListener(SelectBuildTowerType)				 
			end 
			local TowerIcon4 = TowerIconRoot:getChildByTag(58)
			if TowerIcon4 ~= nil then
				 TowerIcon4:addTouchEventListener(SelectBuildTowerType)				 
			end 
			local TowerIcon5 = TowerIconRoot:getChildByTag(60)
			if TowerIcon5 ~= nil then
				 TowerIcon5:addTouchEventListener(SelectBuildTowerType)				 
			end 
			--确定按钮
			local okButton = TowerIconRoot:getChildByTag(48)
			if okButton ~= nil then
				 okButton:addTouchEventListener(StartBuildTower)  			 
			end 
			buildTowerUI:setPosition(pos)
			GameMainScene:addChild(buildTowerUI,0,304)
			if SelectTowerEffect ~= nil then
			     SelectTowerEffect:removeOblect()
			end
			SelectTowerEffect=nil
			SelectTowerEffect = EffectObject:create()
	        SelectTowerEffect:init(GameMainScene)
			SelectBuildTowerType(TowerIcon1,ccui.TouchEventType.ended)
			--MoveMap=false
end
--移除界面
function removeUI(tag)
      local gameUI = GameMainScene:getChildByTag(tag)
		 if gameUI ~= nil then
		      if SelectTowerEffect ~= nil then
			       SelectTowerEffect:removeOblect()
				   SelectTowerEffect=nil
				    cclog("移除选择塔效果") 
			  end
			 GameMainScene:removeChildByTag(tag)
			 MoveMap=true
		end
end 
 --显示胜利界面UI
 function showGameVictoryUI(pos)
       local gameVictoryUI = ccs.GUIReader:getInstance():widgetFromJsonFile("res/GameVictoryUI/GameVictoryUI.json");
	   if gameVictoryUI ~= nil then
	         
			  local  Player1Name = gameVictoryUI:getChildByTag(4):getChildByTag(86)
			  if Player1Name ~= nil then
			     Player1Name:setText("快乐王子")
			  end
			  local  Player2Name = gameVictoryUI:getChildByTag(7):getChildByTag(91)
			   if Player2Name ~= nil then
			      Player2Name:setText("黑暗幽灵")
			  end
			  local  Player1Hp = gameVictoryUI:getChildByTag(4):getChildByTag(40):getChildByTag(77)
			   if Player1Hp ~= nil then
			       	 Player1Hp:setStringValue(string.format("%d",Play1Hp))
			  end
			  local  Player2Hp = gameVictoryUI:getChildByTag(7):getChildByTag(43):getChildByTag(83)
			  if Player2Hp ~= nil then
			       	 Player1Hp:setStringValue(string.format("%d",Play2Hp))
			  end
			  local   PlayerXP = gameVictoryUI:getChildByTag(32):getChildByTag(59):getChildByTag(65)
			  if PlayerXP ~= nil then
			       	 PlayerXP:setText(string.format("%d",100))
			  end
			  local   PlayerGold = gameVictoryUI:getChildByTag(32):getChildByTag(59):getChildByTag(69)
			  if PlayerGold ~= nil then
			       	 PlayerGold:setText(string.format("%d",100))
			  end
			  local   PlayerDiamond = gameVictoryUI:getChildByTag(32):getChildByTag(59):getChildByTag(72)
			    if PlayerDiamond ~= nil then
			       	 PlayerDiamond:setText(string.format("%d",10))
			  end
	         GameMainScene:addChild(gameVictoryUI,0,303)
			 MoveMap=false
			SetGameState(3)
	   end
 end
  --显示失败界面UI
 function showGameDefeateUI(pos)
       local gameVictoryUI = ccs.GUIReader:getInstance():widgetFromJsonFile("res/GameDefeateUI/GameDefeateUI.json");
	   if gameVictoryUI ~= nil then
	        GameMap:addChild(gameVictoryUI,0,302)
		    MoveMap=false
			SetGameState(3)
	   end
 end
 --创建游戏主界面UI
 function createGameMainUI()
      GameMainUI = ccs.GUIReader:getInstance():widgetFromJsonFile("res/GameMainUI/GameMainUI.json");
	  if GameMainUI ~= nil then
				-- local skillEffect = Effect:create()
				   -- skillEffect:initEffect(GameMainUI,200,100)
				-- if skillEffect ~= nil then
					-- table.insert(EffectArray,skillEffect)
				-- end	 
		  GameMainUI:setPosition(0, 0)
		  GameMainScene:addChild(GameMainUI,0,301)
		  cclog("创建游戏主界面成功")
		  
	   end
 end

 --创建游戏场景
function createGameScene()
    cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile("res/Sprite.plist")
	GameMainScene = cc.Scene:create()
	createGameMap()
	createGameMainUI()
	--创建选择战士界面
	GameMainScene:addChild(SoldiersUI.createUI(),0,101)
	SoldiersUI.ShowUI(false)
	updaePlayerInfoUI()
	SetGameState(0)
	GamePlayer1 = GamePlayer:create()
	GamePlayer1:init(GameMap,0)   --自己玩家
	GamePlayer2 = GamePlayer:create()
	GamePlayer2:init(GameMap,1)    --AI玩家
	return GameMainScene
end
  --更新游戏状态
 function SetGameState(gameState)
        GameState=gameState
		local BuildTimeText = GameMainUI:getChildByTag(107)
		local BuildTime = BuildTimeText:getChildByTag(108)
		 if GameState==0 then
				    BuildTimeText:setText("炮塔建造阶段")
					BuildTime:setVisible(true)
					BuildTimerEntry=cc.Director:getInstance():getScheduler():scheduleScriptFunc(ShowTimer, 1, false)
		
		elseif GameState==1 then
		            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(BuildTimerEntry)
				    BuildTimeText:setText("怪物战斗序列编辑阶段")
					BuildTime:setVisible(false)
					SoldiersUI.ShowUI(true)
		elseif GameState==2 then
                    --敌方怪物军团进攻
                     GamePlayer1.WaveArray[1]={}
	                 GamePlayer1.WaveArray[1].totalNum=1  --怪物数目
	                 GamePlayer1.WaveArray[1].spawnRate=4.0  --怪物数目
	                 GamePlayer1.WaveArray[1].monsterType=1  --怪物数目
	                 GamePlayer1.WaveArray[2]={}
	                 GamePlayer1.WaveArray[2].totalNum=3 --怪物数目
	                 GamePlayer1.WaveArray[2].spawnRate=4.0  --怪物数目
	                 GamePlayer1.WaveArray[2].monsterType=2  --怪物数目	
                     GamePlayer1.WaveArray[3]={}
	                 GamePlayer1.WaveArray[3].totalNum=2 --怪物数目
	                 GamePlayer1.WaveArray[3].spawnRate=4.0  --怪物数目
	                 GamePlayer1.WaveArray[3].monsterType=2  --怪物数目	
                     GamePlayer1.WaveArray[4]={}
	                 GamePlayer1.WaveArray[4].totalNum=0 --怪物数目
	                 GamePlayer1.WaveArray[4].spawnRate=4.0  --怪物数目
	                 GamePlayer1.WaveArray[4].monsterType=1  --怪物数目						 
					function callback()
			            GamePlayer1:StartMonsterAttack(PointArray) 
                        GamePlayer2:StartMonsterAttack(PointArray) 						
			        end
					--设置游戏的玩家
					--GamePlayer1:SetGamePlayer(GamePlayer2)
					--GamePlayer2:SetGamePlayer(GamePlayer1)
					--怪物军团开始进攻
					cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 2, false)
				   
				    BuildTimeText:setText("战斗阶段")
					BuildTime:setVisible(false)
		elseif GameState==3 then
				    BuildTimeText:setText("游戏结束阶段")
					BuildTime:setVisible(false)

		end 
 end
 --设置玩家进攻怪物军团数组
  function SetAttackMonsterArray(monsterInfoArray)
            for i,monsterInfo in pairs(monsterInfoArray)  do
		          if  nil ~= monsterInfo then
				       GamePlayer2.WaveArray[i]={}
					   GamePlayer2.WaveArray[i].totalNum=monsterInfo.soldierNum
	                   GamePlayer2.WaveArray[i].spawnRate=4.0  
	                   GamePlayer2.WaveArray[i].monsterType=monsterInfo.soldierType+1
				  end
			end
	       SetGameState(2)   
  end