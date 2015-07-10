#!/bin/bash

# Note: to enable armhf download:
#       sudo dpkg --add-architecture armhf
#
# or add the armhf repo manually to the source.list:
#       
#

#check params
if [ -z $1 ]; then
    echo "usage: $0 <guhd-builddir>"
    exit 1
fi

# ip to deploy
IP="10.10.10.54"
PORT="22"

CURRENT_DIR=`pwd`
BUILD_DIR=${CURRENT_DIR}/build-snappy
GUHD_BUILD_DIR=$1

# colors
Color_Off='\e[0m'       # Text Reset
Green='\e[0;32m'        # Green


if [ -d ${BUILD_DIR} ]; then
    echo -e "${Green}Clean up build directory...${Color_Off}"
    rm -rf ${BUILD_DIR}
fi

# create build dir
echo -e "${Green}Create build directory... ${BUILD_DIR}${Color_Off}"
mkdir -pv ${BUILD_DIR}
cd ${BUILD_DIR}

echo -e "${Green}Copy guhd snappy build directory: ${GUHD_BUILD_DIR}${Color_Off}"
cp -rv ${GUHD_BUILD_DIR}/.ubuntu-sdk-deploy/* ./

echo -e "${Green}Copy meta data${Color_Off}"
cp -rv ${CURRENT_DIR}/meta ${BUILD_DIR}

echo -e "${Green}Clone guh-cli package from guh repo...${Color_Off}"
git clone https://github.com/guh/guh-cli.git

echo -e "${Green}Download guh-webserver package from guh repo...${Color_Off}"
apt-get download guh-webserver:armhf
echo -e "${Green}Download guh-webinterface package from guh repo...${Color_Off}"
apt-get download guh-webinterface

echo -e "${Green}Extract package data...${Color_Off}"
dpkg -x guh-webserver* ./
dpkg -x guh-webinterface* ./

mv -v usr/share/guh-webinterface/public/ ./

echo -e "${Green}Install guh-cli...${Color_Off}"
mv -v guh-cli/guh-cli usr/bin/
mv -v guh-cli/guh usr/bin/

echo -e "${Green}Clean up...${Color_Off}"
rm -fv *.deb
rm -rfv guh-cli
rm -rfv usr/share/guh-webinterface/public/

echo -e "${Green}Build snappy package...${Color_Off}"
snappy build .

du -h *.snap

echo -e "${Green}Install snappy on target ${IP}:${PORT}...${Color_Off}"
snappy-remote --url=ssh://${IP}:${PORT} install *.snap









