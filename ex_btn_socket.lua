-- 語音位置
local mURL = "readyshare/USB_Storage/flh8.mp3"
--local mURL = "flh-temppi/share/playlist.m3u"
-- 音量
local mVol = 40

local mId = fibaro:getSelfId()
local mIp = fibaro:get( mId , "IPAddress" )
local mPort = fibaro:get( mId , "TCPPort" )

function ReponseCallback( _fnc , _args )
  if _fnc == nil then
    return nil
  end
  return _fnc( _args )
end

function CreateSocket()
    -- Check IP and PORT before
  if ( mIp == nil or mPort == nil) then
    fibaro:debug( "You must configure IPAddress and TCPPort first" )
    return
  end
  local socket
  local status , err = pcall(
    function() 
      socket = Net.FTcpSocket( mIp , mPort )
      socket:setReadTimeout( 5000 )
    end )  
  if status ~= nil and status ~= true then
    fibaro:debug( "socket status: " .. tostring( status or "" ) )
  end  
  if err ~= nil then
    fibaro:debug( "socket err: " .. tostring( err or "" ) )
    return;
  end
  return socket
end

function DisposeSocket( _socket )
  if _socket ~= nil then
    _socket:disconnect()
    _socket = nil
    return true
  end
  return false
end

function SendSoapMessage( _url , _service , _action , _args , _callback , _retry )
  local socket = CreateSocket()
  if socket == nil then
    return
  end
  retry = retry or 0
  -- prepare data
  local url = "POST " .. _url .. " HTTP/1.1"
  local soapaction = "SOAPACTION: \"" .. _service .. "#" .. _action.name .. "\""
  local body = string.format( "<u:%s xmlns:u=\"%s\">%s</u:%s>" , _action.name , _action.service , tostring( _args or "" ) , _action.name )
  local envelope = "<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body>" .. body .. "</s:Body></s:Envelope>"
  local ctl = "Content-Length: " .. string.len( envelope )
  local payload = url .. "\r\n" .. ctl .. "\r\n" .. soapaction .. "\r\n" .. "\r\n" .. envelope
  -- write data
  local bytes , errorcode = socket:write( payload )
  if errorcode == 0 then
    local state , errorcode = socket:read()
    if errorcode == 0 then
      if string.len( state or "" ) > 0 then
        -- callback
        if _callback ~= nil then
          ReponseCallback( _callback , state )
        end
        -- dispose ...
        DisposeSocket( socket )
        return true
      else
        fibaro:debug( "Error: Invalid response. response length: " .. string.len( state or "" ) )
      end
    else      
      if _retry < 5 then
        fibaro:debug( "retry #" .. _retry .. " action: " .. _action.name )
        return SendSoapMessage( _url , _service , _action , _args , _callback, _retry + 1 )
      else
        fibaro:debug( "Error: Code returned " .. tostring( errorcode or "" ) )
      end
    end
  elseif errorcode == 2 then
    fibaro:debug( "Error: You must check your IP and PORT settings." )
  else
    if _retry < 5 then
      fibaro:debug( "retry #" .. retry .. " action: " .. action.name )
      return SendSoapMessage( _url , _service , _action , _args , _callback , _retry + 1 )
    else
      fibaro:debug( "Error: Code returned " .. tostring( errorcode or "" ) )
    end
  end  
  -- dispose ...
  DisposeSocket(socket)
  -- default response
  return false
end

function UnMute()
  return SendSoapMessage(
    -- control url
    "/MediaRenderer/RenderingControl/Control" ,
    -- service type
    "urn:schemas-upnp-org:service:RenderingControl:1" ,
    -- action
    { name = "SetMute" , service = "urn:schemas-upnp-org:service:RenderingControl:1" } ,
    -- soap body data (options)
    "<InstanceID>0</InstanceID><Channel>Master</Channel><DesiredMute>0</DesiredMute>" ,
      -- callback (options)
    function( response )
      fibaro:debug( "unMute sent" )
    end ) 
end

function Play()
  return SendSoapMessage(
    -- control url
    "/MediaRenderer/AVTransport/Control" ,
    -- service type
    "urn:schemas-upnp-org:service:AVTransport:1" ,
    -- action
    { name = "Play" , service = "urn:schemas-upnp-org:service:AVTransport:1" } ,
    -- soap body data (options)
    "<InstanceID>0</InstanceID><Speed>1</Speed>" ,
      -- callback (options)
    function( response )   
      fibaro:debug( "Play" )
    end )
end

function SetVolume( _vol )
  return SendSoapMessage(
    -- control url
    "/MediaRenderer/RenderingControl/Control" ,
    -- service type
    "urn:schemas-upnp-org:service:RenderingControl:1" ,
    -- action
    { name = "SetVolume" , service = "urn:schemas-upnp-org:service:RenderingControl:1" } ,
    -- soap body data (options)
    "<InstanceID>0</InstanceID><Channel>Master</Channel><DesiredVolume>" .. tostring( _vol ) .. "</DesiredVolume>" ,
    -- callback (options)
    function( response )      
      fibaro:debug( "Volume set: " .. _vol )
    end )
end

function PlayMusic( _url , _vol )
  return SendSoapMessage(  
    -- control url
    "/MediaRenderer/AVTransport/Control" ,
    -- service type
    "urn:schemas-upnp-org:service:AVTransport:1" ,
    -- action
    { name = "SetAVTransportURI" , service = "urn:schemas-upnp-org:service:AVTransport:1" } ,
    -- soap body data (options)
    "<InstanceID>0</InstanceID>,<CurrentURI>x-file-cifs://" .. _url .. "</CurrentURI>,<CurrentURIMetaData></CurrentURIMetaData>" ,
    -- callback (options)
    function( response )
      UnMute()
      SetVolume( _vol )
      Play()

    end )
end

PlayMusic( mURL , mVol )