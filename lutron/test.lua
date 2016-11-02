data1 = [[~DEVICE,11,1,3
~OUTPUT,7,1,100.00
~OUTPUT,7,29,8
~OUTPUT,7,30,1,100.00
~DEVICE,11,81,9,1
~DEVICE,11,85,9,1]]

data2 = '~DEVICE,11,1,3\r\n~OUTPUT,7,1,100.00\r\n~OUTPUT,7,29,8\r\n'

count = 1
data = data2
print(data)
meta = {}
for entry in string.gmatch(data,'~(.-)%\r%\n') do
    devType = string.match(entry,'(.-),')
    devID = string.match(entry,',(%d+,%d+),')
    meta[devID] = entry
    print(count, entry, devType, devID)
    count = count + 1
end
--print(meta)
