#!/usr/bin/env bash
if [[ ! $EUID -eq 0 ]]
then
    echo "Please run as sudo.\n" >&2
    exit 1
fi

wget https://github.com/algorythm/secure-rpi-setup/archive/master.zip
[ ! -x "$(command -v unzip)" ] && sudo apt-get install -y unzip
unzip master.zip
cd secure-rpi-setup*
sudo ./setup.sh
