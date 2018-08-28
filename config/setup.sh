#!/usr/bin/env bash

# ==== System ====

# Stop on error and make it verbose.

set -xe

# Resolve the path to this directory.

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"

# Resolve the path to the root.
ROOT_DIR=$(realpath $DIR/..)

# Variables

TOOLS_DIRECTORY="$ROOT_DIR/tools/"
CONFIG_DIRECTORY="$ROOT_DIR/config/"
CTF_DIRECTORY="$ROOT_DIR/ctfs/"

# System packages

dpkg --add-architecture i386
apt-get update && apt-get -y upgrade
apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386
apt-get install -y python-minimal python-pip git python3-pip
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
apt-get install -y wget
pip install -U pip
hash -r
pip install -U ipython

# Docker

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce
usermod -aG docker vagrant

# ==== Build ====

# Basic

apt-get install -y build-essential cmake

# ARM

apt-get install -y gcc-arm-linux-gnueabihf

# MIPS

apt-get install -y gcc-mips-linux-gnu

# PowerPC

apt-get install -y gcc-powerpc64-linux-gnu

# ==== Languages ====

# Java

apt install -y openjdk-11-jre-headless

# Go

apt install -y golang-go

# ==== Tools ====

# Pwntools

apt-get install -y python-dev git libssl-dev libffi-dev build-essential
pip install -U capstone
pip install -U ropper
pip install -U pwntools

# Gef

apt-get install -y gdb
pushd $TOOLS_DIRECTORY
if [ ! -d "gef" ] ; then
    git clone --depth 1 https://github.com/hugsy/gef.git gef
fi
echo "source $TOOLS_DIRECTORY/gef/gef.py" >> ~/.gdbinit
popd

# Radare2

pushd $TOOLS_DIRECTORY
if [ ! -d "radare2" ] ; then
    git clone --depth 1 https://github.com/radare/radare2.git radare2
fi
pushd radare2
sys/install.sh
popd
popd

# Libc Database
pushd $TOOLS_DIRECTORY
if [ ! -d "libc-database" ] ; then
    git clone --depth 1 https://github.com/niklasb/libc-database.git libc-database
fi
pushd libc-database
./get || true
popd
popd

# Angr

pip install -U angr

# ==== Emulators ====

apt-get install -y e2tools qemu unzip
pip3 install https://github.com/nongiach/arm_now/archive/master.zip --upgrade
