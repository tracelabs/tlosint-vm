#!/bin/sh
#Dumpsterdiver
git clone --recursive https://github.com/securing/DumpsterDiver.git /usr/share/DumpsterDiver
cd /usr/share/DumpsterDiver
pip install -r requirements.txt
chmod 757 /usr/share/DumpsterDiver
chmod +x /usr/bin/dumpsterdiver

#Infoga
git clone --recursive https://github.com/m4ll0k/Infoga.git /usr/share/Infoga
cd /usr/share/Infoga
python3 setup.py install
chmod +x /usr/bin/infoga

#PhoneInfoga
mkdir -p /usr/share/phoneinfoga
wget https://github.com/sundowndev/phoneinfoga/releases/download/v2.0.8/phoneinfoga_$(uname -s)_$(uname -m).tar.gz -O /usr/share/phoneinfoga/phoneinfoga_$(uname -s)_$(uname -m).tar.gz
cd /usr/share/phoneinfoga
tar xvf phoneinfoga_$(uname -s)_$(uname -m).tar.gz
ln -s /usr/share/phoneinfoga/phoneinfoga /usr/bin/phoneinfoga
chmod +x /usr/bin/phoneinfoga

#Spiderpig
git clone --recursive https://github.com/hatlord/Spiderpig.git /usr/share/Spiderpig
cd /usr/share/Spiderpig
bundle install
chmod +x /usr/bin/spiderpig

#TJ-Null OSINT Notebook
git clone --recursive https://github.com/tjnull/TJ-OSINT-Notebook.git /etc/skel/Desktop/TJ-OSINT-Notebook
