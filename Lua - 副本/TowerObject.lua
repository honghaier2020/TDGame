require "Lua/GameObject"  
	TowerObject = {}
	setmetatable(TowerObject, GameObject)  
	--还是和类定义一样，表索引设定为自身  
	TowerObject.__index = TowerObject  
	function TowerObject:create()  
	   local self = {}            --初始化对象自身  
	   self = GameObject:create() --将对象自身设定为父类，这个语句相当于其他语言的super   
	   setmetatable(self, TowerObject) --将对象自身元表设定为Main类  
	   return self  
	end   
	function TowerObject:initTower(x,y) 
	   self.towerPos=cc.p(x,y)    --塔位置
	   self.state=0               --搭状态   0 未建造状态 1 建造状态  2 等待攻击状态  3攻击状态
	                              --初始未建造塔图标
	   local initTowerTexture = cc.Director:getInstance():getTextureCache():addImage("res/battle_0003s_0001_skill-resource-counter.png")
	   self.initTower =cc.Sprite:createWithTexture(initTowerTexture)
	    if self.initTower ~= nil then
		    self.initTower:setPosition(self.towerPos)
			self.parentNode:addChild(self.initTower)
		end 
   end 
   --得到塔的当前状态
   function TowerObject:getTowerState()  
		   return self.state
   end
   --检测是否触摸到塔
  function  TowerObject:containsTouchLocation(x,y)
     --初始状态
     if self.state ==0  then
	      if self.initTower ~= nil then
	       local rect = self.initTower:getBoundingBox()
		   return cc.rectContainsPoint(rect,cc.p(x,y))
	     end
	 elseif self.state ==2  then
	      if self.buildTower ~= nil then
	       local rect = self.buildTower:getBoundingBox()
		   return cc.rectContainsPoint(rect,cc.p(x,y))
	     end
	 end
	  return false
  end
   --建造塔
  function  TowerObject:buildTower(towerconfig)
   ---塔的视线范围
    self.towerConfig=towerconfig
	self.attackRange=200             
    self.buildPercentage=0
	self.state=1 
	--创建怪物血条背景
	self.hpBgSprite =cc.Sprite:createWithSpriteFrameName("hpBg1.png")
	self.hpBgSprite:setPosition(self.towerPos)
	self.parentNode:addChild(self.hpBgSprite)
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
    function  TowerObject:buildTowerDone()
	   
	    local buildTowerTexture = cc.Director:getInstance():getTextureCache():addImage("res/battle_0001s_0002_T1-icon.png")
	    self.buildTower =cc.Sprite:createWithTexture(buildTowerTexture)
	    if self.buildTower ~= nil then		
		   local RangeTexture = cc.Director:getInstance():getTextureCache():addImage("res/Range.png")
	       local RangeSprite =cc.Sprite:createWithTexture(RangeTexture)
		   RangeSprite:setScale(self.attackRange*0.02)
		   RangeSprite:setPosition(self.towerPos)	
		  self.parentNode:addChild(RangeSprite)
          self.buildTower:setPosition(self.towerPos)		
		  self.parentNode:removeChild(self.hpBgSprite)
		  self.parentNode:removeChild(self.initTower)
          self.parentNode:addChild(self.buildTower)
		  self.state=2 
		  self.attackPos=nil
		   function callback()
			       self:towerLogic() 	
		   end
		   cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0.2, false)  
		end 
    end
	--得到最近攻击的目标
	 function  TowerObject:getClosestTarget()
	     local attackMonster=nil
		 local maxDistant = 99999;
		 for j,monster in pairs(GameScene.getMonsterArray())  do
		        local curDistance =cc.pGetDistance(self.towerPos,monster.monsterPos)
				 if curDistance < maxDistant  then	
			               maxDistant = curDistance	
						   attackMonster=monster					   
				  end 
		end
		if maxDistant <self.attackRange then	
             return 	attackMonster		 
		end
		return nil
	 end 
	 --塔更新逻辑
	 function  TowerObject:towerLogic()  
         self.attackMonster=self:getClosestTarget()	
         if self.attackMonster ~= nil then
		      self:attack()
         end		 
	 end
	--攻击
	 function  TowerObject:attack()	
	       if self.attackMonster ~= nil then   
			 self:createBullet(self.attackMonster.monsterPos)   			   
           end			 
	 end
	 --创建塔的攻击子弹
    function  TowerObject:createBullet(attackPos)
	        local bullet =sp.SkeletonAnimation:create(self.towerConfig.attackEffectResPath[1],self.towerConfig.attackEffectResPath[2], 0.5)
            bullet:setPosition(self.towerPos)
			function callback(sender)
                  self:removeBullet(sender)		 
	         end
			bullet:runAction(cc.Sequence:create(cc.MoveTo:create(1, attackPos),cc.CallFunc:create(callback)))
            self.parentNode:addChild(bullet)
		    table.insert(GameScene.getBulletArray(),bullet)
	end 
    function  TowerObject:removeBullet(bullet)
	    if bullet ~= nil then
		    for i,bulletObject in pairs(GameScene.getBulletArray())  do
		         if  nil ~= bulletObject and bulletObject == bullet then
	                  table.remove(GameScene.getBulletArray(), i)
	                  bullet:removeFromParent()
					  break
				  end
		   end
		  end
	 end
--移除物体
function TowerObject:removeOblect()
	      if self.buildTower ~= nil then
		     self.buildTower:removeFromParent()
		  end
		  if self.hpBgSprite ~= nil then
		     self.hpBgSprite:removeFromParent()
		  end
		   if self.initTower ~= nil then
		     self.initTower:removeFromParent()
		  end
 end 
   