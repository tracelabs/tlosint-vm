#!/bin/sh


sudo apt-get update 
sudo apt-get dist-upgrade -y

echo '\nexport PATH=$PATH:$HOME/.local/bin' >> ~/.zshrc
source ~/.zshrc

sudo apt install spiderfoot -y
sudo apt install sherlock -y
sudo apt install maltego -y
sudo apt install python3-shodan -y
sudo apt install theharvester -y
sudo apt install webhttrack -y
sudo apt install outguess -y
sudo apt install stegosuite -y
sudo apt install wireshark -y
sudo apt install metagoofil -y
sudo apt install eyewitness -y
sudo apt install exifprobe -y
sudo apt install ruby-bundler -y
sudo apt install recon-ng -y
sudo apt install cherrytree -y
sudo apt install instaloader -y
sudo apt install photon -y
sudo apt install sublist3r -y
sudo apt install osrframework -y
sudo apt install joplin -y
sudo apt install drawing -y
sudo apt install finalrecon -y
sudo apt install cargo -y
sudo apt install pkg-config -y
sudo apt install npm -y
sudo apt install curl -y
sudo apt install python3-pip -y
sudo apt install pipx -y
sudo apt install python3-tweepy -y
sudo apt install python3-exifread -y
sudo apt install python3-fake-useragent -y
sudo apt install yt-dlp -y


pipx install youtube-dl
pip3 install dnsdumpster
pipx install h8mail
pipx install toutatis


mkdir -p ~/github-tools
cd ~/github-tools


# Install sn0int
curl -s https://apt.vulns.sexy/kpcyrd.pgp | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg
echo "deb http://apt.vulns.sexy stable main" | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list
sudo apt update        
sudo apt install sn0int -y




sudo npm i -g tiktok-scraper




# TJ Null Jopolin Notebook
if [ -d "~/Desktop/TJ-OSINT-Notebook" ]; then
    cd ~/Desktop/TJ-OSINT-Notebook
    git pull
    cd
    
else
    cd ~/Desktop
    git clone https://github.com/tjnull/TJ-OSINT-Notebook.git 
    cd
fi

