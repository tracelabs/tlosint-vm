#!/bin/sh
echo "deb http://http.kali.org/kali kali-last-snapshot main non-free contrib" | sudo tee /etc/apt/sources.list
apt-get install software-properties-common -y
apt-get update 
apt-get install -y python3-pip
cargo build --release
pip install --upgrade virtualenv
pip install --upgrade tweepy
pip install --upgrade pillow
pip install --upgrade exifread
pip install --upgrade jinja2
pip install --upgrade oauth2pip 
pip install --upgrade youtube-dl
pip install --upgrade requests
pip install --upgrade fake_useragent
pip install --upgrade dnsdumpster
pip install --upgrade simplejson
pip install --upgrade cfscrape
pip install --upgrade python-docx
pip install --upgrade urllib3
pip install --upgrade bs4
pip install --upgrade lxml
pip install --upgrade ipdb
pip install --upgrade pprint
pip install --upgrade click
pip install --upgrade numpy
pip install --upgrade tqdm
pip install --upgrade shodan
pip install --upgrade googletransx
pip install --upgrade requirements
pip install --upgrade schedule
pip install --upgrade pandas
pip install --upgrade aiohttp
pip install --upgrade aiohttp_socks
pip install --upgrade cchardet
pip install --upgrade elasticsearch
pip install --upgrade geopy
pip install --upgrade h8mail
pip install --upgrade shodan
pip install toutatis
pip install --upgrade yt-dlp
