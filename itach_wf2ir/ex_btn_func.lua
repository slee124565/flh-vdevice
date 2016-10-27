local gDatas = "CM_Datas"
local gCmds = "CM_Cmds"
local gIsBusy = "CM_IsBusy"
local windIdx = 3

local selfID = fibaro:getSelfId()
local isBusy = fibaro:getGlobalValue( gIsBusy ) == "true"
if isBusy then
  fibaro:call( selfID , "setProperty" , "ui.Info.value" , "BUSY...WAIT..." )
else
  if fibaro:getValue( selfID , "ui.State.value" ) ~= "" then
    local acID = fibaro:getValue( selfID , "ui.ID.value" )
    local rawDatas = fibaro:getGlobal( gDatas )
    local datas = json.decode( rawDatas )
    local devices = datas.elements
    local deviceLength = #devices
    local findIdx = 0
    for i = 1 , deviceLength do
      if devices[ i ].name == acID then
        findIdx = i
        break
      end
    end
    
    devices[ findIdx ].wind = windIdx 
    
    if findIdx == deviceLength then
      local modeIdx = devices[ deviceLength ].mode
      local tempValue = devices[ deviceLength ].temp
      for i = 1 , deviceLength - 1 do
        if devices[ i ].on and devices[ i ].modeEnable[ modeIdx ] then
          devices[ i ].mode = modeIdx 
          devices[ i ].wind = windIdx
          devices[ i ].temp = tempValue
        end
      end
    else
      local allSame = true
      for i = 1 , deviceLength - 1 do
        if devices[ i ].wind ~= windIdx and devices[ i ].on then
          allSame = false
          break
        end
      end
      if allSame then
        devices[ deviceLength ].wind = windIdx
      end
    end
    
    local modeIdx = devices[ findIdx ].mode
    local state = datas.modeNames[ modeIdx ] .. " " 
    state = state .. datas.windNames[ windIdx ] .. " " 
    if datas.tempShowModes[ modeIdx ] then
      state = state .. devices[ findIdx ].temp .. "℃"
    else
      state = state .. "　 　"
    end
    
    fibaro:call( selfID , "setProperty" , "ui.State.value" , state )
     
    fibaro:setGlobal( gDatas , json.encode( datas ) )
    local cmd = fibaro:getGlobal( gCmds ) .. " SETTING_" .. findIdx
    fibaro:setGlobal( gCmds , cmd )
  end
end