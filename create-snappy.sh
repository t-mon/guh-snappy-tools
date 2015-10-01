#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                         #
#  Copyright (C) 2015 Simon Stuerz <simon.stuerz@guh.guru>                #
#                                                                         #
#  This file is part of guh.                                              #
#                                                                         #
#  guh is free software: you can redistribute it and/or modify            #
#  it under the terms of the GNU General Public License as published by   #
#  the Free Software Foundation, version 2 of the License.                #
#                                                                         #
#  guh is distributed in the hope that it will be useful,                 #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of         #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           #
#  GNU General Public License for more details.                           #
#                                                                         #
#  You should have received a copy of the GNU General Public License      #
#  along with guh. If not, see <http://www.gnu.org/licenses/>.            #
#                                                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


#check params
if [ -z $1 ]; then
    echo "usage: $0 <guhd-builddir>"
    exit 1
fi

# ip to deploy
IP="10.10.10.50"
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

echo -e "${Green}Clone guh-cli git clone https://github.com/guh/guh-cli.git package from guh repo...${Color_Off}"
git clone https://github.com/guh/guh-cli.git

echo -e "${Green}Download guh-webinterface package from guh repo...${Color_Off}"
apt-get download guh-webinterface

echo -e "${Green}Extract package data...${Color_Off}"
dpkg -x guh-webinterface* ./

mv -v usr/share/guh-webinterface/public/ ./

echo -e "${Green}Install guh-cli...${Color_Off}"
mv -v guh-cli/guh-cli usr/bin/
mv -v guh-cli/guh usr/bin/

echo -e "${Green}Clean up...${Color_Off}"
rm -fv *.deb
rm -rf guh-cli
rm -rf usr/share/guh-webinterface
rm -rf etc
rm -fv ${BUILD_DIR}/usr/lib/guh/plugins/libguh_devicepluginmock.so

echo -e "${Green}Build snappy package...${Color_Off}"
snappy build .
echo -e "${Green}"
du -h *.snap
echo -e "${Color_Off}"

#echo -e "${Green}Removing old snappy package from target ${IP}:${PORT}...${Color_Off}"
#ssh ubuntu@${IP} 'sudo snappy remove guh'

echo -e "${Green}Install snappy on target ${IP}:${PORT}...${Color_Off}"
snappy-remote --url=ssh://${IP}:${PORT} install *.snap









