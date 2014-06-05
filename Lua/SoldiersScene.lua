require "Lua/GameScene"
module("SoldiersScene",package.seeall) 
 --创建战士选择框界面
 function createSoldierBarUI()
      local soldierBarUI = ccs.GUIReader:getInstance():widgetFromJsonFile("res/GameSoldiersUI_1/GameSoldierBarUI.json");
	  if soldierBarUI ~= nil then 
	  end
	return soldierBarUI
 end
 
 	 --开始出击按钮响应
function StartAttackButtonCallback(sender, eventType)
      if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():replaceScene(GameScene.createGameScene())
	   end
 end
 --创建选人场景
function createSoldiersScene()
	local scene = cc.Scene:create()
	local soldiersUI = ccs.GUIReader:getInstance():widgetFromJsonFile("res/GameSoldiersUI_1/GameSoldiersUI_1.json");
	scene:addChild(soldiersUI)
			 local listView = soldiersUI:getChildByTag(445)
			  if listView ~= nil then
		listView:setItemsMargin(2)
		local default_item = createSoldierBarUI()
		default_item:setTouchEnabled(true)
		local itemSize=default_item:getSize()
		default_item:setScale(0.9)
		default_item:setSize(cc.size(itemSize.width, 300))
		listView:setItemModel(default_item)
				for i = 0,19 do
					listView:pushBackDefaultItem()
				end
			  end 
			  
			-- 开始出击按钮响应
		     local StartButton = soldiersUI:getChildByTag(1092):getChildByTag(102):getChildByTag(101)
			  if StartButton ~= nil then
	               StartButton:addTouchEventListener(StartAttackButtonCallback)
			  end 
			  --MoveMap=false
	return scene
end