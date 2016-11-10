--[[
    @Global Variable: 
        gLu_D_Cmd: command to be sent for Lutron QS
        gLu_D_State: true (activate) or false (deactivate)
        gLu_D_Meta: json data storage for Lutron devices status
        gLu_D_Stop: true (stop daemon) or false (start daemon)
--]]

-- lutron integration ID
DEV_INTEG_ID = 11                   

-- component number
COMPONENT_NUM_BTN_1 = 1             
COMPONENT_NUM_BTN_2 = 2             
COMPONENT_NUM_BTN_3 = 3             
COMPONENT_NUM_BTN_4 = 4             
COMPONENT_NUM_BTN_5 = 5             
COMPONENT_NUM_BTN_18 = 18           
COMPONENT_NUM_BTN_19 = 19           

-- vdev config
btnCmd = '#device,' .. DEV_INTEG_ID .. ',' .. COMPONENT_NUM_BTN_18 .. ',3'
btnCmdDescription = 'button up press'

-- global variable in used
G_VAR_NAME_META = 'gLu_D_Meta'
G_VAR_NAME_STATE = 'gLu_D_State'
G_VAR_NAME_CMD = 'gLu_D_Cmd'
G_VAR_NAME_STOP = 'gLu_D_Stop'

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

Trace(btnCmdDescription, _INFO)

-- variable initial
local selfID = fibaro:getSelfId()
local ipAddress = fibaro:getValue( selfID , "IPAddress" )
local tcpPort = fibaro:getValue( selfID , "TCPPort" )
Trace('Socket Server IP: ' .. ipAddress .. ' listen port: ' .. tcpPort)

local wait_cmd = fibaro:getGlobal(G_VAR_NAME_CMD)
-- check if cmd wait
if wait_cmd ~= '' and wait_cmd ~= nil then
    Trace('wait command exist: ' .. wait_cmd, _WARNING)
    fibaro:log('busy, try later')
else
    fibaro:setGlobal(G_VAR_NAME_CMD,btnCmd)
    Trace('set cmd: ' .. btnCmd)
    fibaro:log(btnCmdDescription)
end
