#!/bin/bash

. rom_urls.txt

wget $MIUI_CN_DEV_ZIP || exit 1
unzip $(basename $MIUI_CN_DEV_ZIP) system.transfer.list system.new.dat || exit 1
rm $(basename $MIUI_CN_DEV_ZIP)
python3 sdat2img.py system.transfer.list system.new.dat || exit 1
rm system.transfer.list system.new.dat
7z x -osystem system.img app/VirtualSim || exit 1
rm system.img

mv system/app/VirtualSim system/app/Virtua1Sim

find -exec touch -d @1230768000 -h {} +
find -type d -exec chmod 0755 {} +
find -type f -exec chmod 0644 {} +

version=$(grep -Po "version=\K.*" module.prop)
zip -r -x *.git* build.sh *.txt *.py *.zip *.yml -y -9 Mi6-MIRoaming-Systemless-$version.zip . || exit 1
