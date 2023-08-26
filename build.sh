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

mkdir -p ../build/__rpg 2>/dev/null
mkdir -p ../build/__rpg/fonts 2>/dev/null
cp -f dldi/r4_sd/r4_sd.dldi ../build/__rpg/r4_sd.dldi
cp -f dldi/r4_sd/r4_sd.dldi ../build/__rpg/r4ds.dldi
cp -f dldi/rpg_nand/rpg_nand.dldi ../build/__rpg/
cp -f dldi/rpg_sd/rpg_sd.dldi ../build/__rpg/
../xenobox binreplace dldi/r4idsn_sd/r4idsn_sd.dldi "R4i #" "_R4i#"
cp -f dldi/r4idsn_sd/r4idsn_sd.dldi ../build/__rpg/
cp fonts/*.pcf ../build/__rpg/fonts
cp -a ui ../build/__rpg/
cp -a language ../build/__rpg/

cp -f akmenu4/akmenu4.nds ../build/woodrpg_mod.nds
make clean >/dev/null
../xenobox dldipatch ../build/__rpg/rpg_nand.dldi ../build/woodrpg_mod.nds
#../xenobox modifybanner ../build/woodrpg_mod.nds "Wood RPG mod;with autorunWithLastRom" #"Real Play Gear" is printed by default
cp -f ../patch/libunds_dldi_stub_16k.s libunds/source/arm9/dldi/dldi_stub.s

#BUILD_WOODRPG_BASE

#: <<"#BUILD_WOODR4"
echo Building WoodR4 and WoodR4iDSN...
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodr4.nds
make clean >/dev/null
../xenobox dldipatch ../build/__rpg/r4_sd.dldi ../build/woodr4.nds
../xenobox modifybanner ../build/woodr4.nds "Wood R4 mod;external akloader"
#BUILD_WOODR4

#: <<"#BUILD_WOODR4IDSN"
echo Building WoodR4iDSN...
make akmenu4/_DSMENU.DAT >/dev/null
cp -f akmenu4/_DSMENU.DAT ../build/woodr4idsn.nds
make clean >/dev/null
../xenobox dldipatch ../build/__rpg/r4idsn_sd.dldi ../build/woodr4idsn.nds
../xenobox modifybanner ../build/woodr4idsn.nds "Wood R4idsn mod;external akloader"
#BUILD_WOODR4IDSN

: <<"#BUILD_WOODR4SDHC"
echo Building WoodR4sdhc...
cp -f ../patch/romloader_r4sdhc.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodr4sdhc.nds
make clean >/dev/null
../xenobox dldipatch ../build/__rpg/r4_sd.dldi ../build/woodr4sdhc.nds
../xenobox modifybanner ../build/woodr4sdhc.nds "Wood R4 SDHC;partial clone support;sav defragment"
mkdir -p ../release/woodr4sdhc/__rpg
cp -a ../build/__rpg/fonts ../release/woodr4sdhc/__rpg/
cp -a ../build/__rpg/language ../release/woodr4sdhc/__rpg/
cp -a ../build/__rpg/ui ../release/woodr4sdhc/__rpg/
cp -f ../build/woodr4sdhc.nds ../release/woodr4sdhc/woodr4sdhc.nds
#BUILD_WOODR4SDHC

: <<"#BUILD_WOODG003"
echo Building WoodG003...
cp -f ../patch/romloader_g003.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodg003.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/g003.dldi ../build/woodg003.nds
../xenobox modifybanner ../build/woodg003.nds "Wood G003;for GMP-Z003;nds/sav defragment"
#BUILD_WOODG003

: <<"#BUILD_WOODDSTT" #bad...
echo Building WoodDSTT...
cp -f ../patch/romloader_dstt.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/wooddstt.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/ttio.dldi ../build/wooddstt.nds
../xenobox modifybanner ../build/wooddstt.nds "Wood DSTT;for DSTT/SCDSONE(i);nds/sav defragment"
#BUILD_WOODDSTT

: <<"#BUILD_WOODTT"
echo Building WoodTT...
cp -f ../patch/romloader_tt.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodtt.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/tt_sd.dldi ../build/woodtt.nds
../xenobox modifybanner ../build/woodtt.nds "Wood TT;for DSTT/SCDSONE(i)"
mkdir -p ../release/woodtt/__rpg
cp -a ../build/__rpg/fonts ../release/woodtt/__rpg/
cp -a ../build/__rpg/language ../release/woodtt/__rpg/
cp -a ../build/__rpg/ui ../release/woodtt/__rpg/
cp -f ../build/woodtt.nds ../release/woodtt/ttmenu.dat
cp -f ../dldi/tt_sd.dldi ../release/woodtt/__rpg/tt_sd.dldi
cp -f ../static/WoodTT/ttloader.nds ../release/woodtt/__rpg/ttloader.nds
7z a -r ../release/woodtt.7z ../release/woodtt/*
#BUILD_WOODTT

#: <<"#BUILD_WOODAK2"
echo Building WoodAK2...
cp -f ../patch/romloader_ak2.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodak2.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/ak2_sd.dldi ../build/woodak2.nds
../xenobox modifybanner ../build/woodak2.nds "Wood AK2;AK2 infolib support"
#BUILD_WOODAK2

#: <<"#BUILD_WOODR4Li"
echo Building WoodR4Li...
cp -f ../patch/romloader_r4li.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodace3dsplus.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/ace3ds_sd.dldi ../build/woodace3dsplus.nds
../xenobox modifybanner ../build/woodace3dsplus.nds "Wood R4li;with autorunWithLastRom"
cp -f ../build/woodace3dsplus.nds ../build/woodr4li.nds
../xenobox binreplace ../build/woodr4li.nds "_ds_menu.dat" "_dsmenu.dat/x00"
../xenobox binreplace ../build/woodr4li.nds "ace3dsplusloader.nds" "r4liloader.nds/x00/x00/x00/x00/x00/x00"
cp -f ../build/woodr4li.nds ../build/woodgateway.nds
#BUILD_WOODR4Li

#: <<"#BUILD_WOODM3"
echo Building WoodM3...
cp -f ../patch/romloader_m3.cpp akmenu4/arm9/source/romloader.cpp
cp -f akmenu4/arm9/source/mainwnd.cpp akmenu4/arm9/source/mainwnd.cpp.bak
cp -f ../patch/mainwnd_m3.cpp akmenu4/arm9/source/mainwnd.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodm3.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/m3ds.dldi ../build/woodm3.nds
../xenobox modifybanner ../build/woodm3.nds "Wood M3;for M3Real/M3iZero"
mv -f akmenu4/arm9/source/mainwnd.cpp.bak akmenu4/arm9/source/mainwnd.cpp
#BUILD_WOODM3

cp -f ../patch/fatx.h akmenu4/arm9/source/fatx.h

: <<"#BUILD_WOODR4LS"
echo Building WoodR4LS...
cp -f ../patch/romloader_r4ls.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodr4ls.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/r4_sd.dldi ../build/woodr4ls.nds
../xenobox modifybanner ../build/woodr4ls.nds "Wood R4LS;R4_AK_Special lives longer"
mkdir -p ../release/woodr4ls/__rpg
cp -a ../build/__rpg/fonts ../release/woodr4ls/__rpg/
cp -a ../build/__rpg/language ../release/woodr4ls/__rpg/
cp -a ../build/__rpg/ui ../release/woodr4ls/__rpg/
cp -f ../build/woodr4ls.nds ../release/woodr4ls/woodr4ls.nds
cp -f ../build/__rpg/r4_sd.dldi ../release/woodr4ls/__rpg/r4_sd.dldi
cp -a ../static/R4LS/* ../release/woodr4ls/
7z a -r ../release/woodr4ls.7z ../release/woodr4ls/*
#BUILD_WOODR4LS


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
make clean >/dev/null
../xenobox dldipatch ../build/__rpg/r4_sd.dldi ../build/__rpg/r4loader.nds
../xenobox dldipatch ../build/__rpg/rpg_nand.dldi ../build/__rpg/rpgloader.nds
../xenobox dldipatch ../build/__rpg/r4idsn_sd.dldi ../build/__rpg/r4idsnloader.nds

#BUILD_NORMAL_LOADER

# ilsloader was built here

cp -f ../patch/akloader_rpgmaps_sav.cpp akloader/arm9/source/rpgmaps.cpp

: <<"#BUILD_R4LOADERSDHC"
echo Building r4loadersdhc.nds...
cp -f ../patch/r4sdhc/*.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/r4loadersdhc.nds
make clean >/dev/null
../xenobox dldipatch ../build/__rpg/r4_sd.dldi ../build/__rpg/r4loadersdhc.nds
cp -f ../build/__rpg/r4loadersdhc.nds ../release/woodr4sdhc/__rpg/r4loadersdhc.nds
7z a -r ../release/woodr4sdhc.7z ../release/woodr4sdhc/*
#BUILD_R4LOADERSDHC

cp -f ../patch/akloader_main.cpp akloader/arm9/source/main.cpp #lock softreset (B4 command not supported)
#cp -f ../patch/reset/resetpatch9.bin akloader/arm9/data/r4/
cp -f ../patch/akloader_rpgmaps_nds.cpp akloader/arm9/source/rpgmaps.cpp

# ex4loader was built here

: <<"#BUILD_M3LOADER"
echo Building m3loader.nds...
cp -f ../patch/m3/*.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/m3loader.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/m3r4_m3ds.dldi ../build/__rpg/m3loader.nds
#BUILD_M3LOADER

: <<"#BUILD_G003LOADER"
echo Building g003loader.nds...
cp -f ../patch/g003/{save_nand,sd_save,dma4}.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/g003loader.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/g003.dldi ../build/__rpg/g003loader.nds
#BUILD_G003LOADER

: <<"#BUILD_DSTTLOADER" #bad...
echo Building dsttloader.nds...
cp -f ../patch/dstt/{save_nand,sd_save,dma4}.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/dsttloader.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/ttio.dldi ../build/__rpg/dsttloader.nds
#BUILD_DSTTLOADER

cp -f ../patch/akloader_rpgmaps_nds_dsttsd.cpp akloader/arm9/source/rpgmaps.cpp

: <<"#BUILD_DSTTSDLOADER" #bad...
echo Building dsttsdloader.nds...
cp -f ../patch/dsttsd/{save_nand,sd_save,dma4}.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/dsttsdloader.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/ttio.dldi ../build/__rpg/dsttsdloader.nds
#BUILD_DSTTSDLOADER

#__BUILD_LOADER


#: <<"#__BUILD_RELEASE"

: <<"#RELEASE_RPG"
mkdir -p ../release/woodrpg_mod/__rpg
cp -a ../build/__rpg/fonts ../release/woodrpg_mod/__rpg/
cp -a ../build/__rpg/language ../release/woodrpg_mod/__rpg/
cp -a ../build/__rpg/ui ../release/woodrpg_mod/__rpg/
cp -f ../build/woodrpg_mod.nds ../release/woodrpg_mod/akmenu4.nds
cp -f ../build/__rpg/rpgloader.nds ../release/woodrpg_mod/__rpg/rpgloader.nds
7z a -r ../release/woodrpg_mod.7z ../release/woodrpg_mod/*
#RELEASE_RPG

#: <<"#RELEASE_R4"
mkdir -p ../release/woodr4/__rpg
cp -a ../build/__rpg/fonts ../release/woodr4/__rpg/
cp -a ../build/__rpg/language ../release/woodr4/__rpg/
cp -a ../build/__rpg/ui ../release/woodr4/__rpg/
r4denc ../build/woodr4.nds ../release/woodr4/_ds_menu.dat
cp -f ../static/WoodR4/__rpg/r4loader.nds ../release/woodr4/__rpg/r4loader.nds
7z a -r ../release/woodr4.7z ../release/woodr4/*
#RELEASE_R4

#: <<"#RELEASE_R4IDSN"
mkdir -p ../release/woodr4idsn/__rpg
cp -a ../build/__rpg/fonts ../release/woodr4idsn/__rpg/
cp -a ../build/__rpg/language ../release/woodr4idsn/__rpg/
cp -a ../build/__rpg/ui ../release/woodr4idsn/__rpg/
cp -f ../build/woodr4idsn.nds ../release/woodr4idsn/_dsmenu.dat
cp -f ../static/WoodR4iDSN/__rpg/r4idsnloader.nds ../release/woodr4idsn/__rpg/r4idsnloader.nds
7z a -r ../release/woodr4idsn.7z ../release/woodr4idsn/*
#RELEASE_R4IDSN

#: <<"#RELEASE_AK2"
mkdir -p ../release/woodak2info/__rpg
cp -a ../build/__rpg/fonts ../release/woodak2info/__rpg/
cp -a ../build/__rpg/language ../release/woodak2info/__rpg/
cp -a ../build/__rpg/ui ../release/woodak2info/__rpg/
cp -f ../build/woodak2.nds ../release/woodak2info/akmenu4.nds
cp -f ../dldi/ak2_sd.dldi ../release/woodak2info/__rpg/ak2sd.dldi
cp -a ../static/WoodAK2-common/* ../release/woodak2info/
cp -a ../static/WoodAK2Info/* ../release/woodak2info/
cp -a ../static/*.ini ../release/woodak2info/__rpg/
cp -f ../static/savelist.bin ../release/woodak2info/__rpg/savelist.bin
7z a -r ../release/woodak2info.7z ../release/woodak2info/*
mkdir -p ../release/woodak2mix/__rpg
cp -a ../build/__rpg/fonts ../release/woodak2mix/__rpg/
cp -a ../build/__rpg/language ../release/woodak2mix/__rpg/
cp -a ../build/__rpg/ui ../release/woodak2mix/__rpg/
cp -f ../build/woodak2.nds ../release/woodak2mix/akmenu4.nds
../xenobox modifybanner ../release/woodak2mix/akmenu4.nds "Wood AK2;AK2 mixinfo support"
cp -f ../dldi/ak2_sd.dldi ../release/woodak2mix/__rpg/ak2sd.dldi
cp -a ../static/WoodAK2-common/* ../release/woodak2mix/
cp -a ../static/WoodAK2Mix/* ../release/woodak2mix/
cp -a ../static/*.ini ../release/woodak2mix/__rpg/
cp -f ../static/savelist.bin ../release/woodak2mix/__rpg/savelist.bin
7z a -r ../release/woodak2mix.7z ../release/woodak2mix/*
#RELEASE_AK2

#: <<"#RELEASE_M3"
echo Archiving WoodM3...
mkdir -p ../release/woodm3/__rpg
cp -a ../build/__rpg/fonts ../release/woodm3/__rpg/
cp -a ../build/__rpg/language ../release/woodm3/__rpg/
cp -a ../build/__rpg/ui ../release/woodm3/__rpg/
cp -f ../build/woodm3.nds ../release/woodm3/akmenu4.nds
cp -f ../dldi/m3ds.dldi ../release/woodm3/__rpg/m3_sd.dldi
cp -a ../static/WoodM3/* ../release/woodm3/
cp -a ../static/*.ini ../release/woodm3/__rpg/
cp -a ../static/savelist.bin ../release/woodm3/__rpg/
7z a -r ../release/woodm3.7z ../release/woodm3/*
#RELEASE_M3

#: <<"#RELEASE_WOODR4LI"
mkdir -p ../release/woodr4li/__rpg
mkdir -p ../release/woodgateway/__rpg
cp -a ../build/__rpg/fonts ../release/woodr4li/__rpg/
cp -a ../build/__rpg/language ../release/woodr4li/__rpg/
cp -a ../build/__rpg/ui ../release/woodr4li/__rpg/
cp -a ../static/*.ini ../release/woodr4li/__rpg/
cp -f ../static/savelist.bin ../release/woodr4li/__rpg/savelist.bin
cp -a ../static/Ace3DSPlus/* ../release/woodr4li/
cp -a ../static/R4Li/* ../release/woodr4li/
cp -f ../dldi/ace3ds_sd.dldi ../release/woodr4li/__rpg/game.dldi
cp -a ../build/__rpg/fonts ../release/woodgateway/__rpg/
cp -a ../build/__rpg/language ../release/woodgateway/__rpg/
cp -a ../build/__rpg/ui ../release/woodgateway/__rpg/
cp -a ../static/*.ini ../release/woodgateway/__rpg/
cp -f ../static/savelist.bin ../release/woodgateway/__rpg/savelist.bin
cp -a ../static/R4Li/* ../release/woodgateway/
cp -f ../dldi/ace3ds_sd.dldi ../release/woodgateway/__rpg/game.dldi
r4denc -k 0x4002 ../build/woodace3dsplus.nds ../release/woodr4li/_ds_menu.dat
../xenobox binreplace ../build/woodr4li.nds "/x2E/x00/x00/xEA" "R4XX"
r4denc -k 0x4002 ../build/woodr4li.nds ../release/woodr4li/_dsmenu.dat
../xenobox binreplace ../build/woodr4li.nds "/x2E/x00/x00/xEA" "R4IT"
r4denc -k 0x4002 ../build/woodr4li.nds ../release/woodgateway/_dsmenu.dat
7z a -r ../release/woodr4li.7z ../release/woodr4li/*
7z a -r ../release/woodgateway.7z ../release/woodgateway/*
#RELEASE_WOODR4LI

#__BUILD_RELEASE

cd ..
echo Done.


: <<"#DEPRECATED"

: <<"#BUILD_WOODILS"
echo Building WoodiLS...
cp -f ../patch/romloader_ils.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodils.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/ex4tf.dldi ../build/woodils.nds
../xenobox modifybanner ../build/woodils.nds "Wood iLS;for R4iLS;only for SD <=4GB"
mkdir -p ../release/woodils/__rpg
cp -a ../build/__rpg/fonts ../release/woodils/__rpg/
cp -a ../build/__rpg/language ../release/woodils/__rpg/
cp -a ../build/__rpg/ui ../release/woodils/__rpg/
cp -f ../build/woodils.nds ../release/woodils/woodils.nds
#BUILD_WOODILS

: <<"#BUILD_WOODEX4"
echo Building WoodEX4...
cp -f ../patch/romloader_ex4.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodex4.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/ex4tf.dldi ../build/woodex4.nds
../xenobox modifybanner ../build/woodex4.nds "Wood EX4;for R4iLS/EX4DS;nds/sav defragment"
mkdir -p ../release/woodex4/__rpg
cp -a ../build/__rpg/fonts ../release/woodex4/__rpg/
cp -a ../build/__rpg/language ../release/woodex4/__rpg/
cp -a ../build/__rpg/ui ../release/woodex4/__rpg/
r4denc ../build/woodex4.nds ../release/woodex4/_ds_menu.dat
#BUILD_WOODEX4

: <<"#BUILD_WOODRPG_AK2i"
echo Building WoodRPG AK2i...
cp -f ../patch/romloader_rpgak2i.cpp akmenu4/arm9/source/romloader.cpp
make akmenu4/_DS_MENU.DAT >/dev/null
cp -f akmenu4/akmenu4_r4.nds ../build/woodrpg_ak2i.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/ak2_sd.dldi ../build/woodrpg_ak2i.nds
../xenobox modifybanner ../build/woodrpg_ak2i.nds "Wood R4;modified for akloader"
mkdir -p ../release/woodrpg_ak2i/__rpg
cp -a ../build/__rpg/fonts ../release/woodrpg_ak2i/__rpg/
cp -a ../build/__rpg/language ../release/woodrpg_ak2i/__rpg/
cp -a ../build/__rpg/ui ../release/woodrpg_ak2i/__rpg/
cp -f ../build/woodrpg_ak2i.nds ../release/woodrpg_ak2i/akmenu4.nds
cp -f ../dldi/ak2_sd.dldi ../release/woodrpg_ak2i/__rpg/ak2_sd.dldi
7z a -r ../release/woodrpg_ak2i.7z ../release/woodrpg_ak2i/*
#BUILD_WOODRPG_AK2i

: <<"#BUILD_EX4LOADER"
echo Building ex4loader.nds...
cp -f ../patch/ex4/*.bin akloader/arm9/data/r4/
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/ex4loader.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/ex4tf.dldi ../build/__rpg/ex4loader.nds
cp -f ../build/__rpg/ex4loader.nds ../release/woodex4/__rpg/ex4loader.nds
7z a -r ../release/woodex4.7z ../release/woodex4/*
#BUILD_EX4LOADER

: <<"#BUILD_ILSLOADER"
echo Building ilsloader.nds...
make akloader/akloader_r4.nds >/dev/null
cp -f akloader/akloader_r4.nds ../build/__rpg/ilsloader.nds
make clean >/dev/null
../xenobox dldipatch ../dldi/ex4tf.dldi ../build/__rpg/ilsloader.nds
cp -f ../build/__rpg/ilsloader.nds ../release/woodils/__rpg/ilsloader.nds
7z a -r ../release/woodils.7z ../release/woodils/*
#BUILD_ILSLOADER

#DEPRECATED