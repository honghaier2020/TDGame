require"Lua/MonsterObject"
require "Lua/MonsterConfig"
require"Lua/TowerObject"
require "Lua/TowerConfig" 
require"Lua/EffectObject"
  --定义一个游戏玩家及实例化
	GamePlayer = {}
	GamePlayer.__index = GamePlayer 
	--创建
	function GamePlayer:create() 
	    local self = {}
	    setmetatable(self, GamePlayer) 
	    return self    
	 end
	 --初始化节
	 function GamePlayer:init(gameMap,playerType) 
	       self.baseNode = cc.Node:create()
		   gameMap:addChild(self.baseNode)
	       self.lastTimeTargetAdded=0
		   self.gameMap=gameMap
		   self.monsterArray = {}  --敌方怪物数组
		   self.WaveArray = {}     --敌方刷怪队列
		   self.towerArray = {}    --玩家建造的塔
		   self.bulletArray={}     --玩家子弹数组
		   self.Hp = 20            --玩家血量
		   self.currentAttackWave=1 --玩家当前攻击波数
		   self.diamondNum=100       --玩家钻石数目
		   self.goldNum=1000         --玩家金钱数目
           self.playerType=playerType--玩家金钱数目
           if 	playerType==1 then
		     self.baseNode:setVisible(false)
           end		   
	 end
	 --增加怪物
function GamePlayer:addAttackMonster(monsterType,PointArray)
     local monster = MonsterObject:create()
	 monster:init(self.baseNode)
	 monster:initMonster(monsterConfig[monsterType],PointArray,self)
	  if monster ~= nil then
	       table.insert(self.monsterArray,monster)
	  end
 end 
--自己怪物军团开始进攻
function GamePlayer:StartMonsterAttack(PointArray)
         self.waveNum=table.getn(self.WaveArray)
		 local wave =self:getCurrentWave() 
		 if wave ~= nil then
		     cclog("%d",wave.totalNum)
	      local now = 0
          if  self.lastTimeTargetAdded == 0 or now - self.lastTimeTargetAdded >= wave.spawnRate then
		        if  wave.totalNum > 0 then
				   self:addAttackMonster(wave.monsterType,PointArray)
				   cclog("wave%dmonsterNum%d",self.currentAttackWave,wave.totalNum)
				   wave.totalNum=wave.totalNum-1
				   
				else
				     self.currentAttackWave=self.currentAttackWave+1 
					 self.lastTimeTargetAdded=0
                end				
		       self.lastTimeTargetAdded = now
		  end 
         end		  
end
--得到当前攻击怪物波
 function GamePlayer:getCurrentWave()
     if self.currentAttackWave >self.waveNum then
	   return nil
	 end 
     return   self.WaveArray[self.currentAttackWave]
 end
   function  GamePlayer:buildTower(towerconfig,bulidTowPos)
       local tower = TowerObject:create()
	   tower:init(self.baseNode)
	   tower:buildTower(towerconfig,bulidTowPos,self)
	   if tower ~= nil then
	        table.insert(self.towerArray,tower)
	   end
   end
   function GamePlayer:removeMonster(monster)
            for k,monsterObject in pairs(self.monsterArray)  do
		          if  nil ~= monsterObject and monsterObject == monster then
	                   table.remove(self.monsterArray, k)
					   monster:removeOblect()
				   end
		       end	
   end	
   function GamePlayer:updaePlayerHp(monster)
       self.Hp=self.Hp-1
	   self:removeMonster(monster)
	   GameScene:updaePlayerHpUI()  
	end