--[[
  @author eFa
  @date   105.03.09
  @brief  cool master簡易遙控器

  @note   記得建立Global Value [gDatas]、[gCmds]、[gSync]、[gSyncTime]、[gIsBusy]
		  記得填寫IP及Port，Port預設80
		  根據不同CoolMaster型號，支援的模式跟風量功能有所區別，同步修改模式按鍵及風量按鍵的功能id

  @date   105.03.09 by eFa . 更新 sync更改為須同步且遙控器閒置幾秒才開始
		  105.05.25	by eFa . 修正 對predefine global value取得值（從index值改為實際string，需配合Fibaro系統版本）
						   . 修正 Update按鈕內最後gCmds的將重新再抓一次值，避免此時外部按鈕增加指令，而被一同清除，造成miss指令
--]]
if mtDatas == nil then
  
  --[[參數設定 開始]]--
  
  -- global value
  gDatas = "CM_Datas"
  gCmds = "CM_Cmds"
  gSync = "CM_Sync"
  gSyncTime = "CM_SyncTime"
  gIsBusy = "CM_IsBusy"
  gIsUpdate = "CM_IsUpdate"
  
  -- 設備UID（程式會自動加入 控制全部冷氣但ID為0的設備）
  tSetupDevices = 
  { 
    -- uid      面板顯示名稱      支援模式：暖氣/冷氣/除濕/送風/自動/其他
    { uid = 100 , name = "冷氣1" , tModeEnable = { true , true , true , true , true , true } } ,
    { uid = 101 , name = "冷氣2" , tModeEnable = { true , true , true , true , true , true } } ,
    { uid = 102 , name = "冷氣3" , tModeEnable = { true , true , true , true , true , true } } ,
    { uid = 103 , name = "冷氣4" , tModeEnable = { true , true , true , true , true , true } } ,
    { uid = 104 , name = "冷氣5" , tModeEnable = { true , true , true , true , true , true } } ,
    { uid = 105 , name = "冷氣6" , tModeEnable = { true , true , true , true , true , true } } ,
    { uid = 106 , name = "冷氣7" , tModeEnable = { true , true , true , true , true , true } } ,
    { uid = 107 , name = "冷氣8" , tModeEnable = { true , true , true , true , true , true } } ,
    { uid = 108 , name = "冷氣9" , tModeEnable = { true , true , true , true , true , true } } ,
    { uid = 109 , name = "交換機" , tModeEnable = { true , true , true , true , true , true } } ,
}
  
  -- 功能範圍，目前寫死不能動
  mModes = { "暖氣" , "冷氣" , "除濕" , "送風" , "自動" , "其他" }
  mTempDisplayModes = { true , true , false , false , true , false }
  mDefaultMode = 2
  
  -- 風量範圍，目前寫死不能動
  mWinds = { "微　風" , "弱　風" , "強　風" , "超強風" , "自動風" }
  mDefaultWind = 2
  
  -- 溫度範圍
  mMaxTemp = 32
  mMinTemp = 16
  mDefaultTemp = math.floor( ( mMaxTemp + mMinTemp ) / 2 )
  
  -- 更新頻率
  mCmdUpdateSec = 3  -- 指令輸入完多久後送出
  mInfoCleanSec = 6  -- 資訊在畫面維持時間
  mCmdButton = "17"
  mSyncButton = "18"
  
  -- 命令，需與按鈕送出命令相同(與update button同步)
  mExitCmd = " EXIT"
  mPowCmd = " POWER_"
  mSetCmd = " SETTING_"
  
  -- 同步啟動參數
  mWaitSyncSec = 6
  
  -- debug
  tDebugWeights =
  {
    all = 10 ,
    detail = 5 ,
    baisc = 1 ,
    none = 0 ,
  }
  mDebugWeight = tDebugWeights.baisc 
  
  --[[參數設定 結束]]--
  modeRange = #mModes
  windRange = #mWinds
  tempRange = mMaxTemp - mMinTemp + 1

  function Trace( _text , _weight , _color )
    _weight = _weight or 0
	_color = _color or "white"
    if mDebugWeight >= _weight then
      fibaro:debug( '<span style="color:' .. _color .. '">' .. tostring( _text ) .. '</span>' )
    end
  end
   
  -- 建立冷氣資料
  mtDatas = { elements = {} }
  tDevices = mtDatas.elements
  
  for i = 1 , #tSetupDevices do
    local tTable =
    {
      deviceID = tSetupDevices[ i ].uid ,
      name = tSetupDevices[ i ].name , 
      modeEnable = tSetupDevices[ i ].tModeEnable ,
    }
    table.insert( tDevices , tTable )
  end
  
  -- 控制全部的冷氣
  local tTable =
  {
    deviceID = 0 ,
    name = "全部" , 
    modeEnable = { true , true , true , true , },
  }
  table.insert( tDevices , tTable )
  
  deviceCount = #tDevices
  -- 冷氣資料補全初始化
  for i = 1 , deviceCount do
    tDevices[ i ].on = false
    tDevices[ i ].mode = mDefaultMode
    if tDevices[ i ].modeEnable[ mDefaultMode ] ~= true then
      for j = 1 , modeRange do
        if tDevices[ i ].modeEnable[ j ] then
          tDevices[ i ].mode = j
          break
        end
      end
    end
    tDevices[ i ].temp = mDefaultTemp
    tDevices[ i ].wind = mDefaultWind
  end
  
  -- 冷氣常數儲存
  mtDatas.modeNames = mModes
  mtDatas.windNames = mWinds
  mtDatas.tempShowModes = mTempDisplayModes
  mtDatas.tempMax = mMaxTemp
  mtDatas.tempMin = mMinTemp
  
  mSelfId = fibaro:getSelfId()
  mIdleTime = 0
  
  -- 顯示設定
  displayID = deviceCount
  if deviceCount <= 2 then 
    displayID = 1
  end
  fibaro:call( mSelfId , "setProperty" , "ui.ID.value" , tDevices[ displayID ].name )
  fibaro:call( mSelfId , "setProperty" , "ui.State.value" , "" )
  fibaro:call( mSelfId , "setProperty" , "ui.Info.value" , "" )  
  
  -- 顯示匯入裝置資訊
  for i = 1 , deviceCount do
    Trace( tDevices[ i ].deviceID , 1 )
    Trace( tDevices[ i ].name , 1 )
    Trace( "on : " .. tostring( tDevices[ i ].on ) , 1 )
    Trace( "modeEnable : " .. json.encode( tDevices[ i ].modeEnable ) , 1 )
    Trace( mModes[ tDevices[ i ].mode ] .. " " .. mWinds[ tDevices[ i ].wind ] .. " " .. tDevices[ i ].temp .. "℃" , 1 )
  end
  
  fibaro:setGlobal( gDatas , json.encode( mtDatas ) )
  fibaro:setGlobal( gCmds , "" )
  fibaro:setGlobal( gSyncTime , tostring( fibaro:getGlobalModificationTime( gSync ) ) )
  fibaro:setGlobal( gIsBusy , "false" )
  fibaro:setGlobal( gIsUpdate , "false" )
  
  -- first sync
  fibaro:sleep( 500 )
  fibaro:call( mSelfId , "pressButton" , mSyncButton )
end

-- main loop

local time = os.time()

local isBusy = fibaro:getGlobalValue( gIsBusy ) == "true"
local isUpdate = fibaro:getGlobalValue( gIsUpdate ) == "true"

if not ( isBusy or isUpdate ) then
  local cmds = fibaro:getGlobal( gCmds )
  if cmds ~= "" then
    mIdleTime = time
    if cmds:match( mExitCmd ) ~= null then
      Trace( cmds , 4 , "red" )
      fibaro:call( mSelfId , "pressButton" , mCmdButton )
    else
      cmdTimeStamp = fibaro:getGlobalModificationTime( gCmds )
      if time - cmdTimeStamp >= mCmdUpdateSec then
        Trace( cmds , 4 , "yellow" )
        fibaro:call( mSelfId , "pressButton" , mCmdButton )
      else
        Trace( cmds , 4 )
      end
    end
  else
    local lastSyncTimeStamp = fibaro:getGlobalValue( gSyncTime )    
    local syncTimeStamp = tostring(fibaro:getGlobalModificationTime( gSync ) )
    if syncTimeStamp ~= lastSyncTimeStamp then
      if time - mIdleTime > mWaitSyncSec  then
        mIdleTime = time
        fibaro:call( mSelfId , "pressButton" , mSyncButton )
      end
    end
  end
else
  mIdleTime = time
end

local infoTimeStamp = fibaro:getModificationTime( mSelfId , "ui.Info.value" )
if time - infoTimeStamp >= mInfoCleanSec then
  fibaro:call( mSelfId , "setProperty" , "ui.Info.value" , "" )
end