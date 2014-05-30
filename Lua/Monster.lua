require "Lua/GameObject"  
	--继承
	Monster = {}
	setmetatable(Monster, GameObject)  
	--还是和类定义一样，表索引设定为自身  
	Monster.__index = Monster  
	function Monster:create()  
	   local self = {}            --初始化对象自身  
	   self = GameObject:create() --将对象自身设定为父类，这个语句相当于其他语言的super   
	   setmetatable(self, Monster) --将对象自身元表设定为Main类  
	   return self  
	end   
function Monster:currPoint()
 
	 return  self.pointArray[self.pointCounter]
end
function Monster:nextPoint()
    local maxCount = table.getn(self.pointArray)
	 self.pointCounter=self.pointCounter+1
	 if self.pointCounter < maxCount then
	   return self.pointArray[self.pointCounter]
	end
     return nil;
end
function Monster:runFllowPoint()
	    local curPos =self:currPoint()
		if self.spineboy ~= nil then
		    self.spineboy:setPosition(curPos)
		end
	    local nextPos =self:nextPoint() 
		if nextPos ~= nil then
		   function callback()
			    self:runFllowPoint() 	
			end
		 self.spineboy:runAction(cc.Sequence:create( cc.MoveTo:create(2, nextPos), cc.CallFunc:create(callback)))
		end
end
function Monster:initMonster(PointArray)  
    self.pointArray=PointArray
	self.runSpeed=6
	self.pointCounter=1
	self.hpPercentage=100
	self.spineboy =sp.SkeletonAnimation:create("res/spine/skeleton.json", "res/spine/skeleton.atlas", 0.5)
	self.spineboy:setAnimation(0, 'animation', true)
	self.hpBgSprite =cc.Sprite:createWithSpriteFrameName("hpBg1.png")
	self.spineboy:addChild(self.hpBgSprite)
	self.hpBgSprite:setPosition(cc.p(self.spineboy:getContentSize().width / 2, self.spineboy:getContentSize().height ))
	self.hpBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("hp1.png"))
	self.hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	self.hpBar:setMidpoint(cc.p(0, 0.5))
	self.hpBar:setBarChangeRate(cc.p(1, 0))
	self.hpBar:setPercentage(self.hpPercentage)
    self.hpBar:setPosition(cc.p(self.hpBgSprite:getContentSize().width / 2, self.hpBgSprite:getContentSize().height / 3 * 2 ))
    self.hpBgSprite:addChild(self.hpBar);
	self:runFllowPoint()
end 