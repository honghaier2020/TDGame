require "Lua/GameObject"  

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
    function Effect:initEffect(sceneUi,x,y)  
	     
		  local texture = cc.Director:getInstance():getTextureCache():addImage("res/skillUI/battle_0003s_0005_skill-outer-rim.png")
		  self.skillicon =cc.Sprite:createWithTexture(texture)
		  self.skillicon:setPosition(x,y)
		  sceneUi:addChild(self.skillicon)
		  local texture1 = cc.Director:getInstance():getTextureCache():addImage("res/skillUI/battle_0003s_0004_skill-inner-rim.png")
	      self.skillBK1 =cc.Sprite:createWithTexture(texture1)
		  self.skillBK1:setPosition(x,y)
		  sceneUi:addChild(self.skillBK1)
		  local texture2 = cc.Director:getInstance():getTextureCache():addImage("res/skillUI/battle_0003s_0008_planet-craker.png")
		  self.skillBK2 =cc.Sprite:createWithTexture(texture2)
		  self.skillBK2:setPosition(x,y)
		  sceneUi:addChild(self.skillBK2)
		  
	end	
  function  Effect:containsTouchLocation(x,y)
     if self.skillBK2 ~= nil then
	       local rect = self.skillBK2:getBoundingBox()
		   return cc.rectContainsPoint(rect,cc.p(x,y))
	 end
	  return false
   end
  function  Effect:PlaySkillEffect(map,x,y)  
     
     local SkillEffect=sp.SkeletonAnimation:create("res/texiao02/texiao2.json", "res/texiao02/texiao2.atlas", 0.5)
	 if SkillEffect ~= nil then
	      SkillEffect:setAnimation(0, 'animation', false) 
		  SkillEffect:setPosition(x,y)
		  map:addChild(SkillEffect);
	 end
    
  end
	