require"Lua/MonsterObject"
require "Lua/MonsterConfig"
require"Lua/TowerObject"
require "Lua/TowerConfig" 
require"Lua/EffectObject"
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
	 function GamePlayer:init(gameMap,playerType) 
	       self.baseNode = cc.Node:create()
		   gameMap:addChild(self.baseNode)
	       self.lastTimeTargetAdded=0
		   self.gameMap=gameMap
		   self.monsterArray = {}  --�з���������
		   self.WaveArray = {}     --�з�ˢ�ֶ���
		   self.towerArray = {}    --��ҽ������
		   self.bulletArray={}     --����ӵ�����
		   self.Hp = 20            --���Ѫ��
		   self.currentAttackWave=1 --��ҵ�ǰ��������
		   self.diamondNum=100       --�����ʯ��Ŀ
		   self.goldNum=1000         --��ҽ�Ǯ��Ŀ
           self.playerType=playerType--��ҽ�Ǯ��Ŀ
           if 	playerType==1 then
		     self.baseNode:setVisible(false)
           end		   
	 end
	 --���ӹ���
function GamePlayer:addAttackMonster(monsterType,PointArray)
     local monster = MonsterObject:create()
	 monster:init(self.baseNode)
	 monster:initMonster(monsterConfig[monsterType],PointArray,self)
	  if monster ~= nil then
	       table.insert(self.monsterArray,monster)
	  end
 end 
--�Լ�������ſ�ʼ����
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
--�õ���ǰ�������ﲨ
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