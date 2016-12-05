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
G_VAR_NAME_PARM_CMD = 'gOppo_D_PCmd'
G_VAR_NAME_STOP = 'gOppo_D_Stop'
G_VAR_NAME_WD_STOP = 'gOppo_WD_Stop'     -- Watch Dog Stop Flag 
G_VAR_LIST = {G_VAR_NAME_META,
    G_VAR_NAME_STATE,
    G_VAR_NAME_CMD,
    G_VAR_NAME_PARM_CMD,
    G_VAR_NAME_STOP,
    G_VAR_NAME_WD_STOP
    }

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

--fibaro:setGlobal(G_VAR_NAME_META, '')
--fibaro:setGlobal(G_VAR_NAME_STATE, '')
--fibaro:setGlobal(G_VAR_NAME_CMD, '')
--fibaro:setGlobal(G_VAR_NAME_STOP, 'true')
for _,vName in pairs(G_VAR_LIST) do
    if vName == G_VAR_NAME_STOP then
        fibaro:setGlobal(vName, 'true')
    elseif vName ~= G_VAR_NAME_META then
        fibaro:setGlobal(vName, '')
    end
end
    

fibaro:call( selfID , "setProperty" , "ui.status.value" , '' )
fibaro:call( selfID , "setProperty" , "ui.lastcmd.value" , '' )
fibaro:call( selfID , "setProperty" , "ui.stopflag.value" , '' )
fibaro:call( selfID , "setProperty" , "ui.err.value" , '' )
