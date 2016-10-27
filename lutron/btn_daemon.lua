--[[
    @Global Variable: 
        gLu_D_Cmd: command to be sent for Lutron QS
        gLu_D_State: true (activate) or false (deactivate)
        gLu_D_Meta: json data storage for Lutron devices status
--]]

-- device constant
ACCOUNT = 'fibaro'
PASSWORD = 'fibaro'

-- global variable in used
G_VAR_NAME_META = 'gLu_D_Meta'
G_VAR_NAME_STATE = 'gLu_D_State'
G_VAR_NAME_CMD = 'gLu_D_Cmd'

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

Trace('lutron daemon enter', _DEBUG)

-- variable initial
local selfID = fibaro:getSelfId()
local ipAddress = fibaro:getValue( selfID , "IPAddress" )
local tcpPort = fibaro:getValue( selfID , "TCPPort" )
Trace('Socket Server IP: ' .. ipAddress .. ' listen port: ' .. tcpPort)

if (fibaro:getGlobal(G_VAR_NAME_STATE) == 'BUSY') then
    Trace('daemon alreay exist', _WARNING)
    return
else
    Trace('daemon activating ...', _INFO)
end

function service_run()

    local socket
    local status , err = pcall(
        function() 
            socket = Net.FTcpSocket( ipAddress , tcpPort )
            socket:setReadTimeout( 5000 )
        end )  
    if status ~= nil and status ~= true then
        Trace( "socket status: " .. tostring( status or "" ) )
    end  
    if err ~= nil then
        Trace( "socket err: " .. tostring( err or "" ), _ERROR )
    else
        local bytes, errCode, rdata
        rdata, errCode = socket:read()
        Trace( 'socket read result code ' .. tostring(errCode) .. ' data: ' .. tostring(rdata) )
        if string.find(rdata,'login') == 1 then
            Trace('enter account ...')
            bytes, errCode = socket:write(ACCOUNT .. '\r\n')
            Trace( 'socket write result code ' .. tostring(errCode) .. ' bytes: ' .. tostring(bytes) )
            rdata, errCode = socket:read()
            Trace( 'socket read result code ' .. tostring(errCode) .. ' data: ' .. tostring(rdata) )
            if string.find(rdata,'password') == 1 then
                Trace('enter password ...')
                bytes, errCode = socket:write(PASSWORD .. '\r\n')
                Trace( 'socket write result code ' .. tostring(errCode) .. ' bytes: ' .. tostring(bytes) )
                rdata, errCode = socket:read()
                Trace( 'socket read result code ' .. tostring(errCode) .. ' data: ' .. tostring(rdata) )
                if string.find(rdata,'>') > 1 then
                    fibaro:setGlobal(G_VAR_NAME_STATE,'BUSY')
                    Trace('login success')
                end
            end
        end
    end
    -- socket disconnect
    socket:disconnect()
    socket = nil
    
    fibaro:setGlobal(G_VAR_NAME_STATE,'')
    Trace('daemon exit')
end

service_run()


