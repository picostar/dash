#!/usr/bin/lua       

-- report any device that makes a prob-request
                                                                                                                                                                                                             
--    put the router in monitor mode    iw phy phy0 interface add mon0 type monitor                                                                                                                          
--    then enable the interface         ifconfig mon0 up   d

-- opkg install luasocket
-- opkg install tcpdump
                                                                                                                                                                                                             
function get_packet(line)                                                                                                                                                                                    
                                                                                                                                                                                                             
  if not line then                                                                                                                                                                                           
    return nil                                                                                                                                                                                               
  end                                                                                                                                                                                                        
                                                                                                                                                                                                             
        packet = {}                                                                                                                                                                                          
        packet = string.gsub(line,'['..'>,"'..']','')      -- remove >," from tcpdump results                                                                                                                
                                                                                                                                                                                                             
        words = {}                                                                                                                                                                                           
        for word in packet:gmatch("%S+") do                                                                                                                                                                  
                table.insert(words, word)                                                                                                                                                                    
--              print (words, word)                                                                                                                                                                          
        end                                                                                                                                                                                                  
                                                                                                                                                                                                             
  return packet, words                                                                                                                                                                                       
end                                                                                                                                                                                                          
                                                                                                                                                                                                             
function main_loop()                                                                                                                                                                                         
                                                                                                                                                                                                             
        local http=require'socket.http'                                                                                                                                                                      
        local packet = {}                                                                                                                                                                                    
        local f                                                                                                                                                                                              
        local last = 0                                                                                                                                                                                       
        local count = 0                                                                                                                                                                                      
        newmac = 'empty'                                                                                                                                                                                     
        oldmac =  'empty'                                                                                                                                                                                    
        now = socket.gettime()                                                                                                                                                                               
                                                                                                                                                                                                             
--      lets see what's asking for a connection                                                                                                                                                              
--      f = io.popen("tcpdump -enU -s 128 -i mon0 type mgt subtype probe-req")                                                                                                                               
        f = io.popen("grep -q mon0 /proc/net/dev || /usr/sbin/iw phy phy0 interface add mon0 type monitor /sbin/ifconfig mon0 up; /usr/sbin/tcpdump -enUl -s 128 -i mon0 -y IEEE802_11_RADIO type mgt subtype 
                                                                                                                                                                                                             
        print ('hello')                                                                                                                                                                                      
                                                                                                                                                                                                             
        while true do                                       -- big loop, waiting for packets                                                                                                                 
                                                                                                                                                                                                             
                        packet = get_packet(f:read("*l"))           --                                                                                                                                       
--                      print(packet, '\n')                                                                                                                                                                  
                                                                                                                                                                                                             
--                      for k, v in pairs( words ) do                                                                                                                                                        
--                         print(k, v)                                                                                                                                                                       
--                      end                                                                                                                                                                                  
                                                                                                                                                                                                             
     --                   newmac=words[15]                        -- station/device MAC 
                        newmac=words[13]                        -- station/device MAC 
      
                        now = socket.gettime()                                                                                                                                                               
                                                                                                                                                                                                             
                        if newmac == oldmac then                                                                                                                                                             
                                count = count + 1                                                                                                                                                            
                                print(count,'   ',now, '  ',' repeat MAC adddress is =  '..newmac)                                                                                                           
                        else                                                                                                                                                                                 
                                count = 0                                                                                                                                                                    
                                print(count,'   ',now,'  ','        MAC adddress is =  '..newmac)                                                                                                            
                                oldmac = newmac                                                                                                                                                              
                        end                                                                                                                                                                                  
                                                                                                                                                                                                             
        end                                                                                                                                                                                                  
        io.close(f)                                                                                                                                                                                          
end                                                                                                                                                                                                          
main_loop()   
