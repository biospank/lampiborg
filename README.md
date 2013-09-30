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

To build/install
cd wiringPi
./build

clone this repository into /home/root
git clone https://github.com/biospank/lampi.git

copy services to /etc/init.d
cp lamp udp /etc/init.d

setup services
update-rc.d lamp defaults
update-rc.d udp defaults

to update lampi at startup insert into /etc/init.local
/root/lampi/git_pull.sh

@reboot /root/lampi/git_pull_sh

install ruby
curl -L https://get.rvm.io | bash -s stable --ruby
source /usr/local/rvm/scripts/rvm

install sinatra
gem install sinatra

