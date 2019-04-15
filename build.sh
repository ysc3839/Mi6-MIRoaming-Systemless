#!/bin/bash

. rom_urls.txt

wget $MIUI_CN_DEV_ZIP || exit 1
unzip $(basename $MIUI_CN_DEV_ZIP) system.transfer.list system.new.dat || exit 1
rm $(basename $MIUI_CN_DEV_ZIP)
python3 sdat2img.py system.transfer.list system.new.dat || exit 1
rm system.transfer.list system.new.dat
7z x -osystem system.img app/VirtualSim || exit 1
rm system.img

pushd system/app/VirtualSim
  ../../../vdexExtractor -i oat/arm64/VirtualSim.vdex -o . || exit 1
  rm -r oat

  java -jar ../../../baksmali-2.2.5.jar disassemble --debug-info false -o smali VirtualSim_classes.dex || exit 1

  pushd smali/com/miui/virtualsim/utils
    name=$(grep -rl IS_INTERNATIONAL_BUILD)
    [ $? -eq 0 ] && sed -i 's|sget-boolean \([a-z][0-9]\+\), Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z|const/4 \1, 0x0|g' $name
  popd

  pushd smali/com/miui/mimobile/utils
    sed -i 's/su"/noexistsu"/g' RootUtil.smali
  popd

  java -jar ../../../smali-2.2.5.jar a -a 26 smali -o classes.dex
  rm -r smali
  rm VirtualSim_classes.dex

  mv VirtualSim_classes2.dex classes2.dex

  zip VirtualSim.apk classes.dex classes2.dex
  rm classes.dex classes2.dex
popd

mv system/app/VirtualSim system/app/Virtua1Sim

find -exec touch -d @0 -h {} +
find -type d -exec chmod 0755 {} +
find -type f -exec chmod 0644 {} +

version=$(grep -Po "version=\K.*" module.prop)
zip -r -x *.git* build.sh *.txt *.py *.zip *.yml *.jar vdexExtractor -y -9 Mi6-MIRoaming-Systemless-$version.zip . || exit 1
