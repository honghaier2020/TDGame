require "Lua/SoldiersConfig"
module("SoldiersUI",package.seeall) 
local GameSoldiersUI=nil
local showTimerEntry=nil
local StartGameTime=30
local AddSoldierArray={}
 	 --开始出击按钮响应
function addSoldierButtonCallback(sender, eventType)
      if eventType == ccui.TouchEventType.ended then
          local listView = GameSoldiersUI:getChildByTag(445)
		   if listView ~= nil then
		        local selectIndex=  listView:getCurSelectedIndex()
				cclog("选战士%d",selectIndex) 
				local newAddSoldierType=true
				for i,addSoldierInfo in pairs(AddSoldierArray)  do
		          if  nil ~= addSoldierInfo then
				       if addSoldierInfo.soldierType==selectIndex then
					      addSoldierInfo.soldierNum=addSoldierInfo.soldierNum+1
						  newAddSoldierType=false
						  AddNewSoldierType(SoldiersConfig[selectIndex+1],i,addSoldierInfo.soldierNum)
						  break
					   end
				  end
				end
				--增加新战士类型
				if newAddSoldierType==true then
				  local addSoldierInfo={}
				  addSoldierInfo.soldierType=selectIndex
				  addSoldierInfo.soldierNum=1
				  table.insert(AddSoldierArray,addSoldierInfo)
				  local  soldierTypeNum     = table.getn(AddSoldierArray)
				  AddNewSoldierType(SoldiersConfig[selectIndex+1],soldierTypeNum,1)
				  cclog("add new Soldier") 
				end
				
		   end
	   end
 end
 --创建战士选择框界面
 function createSoldierBarUI(soldiersConfig)
      local soldierBarUI = ccs.GUIReader:getInstance():widgetFromJsonFile("res/GameSoldiersUI_1/GameSoldierBarUI.json");
	  if soldierBarUI ~= nil then 
		 local soldierHead= soldierBarUI:getChildByTag(800):getChildByTag(836)
		 soldierHead:loadTexture(soldiersConfig.soldiersHeadRes)
		 local addSoldierbutton = soldierBarUI:getChildByTag(800):getChildByTag(829)
		 if addSoldierbutton ~= nil then
	               addSoldierbutton:addTouchEventListener(addSoldierButtonCallback)
		 end 
	  end
	return soldierBarUI
 end
 
 	 --开始出击按钮响应
function StartAttackButtonCallback(sender, eventType)
      if eventType == ccui.TouchEventType.ended then
           ShowUI(false)
		   GameScene.SetAttackMonsterArray(AddSoldierArray)
	   end
 end
 --创建选人场景
function createUI()
	local soldiersUI = ccs.GUIReader:getInstance():widgetFromJsonFile("res/GameSoldiersUI_1/GameSoldiersUI_1.json");
		local listView = soldiersUI:getChildByTag(445)
			  if listView ~= nil then
		listView:setItemsMargin(2)
				for i = 0,3 do
				    local default_item = createSoldierBarUI(SoldiersConfig[i+1])
					default_item:setTouchEnabled(true)
					local itemSize=default_item:getSize()
		            default_item:setScale(0.9)
		            default_item:setSize(cc.size(itemSize.width, 300))
					listView:pushBackCustomItem(default_item)
				end
			  end 
			  
			-- 开始出击按钮响应
		     local StartButton = soldiersUI:getChildByTag(1092):getChildByTag(102):getChildByTag(101)
			  if StartButton ~= nil then
	               StartButton:addTouchEventListener(StartAttackButtonCallback)
			  end 
	GameSoldiersUI=soldiersUI
	ShowSoldierDeploy()
	return soldiersUI
end
function ShowUI(visible)
     if GameSoldiersUI ~= nil then 
	     if visible==true then
           showTimerEntry=cc.Director:getInstance():getScheduler():scheduleScriptFunc(ShowTime, 1, false)		
		 else 
		     if showTimerEntry ~= nil then 
			    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(showTimerEntry)
			 end   
		 end
	    GameSoldiersUI:setVisible(visible)
		GameSoldiersUI:setEnabled(visible)
	  end
end
--设置开始攻击的剩余时间
function ShowTime()
     StartGameTime=StartGameTime-1
     if GameSoldiersUI ~= nil then 
	    local BuildTimeText = GameSoldiersUI:getChildByTag(1092):getChildByTag(121):getChildByTag(129)
			 if BuildTimeText ~= nil then
				 BuildTimeText:setStringValue(string.format("%d",StartGameTime))
				if StartGameTime==0 then
					  ShowUI(false)
					  GameScene.SetAttackMonsterArray(AddSoldierArray)
				end	
         end	
	  end
end
--显示战士部署信息
function ShowSoldierDeploy()
  
  local  soldier1=GameSoldiersUI:getChildByTag(1212):getChildByTag(1215):getChildByTag(1217)
  soldier1:setVisible(false)
  --移除战士按钮回调
  soldier1:addTouchEventListener(removeSoldierButtonCallback)	  
  local  soldierNum1=GameSoldiersUI:getChildByTag(1212):getChildByTag(1215):getChildByTag(1218)
   soldierNum1:setStringValue(string.format("%d",0))
  local  soldier2=GameSoldiersUI:getChildByTag(1212):getChildByTag(1223):getChildByTag(1225)
  soldier2:setVisible(false)
   soldier2:addTouchEventListener(removeSoldierButtonCallback)	
  local  soldierNum2=GameSoldiersUI:getChildByTag(1212):getChildByTag(1223):getChildByTag(1226)
    soldierNum2:setStringValue(string.format("%d",0))
  local  soldier3=GameSoldiersUI:getChildByTag(1212):getChildByTag(1231):getChildByTag(1233)
  soldier3:setVisible(false)
   soldier3:addTouchEventListener(removeSoldierButtonCallback)	
  local  soldierNum3=GameSoldiersUI:getChildByTag(1212):getChildByTag(1231):getChildByTag(1234)
   soldierNum3:setStringValue(string.format("%d",0))
  local  soldier4=GameSoldiersUI:getChildByTag(1212):getChildByTag(1235):getChildByTag(1237)
   soldier4:setVisible(false)
   soldier4:addTouchEventListener(removeSoldierButtonCallback)
  local  soldierNum4=GameSoldiersUI:getChildByTag(1212):getChildByTag(1235):getChildByTag(1238)
  soldierNum4:setStringValue(string.format("%d",0))
  local  soldier5=GameSoldiersUI:getChildByTag(1212):getChildByTag(1247):getChildByTag(1249)
   soldier5:setVisible(false)
   soldier5:addTouchEventListener(removeSoldierButtonCallback)
  local  soldierNum5=GameSoldiersUI:getChildByTag(1212):getChildByTag(1247):getChildByTag(1250)
  soldierNum5:setStringValue(string.format("%d",0))
  local  soldier6=GameSoldiersUI:getChildByTag(1212):getChildByTag(1251):getChildByTag(1253)
   soldier6:setVisible(false)
   soldier6:addTouchEventListener(removeSoldierButtonCallback)
  local  soldierNum6=GameSoldiersUI:getChildByTag(1212):getChildByTag(1251):getChildByTag(1254)
  soldierNum6:setStringValue(string.format("%d",0))
  local  soldier7=GameSoldiersUI:getChildByTag(1212):getChildByTag(1243):getChildByTag(1245)
   soldier7:setVisible(false)
    soldier7:addTouchEventListener(removeSoldierButtonCallback)
  local  soldierNum7=GameSoldiersUI:getChildByTag(1212):getChildByTag(1243):getChildByTag(1246)
   soldierNum7:setStringValue(string.format("%d",0))
  local  soldier8=GameSoldiersUI:getChildByTag(1212):getChildByTag(1259):getChildByTag(1261)
   soldier8:setVisible(false)
   soldier8:addTouchEventListener(removeSoldierButtonCallback)
  local  soldierNum8=GameSoldiersUI:getChildByTag(1212):getChildByTag(1259):getChildByTag(1262)
  soldierNum8:setStringValue(string.format("%d",0))

end
   
 function AddNewSoldierType(soldiersConfig,soldierTypeIndex,soldierNum)
     local newsoldier=nil
	 local soldierNumText=nil
     if soldierTypeIndex==1 then
	   newsoldier=GameSoldiersUI:getChildByTag(1212):getChildByTag(1215):getChildByTag(1217)
       soldierNumText=GameSoldiersUI:getChildByTag(1212):getChildByTag(1215):getChildByTag(1218)
	 elseif soldierTypeIndex==2 then
	   newsoldier=GameSoldiersUI:getChildByTag(1212):getChildByTag(1223):getChildByTag(1225) 
       soldierNumText=GameSoldiersUI:getChildByTag(1212):getChildByTag(1223):getChildByTag(1226)
	 elseif soldierTypeIndex==3 then
	   newsoldier=GameSoldiersUI:getChildByTag(1212):getChildByTag(1231):getChildByTag(1233)
       soldierNumText=GameSoldiersUI:getChildByTag(1212):getChildByTag(1231):getChildByTag(1234)
	 elseif soldierTypeIndex==4 then
	     newsoldier=GameSoldiersUI:getChildByTag(1212):getChildByTag(1235):getChildByTag(1237)
         soldierNumText=GameSoldiersUI:getChildByTag(1212):getChildByTag(1235):getChildByTag(1238)
	 end
	  if newsoldier ~= nil then
	      newsoldier:loadTexture(soldiersConfig.soldiersHeadRes)
	      newsoldier:setVisible(true)
		  soldierNumText:setStringValue(string.format("%d",soldierNum))
	  end   
 end
 --移除战士回调函数
function removeSoldierButtonCallback(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
           local btnTag=sender:getTag()
		    local soldierNumText=nil
			local soldierNum=0
			local soldierIndex=0
			cclog("6666")
		   if btnTag==1217 then
		      soldierNumText=GameSoldiersUI:getChildByTag(1212):getChildByTag(1215):getChildByTag(1218)
			  soldierIndex=1
		   elseif btnTag==1225 then
		      soldierNumText=GameSoldiersUI:getChildByTag(1212):getChildByTag(1223):getChildByTag(1226)
			  soldierIndex=2
		   elseif btnTag==1233 then
		      soldierNumText=GameSoldiersUI:getChildByTag(1212):getChildByTag(1231):getChildByTag(1234)
			   soldierIndex=3
		   elseif btnTag==1237 then
		      soldierNumText=GameSoldiersUI:getChildByTag(1212):getChildByTag(1235):getChildByTag(1238)
			  soldierIndex=4
		   end
		    if soldierNumText ~= nil then
			    AddSoldierArray[soldierIndex].soldierNum=AddSoldierArray[soldierIndex].soldierNum-1
			    soldierNum=AddSoldierArray[soldierIndex].soldierNum
			    soldierNumText:setStringValue(string.format("%d",soldierNum))
				if soldierNum==0 then
				   sender:setVisible(false)
				   AddSoldierArray[soldierIndex]=nil
				end
			end
	 end
end
 