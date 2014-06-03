require "Lua/Object"  
require"Lua/GameManager"
	Tower = { nearestMonster=nil}
	setmetatable(Tower, GameObject)  
	--还是和类定义一样，表索引设定为自身  
	Tower.__index = Tower  
	function Tower:create()  
	   local self = {}            --初始化对象自身  
	   self = GameObject:create() --将对象自身设定为父类，这个语句相当于其他语言的super   
	   setmetatable(self, Tower) --将对象自身元表设定为Main类  
	   self.nearestMonster=nil  ---塔子视野内最近的敌人
	   return self  
	end   
	function Tower:initTower(map,x,y)  
	   self.baseNode:setPosition(x,y)
	   self.state=0   --搭的状态
	   --初始未建造塔图标
	   local initTowerTexture = cc.Director:getInstance():getTextureCache():addImage("res/battle_0003s_0001_skill-resource-counter.png")
	   self.initTowerIcon =cc.Sprite:createWithTexture(initTowerTexture)
	    if self.initTowerIcon ~= nil then
		    --self.initTowerIcon:setPosition(self.towerPos)
			self.baseNode:addChild(self.initTowerIcon)
			cclog("创建未建造炮塔,位置: %0.2f, %0.2f", x,y) 
		end 
   end 
   --得到塔的当前状态
   function Tower:getTowerState()  
		   return self.state
   end
   --检测是否触摸到塔
  function  Tower:containsTouchLocation(x,y)
     --初始状态
     if self.state ==0  then
	      if self.initTowerIcon ~= nil then
	       local rect = self.initTowerIcon:getBoundingBox()
		    rect.x=rect.x+self:GetCurPos().x
		    rect.y=rect.y+self:GetCurPos().y
		
		   return cc.rectContainsPoint(rect,cc.p(x,y))
	     end
	 elseif self.state ==1  then
	      if self.buildTower ~= nil then
	       local rect = self.buildTower:getBoundingBox()
		    rect.x=rect.x+self:GetCurPos().x
		    rect.y=rect.y+self:GetCurPos().y
		   return cc.rectContainsPoint(rect,cc.p(x,y))
	     end
	 end
	  return false
  end
   --建造塔
  function  Tower:buildTower()
	self.attackRange=400             ---塔的视线范围
    self.buildPercentage=0
    self.nearestMonster=0
	--创建怪物血条背景
	self.hpBgSprite =cc.Sprite:createWithSpriteFrameName("hpBg1.png")
	self.baseNode:addChild(self.hpBgSprite)
	--创建怪物血条进度条背景
	self.hpBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("hp1.png"))
	self.hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	self.hpBar:setMidpoint(cc.p(0, 0.5))
	self.hpBar:setBarChangeRate(cc.p(1, 0))
	self.hpBar:setPercentage(self.buildPercentage)
    self.hpBar:setPosition(cc.p(self.hpBgSprite:getContentSize().width / 2, self.hpBgSprite:getContentSize().height / 3 * 2 ))
	--建造完成回调函数
	 function callback()
         cclog("建造完成") 
         self:buildTowerDone()		 
	 end
	self.hpBar:runAction(cc.Sequence:create( cc.ProgressTo:create(10, 100), cc.CallFunc:create(callback)))
    self.hpBgSprite:addChild(self.hpBar)
	
   end
   --建造塔完成
    function  Tower:buildTowerDone()
	    local buildTowerTexture = cc.Director:getInstance():getTextureCache():addImage("res/battle_0001s_0002_T1-icon.png")
	    self.buildTower =cc.Sprite:createWithTexture(buildTowerTexture)
	    if self.buildTower ~= nil then		 
		  self.baseNode:removeChild(self.hpBgSprite)
		  self.baseNode:removeChild(self.initTowerIcon)
          self.baseNode:addChild(self.buildTower)
		  self.state=1
		  self.rotateArrow =cc.Sprite:createWithSpriteFrameName("arrow.png")
		  self.rotateArrow:setPosition(0, self.buildTower:getContentSize().height /4)
	      self.baseNode:addChild(self.rotateArrow)
		   local function callback()
			    self:rotateAndattack() 	
		  end
		  cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0.8, false)
		end 
    end
	--检测塔附近的怪物
	function  Tower:checkNearestMonster()
	       self.nearestMonster=0
		   local maxDistant=WinSize.width
		   for k,monster in pairs(MonsterArray)  do
		         local curDistance =cc.pGetDistance(self:GetCurPos(),monster:GetCurPos())
				   if curDistance < maxDistant  then	
			           maxDistant = curDistance	
					   	if maxDistant <self.attackRange then	
		                   self.nearestMonster=monster
		                end				   
				   end 
	       end
	 end
	 function  Tower:attack()
	        if self.nearestMonster ~= 0 and self.nearestMonster.hp > 0 then
			     local shootVector1 = cc.pSub(self.nearestMonster:GetCurPos(),self:GetCurPos()) 
				 cclog("%d,%d",shootVector1.x,shootVector1.y) 
				 local normalizedShootVector =cc.pNormalize(shootVector1)
				 normalizedShootVector.x=-normalizedShootVector.x
				 normalizedShootVector.y=-normalizedShootVector.y
				 local farthestDistance = WinSize.width
				 local overshotVector = cc.pMul(normalizedShootVector,farthestDistance)
				 local rotateArrowPosX,rotateArrowPosY=self.rotateArrow:getPosition()
		         local offscreenPoint = cc.pSub(cc.p(rotateArrowPosX,rotateArrowPosY),overshotVector)
				 local currBullet = self:createTowerBullet()
				  function callback(sender)
                    self:removeBullet(sender)		 
	              end
				 currBullet:runAction(cc.Sequence:create(cc.MoveTo:create(2, offscreenPoint),cc.CallFunc:create(callback)))
			end
	 end
	  function  Tower:rotateAndattack()
	  
	           self:checkNearestMonster()
		      if self.nearestMonster ~= 0 then
				 local shootVector1 = cc.pSub(self.nearestMonster:GetCurPos(),self:GetCurPos())
			     local shootRadians = math.atan2(shootVector1.y,shootVector1.x)
			     local shootDegrees = -shootRadians / math.pi * 180.0
			     local speed = 0.5 / math.pi;
		         local rotateDuration = math.abs(shootRadians * speed)
			     function callback()
			        self:attack() 	
			    end
			      self.rotateArrow:runAction(cc.Sequence:create(cc.RotateTo:create(rotateDuration, shootDegrees), cc.CallFunc:create(callback)))
			 end
	 end
	 --创建子弹
    function  Tower:createTowerBullet()
	     local bullet = cc.Sprite:createWithSpriteFrameName("arrowBullet.png");
		 local rotateArrowPosX,rotateArrowPosY=self.rotateArrow:getPosition()
         bullet:setPosition(rotateArrowPosX,rotateArrowPosY)
         bullet:setRotation(self.rotateArrow:getRotation())
         self.baseNode:addChild(bullet)
		 table.insert(BulletArray,bullet)
         return bullet;
	end 
    function  Tower:removeBullet(bullet)
	    if bullet ~= nil then
		    for i,bulletObject in pairs(BulletArray)  do
		         if  nil ~= bulletObject and bulletObject == bullet then
			  
	                  table.remove(BulletArray, i)
		              len     = table.getn(BulletArray)
	                  bullet:removeFromParent()
					  break
				  end
		   end
		  end
	 end
   