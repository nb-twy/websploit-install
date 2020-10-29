#!/usr/bin/env bash

# WebSploit installation script
# Author: Omar Ωr Santos
# Web: https://websploit.org
# Twitter: @santosomar
# Version: 2.7


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

# Make sure apt is using https (http is the default)
echo "[*] Make sure apt is using https"
sed -i 's|^deb http://|deb https://|'  /etc/apt/sources.list || exit 50

echo "[*] Make sure the system is up to date"
# Update repository metadata
apt update || exit 10

# Upgrade existing packages
apt upgrade -y --with-new-pkgs || exit 51

# Install applications from standard repositories
echo "[*] Install applications from standard repositories"
apt install -y wget vim vim-python-jedi curl exuberant-ctags \
    git ack-grep python3-pip ffuf jupyter-notebook \
    edb-debugger gobuster zaproxy || exit 11

# Clean up any packages and dependencies that are no longer needed
echo "[*] Clean up any packages and dependencies that are no longer needed"
apt autoremove -y || exit 10

# Get the username of the user running the script using sudo
SCRIPT_USER="$(whoami)"

# Create a directory for all setup files /home/$SCRIPT_USER/websploit
SETUP_DIR="/home/$SCRIPT_USER/websploit"
mkdir -p "$SETUP_DIR" || exit 12

# Installing radamsa
echo "[*] Install radamsa"
cd "$SETUP_DIR"
if ! radamsa --version 2>/dev/null; then
    if [[ ! -d radamsa ]]; then
        git clone https://gitlab.com/akihe/radamsa.git
    else
        echo "[-] Radamsa repo already cloned in $(pwd)/radamsa"
    fi
    cd radamsa && make && make install || exit 13
else
    echo "[-] Radamsa is already installed: $(radamsa --version)"
fi

# Installing Ghidra
# Ghidra requires java
# Kali linux comes with java 11.0.7 installed by default
# Check if java version >=11 is installed.  If not, install it.
JAVA_VER="$(java --version 2>/dev/null | grep "^openjdk" | cut -d' ' -f2 | cut -d'.' -f1)"
if [[ JAVA_VER -lt 11 ]]; then
    echo "[*] Install Java"
    cd "$SETUP_DIR"
    wget https://download.websploit.org/jdk.deb || exit 14
    apt install -y ./jdk.deb || exit 15
else
    echo "[-] Java already installed: \n\n $(java --version)"
fi

# Download and unzip ghidra
GHIDRA_DIR="ghidra_9.1.2_PUBLIC"
GHIDRA_FILE="$GHIDRA_DIR""_20200212.zip"
cd "$SETUP_DIR"
if [[ ! -d "$GHIDRA_FILE" ]]; then
    wget https://ghidra-sre.org/ghidra_9.1.2_PUBLIC_20200212.zip || exit 16
else
    echo "[-] Ghidra file already downloaded"
fi
if [[ ! -f "GHIDRA_DIR" ]]; then
    unzip ghidra* || exit 17
else
    echo "[-] Ghidra already extracted to $GHIDRA_DIR"
fi


# Cloning H4cker github
echo "[*] Cloning h4cker to $(pwd)/h4cker"
cd "$SETUP_DIR"
if [[ ! -d h4cker ]]; then
    git clone https://github.com/The-Art-of-Hacking/h4cker.git || exit 30
else
    echo "[-] h4cker repo already cloned to $(pwd)/h4cker"
fi

# Getting test ssl script
echo "[*] Getting testssl.sh"
cd "$SETUP_DIR"
if [[ ! -f testssl.sh ]]; then
    curl -L https://testssl.sh --output testssl.sh || exit 31
    chmod +x testssl.sh || exit 32
else
    echo "[-] testssl.sh file already exists"
fi

# Install python modules
# Use pip3 by default, since Python2 is officially deprecated
echo "[*] Install python modules"
pip3 install pep8 flake8 pyflakes isort yapf || exit 17

# Then get the .vimrc file from my repo, and install in /etc/vim/vimrc.local so that
# every user gets the same vim experience:
curl https://raw.githubusercontent.com/The-Art-of-Hacking/websploit/master/.vimrc > /etc/vim/vimrc.local || exit 18

#installing Docker
echo "[*] Installing docker"
if ! docker ps -a 2>&1 1>/dev/null; then
    cd "$SETUP_DIR"
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - || exit 20
    echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' | sudo tee /etc/apt/sources.list.d/docker.list || exit 21
    apt update || exit 22
    apt remove docker docker-engine docker.io || exit 23
    apt install -y docker-ce || exit 24
    # The vendor preset for docker-ce is for the service to be enabled.
    # If we do not want it to run on boot, we need to disable it
    # systemctl disable docker || exit 40
else
    echo "[-] Docker already installed: $(docker --version)"
fi

# setup containers
if docker ps 2>&1 1>/dev/null; then
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
else
    echo "[ERROR] Docker is not running. Cannot run containers."
    exit 60
fi
# for bwapp - go to /install.php then user/pass is bee/bug

# Downloading the h4cker wallpaper
echo "[*] Downloading h4cker wallpaper"
if [[ -d "$HOME/Pictures" ]]; then
    cd "$HOME"/Pictures
    if [[ ! -f h4cker_wallpaper.png ]]; then
        wget https://h4cker.org/img/h4cker_wallpaper.png
    else
        echo "[-] h4cker wallpaper already downloaded"
    fi
fi

# Adding an alias for ip command
ALIAS_FILE="$SETUP_DIR/websploit-aliases.sh"
echo "[*] Adding aliases"
cd "$SETUP_DIR"
if [[ ! -f "$ALIAS_FILE" ]]; then
    echo "alias i='ip -c -brie a'" >> "$ALIAS_FILE"
    echo "source $ALIAS_FILE" >> "$HOME/.bashrc"
    echo "source $ALIAS_FILE" >> root/.bashrc
    source .bashrc
else
    echo "[-] Alias file already exists.  Edit aliases at $ALIAS_FILE"
fi

# --> Need a set of tests to confirm that everything is installed properly!
#     If this is intended to help people with little experience setting up
#     a lab as complicated as this one, we should really check to make sure
#     that everything is set up properly before letting them loose with a false
#     sense of security.

#Getting the container info script
echo "[*] Get containers.sh"
cd "$SETUP_DIR"
if [[ ! -f containers.sh ]]; then
    wget http://websploit.h4cker.org/containers.sh
    chmod 744 containers.sh
else
    echo "[-] containers.sh already exists."
fi

#Final confirmation
./containers.sh
echo "
All tools, apps, and containers have been installed and setup.
-----------------
"

echo "All set! Have fun! - Ωr"
