#!/bin/sh
#./buildcmd2sh.rb
cp patch/asm.sh woodrpg/akloader/patches/build.sh
cd woodrpg/akloader/patches/

#r4sdhc
echo r4sdhc
cp ../../../patch/r4sdhc/asm/*.s include/r4/
./build.sh
cp data/r4/save_nand.bin ../../../patch/r4sdhc/
cp data/r4/sd_save.bin ../../../patch/r4sdhc/

#ex4
echo ex4
cp ../../../patch/ex4/asm/*.s include/r4/
./build.sh
cp data/r4/save_nand.bin ../../../patch/ex4/
cp data/r4/sd_save.bin ../../../patch/ex4/
cp data/r4/dma4.bin ../../../patch/ex4/

#m3
echo m3
cp ../../../patch/m3/asm/*.s include/r4/
./build.sh
cp data/r4/save_nand.bin ../../../patch/m3/
cp data/r4/sd_save.bin ../../../patch/m3/
cp data/r4/dma4.bin ../../../patch/m3/

#g003
echo g003
cp ../../../patch/g003/asm/*.s include/r4/
./build.sh
cp data/r4/save_nand.bin ../../../patch/g003/
cp data/r4/sd_save.bin ../../../patch/g003/
cp data/r4/dma4.bin ../../../patch/g003/

#dstt
echo dstt
cp ../../../patch/dstt/asm/*.s include/r4/
./build.sh
cp data/r4/save_nand.bin ../../../patch/dstt/
cp data/r4/sd_save.bin ../../../patch/dstt/
cp data/r4/dma4.bin ../../../patch/dstt/

#dsttsd
echo dsttsd
cp ../../../patch/dsttsd/asm/*.s include/r4/
./build.sh
cp data/r4/save_nand.bin ../../../patch/dsttsd/
cp data/r4/sd_save.bin ../../../patch/dsttsd/
cp data/r4/dma4.bin ../../../patch/dsttsd/

echo finished.