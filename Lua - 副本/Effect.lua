require "Lua/Object"  

	--继承
	Effect = {}
	setmetatable(Effect, GameObject)  
	--还是和类定义一样，表索引设定为自身  
	Effect.__index = Effect  
	function Effect:create()  
	   local self = {}            --初始化对象自身  
	   self = GameObject:create() --将对象自身设定为父类，这个语句相当于其他语言的super   
	   setmetatable(self, Effect) --将对象自身元表设定为Main类  
	   return self  
	end
 --播放技能效果
  function  Effect:PlaySkillEffect(x,y,loop)  
        local SkillEffect=sp.SkeletonAnimation:create("res/texiao02/texiao2.json", "res/texiao02/texiao2.atlas", 0.5)
	    if SkillEffect ~= nil then
	      SkillEffect:setAnimation(0, 'animation', loop) 
		  self.baseNode:setPosition(x,y)
		  self.baseNode:addChild(SkillEffect);
	   end
  end
  
	