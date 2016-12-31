# dash
Amazon dash button hack
An Amazon dash button hack with some lua hacking small router

The Dash button from Amazon is an interesting IoT concept; sell the consumer an inexpensive ($5) branded button to order consumables directly from Amazon; detergent, diapers, plastic bags and the like. The ultimate end game is for the auto consumable ordering feature, sans button, to be builtin into appliances and the appliances order the consumables for the consumer when needed. For me, it’s an amazingly inexpensive wifi button in a nice key chain enclosure. I purchase a couple "Glad" bag buttons, not because I want to order plastic bags, but I want to experiment with the button and I like the Glad logo. I am glad to be using a button that connects to a wifi router as a trigger. The first task is to capture the button before it sends the request to Amazon. I am not the only one that’s experimented with the idea, see here; https://medium.com/@edwardbenson/how-i-hacked-amazon-s-5-wifi-button-to-track-baby-data-794214b0bdd8#.kbscrwkhz

Follow the instructions in the above how to to set up the button to connect to your house wifi router. The most important step is not to do the last step of entering in what you want to order. The result will be when you press the button, your mobile phone (in my case) will have an alert that you have not set up the last step, that’s good. Ignore that and be assured you’re not ordering a product. The message on your phone is a good debug feature and I will explain how to block it later.

Now that the button is partially set up let’s add another wifi router to your network as a button gateway. You could use your main house router but there a few good reasons not to. We’re going to play with firewall rules, add code to do interesting things and all around fun stuff, why do this to your working home router when you can buy one for $25 or so. I like the http://www.gl-inet.com/gl-inet6416/ but there are others, this seems to be a newer version https://wiki.openwrt.org/toh/gl-inet/gl-ar150. My instructions and code are based on the inet6416 with the stock openwrt OS, and the code is written in lua.

Ok, let’s set up the openwrt router. My set up is with an ethernet cable (cat5) from the house router to the openwrt router. The small openwrt router takes power from the micro USB port and once powered it should be served an dhcp IP to the outside world from your house router. Then follow the router instructions to connect your computer wifi to the new openwrt router: connect to the SSID of the new openwrt router, open web browser and browse the openwrt router IP, in my case 192.168.8.1. A good test you’re good to go is to assure your computer has a path to the internet from your new openwrt router through the house router. Open your browser and go to some outside site; www.google.com…​ All good? If not go back to setting up your openwrt router, there are several howto’s on the internet if you run into trouble.

You will also be able to ssh into the openwrt router as root with the password that was asked of you when you set up the openwrt router.

Looks something like this; (i’ve named my router "wackamole" during setup)

ssh root@192.168.8.1 root@192.168.8.1’s password:

BusyBox v1.23.2 (2015-11-06 10:55:02 HKT) built-in shell (ash)

  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 CHAOS CALMER (Chaos Calmer, r47065)
 -----------------------------------------------------
  * 1 1/2 oz Gin            Shake with a glassful
  * 1/4 oz Triple Sec       of broken ice and pour
  * 3/4 oz Lime Juice       unstrained into a goblet.
  * 1 1/2 oz Orange Juice
  * 1 tsp. Grenadine Syrup
 -----------------------------------------------------`
root@wackamole:~#
Let’s test (again) you have access to the outside internet with ping;

root@wackamole:~# ping www.google.com PING www.google.com (172.217.1.68): 56 data bytes 64 bytes from 172.217.1.68: seq=0 ttl=58 time=9.363 ms 64 bytes from 172.217.1.68: seq=1 ttl=58 time=9.756 ms ^C (control C out) --- www.google.com ping statistics --- 2 packets transmitted, 2 packets received, 0% packet loss round-trip min/avg/max = 9.363/9.559/9.756 ms root@wackamole:~#

Let’s go back to the button. It’s currently associated with your house router, let’s associate it with your new openwrt router. We could go back to setting up the button with the Amazon mobile app as you did above but instead there is another interesting feature of the button we can use in this case. There is a http server built into it and it’s useful when you change your wifi router it connects to. You only need to hold the button down until the led blinks blue, and then in a minute or so (be patient) it will be visible as a wifi access point you connect your computer’s wifi to. The SSID is "Amazon ConfigureMe". Once connected you can look at the IP your served in your network settings, or it should be 192.168.0.1. Enter that IP in your browser and you will be served a very simple web page to select the SSID of your home router and enter the password. Ok…​ Now that you have the button set up to communicate to your wifi router. The button will no longer be an access point and your computer should reconnect to last router connected to, but check, reconnect your computer to the openwrt router.

Ok now let’s try to figure out the MAC address of the DASH button.

let’s block the mac address at the router so we can block it from communicating to Amazon;

I first do an ifconfig at the prompt to determine the interface name, in this case it’s the interface that has the inet address you used to configure the router;

root@wackamole:~# ifconfig

br-lan Link encap:Ethernet HWaddr E4:95:6E:40:0A:CA inet addr:192.168.8.1 Bcast:192.168.8.255 Mask:255.255.255.0 inet6 addr: fe80::e695:6eff:fe40:aca/64 Scope:Link inet6 addr: fd66:67b7:4126::1/60 Scope:Global UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1 RX packets:1063806 errors:0 dropped:0 overruns:0 frame:0 TX packets:440403 errors:0 dropped:0 overruns:0 carrier:0 collisions:0 txqueuelen:0 RX bytes:770391086 (734.7 MiB) TX bytes:261889638 (249.7 MiB)

There will be several other interfaces listed, ignore those for now.

We’re interested in br-lan as the interface name.

Now we want the MAC address of the DASH button, it’s not printed on the button. Let’s find it with tcpdump. The -e parameter will dump the MAC address -i interface and filter on arp packets; tcpdump -e -i br-lan arp.

start tcpdump and press the DASH button, if all the above was explained well enough you should see some arp packets captured.

at the prompt type tcpdump -h to test if it is installed. if installed it will list version and parameter options, if if tcpdump is not install the install with opkg, first update the repository, then install tcpdump;

opkg update opkg install tcpdump

then back to business;

root@wackamole:~# tcpdump -e -i br-lan arp tcpdump: verbose output suppressed, use -v or -vv for full protocol decode listening on br-lan, link-type EN10MB (Ethernet), capture size 65535 bytes 17:41:42.941337 74:75:48:b5:bf:ae (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.8.240 tell localhost, length 28 17:41:43.956651 74:75:48:b5:bf:ae (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has GL-iNet.lan tell 192.168.8.240, length 28

ctrl-c out of tcpdump soon. The first two entries should be from the button,

Let’s test it by using this tcpdump command, adding -vv for very verbose and filtering on the suspected Button MAC address

tcpdump -vv -e -i br-lan ether host 74:75:48:b5:bf:ae

If it’s correct you should see a packet stream by that has this line;

Hostname Option 12, length 17: "WICED DHCP Client"

WICED is the name of the Broadcomms IoT SDK stuff, stands for WICED, Wireless Internet Connectivity for Embedded Devices and yes they want you to pronounce it as wicked, cute.

If you do not see WICED in your tcpdump results then go back to the filtering on ARP packets for another MAC address.

Move on to the next step of you’re confident you have the button MAC address.

Let’s added the firewall rules of the router from the prompt or CLI. the editor "vi" should be standard on the openwrt router. do this at the prompt

vi /etc/config/firewall

use the arrow keys to scroll to the bottom or upper case "G" will send to end of file. press "i" to enter input mode and past the following, exactly;

config rule 'block_DASH' option src 'lan' option dest 'wan' option src_mac 74:75:48:b5:bf:ae option target 'REJECT'

press "esc" then type colon ":" to enter command line, then "wq" for write file and quite.. You should be back at the CLI prompt…​

After a configuration change, firewall rules are rebuilt do this at the prompt;

/etc/init.d/firewall restart

OK now the button is blocked from communicating to Amazon and we’re ready to write some code to

on the openwrt router, let’s install a lua communications library, luasocket;

opkg install luasocket

scratch pad

tcpdump -nnXSs 0 -i br-lan ether host 74:75:48:b5:bf:ae

tcpdump -vv -e -i br-lan ether host 74:75:48:b5:bf:ae

tcpdump -e -i br-lan arp
