#!/bin/bash
git clone --recursive https://github.com/securing/DumpsterDiver.git /usr/share/DumpsterDiver
cd /usr/share/DumpsterDiver
pip install -r requirements.txt
chmod 757 /usr/share/DumpsterDiver
chmod +x /usr/bin/dumpsterdiver