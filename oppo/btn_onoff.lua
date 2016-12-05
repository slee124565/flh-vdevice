--[[
    @Global Variable: 
        gOppo_D_Cmd: command to be sent for RPI on OPPO
        gOppo_D_State: true (activate) or false (deactivate)
        gOppo_D_Meta: json data storage for OPPO devices status
        gOppo_D_Stop: true (stop daemon) or false (daemon keep going)
        gLu_WD_Stop: true (stop watchdog) or false (watch keep going)
--]]

-- global variable in used
G_VAR_NAME_META = 'gOppo_D_Meta'
G_VAR_NAME_STATE = 'gOppo_D_State'
G_VAR_NAME_CMD = 'gOppo_D_Cmd'
G_VAR_NAME_STOP = 'gOppo_D_Stop'
G_VAR_NAME_WD_STOP = 'gOppo_WD_Stop'     -- Watch Dog Stop Flag 

VDEV_NAME = 'oppo-rpi'

-- device constant
BTN_START_ID = 2
BTN_STOP_ID = 3


-- debug function declare
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

Trace(VDEV_NAME .. ' daemon switch', _DEBUG)

-- variable initial
local selfID = fibaro:getSelfId()
local ipAddress = fibaro:getValue( selfID , "IPAddress" )
local tcpPort = fibaro:getValue( selfID , "TCPPort" )
Trace('Socket Server IP: ' .. ipAddress .. ' listen port: ' .. tcpPort)

local vdev_state = fibaro:getGlobal(G_VAR_NAME_STATE)
Trace('current state is ' .. vdev_state)
if vdev_state == 'BUSY' then
    fibaro:log('Stoping Daemon')
    Trace('active daemon stop')
    fibaro:call( selfID , "pressButton" , BTN_STOP_ID )
    
else
    fibaro:log('Starting Deamon')
    Trace('activate datemon start')
    fibaro:call( selfID , "pressButton" , BTN_START_ID )
end
