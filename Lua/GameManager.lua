require "Lua/MonsterConfig" 
--怪物数组
 MonsterArray = {}
--效果数组
 EffectArray = {}
--炮塔数组
TowerArray = {}
--怪物运行路径数组
PointArray = {}
--子弹数组
BulletArray = {}
--游戏主场景
GameMainScene=nil 
WinSize = cc.Director:getInstance():getWinSize()
Play1Hp=20
Play2Hp=20
play1HpUI=nil
play2HpUI=nil
RefreshMonsterNum=20
--游戏主界面
GameMainUI=nil
GameMap=nil 
--游戏状态   0  建造状态  1 战斗状态 2战斗结束状态
GameState=0 