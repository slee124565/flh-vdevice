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

Trace('check daemon state ' .. fibaro:getGlobal(G_VAR_NAME_STATE))
if (fibaro:getGlobal(G_VAR_NAME_STATE) == 'BUSY') then
    fibaro:call( selfID , "setProperty" , "ui.err.value" , 'State Busy' )
    return
end

fibaro:setGlobal(G_VAR_NAME_STOP, '')
Trace('reset daemon stop flag ' .. fibaro:getGlobal(G_VAR_NAME_STOP))
fibaro:call( selfID , "setProperty" , "ui.stopflag.value" , false )

fibaro:setGlobal(G_VAR_NAME_CMD, '')
Trace('reset daemon cmd queue ' .. fibaro:getGlobal(G_VAR_NAME_STOP))
fibaro:call( selfID , "setProperty" , "ui.lastcmd.value" , '' )

fibaro:call( selfID , "setProperty" , "ui.err.value" , '' )

--fibaro:call( selfID , "setProperty" , "ui.err.value" , '' )
--fibaro:call( selfID , "setProperty" , "ui.status.value" , 'Starting' )
--fibaro:call( selfID , "setProperty" , "ui.lastcmd.value" , '' )

function lutron_data_handler(_data)
    fibaro:call( selfID , "setProperty" , "ui.status.value" , 'receiving data' )
    Trace('TODO: lutron_data_handler ' .. tostring(_data), _WARNING)
end

function cmd_handler(_cmd)
    fibaro:call( selfID , "setProperty" , "ui.status.value" , 'execute cmd' )
    Trace('TODO: cmd_handler ' .. tostring(_cmd), _WARNING)
end

function service_run()

    fibaro:setGlobal(G_VAR_NAME_STATE, 'BUSY')
    fibaro:call( selfID , "setProperty" , "ui.status.value" , 'Starting' )

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
        fibaro:call( selfID , "setProperty" , "ui.err.value" , 'SCK ERROR' )
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
                    fibaro:call( selfID , "setProperty" , "ui.status.value" , 'logon', _INFO )
                    Trace('login success')
                    local count = 0
                    local MAX_COUNT = 4
                    local stopflag = fibaro:getGlobal(G_VAR_NAME_STOP)
                    while ( tostring(stopflag) ~= 'true' ) do
                        fibaro:call( selfID , "setProperty" , "ui.status.value" , 'listening' )
                        rdata, errCode = socket:read()
                        Trace( 'socket read result code ' .. tostring(errCode) .. ' data: ' .. tostring(rdata) )
                        SCK_READ_TIMEOUT_ERR_CODE = 1
                        if rdata ~= '' and errCode ~= SCK_READ_TIMEOUT_ERR_CODE then
                            lutron_data_handler(rdata)
                        else
                            fibaro:sleep(1000)
                        end
                        cmd = fibaro:getGlobal('G_VAR_NAME_CMD')
                        Trace('check cmd queue: ' .. tostring(cmd))
                        if cmd ~= '' and cmd ~= nil then
                            fibaro:setGlobal('G_VAR_NAME_CMD', '')
                            Trace('clear cmd queue and handle cmd')
                            cmd_handler(cmd)
                        end
                        stopflag = fibaro:getGlobal(G_VAR_NAME_STOP)
                        Trace('check stop flag ' .. tostring(stopflag))
                    end
                end
            end
        end
        if errCode ~= 0 and errCode ~= SCK_READ_TIMEOUT_ERR_CODE then
            fibaro:call( selfID , "setProperty" , "ui.err.value" , 'sck err code ' .. tostring(errCode) )

        end
    end
    -- socket disconnect
    socket:disconnect()
    socket = nil
    
    
    fibaro:setGlobal(G_VAR_NAME_STATE,'')
    fibaro:call( selfID , "setProperty" , "ui.status.value" , 'STOP' )
    Trace('daemon exit', _INFO)
end

service_run()


