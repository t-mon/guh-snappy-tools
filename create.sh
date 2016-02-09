#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                         #
#  Copyright (C) 2016 Simon Stuerz <simon.stuerz@guh.guru>                #
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


########################################################
# ip to deploy
IP="10.10.10.62"
PORT="22"

CURRENT_DIR=`pwd`
BUILDDIR=${CURRENT_DIR}/build-snappy

########################################################
# bash colors
BASH_GREEN="\e[1;32m"
BASH_RED="\e[1;31m"
BASH_NORMAL="\e[0m"

printGreen() {
    echo -e "${BASH_GREEN}$1${BASH_NORMAL}"
}

printRed() {
    echo -e "${BASH_RED}$1${BASH_NORMAL}"
}

#########################################################
# check build dir
if [ -d ${BUILDDIR} ]; then
    read -p "Build directory already exists. Do you want to delete is? [y/N] " response
    if [[ $response == "y" || $response == "Y" || $response == "yes" || $response == "Yes" ]]
    then
        printGreen "[OK] Delete ${BUILDDIR}"
        sudo rm -rf ${BUILDDIR}
    else
        printRed "Exit without deleting build directory. Bye."
        exit 1
    fi
fi

########################################################

# create build dir
printGreen "[OK] Create build directory: ${BUILDDIR}"
mkdir -pv ${BUILDDIR}
cd ${BUILDDIR}

printGreen "[OK] Download guhd snappy build..."
wget http://www.guh.guru:8080/job/guh-builder-armhf-vivid-snappy/lastSuccessfulBuild/artifact/build-guh-snappy.tar.gz

printGreen "[OK] Extract guhd snappy build..."
tar -xvzf build-guh-snappy.tar.gz

printGreen "[OK] Copy meta data..."
cp -rv ${CURRENT_DIR}/meta ${BUILDDIR}

printGreen "[OK] Copy patched libsqlite3 data"
mkdir ${BUILDDIR}/sqlite3

cp ${CURRENT_DIR}/build-sqlite3.tar.gz ${BUILDDIR}/sqlite3
cd ${BUILDDIR}/sqlite3
tar -xvzf build-sqlite3.tar.gz

cd ..
cp -rv ${BUILDDIR}/sqlite3/.libs/libsqlite3.so* ${BUILDDIR}/usr/lib

printGreen "[OK] Clone guh-cli git clone https://github.com/guh/guh-cli.git package from guh repo..."
git clone https://github.com/guh/guh-cli.git

printGreen "[OK] Download guh-webinterface package from guh repo..."
sudo apt-get download guh-webinterface

printGreen "[OK]Extract package data..."
dpkg -x guh-webinterface* ./

mv -v usr/share/guh-webinterface/public/ ./

printGreen "[OK] Install guh-cli..."
mv -v guh-cli/guh-cli usr/bin/
mv -v guh-cli/guh usr/bin/

printGreen "[OK] Clean up..."
rm -fv build-guh-snappy.tar.gz
rm -fv *.deb
rm -rfv guh-cli
rm -rfv sqlite3
rm -rf usr/share/guh-webinterface
rm -rf etc
rm -fv ${BUILDDIR}/usr/lib/guh/plugins/libguh_devicepluginmock.so

printGreen "[OK] Build snappy package..."
snappy build .
echo -e "${BASH_GREEN}"
du -h *.snap
echo -e "${BASH_NORMAL}"

cp *.snap ${CURRENT_DIR}

printGreen "[OK] Install snappy on target ${IP}:${PORT}..."
snappy-remote --url=ssh://${IP}:${PORT} install *.snap

printGreen "[OK] Done."







