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

Trace(VDEV_NAME .. ' daemon exit', _DEBUG)

-- variable initial
local selfID = fibaro:getSelfId()
local ipAddress = fibaro:getValue( selfID , "IPAddress" )
local tcpPort = fibaro:getValue( selfID , "TCPPort" )
Trace('Socket Server IP: ' .. ipAddress .. ' listen port: ' .. tcpPort)

Trace('current state:' .. fibaro:getGlobal(G_VAR_NAME_STATE) .. ' stop flag: ' .. fibaro:getGlobal(G_VAR_NAME_STOP))
fibaro:setGlobal(G_VAR_NAME_STOP, 'true')
local stopflag = fibaro:getGlobal(G_VAR_NAME_STOP)
fibaro:call( selfID , "setProperty" , "ui.stopflag.value" , stopflag )

