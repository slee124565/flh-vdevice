data1 = [[~DEVICE,11,1,3
~OUTPUT,7,1,100.00
~OUTPUT,7,29,8
~OUTPUT,7,30,1,100.00
~DEVICE,11,81,9,1
~DEVICE,11,85,9,1]]

data2 = '~DEVICE,11,1,3\r\n~OUTPUT,7,1,100.00\r\n~OUTPUT,7,29,8\r\n'

data3 = 'QNET>'

count = 1
data = data3
print(data)
meta = {}
for entry in string.gmatch(data,'~(.-)%\r%\n') do
    devType = string.match(entry,'(.-),')
    if devType == 'DEVICE' or devType == 'OUTPUT' then
        devID = string.match(entry,',(%d+,%d+),')
        meta[devID] = entry
        print(count, entry, devType, devID)
    else
        print('unknow devType ' .. devType)
    end
    count = count + 1
end
--print(meta)
