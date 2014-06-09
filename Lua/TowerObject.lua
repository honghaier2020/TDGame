require "Lua/GameObject"  
	TowerObject = {}
	setmetatable(TowerObject, GameObject)   
	TowerObject.__index = TowerObject  
	function TowerObject:create()  
	   local self = {}              
	   self = GameObject:create()   
	   setmetatable(self, TowerObject)
	   return self  
	end   
   --�õ����ĵ�ǰ״̬
   function TowerObject:getTowerState()  
		   return self.state
   end
   --����Ƿ�������
  function  TowerObject:containsTouchLocation(x,y)
     -- --��ʼ״̬
     -- if self.state ==0  then
	      -- if self.initTower ~= nil then
	       -- local rect = self.initTower:getBoundingBox()
		   -- return cc.rectContainsPoint(rect,cc.p(x,y))
	     -- end
	 -- elseif self.state ==2  then
	      -- if self.buildTower ~= nil then
	       -- local rect = self.buildTower:getBoundingBox()
		   -- return cc.rectContainsPoint(rect,cc.p(x,y))
	     -- end
	 -- end
	  -- return false
  end
   --������
  function  TowerObject:buildTower(towerConfig,bulidTowPos,gamePlayer)
   ---�������߷�Χ
    --self.towerConfig=towerconfig   
    self.gamePlayer=gamePlayer 
    self.attackRange=towerConfig.attackRange
    self.attackEffectRes=towerConfig.attackEffectRes
	self.HitEffectRes=towerConfig.HitEffectRes	
    self.buildPercentage=0
	self.state=0  --������
	self.towerPos=bulidTowPos  --������
	--��������Ѫ������
	self.hpBgSprite =cc.Sprite:createWithSpriteFrameName("hpBg1.png")
	self.hpBgSprite:setPosition(self.towerPos)
	self.parentNode:addChild(self.hpBgSprite)
	--��������Ѫ������������
	self.hpBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("hp1.png"))
	self.hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	self.hpBar:setMidpoint(cc.p(0, 0.5))
	self.hpBar:setBarChangeRate(cc.p(1, 0))
	self.hpBar:setPercentage(self.buildPercentage)
    self.hpBar:setPosition(cc.p(self.hpBgSprite:getContentSize().width / 2, self.hpBgSprite:getContentSize().height / 3 * 2 ))
	--������ɻص�����
	 function callback()
         cclog("�������") 
         self:buildTowerDone()		 
	 end
	self.hpBar:runAction(cc.Sequence:create( cc.ProgressTo:create(10, 100), cc.CallFunc:create(callback)))
    self.hpBgSprite:addChild(self.hpBar)
   end
   --���������
    function  TowerObject:buildTowerDone()
	   self.state=1 --�������
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
          self.parentNode:addChild(self.buildTower)
		  self.state=2 
		  self.attackMonster=nil
		   function callback()
			       self:towerLogic() 	
		   end
		   cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 2, false)   
		end 
    end
	--�õ����������Ŀ��
	 function  TowerObject:getClosestTarget()
	     local attackMonster=nil
		 local maxDistant = 99999;
		 for j,monster in pairs(self.gamePlayer.monsterArray)  do
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
	 --�������߼�
	 function  TowerObject:towerLogic()  
	    if self.attackMonster == nil then
		    self.attackMonster=self:getClosestTarget()
			
        else
		    local curDistance =cc.pGetDistance(self.towerPos,self.attackMonster.monsterPos)
			if self.attackMonster.hpPercentage<=0 or curDistance > self.attackRange then
			     self.attackMonster=self:getClosestTarget()
			end
		end	 
		  if self.attackMonster ~= nil then 
		      local rect = self.attackMonster.spineAnimation:getBoundingBox()
			  local attackPos=cc.p(rect.x+rect.width*0.5,rect.y+rect.height*0.5)
              self:attack(attackPos)   			  
		  end
	 end
	--����
	 function  TowerObject:attack(attackPos)	  
			 self:createBullet(attackPos)   			   
  		 
	 end
	 --�������Ĺ����ӵ�
    function  TowerObject:createBullet(attackPos)
	        local bullet =sp.SkeletonAnimation:create(self.attackEffectRes[1],self.attackEffectRes[2], 1)
			bullet:setAnimation(0, self.attackEffectRes[3], true)
            bullet:setPosition(self.towerPos)
			function callback(sender)
                  self:removeBullet(sender)		 
	         end
			bullet:runAction(cc.Sequence:create(cc.MoveTo:create(1, attackPos),cc.CallFunc:create(callback)))
            self.parentNode:addChild(bullet)
		    table.insert(self.gamePlayer.bulletArray,bullet)
	end 
    function  TowerObject:removeBullet(bullet)
	     local hitEffect =sp.SkeletonAnimation:create(self.HitEffectRes[1],self.HitEffectRes[2], 1)
	     hitEffect:setAnimation(0, self.HitEffectRes[3], false)
		 local hitPosX,hitPosY=bullet:getPosition()
		 hitEffect:setPosition(hitPosX,hitPosY)
		 self.parentNode:addChild(hitEffect)
	    if bullet ~= nil then
		    for i,bulletObject in pairs(self.gamePlayer.bulletArray)  do
		         if  nil ~= bulletObject and bulletObject == bullet then
	                  table.remove(self.gamePlayer.bulletArray, i)
	                  bullet:removeFromParent()
					  if self.attackMonster ~= nil then   
			                 self.attackMonster.hpPercentage=self.attackMonster.hpPercentage-30
                               self.attackMonster.hpBar:setPercentage(self.attackMonster.hpPercentage)
	                           if self.attackMonster.hpPercentage <=0 then
							        self.gamePlayer:removeMonster(self.attackMonster)
									self.attackMonster=nil
	                             end  			   
                       end	
					  break
				  end
		   end
		  end
	 end
--�Ƴ�����
function TowerObject:removeOblect()
	      if self.buildTower ~= nil then
		     self.buildTower:removeFromParent()
		  end
		  if self.hpBgSprite ~= nil then
		     self.hpBgSprite:removeFromParent()
		  end
 end 