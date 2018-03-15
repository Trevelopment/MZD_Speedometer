#!/bin/sh

VER="$*"

# Clean release folder
rm -rf release

# Set Version
#sed -i s/Speedometer\ Version\ .*/Speedometer\ Version\ $VER/ tweaks.sh
#sed -i s/AIO_VER=.*/AIO_VER=$VER/ tweaks.sh
echo 'For more information visit <a href="https://github.com/Trevelopment/MZD_Speedometer">The MZD_Speedometer Repository</a>' > ./readme.htm
# Make new release folder and zip
mkdir release
7z a -aoa release/MZD_Speedometer_v"$VER".zip @list.txt
rm -f ./readme.htm