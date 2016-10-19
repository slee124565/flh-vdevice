local gDatas = "CM_Datas"
local gIsBusy = "CM_IsBusy"
local gSycn = "CM_Sync"
local gSycnTime = "CM_SyncTime"

local mSocketTryErrTime = 5
local mSocketRetrySec = 1

local tDebugWeights =
{
  all = 10 ,
  detail = 5 ,
  baisc = 1 ,
  none = 0 ,
}
local mDebugWeight = tDebugWeights.baisc 

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

function GetStat( _retry )
  if _retry > mSocketTryErrTime then 
    Trace( "GetStat try too many time" , 1 , "red" )
    return ""
  end
  local respose , status , errorCode = mSocket:GET( "/appeng/cmapi/stat/" )
  if CheckSocket( status , errorCode ) == false then 
    Trace( "GetStat retry" , 5 , "yellow" )
    fibaro:sleep( 1000 * mSocketRetrySec )
    return GetStat( _retry + 1 )
  end
  if respose:find( "ERROR" ) ~= nil then
    return GetStat( _retry + 1 )
  end
  return respose
end

local isBusy = fibaro:getGlobalValue( gIsBusy ) == "true"
if isBusy then
  Trace( "busing..." , 1 )
else
  local timestamp = fibaro:getGlobalModificationTime( gSycn )
  fibaro:setGlobal( gSycnTime , tostring( timestamp ) )
  
  fibaro:setGlobal( gIsBusy , "true" )
  local rawDatas = fibaro:getGlobal( gDatas )
  local datas = json.decode( rawDatas )
  local devices = datas.elements
  local deviceLength = #devices

  local response = GetStat( 0 )
  if response:len() > 0 then
    -- sync
    for uid , stat in response:gmatch( "(%d+)(.-)\r\n" ) do
      local findIdx = 0
      for i = 1 , deviceLength do
        if devices[ i ].deviceID == tonumber( uid ) then
          findIdx = i
          break
        end
      end
      
      if findIdx ~= 0 then
        local on = stat:match( "(%a+)" )
        if on == "ON" then
          devices[ findIdx ].on = true
        else
          devices[ findIdx ].on = false
        end
        
        local mode = stat:match( "(%a+)" , 22 )
        if mode == "Heat" then
          devices[ findIdx ].mode = 1
        elseif mode == "Cool" then
          devices[ findIdx ].mode = 2
        elseif mode == "Dry" then
          devices[ findIdx ].mode = 3
        elseif mode == "Fan" then
          devices[ findIdx ].mode = 4
        elseif mode:find( "Aut" ) ~= nil then
          devices[ findIdx ].mode = 5
        else
          devices[ findIdx ].mode = 6
        end
        
        local wind = stat:match( "(%a+)" , 17 )
        if wind == "Low" then
          devices[ findIdx ].wind = 1
        elseif wind == "Med" then
          devices[ findIdx ].wind = 2
        elseif wind == "High" then
          devices[ findIdx ].wind = 3
        elseif wind == "Top" then
          devices[ findIdx ].wind = 4
        else
          devices[ findIdx ].wind = 5
        end
        
        local temp = stat:match( "(%d+)" )
        devices[ findIdx ].temp = temp
        
        Trace( uid .. " : " .. on , 9 )
        Trace( uid .. " : " .. mode , 9 )
        Trace( uid .. " : " .. wind  , 9 )
        Trace( uid .. " : " .. temp .. "℃" , 9 )
        Trace( "-------------------" , 9 )
      end
    end
    
    local allSameOn , allSameMode , allSameWind , allSameTemp = true , true , true , true
    for i = 2 , deviceLength - 1 do
      if devices[ i ].on ~= devices[ 1 ].on then
        allSameOn = false
      end
      if devices[ i ].mode ~= devices[ 1 ].mode then
        allSameMode = false
      end
      if devices[ i ].wind ~= devices[ 1 ].wind then
        allSameWind = false
      end
      if devices[ i ].temp ~= devices[ 1 ].temp then
        allSameTemp = false
      end
    end
    
    if allSameOn then
      devices[ deviceLength ].on = devices[ 1 ].on
    end
    if allSameMode then
      devices[ deviceLength ].mode = devices[ 1 ].mode
    end
    if allSameWind then
      devices[ deviceLength ].wind = devices[ 1 ].wind
    end
    if allSameTemp then
      devices[ deviceLength ].temp = devices[ 1 ].temp
    end
    
    fibaro:setGlobal( gDatas , json.encode( datas ) )
    
    -- repaint
    local acID = fibaro:getValue( mSelfId , "ui.ID.value" )
    local findIdx = 0
    for i = 1 , deviceLength do
      if devices[ i ].name == acID then
        findIdx = i
        break
      end
    end
    
    local state = ""
    if devices[ findIdx ].on then
      local modeIdx = devices[ findIdx ].mode
      local windIdx = devices[ findIdx ].wind
      local tempValue = devices[ findIdx ].temp
      
      state = datas.modeNames[ modeIdx ] .. " " 
      state = state .. datas.windNames[ windIdx ] .. " " 
      if datas.tempShowModes[ modeIdx ] then
        state = state .. devices[ findIdx ].temp .. "℃"
      else
        state = state .. "　 　"
      end
    end  
    fibaro:call( mSelfId , "setProperty" , "ui.State.value" , state )
  end  
  fibaro:setGlobal( gIsBusy , "false" )
end