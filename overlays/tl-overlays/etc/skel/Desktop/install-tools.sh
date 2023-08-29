#!/bin/sh


sudo apt-get update 
sudo apt-get dist-upgrade -y
echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc
echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.zshrc
export PATH=$PATH:$HOME/.local/bin

sudo apt install sherlock -y
sudo apt install maltego -y
sudo apt install webhttrack -y
sudo apt install outguess -y
sudo apt install stegosuite -y
sudo apt install metagoofil -y
sudo apt install eyewitness -y
sudo apt install exifprobe -y
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


pip3 install --upgrade tweepy
pip3 install --upgrade exifread 
pip3 install --upgrade youtube-dl
pip3 install --upgrade fake_useragent
pip3 install --upgrade dnsdumpster
pip3 install --upgrade h8mail
pip3 install --upgrade shodan
pip3 install --upgrade toutatis
pip3 install --upgrade yt-dlp


mkdir -p ~/github-tools
cd ~/github-tools


# sn0int, will come back to this and test the install better
#sudo apt install debian-keyring
#gpg -a --export --keyring /usr/share/keyrings/debian-maintainers.gpg kpcyrd@archlinux.org | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg
#echo deb http://apt.vulns.sexy stable main | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list
#sudo apt update
#sudo apt install sn0int




sudo npm i -g tiktok-scraper



# Install Vortimo
vortimo_debian=$(curl -s https://www.vortimo.com/down/ | grep --color -E "[^\S ]*Vortimo-.*[0-9].deb" -o | awk -F '="' '{print $2}')
vortimo_package=$(echo $vortimo_debian | awk -F '/' '{print $NF}')
curl -O -s $vortimo_debian
sudo dpkg -i $vortimo_package
rm $vortimo_package


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

# Install Obsidian app image
cd ~/Desktop
wget -O Obsidian-1.3.7.AppImage https://github.com/obsidianmd/obsidian-releases/releases/download/v1.3.7/Obsidian-1.3.7.AppImage 
chmod +x Obsidian-1.3.7.AppImage
