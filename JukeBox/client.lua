--Code to get client input and request server song data--
 
 
-- Load the json api (found on wiki)
os.loadAPI("json")

--list of numbers to add 0's too in time
baddies = {0,1,2,3,4,5,6,7,8,9}
 

--converts raw seconds into formatted minutes and seconds MM:SS
local function dispTime(times)
    min = math.floor(times/60)
    sec = math.floor(times%60)

    --checks if minutes need 0 added in front (for aesthetics)
    for _,v in pairs(baddies) do
        if min == v then
            min = "0"..min
        end
    end

    --checks if seconds need 0 added in front (for aesthetics)
    for _,v in pairs(baddies) do
        if sec == v then
            sec = "0"..sec
        end
    end    
    return min..":"..sec
end
 
 
local function musictime(songtime)
    disk = peripheral.wrap("right")

    url = "http://192.168.23.30:5000/audio" --url to download audio data file (converted on server pc)
    res = http.get(url, nil, true)
    audio = res.readAll()

    -- resets the disk and writes data
    disk.seek(-disk.getPosition())
    disk.write(audio)
    disk.seek(-disk.getPosition())
    disk.play()

    --creates seperate worker program to monitor for button press to stop disk
    multishell.launch({},"waiter.lua")

    --finds the current position of cursor for the time elapsed
    curx,cury = term.getCursorPos()
    print()

    --Time elapsed timer (for aesthetics aswell as knowing when to stop disk)
    for num = 0,songtime+0.5 do
    if disk.getState() ~= "PLAYING" then break end
    current_num = dispTime(num)
        term.clearLine() 
        term.setCursorPos(curx,cury)
        write("Time Elapsed: "..current_num.."/"..dispTime(songtime))
        sleep(1)
    end
    disk.stop()
    print("\n")
end
 
--create table for query and get user input
musicquery = {}
write("Search for song: ")
musicquery.query = read()
 
--encode lua table into json for post request
dataJson = json.encodePretty(musicquery)
 
-- make post request to server and get json result
res = http.post("http://192.168.23.30:5000/song",dataJson,{ ["Content-Type"] = "application/json"})
returnedTable = json.decode(res.readAll())
 
 
--check for 404 not found if not, print song info
if(returnedTable.error == "404") then
    print("Song not found")
    
else
    returnedTable = returnedTable[0]
    print("Song found")
    print("Title: " .. returnedTable.title)
    print("Artist: " .. returnedTable.artist)
    print("Album: " .. returnedTable.album)
    os.sleep(1)
    print("Playing song... ".. returnedTable.title)
    
    -- trigger fuunction to play song
    musictime(returnedTable.time)
end