#!/bin/sh
export LC_ALL=en_US.UTF-8

#: <<"#FETCH_WOODRPG"
echo Fetching WoodRPG...
if [ -f woodrpg.7z ]; then #use cache
	7z x -y woodrpg.7z
	#due to diropen() stuff, only dkarm r32 is supported...
	#find -name "Makefile"|xargs sed -i "s/ -mno-fpu//" #bah...
else
	svn co http://woodrpg.googlecode.com/svn/trunk/ woodrpg
	7z a -mx=9 -xr0!*/.svn/* -xr0!*/.svn woodrpg.7z woodrpg #cache. This cache is also meant to meet GPL condition...
fi

cp -f patch/libelm_Makefile_dldi woodrpg/libelm/build/Makefile
dos2unix woodrpg/libelm/source/ff.c
patch -p0 < patch/libelm_ff.patch

cp -f patch/libunds_dldi_stub_16k.s woodrpg/libunds/source/arm9/dldi/dldi_stub.s
cp -f patch/makefile_all woodrpg/makefile
#FETCH_WOODRPG

cd woodrpg

#: <<"#__BUILD_GUI"

cp -f ../patch/romloader.cpp akmenu4/arm9/source/
rm -f akmenu4/arm9/data/r4/*.bin
rm -f akmenu4/arm9/data/rpg/*.bin
rm -f akmenu4/arm9/data/r4idsn/*.bin

#: <<"#BUILD_WOODRPG_BASE"
echo Building WoodRPG base structure...
cp -f ../patch/libunds_dldi_stub.s libunds/source/arm9/dldi/dldi_stub.s
make dldi fonts akmenu4/akmenu4.nds >/dev/null

mkdir ../build/__rpg 2>/dev/null
mkdir ../build/__rpg/fonts 2>/dev/null
cp -f dldi/r4_sd/r4_sd.dldi ../build/__rpg/r4_sd.dldi
cp -f dldi/r4_sd/r4_sd.dldi ../build/__rpg/r4ds.dldi
cp -f dldi/rpg_nand/rpg_nand.dldi ../build/__rpg/
cp -f dldi/rpg_sd/rpg_sd.dldi ../build/__rpg/
binreplace dldi/r4idsn_sd/r4idsn_sd.dldi "R4i #" "_R4i#"
cp -f dldi/r4idsn_sd/r4idsn_sd.dldi ../build/__rpg/
cp fonts/*.pcf ../build/__rpg/fonts
cp -a ui ../build/__rpg/
cp -a language ../build/__rpg/

cp -f akmenu4/akmenu4.nds ../build/woodrpg_mod.nds
make clean >/dev/null
dldipatch ../build/__rpg/rpg_nand.dldi ../build/woodrpg_mod.nds
#modifybanner ../build/woodrpg_mod.nds "Wood RPG mod;with autorunWithLastRom" #"Real Play Gear" is printed by default
cp -f ../patch/libunds_dldi_stub_16k.s libunds/source/arm9/dldi/dldi_stub.s
#BUILD_WOODRPG_BASE

#: <<"#BUILD_WOODR4"
echo Building WoodR4 and WoodR4iDSN...
make akmenu4/_DS_MENU.DAT akmenu4/_DSMENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodr4.nds
cp -f akmenu4/_DSMENU.DAT ../build/woodr4idsn.nds
make clean >/dev/null
dldipatch ../build/__rpg/r4_sd.dldi ../build/woodr4.nds
dldipatch ../build/__rpg/r4idsn_sd.dldi ../build/woodr4idsn.nds
modifybanner ../build/woodr4.nds "Wood R4 mod;with autorunWithLastRom"
modifybanner ../build/woodr4idsn.nds "Wood R4idsn mod;with autorunWithLastRom"
#BUILD_WOODR4

#: <<"#BUILD_WOODR4SDHC"
echo Building WoodR4sdhc...
cp -f ../patch/romloader_r4sdhc.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodr4sdhc.nds
make clean >/dev/null
dldipatch ../build/__rpg/r4_sd.dldi ../build/woodr4sdhc.nds
modifybanner ../build/woodr4sdhc.nds "Wood R4 SDHC;partial clone support;sav defragment"
#BUILD_WOODR4SDHC

#: <<"#BUILD_WOODILS"
echo Building WoodiLS...
cp -f ../patch/romloader_ils.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodils.nds
make clean >/dev/null
dldipatch ../patch/ex4tf.dldi ../build/woodils.nds
modifybanner ../build/woodils.nds "Wood iLS;for R4iLS;only for SD <=4GB"
#BUILD_WOODILS

#: <<"#BUILD_WOODEX4"
echo Building WoodEX4...
cp -f ../patch/romloader_ex4.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodex4.nds
make clean >/dev/null
dldipatch ../patch/ex4tf.dldi ../build/woodex4.nds
modifybanner ../build/woodex4.nds "Wood EX4;for R4iLS/EX4DS;nds/sav defragment"
#BUILD_WOODEX4

#: <<"#BUILD_WOODM3"
echo Building WoodM3...
cp -f ../patch/romloader_m3.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodm3.nds
make clean >/dev/null
dldipatch ../patch/m3ds.dldi ../build/woodm3.nds
modifybanner ../build/woodm3.nds "Wood M3;for M3Real/M3iZero"
#BUILD_WOODM3

: <<"#BUILD_WOODG003"
echo Building WoodG003...
cp -f ../patch/romloader_g003.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodg003.nds
make clean >/dev/null
dldipatch ../patch/g003.dldi ../build/woodg003.nds
modifybanner ../build/woodg003.nds "Wood G003;for GMP-Z003;nds/sav defragment"
#BUILD_WOODG003

: <<"#BUILD_WOODDSTT" #bad...
echo Building WoodDSTT...
cp -f ../patch/romloader_dstt.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/wooddstt.nds
make clean >/dev/null
dldipatch ../patch/ttio.dldi ../build/wooddstt.nds
modifybanner ../build/wooddstt.nds "Wood DSTT;for DSTT/SCDSONE(i);nds/sav defragment"
#BUILD_WOODDSTT

#: <<"#BUILD_WOODTT"
echo Building WoodTT...
cp -f ../patch/romloader_tt.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodtt.nds
make clean >/dev/null
dldipatch ../build/__rpg/tt_sd.dldi ../build/woodtt.nds
modifybanner ../build/woodtt.nds "Wood TT;for DSTT/SCDSONE(i)"
#BUILD_WOODTT

#: <<"#BUILD_WOODAK2i"
echo Building WoodAK2i...
cp -f ../patch/romloader_ak2i.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodak2i.nds
make clean >/dev/null
dldipatch ../build/__rpg/ak2sd.dldi ../build/woodak2i.nds
modifybanner ../build/woodak2i.nds "Wood AK2i"
#BUILD_WOODAK2i

#: <<"#BUILD_WOODR4Li"
echo Building WoodR4Li...
cp -f ../patch/romloader_r4li.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodr4li.nds
make clean >/dev/null
dldipatch ../build/__rpg/r4li_sd.dldi ../build/woodr4li.nds
modifybanner ../build/woodr4li.nds "Wood R4li"
#BUILD_WOODAK2i

cp -f ../patch/fatx.h akmenu4/arm9/source/fatx.h

#: <<"#BUILD_WOODR4LS"
echo Building WoodR4LS...
cp -f ../patch/romloader_r4ls.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodr4ls.nds
make clean >/dev/null
dldipatch ../build/__rpg/r4_sd.dldi ../build/woodr4ls.nds
modifybanner ../build/woodr4ls.nds "Wood R4LS;R4_AK_Special lives longer"
#BUILD_WOODR4LS

#: <<"#BUILD_WOODRPG_AK2i"
echo Building WoodRPG AK2i...
cp -f ../patch/romloader_rpgak2i.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodrpg_ak2i.nds
make clean >/dev/null
modifybanner ../build/woodrpg_ak2i.nds "Wood R4;modified for akloader"
#BUILD_WOODRPG_AK2i

cp -f ../patch/dldi.h akmenu4/arm9/source/dldi.h
cp -f ../patch/main_waio.cpp akmenu4/arm9/source/main.cpp

#: <<"#BUILD_WAIO"
echo Building WAIO...
cp -f ../patch/romloader_waio.cpp akmenu4/arm9/source/romloader.cpp
cp -f ../patch/libunds_dldi_stub.s libunds/source/arm9/dldi/dldi_stub.s
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/waio.nds
make clean >/dev/null
modifybanner ../build/waio.nds "WAIO - Wood All In One;another frontend for;MoonShell2 Extlink Wrapper"
cp -f ../patch/libunds_dldi_stub_16k.s libunds/source/arm9/dldi_stub.s
#BUILD_WAIO

#__BUILD_GUI

#: <<"#__BUILD_LOADER"

cp -f ../patch/akloader_main_ils.cpp akloader/arm9/source/main.cpp
cp -f ../patch/dldi.c akloader/arm9/source/dldi.c
cp -f ../patch/akloader_dbgtool.h akloader/arm9/source/dbgtool.h #dldi() uses dbg_printf()
cp -f ../patch/libunds_dldi_stub_16k.s libunds/source/arm9/dldi/dldi_stub.s

#cp -f ../patch/akloader_patches_ar.cpp akloader/arm9/source/patches_ar.cpp

: <<"#BUILD_NORMAL_LOADER"
echo Building normal loaders...
make akloader/akloader_r4.nds akloader/akloader_rpg.nds akloader/akloader_r4idsn.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/r4loader.nds
cp -f akloader/akloader_rpg.nds ../build/__rpg/rpgloader.nds
cp -f akloader/akloader_r4idsn.nds ../build/__rpg/r4idsnloader.nds
cp -f akloader/akloader_r4.nds ../build/__rpg/ilsloader.nds
make clean >/dev/null
dldipatch ../build/__rpg/r4_sd.dldi ../build/__rpg/r4loader.nds
dldipatch ../build/__rpg/rpg_nand.dldi ../build/__rpg/rpgloader.nds
dldipatch ../build/__rpg/r4idsn_sd.dldi ../build/__rpg/r4idsnloader.nds
dldipatch ../patch/ex4tf.dldi ../build/__rpg/ilsloader.nds
#BUILD_NORMAL_LOADER

#: <<"#BUILD_ILSLOADER"
echo Building ilsloader.nds...
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/ilsloader.nds
make clean >/dev/null
dldipatch ../patch/ex4tf.dldi ../build/__rpg/ilsloader.nds
#BUILD_ILSLOADER

cp -f ../patch/akloader_rpgmaps_sav.cpp akloader/arm9/source/rpgmaps.cpp

#: <<"#BUILD_R4LOADERSDHC"
echo Building r4loadersdhc.nds...
cp -f ../patch/r4sdhc/{save_nand,sd_save}.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/r4loadersdhc.nds
make clean >/dev/null
dldipatch ../build/__rpg/r4_sd.dldi ../build/__rpg/r4loadersdhc.nds
#BUILD_R4LOADERSDHC

cp -f ../patch/akloader_main.cpp akloader/arm9/source/main.cpp #lock softreset (B4 command not supported)
#cp -f ../patch/reset/resetpatch9.bin akloader/arm9/data/r4/
cp -f ../patch/akloader_rpgmaps_nds.cpp akloader/arm9/source/rpgmaps.cpp

#: <<"#BUILD_EX4LOADER"
echo Building ex4loader.nds...
cp -f ../patch/ex4/{save_nand,sd_save,dma4}.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/ex4loader.nds
make clean >/dev/null
dldipatch ../patch/ex4tf.dldi ../build/__rpg/ex4loader.nds
#BUILD_EX4LOADER

#: <<"#BUILD_M3LOADER"
echo Building m3loader.nds...
cp -f ../patch/m3/{save_nand,sd_save,dma4}.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/m3loader_old.nds
make clean >/dev/null
dldipatch ../patch/m3ds.dldi ../build/__rpg/m3loader_old.nds
#BUILD_M3LOADER

: <<"#BUILD_G003LOADER"
echo Building g003loader.nds...
cp -f ../patch/g003/{save_nand,sd_save,dma4}.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/g003loader.nds
make clean >/dev/null
dldipatch ../patch/g003.dldi ../build/__rpg/g003loader.nds
#BUILD_G003LOADER

: <<"#BUILD_DSTTLOADER" #bad...
echo Building dsttloader.nds...
cp -f ../patch/dstt/{save_nand,sd_save,dma4}.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/dsttloader.nds
make clean >/dev/null
dldipatch ../patch/ttio.dldi ../build/__rpg/dsttloader.nds
#BUILD_DSTTLOADER

cp -f ../patch/akloader_rpgmaps_nds_dsttsd.cpp akloader/arm9/source/rpgmaps.cpp

: <<"#BUILD_DSTTSDLOADER" #bad...
echo Building dsttsdloader.nds...
cp -f ../patch/dsttsd/{save_nand,sd_save,dma4}.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/dsttsdloader.nds
make clean >/dev/null
dldipatch ../patch/ttio.dldi ../build/__rpg/dsttsdloader.nds
#BUILD_DSTTSDLOADER

#__BUILD_LOADER

cd ..
echo Done.
