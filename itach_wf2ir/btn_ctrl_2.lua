-- device constant declare
ITACH_PORT = '1:3'

IRCODE_POWER_ON = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,24,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1012,96,24,24,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1012,96,24,24,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,3144' .. '\r'
IRCODE_POWER_OFF = 'sendir,' .. ITACH_PORT .. ',1,40064,1,1,96,24,48,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,985,96,24,48,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,985,96,24,48,24,48,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,3128' .. '\r'
IRCODE_VOL_UP = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1060,96,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1060,96,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,5144' .. '\r'
IRCODE_VOL_DOWN = 'sendir,' .. ITACH_PORT .. ',1,40322,1,1,96,24,48,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1039,96,24,48,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1039,96,24,48,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,5161' .. '\r'
IRCODE_CH_UP = 'sendir,' .. ITACH_PORT .. ',1,40322,1,1,96,24,24,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1088,96,24,24,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1087,96,24,24,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,5161' .. '\r'
IRCODE_CH_DOWN = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,48,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1060,96,24,48,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1060,96,24,48,24,24,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,5144' .. '\r'
IRCODE_SELECT_INPUT = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,48,24,24,24,48,24,24,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1036,96,24,48,24,24,24,48,24,24,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1036,96,24,48,24,24,24,48,24,24,24,24,24,48,24,24,24,48,24,24,24,24,24,24,24,24,5144' .. '\r'
IRCODE_VID2 = 'sendir,' .. ITACH_PORT .. ',1,40064,1,1,96,24,48,24,48,24,48,24,24,24,48,24,48,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,48,769,96,24,48,24,48,24,48,24,24,24,48,24,48,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,48,769,96,24,48,24,48,24,48,24,24,24,48,24,48,24,48,24,24,24,24,24,48,24,24,24,24,24,48,24,24,24,48,5128' .. '\r'
IRCODE_COMPONENT = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,48,24,24,24,48,24,48,24,24,24,24,24,48,24,48,24,24,24,24,24,24,24,24,1012,96,24,48,24,24,24,48,24,48,24,24,24,24,24,48,24,48,24,24,24,24,24,24,24,24,1012,96,24,48,24,24,24,48,24,48,24,24,24,24,24,48,24,48,24,24,24,24,24,24,24,24,5144' .. '\r'
IRCODE_MUTE = 'sendir,' .. ITACH_PORT .. ',1,40064,1,1,96,24,24,24,24,24,48,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1057,96,24,24,24,24,24,48,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,1056,96,24,24,24,24,24,48,24,24,24,48,24,24,24,24,24,48,24,24,24,24,24,24,24,24,5128' .. '\r'
IRCODE_MENU = 'sendir,' .. ITACH_PORT .. ',1,40064,1,1,96,24,24,24,24,24,24,24,24,24,24,24,48,24,48,24,48,24,24,24,24,24,24,24,24,1057,96,24,24,24,24,24,24,24,24,24,24,24,48,24,48,24,48,24,24,24,24,24,24,24,24,1056,96,24,24,24,24,24,24,24,24,24,24,24,48,24,48,24,48,24,24,24,24,24,24,24,24,5128' .. '\r'
IRCODE_MENU_SELECT = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,48,24,48,24,24,24,24,24,48,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1012,96,24,48,24,48,24,24,24,24,24,48,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1012,96,24,48,24,48,24,24,24,24,24,48,24,48,24,24,24,48,24,24,24,24,24,24,24,24,5144' .. '\r'
IRCODE_UP = 'sendir,' .. ITACH_PORT .. ',1,40064,1,1,96,24,24,24,24,24,48,24,24,24,48,24,48,24,48,24,48,24,24,24,24,24,24,24,24,988,96,24,24,24,24,24,48,24,24,24,48,24,48,24,48,24,48,24,24,24,24,24,24,24,24,988,96,24,24,24,24,24,48,24,24,24,48,24,48,24,48,24,48,24,24,24,24,24,24,24,24,5128' .. '\r'
IRCODE_LEFT = 'sendir,' .. ITACH_PORT .. ',1,40000,1,1,97,24,24,23,24,23,48,23,24,23,48,23,48,23,24,23,48,23,24,23,24,23,24,23,24,1031,97,24,24,23,24,23,48,23,24,23,48,23,48,23,24,23,48,23,24,23,24,23,24,23,24,1031,97,24,24,23,24,23,48,23,24,23,48,23,48,23,24,23,48,23,24,23,24,23,24,23,24,1038,97,24,24,23,24,23,48,23,24,23,48,23,48,23,24,23,48,23,24,23,24,23,24,23,24,5128' .. '\r'
IRCODE_SELECT = 'sendir,' .. ITACH_PORT .. ',1,40000,1,1,97,24,48,23,24,23,48,23,24,23,24,23,48,23,48,23,48,23,24,23,24,23,24,23,24,1008,97,24,48,23,24,23,48,23,24,23,24,23,48,23,48,23,48,23,24,23,24,23,24,23,24,1014,97,24,48,23,24,23,48,23,24,23,24,23,48,23,48,23,48,23,24,23,24,23,24,23,24,5128' .. '\r'
IRCODE_RIGHT = 'sendir,' .. ITACH_PORT .. ',1,40192,1,1,96,24,48,24,48,24,24,24,24,24,48,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1012,96,24,48,24,48,24,24,24,24,24,48,24,48,24,24,24,48,24,24,24,24,24,24,24,24,1012,96,24,48,24,48,24,24,24,24,24,48,24,48,24,24,24,48,24,24,24,24,24,24,24,24,5144' .. '\r'
IRCODE_DOWN = 'sendir,' .. ITACH_PORT .. ',1,40064,1,1,96,24,48,24,24,24,48,24,24,24,48,24,48,24,48,24,48,24,24,24,24,24,24,24,24,964,96,24,48,24,24,24,48,24,24,24,48,24,48,24,48,24,48,24,24,24,24,24,24,24,24,964,96,24,48,24,24,24,48,24,24,24,48,24,48,24,48,24,48,24,24,24,24,24,24,24,24,5128' .. '\r'
IRCODE_BACK = 'sendir,' .. ITACH_PORT .. ',1,40064,1,1,96,24,48,24,48,24,24,24,24,24,24,24,48,24,48,24,48,24,24,24,24,24,24,24,24,1009,96,24,48,24,48,24,24,24,24,24,24,24,48,24,48,24,48,24,24,24,24,24,24,24,24,1009,96,24,48,24,48,24,24,24,24,24,24,24,48,24,48,24,48,24,24,24,24,24,24,24,24,5128' .. '\r'
IRCODE_HDMI1 = 'sendir,' .. ITACH_PORT .. ',4,40000,1,1,96,24,24,24,48,24,24,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,48,24,48,24,24,24,24,24,24,810,96,24,24,24,48,24,24,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,48,24,48,24,24,24,24,24,24,810,96,24,24,24,48,24,24,24,48,24,48,24,24,24,48,24,24,24,48,24,24,24,48,24,48,24,24,24,24,24,24,5128' .. '\r'

IR_DEVICE_CMDCODES = {}
IR_DEVICE_CMDCODES['VID2'] = IRCODE_VID2
IR_DEVICE_CMDCODES['COMPONENT'] = IRCODE_COMPONENT
IR_DEVICE_CMDCODES['MUTE'] = IRCODE_MUTE
IR_DEVICE_CMDCODES['MENU'] = IRCODE_MENU
IR_DEVICE_CMDCODES['MENU_SELECT'] = IRCODE_MENU_SELECT
IR_DEVICE_CMDCODES['UP'] = IRCODE_UP
IR_DEVICE_CMDCODES['LEFT'] = IRCODE_LEFT
IR_DEVICE_CMDCODES['SELECT'] = IRCODE_SELECT
IR_DEVICE_CMDCODES['RIGHT'] = IRCODE_RIGHT
IR_DEVICE_CMDCODES['DOWN'] = IRCODE_DOWN
IR_DEVICE_CMDCODES['BACK'] = IRCODE_BACK
IR_DEVICE_CMDCODES['HDMI1'] = IRCODE_HDMI1
IR_DEVICE_CMDCODES['POWER_ON'] = IRCODE_POWER_ON
IR_DEVICE_CMDCODES['POWER_OFF'] = IRCODE_POWER_OFF
IR_DEVICE_CMDCODES['VOL_UP'] = IRCODE_VOL_UP
IR_DEVICE_CMDCODES['VOL_DOWN'] = IRCODE_VOL_DOWN
IR_DEVICE_CMDCODES['CH_UP'] = IRCODE_CH_UP
IR_DEVICE_CMDCODES['CH_DOWN'] = IRCODE_CH_DOWN
IR_DEVICE_CMDCODES['SELECT_INPUT'] = IRCODE_SELECT_INPUT

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
            fibaro:sleep(150)
        else
            break
        end
    end
end

-- doCmds function
btn_cmd = fibaro:getGlobal( G_VAR_NAME_CMD )
Trace( 'execute cmd: ' .. tostring(btn_cmd) .. ' ...', _INFO)
if btn_cmd ~= '' then
    fibaro:setGlobal( G_VAR_NAME_CMD, '')
    Trace( 'execute cmd: ' .. tostring(btn_cmd) .. ' ...', _INFO)
    local state = 'SendIr CMD ' .. btn_cmd
    sendIrSocketDataWithRetry(IR_DEVICE_CMDCODES[btn_cmd])
    Trace( 'execute cmd finished', _INFO)
else
    Trace( 'no cmd execute', _WARNING)
end
