
--定义一个游戏对象基类及实例化
	GameObject = {}
	setmetatable(GameObject, GameObject)  
	--这句是重定义元表的索引，必须要有，
	GameObject.__index = GameObject 
	function GameObject:create() 
	    local self = {}
	    setmetatable(self, GameObject)   --必须要有  	 
	    return self    
	 end
