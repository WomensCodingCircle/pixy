#!/bin/bash

cd ..

PIXY_ROOT=$PWD
TARGET_BUILD_FOLDER=robot_in_python

mkdir $PIXY_ROOT/build/
mkdir $PIXY_ROOT/build/$TARGET_BUILD_FOLDER

echo "-----------------------------------------"
echo "Installing motor libraries"
echo "-----------------------------------------"
sudo pip install rrb3
sudo apt-get install python-dev python-setuptools
sudo pip install wiringpi
cd /tmp
git clone https://github.com/pololu/drv8835-motor-driver-rpi.git
cd drv8835-motor-driver-rpi
sudo python setup.py install
echo "-----------------------------------------"
echo "Finished installing motor libraries"
echo "-----------------------------------------"


cd $PIXY_ROOT/src/host/robot_in_python

# Abort script on error
set -e

echo "-----------------------------------------"
echo " Building Pixy Robot module"
echo "-----------------------------------------"

# Pass OS identity to C preprocessor #
OS=`uname`
if [ "$OS" == "Darwin" ]
then
  OS="__MACOS__"
elif [ "$OS" == "Linux" ]
then
  OS="__LINUX__"
fi

cp demo.py $PIXY_ROOT/build/$TARGET_BUILD_FOLDER
cp get_blocks.py $PIXY_ROOT/build/$TARGET_BUILD_FOLDER
cp pan_tilt.py $PIXY_ROOT/build/$TARGET_BUILD_FOLDER
cp pixy_racer.py $PIXY_ROOT/build/$TARGET_BUILD_FOLDER
cp rr_pixy_racer.py $PIXY_ROOT/build/$TARGET_BUILD_FOLDER
cp pixy.i $PIXY_ROOT/build/$TARGET_BUILD_FOLDER
cp setup.py $PIXY_ROOT/build/$TARGET_BUILD_FOLDER

cd $PIXY_ROOT/build/$TARGET_BUILD_FOLDER

swig -c++ -python pixy.i 

if [ "$1" == "debug" ]
then
  echo "OS is $OS"
  python setup.py build_ext --inplace -D"DEBUG,$OS"
else
  python setup.py build_ext --inplace -D$OS
fi

set +e

echo ""
echo "-----------------------------------------"
echo " Build complete"
echo "-----------------------------------------"
echo ""
echo "To run the examples execute the following commands:"
echo ""
echo " > cd ../build/robot_in_python"
echo " > python demo.py"
echo " > python get_blocks.py"
echo " > python pan_tilt.py"
echo " > python pixy_racer.py"
echo ""

cd $PIXY_ROOT/scripts
