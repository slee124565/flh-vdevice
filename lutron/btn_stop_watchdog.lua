--[[
    @Global Variable: 
        gLu_D_Cmd: command to be sent for Lutron QS
        gLu_D_State: true (activate) or false (deactivate)
        gLu_D_Meta: json data storage for Lutron devices status
        gLu_D_Stop: true (stop daemon) or false (start daemon)
--]]

-- device constant
ACCOUNT = 'fibaro'
PASSWORD = 'fibaro'

-- global variable in used
G_VAR_NAME_META = 'gLu_D_Meta'
G_VAR_NAME_STATE = 'gLu_D_State'
G_VAR_NAME_CMD = 'gLu_D_Cmd'
G_VAR_NAME_STOP = 'gLu_D_Stop'
G_VAR_NAME_WD_STOP = 'gLu_WD_Stop'     -- Watch Dog Stop Flag 

-- debug function declare
_DEBUG = 10
_INFO = 20
_WARNING = 30
_ERROR = 40
logLevel = _INFO

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

Trace('lutron watch dog stop', _DEBUG)

-- variable initial
local selfID = fibaro:getSelfId()
local ipAddress = fibaro:getValue( selfID , "IPAddress" )
local tcpPort = fibaro:getValue( selfID , "TCPPort" )
Trace('Socket Server IP: ' .. ipAddress .. ' listen port: ' .. tcpPort)

Trace('current watchdog stop flag:' .. tostring(fibaro:getGlobal(G_VAR_NAME_WD_STOP)))
fibaro:setGlobal(G_VAR_NAME_WD_STOP, 'true')
fibaro:log('stop watch dog')
