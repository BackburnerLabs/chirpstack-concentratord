#!/bin/bash
set -e

# ChirpStack HAL library versions (from the Dockerfile)
SX1301_VERSION=v5.0.1r4
SX1302_VERSION=V2.1.0r9
SX2G4_VERSION=V1.1.0

# Create build directory
HAL_DIR="/tmp/chirpstack-hal"
mkdir -p $HAL_DIR
cd $HAL_DIR

echo "Building ChirpStack HAL libraries locally..."

# Build SX1301 HAL
echo "Building sx1301 HAL"
if [ ! -d "lora_gateway" ]; then
    git clone https://github.com/brocaar/lora_gateway.git -b $SX1301_VERSION
fi
cd lora_gateway
sed -i "s/CFLAGS\(.*\)/CFLAGS\1\ -fPIE/" libloragw/Makefile
make clean || true
make

# Install SX1301 HAL
sudo mkdir -p /usr/local/include/libloragw-sx1301
sudo mkdir -p /usr/local/lib
sudo cp -r libloragw/inc/* /usr/local/include/libloragw-sx1301/
sudo cp libloragw/libloragw.a /usr/local/lib/libloragw-sx1301.a

cd $HAL_DIR

# Build SX1302 HAL
echo "Building sx1302 HAL"
if [ ! -d "sx1302_hal" ]; then
    git clone https://github.com/brocaar/sx1302_hal.git -b $SX1302_VERSION
fi
cd sx1302_hal
sed -i "s/CFLAGS\(.*\)/CFLAGS\1\ -fPIE/" libloragw/Makefile
make clean || true
make libloragw

# Install SX1302 HAL
sudo mkdir -p /usr/local/include/libloragw-sx1302
sudo cp -r libloragw/inc/* /usr/local/include/libloragw-sx1302/
sudo cp libloragw/libloragw.a /usr/local/lib/libloragw-sx1302.a
sudo cp libtools/inc/* /usr/local/include/
sudo cp libtools/*.a /usr/local/lib/

cd $HAL_DIR

# Build 2G4 HAL
echo "Building 2g4 HAL"
if [ ! -d "gateway_2g4_hal" ]; then
    git clone https://github.com/Lora-net/gateway_2g4_hal.git -b $SX2G4_VERSION
fi
cd gateway_2g4_hal
sed -i "s/CFLAGS\(.*\)/CFLAGS\1\ -fPIE/" libloragw/Makefile
make clean || true
make libloragw

# Install 2G4 HAL
sudo mkdir -p /usr/local/include/libloragw-2g4
sudo cp -r libloragw/inc/* /usr/local/include/libloragw-2g4/
sudo cp libloragw/libloragw.a /usr/local/lib/libloragw-2g4.a

# Update library cache
sudo ldconfig

echo "HAL libraries built and installed successfully!"
echo "You can now run: cargo build --release"

# Optional: clean up build directory
# rm -rf $HAL_DIR