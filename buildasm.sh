#!/bin/sh
./buildcmd2sh.rb
cd woodrpg/akloader/patches/

#r4sdhc
cp ../../../patch/r4sdhc/asm/*.s include/r4/
./build.sh
cp data/r4/{save_nand,sd_save}.bin ../../../patch/r4sdhc/

#ex4
cp ../../../patch/ex4/asm/*.s include/r4/
./build.sh
cp data/r4/{save_nand,sd_save,dma4}.bin ../../../patch/ex4/

#m3
cp ../../../patch/m3/asm/*.s include/r4/
./build.sh
cp data/r4/{save_nand,sd_save,dma4}.bin ../../../patch/m3/

#g003
cp ../../../patch/g003/asm/*.s include/r4/
./build.sh
cp data/r4/{save_nand,sd_save,dma4}.bin ../../../patch/g003/

#dstt
cp ../../../patch/dstt/asm/*.s include/r4/
./build.sh
cp data/r4/{save_nand,sd_save,dma4}.bin ../../../patch/dstt/

#dsttsd
cp ../../../patch/dsttsd/asm/*.s include/r4/
./build.sh
cp data/r4/{save_nand,sd_save,dma4}.bin ../../../patch/dsttsd/

