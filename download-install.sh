#!/usr/bin/env bash
wget https://github.com/algorythm/secure-rpi-setup/archive/master.zip
[ ! -x "$(command -v unzip)" ] && sudo apt-get install -y unzip
unzip master.zip
cd secure-rpi-setup*
sudo ./setup.sh
