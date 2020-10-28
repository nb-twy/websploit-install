#!/usr/bin/env bash

# WebSploit installation script
# Author: Omar Ωr Santos
# Web: https://websploit.org
# Twitter: @santosomar
# Version: 2.7

# Notes 
# 1. Instead of piping the command from the outpout of curl to sudo bash,
#    it would be better to store the file in a safe place, like Documents/ethical-hacking/install.sh
#    and then have the user/student execute ./install.sh.


clear
echo "

██╗    ██╗███████╗██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗████████╗
██║    ██║██╔════╝██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗██║╚══██╔══╝
██║ █╗ ██║█████╗  ██████╔╝███████╗██████╔╝██║     ██║   ██║██║   ██║
██║███╗██║██╔══╝  ██╔══██╗╚════██║██╔═══╝ ██║     ██║   ██║██║   ██║
╚███╔███╔╝███████╗██████╔╝███████║██║     ███████╗╚██████╔╝██║   ██║
 ╚══╝╚══╝ ╚══════╝╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝

https://websploit.org
Author: Omar Ωr Santos
Twitter: @santosomar
Version: 2.7

A collection of intentionally vulnerable applications running in
Docker containers. These include over 400 exercises to learn and
practice ethical hacking (penetration testing) skills.

"
read -n 1 -s -r -p "Press any key to continue the setup..."

echo " "
# Setting Up vim with Python Jedi to be used in several training courses

cd ~/
apt update
# --> Check to see if the attempt to install python-pip causes the system to fail installing 
#     python3-pip.
apt install -y wget vim vim-python-jedi curl exuberant-ctags git ack-grep python-pip python3-pip
# --> There should definitely be a check here or default to using pip3.  Python2 is officially
#     deprecated afterall.
pip install pep8 flake8 pyflakes isort yapf

# Then get the .vimrc file from my repo:
# --> If you install the vimrc file to /etc/vim/vimrc.local, it will work for every user 
#     instead of being different for different users.  This is a typical problem when editing
#     files as a regular user vs. editing as root, with sudo or as otherwise.
curl https://raw.githubusercontent.com/The-Art-of-Hacking/websploit/master/.vimrc > ~/.vimrc

#installing Docker
#apt install -y docker.io

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' | sudo tee /etc/apt/sources.list.d/docker.list
apt update
apt remove docker docker-engine docker.io
apt install -y docker-ce

# setup containers
docker run --name webgoat -d --restart unless-stopped -p 8881:8080 -t santosomar/webgoat
docker run --name juice-shop --restart unless-stopped -d -p 8882:3000 santosomar/juice-shop:latest
docker run --name dvwa --restart unless-stopped -itd -p 8883:80 santosomar/dvwa
docker run --name mutillidae_2 --restart unless-stopped -d -p 8884:80 santosomar/mutillidae_2
docker run --name bwapp2 --restart unless-stopped -d -p 8885:80 santosomar/bwapp
docker run --name dvna --restart unless-stopped -d -p 8886:9090 santosomar/dvna
docker run --name hackazon -d --restart unless-stopped -p 8887:80 santosomar/hackazon
docker run --name hackme-rtov -d --restart unless-stopped -p 8888:80 santosomar/hackme-rtov
docker run --name mayhem -d --restart unless-stopped -p 8889:80 -p 88:22 santosomar/mayhem
docker run --name rtv-safemode -d --restart unless-stopped -p 9000:80 -p 3306:3306 santosomar/rtv-safemode
docker run --name grayhat-mmxx -d --restart unless-stopped -p 9001:8001 santosomar/grayhat-mmxx
docker run --name yascon-hackme -d --restart unless-stopped -p 9002:80 santosomar/yascon-hackme

# --> Docker seems to be starting at boot.  Check why.
# for bwapp - go to /install.php then user/pass is bee/bug

#downloading the h4cker wallpaper
# --> It would be better to put this in $HOME/Pictures instead of hard coding it to /root
cd /root/Pictures
wget https://h4cker.org/img/h4cker_wallpaper.png

#cloning H4cker github
# --> It would be better to put this in $HOME/Documents/
cd /root
git clone https://github.com/The-Art-of-Hacking/h4cker.git

#getting test ssl script
# --> Put this in $HOME/Documents/ethical-hacking
curl -L https://testssl.sh --output testssl.sh
chmod +x testssl.sh

# --> Put all of the installations in an install section at the top
#Installing ffuf 
apt install -y ffuf

#Installing Jupyter Notebooks
apt install -y jupyter-notebook

#Installing radamnsa
# --> Doesn't need to be in root!  Put in Documents or ethical-hacking
cd /root
git clone https://gitlab.com/akihe/radamsa.git && cd radamsa && make && sudo make install

#Installing Ghidra
cd /root

# first install Java
wget https://download.websploit.org/jdk.deb
apt install -y ./jdk.deb

#then download and unzip ghidra
wget https://ghidra-sre.org/ghidra_9.1.2_PUBLIC_20200212.zip
unzip ghidra*

#Installing EDB
apt install -y edb-debugger

#Installing gobuster
apt install -y gobuster

#Installing OWASP ZAP
apt install -y zaproxy

#Getting the container info script
# --> This should go in the ethical-hacking dir 
cd /root
wget http://websploit.h4cker.org/containers.sh
chmod 744 containers.sh

# Adding an alias for ip command
# --> Aliases need to be added for both the current user and for root
# --> Use an alias script (h4cker.alias.sh), put it in /usr/bin, and reference from both
#     $HOME/.bashrc and /root/.bashrc
echo "alias i='ip -c -brie a'" >> .bashrc
source .bashrc

# --> Need a set of tests to confirm that everything is installed properly!
#     If this is intended to help people with little experience setting up
#     a lab as complicated as this one, we should really check to make sure
#     that everything is set up properly before letting them loose with a false
#     sense of security.

#Final confirmation
/root/containers.sh
echo "
All tools, apps, and containers have been installed and setup.
-----------------
"

echo "All set! Have fun! - Ωr"
