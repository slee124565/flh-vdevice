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

Trace(VDEV_NAME .. ' daemon enter', _DEBUG)

-- variable initial
local selfID = fibaro:getSelfId()
local ipAddress = fibaro:getValue( selfID , "IPAddress" )
local tcpPort = fibaro:getValue( selfID , "TCPPort" )
Trace('Socket Server IP: ' .. ipAddress .. ' listen port: ' .. tcpPort)

Trace('check daemon state ' .. fibaro:getGlobal(G_VAR_NAME_STATE))
if (fibaro:getGlobal(G_VAR_NAME_STATE) == 'BUSY') then
    fibaro:call( selfID , "setProperty" , "ui.err.value" , 'State Busy' )
    Trace(VDEV_NAME .. ' daemon strat process exit')
    return
end

fibaro:setGlobal(G_VAR_NAME_STOP, '')
Trace('reset daemon stop flag ' .. fibaro:getGlobal(G_VAR_NAME_STOP))
fibaro:call( selfID , "setProperty" , "ui.stopflag.value" , false )

fibaro:setGlobal(G_VAR_NAME_CMD, '')
fibaro:setGlobal(G_VAR_NAME_PARM_CMD, '')
Trace('reset daemon cmd queue ' .. fibaro:getGlobal(G_VAR_NAME_STOP))
fibaro:call( selfID , "setProperty" , "ui.lastcmd.value" , '' )

fibaro:call( selfID , "setProperty" , "ui.err.value" , '' )

--fibaro:call( selfID , "setProperty" , "ui.err.value" , '' )
--fibaro:call( selfID , "setProperty" , "ui.status.value" , 'Starting' )
--fibaro:call( selfID , "setProperty" , "ui.lastcmd.value" , '' )

function remote_device_data_handler(_data)
    Trace('_data: ' .. _data)
end

function cmd_rev_fwd_handler(cmdCode)
    local arg, CMD_KEY
    local final_cmd_arg = ''
    CMD_KEY = 'REV_FWD'
    local cmdArgs = fibaro:getGlobal(G_VAR_NAME_PARM_CMD)
    Trace('last cmdArgs: ' .. tostring(cmdArgs))
    if cmdArgs == nil or cmdArgs == '' then
        Trace('G_VAR_NAME_PARM_CMD is nil, initial it', _WARNING)
        cmdArgs = {}
        fibaro:setGlobal(G_VAR_NAME_PARM_CMD,json.encode(cmdArgs))
        arg = 1
        final_cmd_arg = cmdCode .. tostring(arg)
    else
        cmdArgs = json.decode(cmdArgs)
        local last_cmd_arg = cmdArgs[CMD_KEY]

        Trace('last_cmd_arg: ' .. tostring(last_cmd_arg))
        if last_cmd_arg == nil or last_cmd_arg == '' then
            Trace('set default arg value 1')
            arg = 1
            final_cmd_arg = cmdCode .. tostring(arg)
        else
            -- get last cmd ard
            arg = tonumber(string.sub(last_cmd_arg,string.len(cmdCode)))
            Trace('get previous cmd arg: ' .. tostring(arg))

            -- get last cmd
            if string.find(last_cmd_arg,'#REV') ~= nil then
                Trace('last cmd is #REV')
                if cmdCode == '#REV ' then
                    arg = arg + 1
                    if arg > 5 then
                        arg = 5
                    end
                    final_cmd_arg = cmdCode .. tostring(arg)
                else
                    arg = arg - 1
                    if arg < 1 then
                        arg = 1
                        final_cmd_arg = '#FWD 1'
                    else
                        final_cmd_arg = '#REV ' .. tostring(arg)
                    end
                end
            else
                Trace('last cmd is #FWD')
                if cmdCode == '#FWD ' then
                    arg = arg + 1
                    if arg > 5 then
                        arg = 5
                    end
                    final_cmd_arg = cmdCode .. tostring(arg)
                else
                    arg = arg - 1
                    if arg < 1 then
                        arg = 1
                        final_cmd_arg = '#REV 1'
                    else
                        final_cmd_arg = '#FWD ' .. tostring(arg)
                    end
                end
            end
        end
    end
    Trace('final_cmd_arg: ' .. final_cmd_arg)
    cmdArgs[CMD_KEY] = final_cmd_arg
    fibaro:setGlobal(G_VAR_NAME_PARM_CMD, json.encode(cmdArgs))
    Trace('update cmdArgs: ' .. json.encode(cmdArgs))
    return final_cmd_arg
end

function check_cmd_param(cmdCode)
    Trace('check_cmd_param with "' .. cmdCode .. '",len: ' .. tostring(string.len(cmdCode)))

    -- add cmd param if needed
    if cmdCode == '#REV ' or cmdCode == '#FWD ' then
        return cmd_rev_fwd_handler(cmdCode)
    else 
        Trace('no cmd arg need to check and reset PARM_CMD')
        cmdArgs = {}
        fibaro:setGlobal(G_VAR_NAME_PARM_CMD,json.encode(cmdArgs))
        return cmdCode
    end
end

function service_run()

    -- set vdev busy flag
    fibaro:setGlobal(G_VAR_NAME_STATE, 'BUSY')
    fibaro:call( selfID , "setProperty" , "ui.status.value" , 'Starting' )
    Trace('daemon start', _INFO)

    -- setup socket connection
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
        fibaro:call( selfID , "setProperty" , "ui.err.value" , 'SCK ERROR' )
    else
        -- control protocol process
        local bytes, errCode, rdata
        fibaro:call( selfID , "setProperty" , "ui.status.value" , 'oppo-rpi connected', _INFO )
        Trace('oppo-rpi connected', _INFO)
        while ( tostring(stopflag) ~= 'true' ) do
            -- sck conn check process: make remote device must response data
            bytes, errCode = socket:write('\r')
            Trace( 'socket write result code ' .. tostring(errCode) .. ' bytes: ' .. tostring(bytes) )

            -- receive remote data process
            fibaro:call( selfID , "setProperty" , "ui.status.value" , 'listening' )
            local rcount = 0
            local rmax = 10
            local tmp = ''
            rdata = ''
            while rcount < rmax do
                tmp, errCode = socket:read()
                Trace('tmp: ' .. tostring(tmp))
                rdata = rdata .. tmp
                if errCode == 0 and string.len(rdata) > 0 then
                    if string.sub(rdata,string.len(rdata),string.len(rdata)) == '\n' then
                        break
                    else
                        Trace('receive partial data ' .. tmp .. ' kepp reading...', _WARNING)
                    end
                end
                if errCode ~= 0 then
                    break
                end
                rcount = rcount + 1
                fibaro:sleep(100)
            end
            Trace( 'socket read result code ' .. tostring(errCode) .. ' data: ' .. tostring(rdata) )
            
            -- socket conn broken if rcount >= rmax
            if rcount >= rmax then
                Trace('socket read no data exceed max count ' .. rmax, _ERROR )
                fibaro:call( selfID , "setProperty" , "ui.err.value" , 'sck conn err' )
                break
            end

            -- filter conn check msg
            if rdata ~= '' then
                if logLevel == _DEBUG then
                    local dhex
                    if string.len(rdata) > 0 then
                        dhex = 'len:' .. string.len(rdata) .. '=> ' .. string.sub(rdata,1,1) .. ':' .. string.byte(string.sub(rdata,1,1))
                        if string.len(rdata) > 1 then
                            for i = 2, string.len(rdata) do
                                dhex = dhex .. ',' .. string.sub(rdata,i,i) .. ':' .. string.byte(string.sub(rdata,i,i))
                            end
                        end
                        Trace( 'data hex: ' .. dhex )
                    end
                end
                if rdata ~= '@OK\n' then
                    Trace('receive data: ' .. rdata, _INFO)
                end
            end

            if errCode ~= 0 then
                -- socket connection broken event, break loop; let watchdog restart daemon
                Trace('connection broken', _WARNING)
                break
            end

            -- read data processing
            if rdata ~= '' then
                remote_device_data_handler(rdata)
            end

            -- cmd handling
            cmd = fibaro:getGlobal(G_VAR_NAME_CMD)
            Trace('check cmd queue: ' .. tostring(cmd))
            if cmd ~= '' and cmd ~= nil then
                fibaro:call( selfID , "setProperty" , "ui.status.value" , 'execute cmd' )
                fibaro:setGlobal(G_VAR_NAME_CMD, '')
                Trace('clear cmd queue and handle cmd')
                -- check cmd with cmd_parm
                cmd = check_cmd_param(cmd)
                Trace('process cmd: ' .. cmd .. ',len: ' .. tostring(string.len(cmd)), _INFO)
                bytes, errCode = socket:write(cmd .. '\r\n')
                Trace( 'socket write result code ' .. tostring(errCode) .. ' bytes: ' .. tostring(bytes) )
                fibaro:call( selfID , "setProperty" , "ui.lastcmd.value" , cmd )
            else
                fibaro:sleep(300)
            end

            -- check daemon stop flag
            stopflag = fibaro:getGlobal(G_VAR_NAME_STOP)
            Trace('check stop flag ' .. tostring(stopflag))
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


