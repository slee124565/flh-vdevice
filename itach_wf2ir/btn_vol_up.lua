-- device constant declare
BUTTON_CMD = 'VOL_UP'

ITACH_PORT = '1:3'

IRCODE_POWER_ON = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,24,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1012,96,24,24,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1012,96,24,24,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,3144' .. '\r'
IRCODE_POWER_OFF = 'sendir,' .. ITACH_PORT .. ',1,40064,1,1,96,24,48,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,985,96,24,48,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,985,96,24,48,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,3128' .. '\r'
IRCODE_VOL_UP = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1060,96,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1060,96,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,5144' .. '\r'
IRCODE_VOL_DOWN = 'sendir,' .. ITACH_PORT .. ',1,40322,1,1,96,24,48,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1039,96,24,48,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1039,96,24,48,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,5161' .. '\r'
IRCODE_CH_UP = 'sendir,' .. ITACH_PORT .. ',1,40322,1,1,96,24,24,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1088,96,24,24,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1087,96,24,24,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,5161' .. '\r'
IRCODE_CH_DOWN = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,48,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1060,96,24,48,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1060,96,24,48,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,5144' .. '\r'
IRCODE_SELECT_INPUT = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,48,24,24,24,48,24,24,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1036,96,24,48,24,24,24,48,24,24,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1036,96,24,48,24,24,24,48,24,24,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,5144' .. '\r'

IR_DEVICE_CMDCODES = {}
IR_DEVICE_CMDCODES['POWER_ON'] = IRCODE_POWER_ON
IR_DEVICE_CMDCODES['POWER_OFF'] = IRCODE_POWER_OFF
IR_DEVICE_CMDCODES['VOL_UP'] = IRCODE_VOL_UP
IR_DEVICE_CMDCODES['VOL_DOWN'] = IRCODE_VOL_DOWN
IR_DEVICE_CMDCODES['CH_UP'] = IRCODE_CH_UP
IR_DEVICE_CMDCODES['CH_DOWN'] = IRCODE_CH_DOWN
IR_DEVICE_CMDCODES['SELECT_INPUT'] = IRCODE_SELECT_INPUT


DEVICE_STR_BUSY = 'BUSY...WAIT...'
DEVICE_STR_ON = 'ON'
DEVICE_STR_OFF = 'OFF'
DEVICE_STR_CMD_ERR = 'ERROR'

G_VAR_NAME_META = 'gWF2IR_8_Meta'
G_VAR_NAME_BUSY = 'gWF2IR_8_Isbusy'
G_VAR_NAME_CMD = 'gWF2IR_8_Cmd'

-- device constant declare end

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

Trace('service enter', _DEBUG)

-- variable initial
local selfID = fibaro:getSelfId()
local ipAddress = fibaro:getValue( selfID , "IPAddress" )
local tcpPort = fibaro:getValue( selfID , "TCPPort" )
Trace('Socket Server IP: ' .. ipAddress .. ' listen port: ' .. tcpPort)

-- socket function implement
function sendIrSocketData( _irCode )

    local socket
    local status , err = pcall(
        function() 
            socket = Net.FTcpSocket( ipAddress , tcpPort )
            socket:setReadTimeout( 3000 )
        end )  
    if status ~= nil and status ~= true then
        Trace( "socket status: " .. tostring( status or "" ) )
    end  
    if err ~= nil then
        Trace( "socket err: " .. tostring( err or "" ), _ERROR )
    else
        local bytes , errCode = socket:write( _irCode )
        if errCode == 0 then
            local rdata , errCode = socket:read()
            Trace( 'socket read result code ' .. tostring(errCode) .. ' data: ' .. tostring(rdata) )
            response = tostring(rdata)
            Trace( 'completeir index in ' .. tostring(string.find(response,'completeir')))
            if string.find(response,'completeir') == 1 then
                cmdResult = true
            else
                cmdResult = false
                Trace('socket data check fail', _ERROR)
            end
        else
            Trace( 'socket write err code ' .. tostring(errCode) )

        end
        -- socket disconnect
        socket:disconnect()
        socket = nil
        return (errCode == 0) and cmdResult    
    end
    return false
end

function sendIrSocketDataWithRetry( _irCode )
    local MAX_COUNT = 3
    local _count = 0
    while _count <= MAX_COUNT do
        if not sendIrSocketData(_irCode) then
            _count = _count + 1
            Trace('sendIrSocketDataWithRetry retry ' .. _count)
        else
            break
        end
    end
end

-- doCmds function
Trace( 'execute cmd: ' .. tostring(BUTTON_CMD) .. ' ...', _INFO)
local state = 'SendIr CMD ' .. BUTTON_CMD
sendIrSocketDataWithRetry(IR_DEVICE_CMDCODES[BUTTON_CMD])
Trace( 'execute cmd finished', _INFO)

