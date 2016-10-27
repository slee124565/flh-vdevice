-- device constant declare
BUTTON_CMD = 'CH_UP'
DEVICE_SOCKET_BTN_ID = 24

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

Trace('Button ' .. BUTTON_CMD .. ' Pressed', _DEBUG)

local selfID = fibaro:getSelfId()

function sendButtonCmd()
    cmd_wait = fibaro:getGlobal( G_VAR_NAME_CMD )
    if cmd_wait == '' then
        Trace('send cmd ' .. BUTTON_CMD)
        fibaro:setGlobal( G_VAR_NAME_CMD , BUTTON_CMD )
        fibaro:call( selfID , "pressButton" , DEVICE_SOCKET_BTN_ID )
        return true
    else
        Trace('previous cmd wait for execute', _WARNING)
        fibaro:call( selfID , "pressButton" , DEVICE_SOCKET_BTN_ID )
        return false
    end
end

function sendButtonCmdWithRetry()
    MAX_COUNT = 3
    _count = 0
    while _count < MAX_COUNT do
        if sendButtonCmd() == false then
            _count = _count + 1
            Trace('sendButtonCmd for ' .. BUTTON_CMD .. ' try ' .. _count)
            fibaro:sleep(150)
        else
            break
        end
    end
end

Trace('send cmd ' .. BUTTON_CMD)
fibaro:setGlobal( G_VAR_NAME_CMD , BUTTON_CMD )
fibaro:call( selfID , "pressButton" , DEVICE_SOCKET_BTN_ID )

