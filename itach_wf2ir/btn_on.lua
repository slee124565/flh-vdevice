-- device constant declare
BUTTON_CMD = 'POWER_ON'

-- system constant declare
G_VAR_NAME_META = 'gWF2IR_8_Meta'
G_VAR_NAME_BUSY = 'gWF2IR_8_Isbusy'
G_VAR_NAME_CMD = 'gWF2IR_8_Cmd'

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

Trace('Button ON Pressed', _DEBUG)

local selfID = fibaro:getSelfId()
local isBusy = fibaro:getGlobalValue( G_VAR_NAME_BUSY ) == "true"
if isBusy then
    Trace('device is busy', _WARNING)
    fibaro:call( selfID , "setProperty" , "ui.state.value" , DEVICE_BUSY_STRING )
else
    local cmd = fibaro:getGlobal( G_VAR_NAME_CMD ) .. " " .. BUTTON_CMD
    fibaro:setGlobal( G_VAR_NAME_CMD , cmd )
end