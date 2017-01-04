#!/usr/bin/lua      

--  original dashit assumed that button is partially set up with amazon, dashit2 works with fresh dash button (old version, 
-- not tested on new version), pressing and holding button starts the wifi connection process with a "probe-request" to any avail 
-- access points/routers.  doing deeper packet inspection to see if it's a broadcom vendor oui (0x40).  This is not fail safe
-- as another broadcom based probe-request could occur. next version would have training mode, press two times to train/save button MAC
-- address
--
--  hold dash button down for a few seconds until blue light blinks, then do same again to toggle off blue blinking light
                                                                                                                                                                                                                                                            
--      opkg install luasocket                                                                                                                                                                                                                              
--      opkg install tcpdump                                                                                                                                                                                                                                
--    put the router in monitor mode    iw phy phy0 interface add mon0 type monitor                                                                                                                                                                         
--    then enable the interface         ifconfig mon0 up                                                                                                                                                                                                    
                                                                                                                                                                                                                                                            
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
                                                                                                                                                                                                                                                            
        local http=require'socket.http' -- opkg install luasocket                                                                                                                                                                                           
        local packet = {}                                                                                                                                                                                                                                   
        local f                                                                                                                                                                                                                                             
        local count = 0                                                                                                                                                                                                                                     
        local newmac = 'empty'                                                                                                                                                                                                                              
        local oldmac =  'empty'                                                                                                                                                                                                                             
        local now = socket.gettime()                                                                                                                                                                                                                        
        local last = now                                                                                                                                                                                                                                    
        local delta = 0                                                                                                                                                                                                                                     
        local delay = 15                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                            
--      lets see what's asking for a connection, long cli to assure interface in in monitor mode                                                                                                                                                            
--      put the router in monitor mode    iw phy phy0 interface add mon0 type monitor                                                                                                                                                                       
--      then enable the interface         ifconfig mon0 up                                                                                                                                                                                                  
                                                                                                                                                                                                                                                            
--      f = io.popen("tcpdump -enlU -s 128 -i mon0 type mgt subtype probe-req")                                                                                                                                                                             
        f = io.popen("grep -q mon0 /proc/net/dev || /usr/sbin/iw phy phy0 interface add mon0 type monitor /sbin/ifconfig mon0 up; /usr/sbin/tcpdump -enlU -s 128 -i mon0 -y IEEE802_11_RADIO link[0] = 0x40 and link[76:2]=0x1018")                         
                                                                                                                                                                                                                                                            
        print ('hello')                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                            
        while true do                                       -- big loop, waiting for packets                                                                                                                                                                
                                                                                                                                                                                                                                                            
                        packet = get_packet(f:read("*l"))           --                                                                                                                                                                                      
                                                                                                                                                                                                                                                            
--                      print(packet, '\n')             -- debug to tune the mac txt location                                                                                                                                                               
--                      for k, v in pairs( words ) do                                                                                                                                                                                                       
--                         print(k, v)                                                                                                                                                                                                                      
--                      end                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                            
--                      newmac=words[15]                -- station/device MAC                                                                                                                                                                               
                        newmac=words[13]                -- find the station/device MAC                                                                                                                                                                      
                        now = socket.gettime()                                        
                        delta=now-last  
    
                        if delta > delay then oldmac='old' end  --timeout to reset
                                                                                      
                        if newmac == oldmac then                                                
                                print(count,'   ',now,'  ',delta,' repeat MAC adddress is =  '..newmac)         
                                count = count + 1                                                      
                        else                                                                           
                                count = 0
                               print(count,'   ',now,'  ','        MAC adddress is =  '..newmac)                
                                last=now                                                        
                                delta=0                                                         
                                oldmac = newmac                                                 
                        end    
    
    
    
    
        end                                                                                                                                                                                                                                                 
        io.close(f)                                                                                                                                                                                                                                         
end                                                                                                                                                                                                                                                         
main_loop()    
