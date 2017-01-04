#!/usr/bin/lua       

--    body,c,l,h = http.request('http://maker.ifttt.com/trigger/DASHit/with/key/yourkeyhere')                                                      
                                                                                
function get_packet(line)                                                       
                                                                                                                         
  if not line then                                                              
    return nil                                                                  
  end                                                                           
                                                                                   
	packet = {}                          
    packet = string.gsub(line,'['..'>,:"'..']','')      -- remove >,:" from tcpdump results
	words = {}
	
	for word in packet:gmatch("%S+") do 
		table.insert(words, word)
--		print (words, word)
	 end                     
                                                                                                                               
  return packet, words                                                              
end                                                                             
                                                                                

function main_loop()
		local http=require'socket.http'                                                        
        local packet = {}                                                            
        local f
        local last = 0
  		local delay = 2                                                              
                                                                                
--       f = io.popen("tcpdump -e -i wls1 arp")            -- desktop    arp
         f = io.popen("tcpdump -e -i wls1") 
                             
--      f = io.popen("tcpdump -e -i br-lan")  -- glnet router                      
                                                                                
        DASHmac = 'empty'
        now = socket.gettime()
--        delta = now
        print ('hello')
                                                                     
        while true do                                       -- big loop, waiting for arp packets
		
            now = socket.gettime()                                                                    
            packet = get_packet(f:read("*l"))           --  
--			print(packet, '\n')

--			for k, v in pairs( words ) do
--			   print(k, v)
--			end 

	    		if words[13]=='BOOTP/DHCP' and words[11]=='localhost.bootpc' then
	    			DASHmac = words[2]
	    			print(now, ' DASH MAC adddress is =  '..DASHmac)
	    		end
	    		                                                  			

	--				print('button pushed  '..DASHmac)
		--    		body,c,l,h = http.request('http://maker.ifttt.com/trigger/DASHit/with/key/yourkeyhere')
		--    		print(body,c,l,h)
                                                                                                   
        end                                                                     
                                                                                
        io.close(f)                                                             
end                                                                             
                                                                                
main_loop()                                                                     
               
