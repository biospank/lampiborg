lampiborg
=========

setup rpi sd card
http://moebiuslinux.sourceforge.net/

install git

    sudo apt-get install git-core

if you get any errors here, make sure your Pi is up to date with the latest versions of Raspbian:

    sudo apt-get update
    sudo apt-get upgrade

clone wiringpi

    git clone git://git.drogon.net/wiringPi

to build/install

    cd wiringPi
    ./build

clone this repository into /home/root

    git clone https://github.com/biospank/lampi.git

copy services to /etc/init.d

    cp lamp udp /etc/init.d

setup services

    update-rc.d lamp defaults
    update-rc.d udp defaults

to update lampi at startup insert into /etc/rc.local

    /root/lampi/git_pull.sh &

install ruby

    curl -L https://get.rvm.io | bash -s stable --ruby
    source /usr/local/rvm/scripts/rvm

install sinatra

    gem install sinatra
    
## RPI wifi

install wpa supplicant

    sudo apt-get install wpasupplicant

edit file /etc/network/interfaces and make sure to have this configuration

    auto lo
    
    iface lo inet loopback
    iface eth0 inet dhcp
    
    auto wlan0
    allow-hotplug wlan0
    iface wlan0 inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
    iface default inet dhcp

edit file /etc/wpa_supplicant/wpa_supplicant.conf

it should look like this:

    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1
    
    network={
      ssid="lampi"
      proto=RSN
      scan_ssid=1
      key_mgmt=WPA-PSK
      pairwise=CCMP TKIP
      group=CCMP TKIP
      psk="lampi9571"
      id_str="lampi"
    }

to disable power management create a new /etc/modprobe.d/8192cu.conf file with this content

    options 8192cu rtw_power_mgnt=0 rtw_enusbss=0
    

## RPI-Wireless-Hotspot (ralink 3570)

    sudo apt-get install hostapd isc-dhcp-server

### Set up DHCP server

Edit /etc/dhcp/dhcpd.conf

Find the lines that say 

    option domain-name "example.org"; 
    option domain-name-servers ns1.example.org, ns2.example.org;

and change them to add a \# at the beginning so they say

    #option domain-name "example.org"; 
    #option domain-name-servers ns1.example.org, ns2.example.org;

Find the lines that say

    #authoritative;

and remove \#

Then scroll down to the bottom and add the following lines

    subnet 192.168.42.0 netmask 255.255.255.0 { 
      range 192.168.42.10 192.168.42.50; 
      option broadcast-address 192.168.42.255; 
      option routers 192.168.42.1; 
      default-lease-time 600;
      max-lease-time 7200; 
      option domain-name "local"; 
      option domain-name-servers 8.8.8.8, 8.8.4.4; 
    }

Edit file /etc/default/isc-dhcp-server

and scroll down to 

    INTERFACES="" 

and update it to say 

    INTERFACES="wlan0"

Edit the file /etc/network/interfaces and replace the line "iface wlan0 inet dhcp" to:

    iface wlan0 inet static
      address 192.168.42.1
      netmask 255.255.255.0

Change the lines (they probably won't all be next to each other):

    allow-hotplug wlan0
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
    iface default inet manual

to:

    #allow-hotplug wlan0
    #wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
    #iface default inet dhcp

To create a WPA-secured network, edit the file /etc/hostapd/hostapd.conf

    interface=wlan0
    driver=nl80211
    ssid=My_AP
    hw_mode=g
    channel=6
    macaddr_acl=0
    auth_algs=1
    ignore_broadcast_ssid=0
    wpa=2
    wpa_passphrase=My_Passphrase
    wpa_key_mgmt=WPA-PSK
    wpa_pairwise=TKIP
    rsn_pairwise=CCMP

If you would like to create an open network, put the following text into /etc/hostapd/hostapd.conf:

    interface=wlan0
    ssid=My_AP
    hw_mode=g
    channel=6
    auth_algs=1
    wmm_enabled=0

Edit file /etc/default/hostapd

Find the line 

    #DAEMON_CONF="" 

and edit it so it says 

    DAEMON_CONF="/etc/hostapd/hostapd.conf"

and finally edit file /etc/default/networking and exclude wlan0 from autoconfigure

    EXCLUDE_INTERFACES=wlan0



