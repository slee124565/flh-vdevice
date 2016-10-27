local gDatas = "CM_Datas"
local gCmds = "CM_Cmds"
local gIsBusy = "CM_IsBusy"
local gIsUpdate = "CM_IsUpdate"

local mSocketTryErrTime = 5
local mSocketRetrySec = 1

local mExitCmd = " EXIT"
local mPowCmd = " POWER_"
local mSetCmd = " SETTING_"

local tDebugWeights =
{
  all = 10 ,
  detail = 5 ,
  baisc = 1 ,
  none = 0 ,
}
local mDebugWeight = tDebugWeights.all 

function Trace( _text , _weight , _color )
  _weight = _weight or 0
  _color = _color or "white"
  if mDebugWeight >= _weight then
    fibaro:debug( '<span style="color:' .. _color .. '">' .. tostring( _text ) .. '</span>' )
  end
end

local mSelfId = fibaro:getSelfId()
local mIPAddress = fibaro:getValue( mSelfId , "IPAddress" )
local mPort = fibaro:getValue( mSelfId , "TCPPort" )
local mSocket = Net.FHttp( mIPAddress , mPort )

local temp = fibaro:getGlobal( gDatas )
local mDatas = json.decode( temp )
local mDevices = mDatas.elements
local mDeviceCount = #mDevices

function CheckSocket( _status , _errorCode )
  if _errorCode > 0 then
    Trace( "error code: " .. tostring( _errorCode ) , 5 , "yellow" )
    return false
  else
    local status = tonumber( _status )
    if status < 200 or status >= 300 then 
      Trace( "status: " .. _status , 5 , "yellow" )
      return false
    end
  end  
  return true
end

function DoTurnOffAll( _errorTime )
  if _errorTime > mSocketTryErrTime then 
    Trace( "DoTurnOffAll try too many time" , 0 , "red" )
    return 
  end
  local respose , status , errorCode = mSocket:GET( "/appeng/cmapi/alloff/" )
  Trace( "alloff = " .. respose , 9 , "white" )
  if CheckSocket( status , errorCode ) == false then 
    Trace( "DoTurnOffAll retry" , 5 , "yellow" )
    fibaro:sleep( 1000 * mSocketRetrySec )
    DoTurnOffAll( _errorTime + 1 )
  end
end

function DoTurnOff( _idx , _errorTime )
  if _errorTime > mSocketTryErrTime then 
    Trace( "DoTurnOff try too many time" , 0 , "red" )
    return 
  end
  local respose , status , errorCode = mSocket:GET( "/appeng/cmapi/off/?arg=" .. _idx )
  Trace( "off = " .. respose , 9 , "white" )
  if CheckSocket( status , errorCode ) == false then 
    Trace( "DoTurnOff retry" , 5 , "yellow" )
    fibaro:sleep( 1000 * mSocketRetrySec )
    DoTurnOff( _idx , _errorTime + 1 )
  end
end 

function DoTurnOn( _idx , _errorTime )
  if _errorTime > mSocketTryErrTime then 
    Trace( "DoTurnOn try too many time" , 0 , "red" )
    return 
  end
  local respose , status , errorCode = mSocket:GET( "/appeng/cmapi/on/?arg=" .. _idx )
  Trace( "on = " .. respose , 9 , "white" )
  if CheckSocket( status , errorCode ) == false then 
    Trace( "DoTurnOn retry" , 5 , "yellow" )
    fibaro:sleep( 1000 * mSocketRetrySec )
    DoTurnOn( _idx , _errorTime + 1 )
  end
end 

function DoMode( _idx , _mode , _errorTime )
  if _errorTime > mSocketTryErrTime then 
    Trace( "DoMode try too many time" , 0 , "red" )
    return 
  end
  local respose , status , errorCode = mSocket:GET( "/appeng/cmapi/" .. _mode .. "/?arg=" .. _idx )
  Trace( "mode = " .. respose , 9 , "white" )
  if CheckSocket( status , errorCode ) == false then 
    Trace( "DoMode retry" , 5 , "yellow" )
    fibaro:sleep( 1000 * mSocketRetrySec )
    DoMode( _idx , _mode , _errorTime + 1 )
  end
end 

function DoWind( _idx , _wind , _errorTime )
  if _errorTime > mSocketTryErrTime then 
    Trace( "DoWind try too many time" , 0 , "red" )
    return 
  end
  local respose , status , errorCode = mSocket:GET( "/appeng/cmapi/fspeed/?arg=" .. _idx .. " " .. _wind )
  Trace( "wind = " .. respose , 9 , "white" )
  if CheckSocket( status , errorCode ) == false then 
    Trace( "DoWind retry" , 5 , "yellow" )
    fibaro:sleep( 1000 * mSocketRetrySec )
    DoWind( _idx , _wind , _errorTime + 1 )
  end
end 

function DoTemp( _idx , _temp , _errorTime )
  if _errorTime > mSocketTryErrTime then 
    Trace( "DoTemp try too many time" , 0 , "red" )
    return 
  end
  local respose , status , errorCode = mSocket:GET( "/appeng/cmapi/temp/?arg=" .. _idx .. "" .. tostring( _temp ) )
  Trace( "temp = " .. respose , 9 , "white" )
  if CheckSocket( status , errorCode ) == false then 
    Trace( "DoTemp retry" , 5 , "yellow" )
    fibaro:sleep( 1000 * mSocketRetrySec )
    DoTemp( _idx , _temp , _errorTime + 1 )
  end
end 

function DoSetting( _idx )
  local idx = mDevices[ _idx ].deviceID
  local modeIdx = mDevices[ _idx ].mode
  local mode = "auto"
  if modeIdx == 1 then
    mode = "heat"
  elseif modeIdx == 2 then
    mode = "cool"
  elseif modeIdx == 3 then
    mode = "dry"
  elseif modeIdx == 4 then
    mode = "fan"
  elseif modeIdx == 5 then
    mode = "auto"
  end
  local windIdx = mDevices[ _idx ].wind
  local wind = "a"
  if windIdx == 1 then
    wind = "l"
  elseif windIdx == 2 then
    wind = "m"
  elseif windIdx == 3 then
    wind = "h"
  elseif windIdx == 4 then
    wind = "t"
  end
  DoTurnOn( idx , 0 )
  DoMode( idx , mode , 0 )
  DoWind( idx , wind , 0 )
  if modeIdx == 1 or modeIdx == 2 then
    DoTemp( idx , mDevices[ _idx ].temp , 0 )
  end
end

function DoCmds( _cmds )
  if _cmds == "" then 
    Trace( "no cmds" , 9 , "white" )
    return 
  end
  
  local idx , powCount = 0 , 0
  for cmd in _cmds:gmatch( mPowCmd .. "(%d+)" ) do
    powCount = powCount + 1
    idx = tonumber( cmd )
  end
  Trace( "power count = " .. powCount , 9 , "white" )
  if powCount ~= 0 then
    if idx ~= nil then
      Trace( "idx form power cmd = " .. idx , 9 , "white" )
    else
      Trace( "cann't find idx form power cmd" , 0 , "red" )
    end
  else
    idx = tonumber( _cmds:match( mSetCmd .. "(%d+)" ) )
    if idx ~= nil then
      Trace( "idx form setting cmd = " .. idx , 9 , "white" )
    else
      Trace( "cann't find idx form setting cmd" , 0 , "red" )
    end
  end

  if idx == nil or idx <= 0 then return end
  -- 關機
  if mDevices[ idx ].on == false then
    Trace( "#" .. idx .. " power off" , 4 , "yellow" )
    if idx == mDeviceCount then
      DoTurnOffAll( 0 )
    else
      DoTurnOff( mDevices[ idx ].deviceID , 0 )
    end
  -- 設值
  else
    Trace( "#" .. idx .. " setting" , 4 , "yellow" )
    if idx == mDeviceCount then
      for i = 1 , mDeviceCount - 1 do
        if mDevices[ i ].on == true then
          if mDevices[ i ].modeEnable[ mDevices[ mDeviceCount ].mode ] then
            DoSetting( i )
          end
        end
      end
    else
      DoSetting( idx )
    end
  end
end

local isBusy = fibaro:getGlobalValue( gIsBusy ) == "true"
local isUpdate = fibaro:getGlobalValue( gIsUpdate ) == "true"

if isBusy or isUpdate then
  Trace( "busing..." , 1 )
else
  fibaro:setGlobal( gIsUpdate , "true" )
  local cmds = fibaro:getGlobal( gCmds )
  Trace( cmds , 9 , "white" )
  local begin , head , tail = 1 , 1 , 1
  while head ~= nil do
    head , tail = cmds:find( mExitCmd , begin )
    Trace( "begin: " .. tostring( begin ) .. " head: " .. tostring( head ) .. " tail: " .. tostring( tail ) , 9 , "purple" )
    if head == nil then
      if begin == 1 then
        Trace( "do all cmds : " .. cmds , 9 , "green" )
        DoCmds( cmds:sub( begin ) )
        --[[避免update過程，指令增加後被刪除掉，因此從新取值]]--
        begin = cmds:len() + 1
      end
    else
      Trace( "do cmds : " .. cmds:sub( begin , head - 1 ) , 9 , "green" )
      DoCmds( cmds:sub( begin , head - 1 ) )
      begin = tail + 1
    end
  end
  
  --[[避免update過程，指令增加後被刪除掉，因此從新取值]]--
  cmds = fibaro:getGlobal( gCmds )
  local ret = cmds:sub( begin )
  Trace( "is empty? " .. tostring( ret == nil ) .. " / " .. begin , 9 , "purple" )
  --[[避免update過程，指令增加後被刪除掉，因此從新取值]]--
  if ret == nil then
    ret = ""
  end
  Trace( "return : " .. ret , 9 , "purple" )
  fibaro:setGlobal( gCmds , ret )
  fibaro:setGlobal( gIsUpdate , "false" )
end