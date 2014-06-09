
  --定义一个游戏对象基类及实例化
	GameObject = {}
	--这句是重定义元表的索引，必须要有，
	GameObject.__index = GameObject 
	--创建
	function GameObject:create() 
	    local self = {}
	    setmetatable(self, GameObject)   --必须要有  	 
	    return self    
	 end
	 --初始化节
	 function GameObject:init(parentNode) 	
        self.parentNode = parentNode		
	 end

	 
