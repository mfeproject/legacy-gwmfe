#!/bin/sh
set -e
cp -f Data/mfein-$1 mfein
echo -n "Running example $1 ..."
./go
echo " Done"
echo "Compare mfelog with Data/mfelog-$1"
echo "Compare mfegrf with Data/mfegrf-$1"

