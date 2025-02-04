#!/bin/bash
set -e
set -o pipefail
# trap any script errors and exit
trap "trapError" ERR

trapError() {
	echo
	echo " ^ Received error ^"
	cat formula.log
	exit 1
}

installPackages(){
    sudo apt-get update -q
    sudo apt-get -y install multistrap unzip coreutils gperf
}

createRaspbianImg(){
    #needed since Ubuntu 18.04 - allow non https repositories
    mkdir -p raspbian/etc/apt/apt.conf.d/
    echo 'Acquire::AllowInsecureRepositories "true";' | sudo tee raspbian/etc/apt/apt.conf.d/90insecure
    multistrap -a arm64 -d raspbian -f multistrap.conf
}

downloadToolchain(){
    wget https://github.com/openframeworks/openFrameworks/releases/download/tools/cross-gcc-10.3.0-pi_64.tar.gz
    tar xvf cross-gcc-10.3.0-pi_64.tar.gz
    mv cross-pi-gcc-10.3.0-64 rpi_toolchain
    rm cross-gcc-10.3.0-pi_64.tar.gz
}

downloadFirmware(){
    wget -nv https://github.com/raspberrypi/firmware/archive/master.zip -O firmware.zip
    unzip firmware.zip
    cp -r firmware-master/opt raspbian/
    rm -r firmware-master
    rm firmware.zip
}

relativeSoftLinks(){
    for link in $(ls -la | grep "\-> /" | sed "s/.* \([^ ]*\) \-> \/\(.*\)/\1->\/\2/g"); do
        lib=$(echo $link | sed "s/\(.*\)\->\(.*\)/\1/g");
        link=$(echo $link | sed "s/\(.*\)\->\(.*\)/\2/g");
        rm $lib
        ln -s ../../..$link $lib
    done

    for f in *; do
        error=$(grep " \/lib/" $f > /dev/null 2>&1; echo $?)
        if [ $error -eq 0 ]; then
            sed -i "s/ \/lib/ ..\/..\/..\/lib/g" $f
            sed -i "s/ \/usr/ ..\/..\/..\/usr/g" $f
        fi
    done
}

if [[ $(uname -m) != armv* ]]; then

	ROOT=$( cd "$(dirname "$0")" ; pwd -P )
	echo $ROOT
	cd $ROOT
	installPackages
	createRaspbianImg
	downloadToolchain
	downloadFirmware

        cp -rn rpi_toolchain/aarch64-linux-gnu/libc/lib/* $ROOT/raspbian/usr/lib/
        cp -rn rpi_toolchain/aarch64-linux-gnu/libc/usr/lib/* $ROOT/raspbian/usr/lib/
        cp -rn rpi_toolchain/aarch64-linux-gnu/lib/* $ROOT/raspbian/usr/lib/

        cd $ROOT/raspbian/usr/lib
        relativeSoftLinks
        cd $ROOT/raspbian/usr/lib/aarch64-linux-gnu
        relativeSoftLinks
fi
