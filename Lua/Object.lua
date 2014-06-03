
  --定义一个游戏对象基类及实例化
	GameObject = {}
	setmetatable(GameObject, GameObject)  
	--这句是重定义元表的索引，必须要有，
	GameObject.__index = GameObject 
	--创建
	function GameObject:create() 
	    local self = {}
	    setmetatable(self, GameObject)   --必须要有  	 
	    return self    
	 end
	 --初始化节点
	 function GameObject:init(parentNode) 
		self.baseNode = cc.Node:create()
		parentNode:addChild(self.baseNode)	  
	 end
	  --得到物体位置
	 function GameObject:GetCurPos() 
		 if self.baseNode ~= nil then
	      local posX,posy =self.baseNode:getPosition()
		   return cc.p(posX,posy)
	  end
		return nil  
	 end
	 function GameObject:SetCurPos(pos) 
		if self.baseNode ~= nil then
	       self.baseNode:setPosition(pos)
	    end 
	 end
	 --移除物体
	 function GameObject:removeOblect()
	      if self.baseNode ~= nil then
		     self.baseNode:removeFromParent()
		  end
	 end 
	 
