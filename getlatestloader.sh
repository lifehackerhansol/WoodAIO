#!/bin/sh
wget -O tmp.7z http://filetrip.net/h25123666-.html #WoodR4
7za x -otmp tmp.7z
r4crypt d tmp/Wood*/_DS_MENU.DAT tmp/akmenu4.nds
akextract_wood tmp/akmenu4.nds >build/__rpg/r4loader.nds
rm -rf tmp/

wget -O tmp.7z http://filetrip.net/h35130032-.html #WoodRPG
7za x -otmp tmp.7z
akextract_wood tmp/Wood*/akmenu4.nds >build/__rpg/rpgloader.nds
rm -rf tmp/

wget -O tmp.7z http://filetrip.net/h35130793-.html #WoodR4iDSN
7za x -otmp tmp.7z
akextract_wood tmp/Wood*/_DSMENU.DAT >build/__rpg/r4idsnloader.nds
rm -rf tmp/
rm tmp.7z
