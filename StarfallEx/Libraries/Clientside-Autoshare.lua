--@name clientShare.library
--@author Vurv
--@shared

-- Basically just automates processes to give information from the owner to the rest of the clients.
-- Needs to be required in a SHARED chip.

if SERVER then
    Data = nil
    queue = {}
    
    net.receive("getdata",function(len)
        Data = net.readString()
        // Get Data from the owner.
    end)
    
    net.receive("addqueue",function(len,ply)
        queue[#queue+1] = ply
    end)
    
    timer.create("loadqueue",1,0,function()
        if Data == nil or net.isStreaming() then return end
        for K,Ply in pairs(queue) do
            net.start("queuesend")
                print("Writing stream to",Ply:getName())
                net.writeStream(Data)
            net.send(Ply)
            table.remove(queue,K)
        end
    end)



else
    lib = {}
    local function httpGetShared(url,success)
        if player() ~= owner() then
            net.start("addqueue")
            net.send()
            net.receive("queuesend",function(len)
                net.readStream(function(data)
                    success(data)
                end)
            end)
        else
            http.get(url,function(data)
                net.start("getdata")
                    net.writeString(data)
                net.send()
                success(data)
            end)
        end
    end
    lib.httpGetShared = httpGetShared
    return lib
end
