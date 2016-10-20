--[[
  @author Lee Shiueh
  @date   2016.10.19
  @brief  send ir via GlobalCache WF2IR by socket connection

  @note   記得建立Global Value [gWF2IR_n_Meta], [gWF2IR_n_Isbusy], [gWF2IR_n_Cmd], [gWF2IR_n_CmdTime]
		  記得填寫IP及Port，Port預設80

--]]

-- device constant delcare

DEVICE_SOCKET_BTN_ID = 24               -- TODO: script auto config

-- system constant declare

G_VAR_NAME_META = 'gWF2IR_8_Meta'      -- TODO: script auto check and create
G_VAR_NAME_BUSY = 'gWF2IR_8_Isbusy'    -- TODO: script auto check and create
G_VAR_NAME_CMD = 'gWF2IR_8_Cmd'        -- TODO: script auto check and create


_DEBUG = 10
_INFO = 20
_WARNING = 30
_ERROR = 40
logLevel = _DEBUG 

function Trace( _text , _weight )
    _weight = _weight or _DEBUG
  	if _weight == _INFO then
    	_color = 'white'
    elseif _weight >= _WARNING then
    	_color = 'red'
    else
    	_color = "gray"
    end
    if _weight >= logLevel then
        fibaro:debug( '<span style="color:' .. _color .. '">' .. tostring( _text ) .. '</span><p>' )
    end
end

-- initialize system global variable
if mtMeta == nil then
    
  	Trace('virtual device initialization ...')
    mtMeta = { text = DEVICE_TEXT, mode = DEVICE_MODE_COOL }
    
    fibaro:setGlobal( G_VAR_NAME_META , json.encode( mtMeta ) )
    fibaro:setGlobal( G_VAR_NAME_CMD , '' )
    fibaro:setGlobal( G_VAR_NAME_BUSY , "false")
  
    mSelfId = fibaro:getSelfId()
    --fibaro:call( mSelfId , "setProperty" , "ui.ID.value" , tDevices[ displayID ].name )
    --fibaro:call( mSelfId , "setProperty" , "ui.State.value" , "" )
    --fibaro:call( mSelfId , "setProperty" , "ui.Info.value" , "" )  
  
end

-- main loop

local time = os.time()
local isBusy = fibaro:getGlobalValue( G_VAR_NAME_BUSY ) == "true"
--Trace('device busy is ' .. tostring(isBusy), _DEBUG)

if not isBusy then
    local cmds = fibaro:getGlobal( G_VAR_NAME_CMD )
    if cmds ~= "" then
        --mIdleTime = time
        Trace('get cmds : ' .. tostring(cmds))
        fibaro:call( mSelfId , "pressButton" , DEVICE_SOCKET_BTN_ID )
    else
        Trace( 'no cmd idle' , _DEBUG )
    end
else
    Trace('busy skip')
end
