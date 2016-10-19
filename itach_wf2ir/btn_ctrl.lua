-- system constant declare
G_VAR_NAME_META = 'gWF2IR_n_Meta'
G_VAR_NAME_BUSY = 'gWF2IR_n_Isbusy'
G_VAR_NAME_CMD = 'gWF2IR_n_Cmd'

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

Trace('Control Button Pressed', _DEBUG)

-- doCmds function
function doCmd( _cmd )
    Trace( 'TODO: implement command ' .. tostring(_cmd) )
    return true
end

-- main function
local isBusy = fibaro:getGlobalValue( G_VAR_NAME_BUSY ) == "true"
if isBusy then
    Trace( "device is busy", _WARNING )
else
    -- set busy token
    fibaro:setGlobal( G_VAR_NAME_BUSY , "true" )
    
    -- read cmd
    local cmds = fibaro:getGlobal( G_VAR_NAME_CMD )
    
    if cmds == '' then
        Trace('[no cmds]')
    else
        Trace('ctrl cmds: ' .. cmds)
        cmds = string.gmatch(cmds,'%S+')

        for tCmd in cmds do
            if doCmd(tCmd) then
                Trace('cmd ' .. tCmd .. ' finished', _INFO)
            else
                Trace('cmd ' .. tCmd .. ' fail', _ERROR)
            end
        end

        fibaro:setGlobal( G_VAR_NAME_CMD , '' )
    end
    
    fibaro:setGlobal( G_VAR_NAME_BUSY , 'false' )
end