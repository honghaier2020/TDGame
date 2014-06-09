require "Lua/GameObject"  
	TowerObject = {}
	setmetatable(TowerObject, GameObject)  
	--���Ǻ��ඨ��һ�����������趨Ϊ����  
	TowerObject.__index = TowerObject  
	function TowerObject:create()  
	   local self = {}            --��ʼ����������  
	   self = GameObject:create() --�����������趨Ϊ���࣬�������൱���������Ե�super   
	   setmetatable(self, TowerObject) --����������Ԫ���趨ΪMain��  
	   return self  
	end   
	function TowerObject:initTower(x,y) 
	   self.towerPos=cc.p(x,y)    --��λ��
	   self.state=0               --��״̬   0 δ����״̬ 1 ����״̬  2 �ȴ�����״̬  3����״̬
	                              --��ʼδ������ͼ��
	   local initTowerTexture = cc.Director:getInstance():getTextureCache():addImage("res/battle_0003s_0001_skill-resource-counter.png")
	   self.initTower =cc.Sprite:createWithTexture(initTowerTexture)
	    if self.initTower ~= nil then
		    self.initTower:setPosition(self.towerPos)
			self.parentNode:addChild(self.initTower)
		end 
   end 
   --�õ����ĵ�ǰ״̬
   function TowerObject:getTowerState()  
		   return self.state
   end
   --����Ƿ�������
  function  TowerObject:containsTouchLocation(x,y)
     --��ʼ״̬
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
   --������
  function  TowerObject:buildTower(towerconfig)
   ---�������߷�Χ
    self.towerConfig=towerconfig
	self.attackRange=200             
    self.buildPercentage=0
	self.state=1 
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
	--�õ����������Ŀ��
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
	 --�������߼�
	 function  TowerObject:towerLogic()  
         self.attackMonster=self:getClosestTarget()	
         if self.attackMonster ~= nil then
		      self:attack()
         end		 
	 end
	--����
	 function  TowerObject:attack()	
	       if self.attackMonster ~= nil then   
			 self:createBullet(self.attackMonster.monsterPos)   			   
           end			 
	 end
	 --�������Ĺ����ӵ�
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
--�Ƴ�����
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
   