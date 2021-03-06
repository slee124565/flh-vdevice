--[[
%% autostart
%% properties
%% events
%% globals
--]]

-- config variables
sceneID = 15                -- this scene ID 
eventExpiredSec = 10        -- the duration for daemon state not BUSY to timeout
watchDaemonID = 398         -- daemon device ID
watchDaemonStartBtnId = 2   -- start button ID in daemon device
watchDaemonResetBtnId = 8   -- reset button ID in daemon device

-- global variable in used
G_VAR_NAME_WATCH = 'gLu_D_State'
G_VAR_NAME_WD_STOP = 'gLu_WD_Stop'     -- Watch Dog Stop Flag 
G_VAR_NAME_EVENT_TIME = 'gLu_WD_TIME'   -- Watch Event Start Time

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

function resetAndStartDaemon()
    Trace('reset and start daemon by fibaro API', _INFO)
    fibaro:call( watchDaemonID , "pressButton" , watchDaemonResetBtnId )
    fibaro:sleep(500)
    fibaro:call( watchDaemonID , "pressButton" , watchDaemonStartBtnId )
end

sceneCount = fibaro:countScenes(sceneID)
Trace('lutron watchdog count ' .. tostring(sceneCount) , _INFO)

MAX_COUNT = 1

-- reset watchdog stop flag
fibaro:setGlobal(G_VAR_NAME_WD_STOP, false)
local stopFlag = fibaro:getGlobal(G_VAR_NAME_WD_STOP)

local daemonStatus = fibaro:getGlobal(G_VAR_NAME_WATCH)
Trace('daemonStatus: ' .. tostring(daemonStatus) .. ', stopFlag: ' .. tostring(stopFlag))

-- reset watchdog event time
local eventTime
fibaro:getGlobal(G_VAR_NAME_EVENT_TIME, '')
local now

Trace('watchdog enter, time: ' .. tostring(os.time()), _INFO)

Trace('restart daemon', _INFO)
resetAndStartDaemon()

-- check scene count and stopFlag
while ((sceneCount <= MAX_COUNT) and (tostring(stopFlag) ~= 'true')) do
    
    -- check watch status
    if daemonStatus ~= 'BUSY' then
        eventTime = fibaro:getGlobal(G_VAR_NAME_EVENT_TIME)
        Trace('eventTime: ' .. tostring(eventTime))
        
        if eventTime == '' or eventTime == nil or eventTime == 'NaN' then
            fibaro:setGlobal(G_VAR_NAME_EVENT_TIME,tostring(os.time()))
            Trace('watch event trigger', _INFO)
        else
            -- check if expired
            Trace('check if expired', _WARNING)
            now = os.time()
            if (now - eventTime) > eventExpiredSec then
                Trace('watch event expired', _INFO)
                resetAndStartDaemon()
                -- reset watch event time
                fibaro:setGlobal(G_VAR_NAME_EVENT_TIME,'')
            else
                Trace('watch event not expired (' .. tostring(now) .. ',' .. tostring(eventTime) .. ')')
            end
        end
    else
        if eventTime ~= '' then
            Trace('reset watch event time', _INFO)
            fibaro:setGlobal(G_VAR_NAME_EVENT_TIME,'')
            eventTime = fibaro:getGlobal(G_VAR_NAME_EVENT_TIME)
        end
    end
    
    
    fibaro:sleep(3000)
    stopFlag = fibaro:getGlobal(G_VAR_NAME_WD_STOP)
    daemonStatus = fibaro:getGlobal(G_VAR_NAME_WATCH)
    Trace('daemonStatus: ' .. tostring(daemonStatus) .. ', stopFlag: ' .. tostring(stopFlag))
    if tostring(stopFlag) == 'true' then
        Trace('stopFlag set ' .. tostring(stopFlag), _INFO)
    end
end

Trace('watchdog exit, time:' .. os.time(), _INFO)
