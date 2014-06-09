require "Lua/GameObject"  

	--继承
	EffectObject = {}
	setmetatable(EffectObject, GameObject)  
	EffectObject.__index = EffectObject  
	function EffectObject:create()  
	   local self = {}           
	   self = GameObject:create()  
	   setmetatable(self, EffectObject)
	   return self  
	end
 --播放技能效果
  function  EffectObject:PlaySkillEffect(x,y,loop)  
        self.skillEffect=sp.SkeletonAnimation:create("res/texiao02/texiao2.json", "res/texiao02/texiao2.atlas", 0.5)
	    if self.skillEffect ~= nil then
	      self.skillEffect:setAnimation(0, 'animation', loop) 
		  self.skillEffect:setPosition(x,y)
		  self.parentNode:addChild(self.skillEffect);
	   end
  end
  --移除物体
function EffectObject:removeOblect()
	      if self.skillEffect ~= nil then
		     self.skillEffect:removeFromParent()
		  end
 end 
	