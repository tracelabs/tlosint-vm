#!/bin/bash
mkdir -p /usr/share/phoneinfoga
wget https://github.com/sundowndev/phoneinfoga/releases/download/v2.0.8/phoneinfoga_$(uname -s)_$(uname -m).tar.gz -O /usr/share/phoneinfoga/phoneinfoga_$(uname -s)_$(uname -m).tar.gz
cd /usr/share/phoneinfoga
tar xvf phoneinfoga_$(uname -s)_$(uname -m).tar.gz
ln -s /usr/share/phoneinfoga/phoneinfoga /usr/bin/phoneinfoga
chmod +x /usr/bin/phoneinfoga