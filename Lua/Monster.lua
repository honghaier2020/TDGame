require "Lua/Object"  
require"Lua/GameManager"
	--怪物基类继承物体类
	Monster = {}
	setmetatable(Monster, GameObject)  
	Monster.__index = Monster  
	function Monster:create()  
	   local self = {}           
	   self = GameObject:create()  
	   setmetatable(self, Monster)
	   return self  
	end   
--得到怪物当前运行的目标点
function Monster:currPoint()
	 return  PointArray[self.pointCounter]
end
--得到怪物下个运行的目标点
function Monster:nextPoint()
    local maxCount = table.getn(PointArray)
	 self.pointCounter=self.pointCounter+1
	 if self.pointCounter < maxCount then
	   return PointArray[self.pointCounter]
	 end
	 GameScene.updaePlayerHpUI(0,self)
	 cclog("怪物到达终点")
     return nil;
end
--怪物运行跟随路径点
function Monster:runFllowPoint()
	    local curPos =self:currPoint()
		if self.baseNode ~= nil then
		    self:SetCurPos(curPos)
		end
	    local nextPos =self:nextPoint() 
		if nextPos ~= nil then
		   function callback()
			    self:runFllowPoint() 	
			end
		 self.baseNode:runAction(cc.Sequence:create( cc.MoveTo:create(2, nextPos), cc.CallFunc:create(callback)))
		end
end
--初始化怪物
function Monster:initMonster(configProperties)  
	self.runSpeed=6
	self.exteriorResPath=0  ---外型资源路径
	self.monsterId=0        ---怪物ID
	self.skillId=0          ---技能ID
	self.departmentId=0     ---系别ID
	self.moveSpeed=20       ---移动速度
	self.hp=100             ---血量
	self.armor=20           ---护甲百分比
	self.resistance=10      --抗性百分比
	self.pointCounter=1
	self.hpPercentage=100
	self.spineAnimation =sp.SkeletonAnimation:create("res/spine/skeleton.json", "res/spine/skeleton.atlas", 0.5)
	self.spineAnimation =sp.SkeletonAnimation:create(configProperties.exteriorResPath[1],configProperties.exteriorResPath[2], 0.5)
	self.spineAnimation:setAnimation(0, 'animation', true)
	self.hpBgSprite =cc.Sprite:createWithSpriteFrameName("hpBg1.png")
	self.spineAnimation:addChild(self.hpBgSprite)
	self.hpBgSprite:setPosition(cc.p(self.spineAnimation:getContentSize().width / 2, self.spineAnimation:getContentSize().height ))
	self.hpBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("hp1.png"))
	self.hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	self.hpBar:setMidpoint(cc.p(0, 0.5))
	self.hpBar:setBarChangeRate(cc.p(1, 0))
	self.hpBar:setPercentage(self.hpPercentage)
    self.hpBar:setPosition(cc.p(self.hpBgSprite:getContentSize().width / 2, self.hpBgSprite:getContentSize().height / 3 * 2 ))
    self.hpBgSprite:addChild(self.hpBar);
	self.baseNode:addChild(self.spineAnimation)
	self:runFllowPoint()
end 
--更新怪物血条
function Monster:updateHp(hpNum)
     self.hpPercentage=self.hpPercentage-hpNum
     self.hpBar:setPercentage(self.hpPercentage)
	 if self.hpPercentage <=0 then
	   GameScene.updaePlayerHpUI(1,self)
	 end
end
 