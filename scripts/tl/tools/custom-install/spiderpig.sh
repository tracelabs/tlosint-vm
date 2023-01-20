#!/bin/bash
git clone --recursive https://github.com/hatlord/Spiderpig.git /usr/share/Spiderpig
cd /usr/share/Spiderpig
bundle install
chmod +x /usr/bin/spiderpig