#!/bin/sh

#OnionSearch
git clone --recursive https://github.com/megadose/OnionSearch.git /usr/share/OnionSearch
cd /usr/share/OnionSearch
python3 setup.py install
chmod +x /usr/bin/OnionSearch

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

#TJ-Null OSINT Notebook
git clone --recursive https://github.com/tjnull/TJ-OSINT-Notebook.git /etc/skel/Desktop/TJ-OSINT-Notebook
