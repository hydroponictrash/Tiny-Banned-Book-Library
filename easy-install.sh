#!/bin/bash
echo "Starting the install process, first to update the system..."

#Run commands to update and upgrade the system.
sudo apt-get update & sudo apt-get upgrade -y
echo "Installing Dependencies and software to make everything run..."
#Run commands to install dependencies to make everything run.
sudo apt-get install hostapd dnsmasq git build-essential libmicrohttpd-dev net-tools nginx netfilter-persistent iptables-persistent make dhcpcd5 -y
cd ~/Downloads/

#echo "Beep, boop, cloning the banned book library git repo for config files..."
#cloning the banned book library config files to the Downloads directory
#sudo git clone https://github.com/hydroponictrash/Tiny-Banned-Book-Library.git

echo "Download and installing Calibre..."
#Download and intall calibre
sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
mkdir /home/library/'Tiny Banned Book Library'
echo "Copying the calibre service to the right area"
#copy over the service to the correct area
cp ~/Downloads/Tiny-Banned-Book-Library/calibre-server.service /etc/systemd/system/calibre-server.service
sudo systemctl daemon-reload
sudo systemctl start calibre-server
sudo systemctl enable calibre-server
sudo systemctl stop calibre-server
sudo systemctl stop systemd-resolved
cd /opt

echo "Downloading NoDogSplash"
#Downloading and installing nodogsplash
sudo git clone https://github.com/nodogsplash/nodogsplash.git
cd /opt/nodogsplash
echo "Make and install nodog splash... Might take a while..."
sudo make
sudo make install
echo "Removing old nodogsplash config files and replacing them with the correct ones..."
sudo rm -rf /etc/nodogsplash/htdocs/*
cp ~/Downloads/Tiny-Banned-Book-Library/nodogsplash-files/* /etc/nodogsplash/htdocs
sudo systemctl unmask hostapd
sudo systemctl disable hostapd


#move all the config files to the right spots
echo "Moving config files to the right areas..."
rm -rf /etc/dnsmasq.conf
cp ~/Downloads/Tiny-Banned-Book-Library/dnsmasq.conf /etc/dnsmasq.conf
cp ~/Downloads/Tiny-Banned-Book-Library/dhcpcd.conf /etc/dhcpcd.conf
sudo rfkill unblock wlan
cp ~/Downloads/Tiny-Banned-Book-Library/hostapd.conf /etc/hostapd/hostapd.conf
sudo systemctl stop systemd-resolved
cp ~/Downloads/Tiny-Banned-Book-Library/rc-disabled.local /etc/rc.local
cp ~/Downloads/Tiny-Banned-Book-Library/nodogsplash.conf /etc/nodogsplash/nodogsplash.conf
echo "Starting NoDogSplash and editing the HTML files"
sudo nodogsplash
sudo unlink /etc/nginx/sites-enabled/default
echo "Move the config file for the nginxserver."
cp ~/Downloads/Tiny-Banned-Book-Library/example.conf /etc/nginx/sites-available/example.conf

sudo ln -s /etc/nginx/sites-available/example.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

echo "The services have been set to disable autorun. Reboot your system and you should have internet access. Download the books or copy them to a USB drive and move them over. Then move them into the library folder for calibre following the tutorial. After you have the books ready and everything you want downloaded, run the rc-enable.sh file in the tiny library github directory (It should be in your downloads). You might have to run chmod +777 rc-enable.sh to get it to run. Then do ./rc-enable.sh to run the script. After a reboot the server will autoload and start all the services and the calibre server. If you want internet access again, run the rc-disabled.sh script and reboot and you can access the internet. Running rc-disabled.sh will give you internet access after a reboot. Running rc-enable.sh will make the banned book library run as normal after a reboot."
