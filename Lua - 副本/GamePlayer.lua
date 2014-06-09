require"Lua/MonsterObject"
require "Lua/MonsterConfig"
require"Lua/TowerObject"
require "Lua/TowerConfig" 
  --����һ����Ϸ��Ҽ�ʵ����
	GamePlayer = {}
	GamePlayer.__index = GamePlayer 
	--����
	function GamePlayer:create() 
	    local self = {}
	    setmetatable(self, GamePlayer) 
	    return self    
	 end
	 --��ʼ����
	 function GamePlayer:init(gameMap) 
	       self.lastTimeTargetAdded=0
		   self.gameMap=gameMap
		   self.monsterArray = {}  --��������
		   self.WaveArray = {}     --ˢ�ֶ���
		   self.towerArray = {}    --��ҽ������
		   self.Hp = 10            --���Ѫ��
		   self.currentAttackWave=1 --��ҵ�ǰ��������
		   self.diamondNum=100       --�����ʯ��Ŀ
		   self.goldNum=1000         --��ҽ�Ǯ��Ŀ
           self.WaveArray[1]={}
	       self.WaveArray[1].totalNum=2  --������Ŀ
	       self.WaveArray[1].spawnRate=0.3  --������Ŀ
	       self.WaveArray[1].monsterType=1  --������Ŀ
	       self.WaveArray[2]={}
	       self.WaveArray[2].totalNum=5  --������Ŀ
	       self.WaveArray[2].spawnRate=2.0  --������Ŀ
	       self.WaveArray[2].monsterType=2  --������Ŀ	 
	 end
	 --���ӹ���
function GamePlayer:AddMonster(monsterType)
     local monster = MonsterObject:create()
	 monster:init(self.gameMap)
	 monster:initMonster(monsterConfig[monsterType],PointArray)
	 if monster ~= nil then  
	 end 
 end 
--�Լ�������ſ�ʼ����
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
--�õ���ǰ�������ﲨ
 function GamePlayer:getCurrentWave()
     if self.currentAttackWave >3 then
	   return nil
	 end 
     return   self.WaveArray[self.currentAttackWave]
 end
