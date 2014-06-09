require"Lua/MonsterObject"
require "Lua/MonsterConfig"
require"Lua/TowerObject"
require "Lua/TowerConfig" 
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
	 function GamePlayer:init(gameMap) 
	       self.lastTimeTargetAdded=0
		   self.gameMap=gameMap
		   self.monsterArray = {}  --怪物数组
		   self.WaveArray = {}     --刷怪队列
		   self.towerArray = {}    --玩家建造的塔
		   self.Hp = 10            --玩家血量
		   self.currentAttackWave=1 --玩家当前攻击波数
		   self.diamondNum=100       --玩家钻石数目
		   self.goldNum=1000         --玩家金钱数目
           self.WaveArray[1]={}
	       self.WaveArray[1].totalNum=2  --怪物数目
	       self.WaveArray[1].spawnRate=0.3  --怪物数目
	       self.WaveArray[1].monsterType=1  --怪物数目
	       self.WaveArray[2]={}
	       self.WaveArray[2].totalNum=5  --怪物数目
	       self.WaveArray[2].spawnRate=2.0  --怪物数目
	       self.WaveArray[2].monsterType=2  --怪物数目	 
	 end
	 --增加怪物
function GamePlayer:AddMonster(monsterType)
     local monster = MonsterObject:create()
	 monster:init(self.gameMap)
	 monster:initMonster(monsterConfig[monsterType],PointArray)
	 if monster ~= nil then  
	 end 
 end 
--自己怪物军团开始进攻
function GamePlayer:StartMonsterAttack()
		 local wave =getCurrentWave() 
		 if wave ~= nil then
	      local now = 0
          if  self.lastTimeTargetAdded == 0 or now - self.lastTimeTargetAdded >= wave.spawnRate then
		        if  wave.totalNum > 0 then
				   AddMonster(wave.monsterType)
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
     if self.currentAttackWave >3 then
	   return nil
	 end 
     return   self.WaveArray[self.currentAttackWave]
 end
