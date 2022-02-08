WAIO - WoodAllInOne (C) Taiju Yamada

[License]
build/*.nds -> GPLv3 or later
build/__rpg/rpglink.nds -> MIT License

[Contents]
build/*.nds	binaries
build/waio.nds
	Wood All In One, which loads /__rpg/rpglink.nds (modified AKRPG loader)
	Don't forget to put /moonshl2/extlink/mshl2wrap.ini
	hbmode is ignored; AKRPG loader is always used for homebrew.
build/woodr4.nds
	WoodR4 patched (use r4loader.nds from official WoodR4)
build/woodr4sdhc.nds
	WoodR4 patched (use modified r4loadersdhc.nds)
build/woodex4.nds
	WoodR4 patched (use modified ex4loader.nds)
build/woodils.nds
	WoodR4 patched (use modified ilsloader.nds)
build/woodm3.nds
	WoodR4 patched (use modified m3loader.nds)
build/woodr4ls.nds
	WoodR4 patched (use r4lsloader.nds from R4_AK_Special)
build/woodrpg_ak2i.nds
	WoodR4 which loads /akloader.nds (please prepare from akextract or AKAIO 1.6RC2)
build/woodrpg_mod.nds
	WoodRPG patched (use rpgloader.nds from official WoodRPG)

build/__rpg/*.nds loaders (loaders has a little different protocol so can be used only from appropriate GUI)
build/__rpg/r4loader.nds
	WoodR4 latest loader
build/__rpg/r4loaderdldi.nds
	WoodR4 loader (DLDI-zed, working on clones)
build/__rpg/ex4loader.nds
	WoodR4 loader (DLDI-zed, for R4iLS/EX4DS)
build/__rpg/ilsloader.nds
	WoodR4 loader (DLDI-zed, for R4iLS)
build/__rpg/m3loader_old.nds
	WoodR4 loader (DLDI-zed, for M3Real/M3iZero)
build/__rpg/r4lsloader.nds
	R4_AK_Special loader
build/__rpg/rpglink.nds
	WAIO MoonShell2 extlink wrapper
build/__rpg/rpgloader.nds
	WoodRPG latest loader

[proprietary loaders]
build/__rpg/m3loader.nds
build/__rpg/ttloader.nds (frontend: woodtt.nds)
	WoodM3/WoodTT loader by toro
build/__rpg/r4liloader.nds
	R4iLS loader (frontend: woodr4li.nds)
build/__rpg/ak2loader.nds
	R4i3D 2012 loader (frontend: woodak2i.nds)

[History]
0.01.100329
WoodRPG can load ak2loader.nds internally(ak2loader extlink concept test)

0.02.100416
Updated code base to WoodR4 1.05. Much stabler.
WoodR4 with .sav/autorunWithLastRom released.

0.03.100515
Updated code base to WoodR4 1.07.

0.04.100617
Updated code base to WoodR4 1.09.
Now building is automated.

0.91.100626
Fixed fatx.h (woodrpg_ak2i 0.4 didn't work)
Added WAIO (WoodAllInOne). Now you can feel WoodRPG GUI on all flashcarts
(as long as extlink is supported :p)

0.92.100701
Now you can use .nds.sav(by binary patching) #Don't use save slot when you use .nds.sav
f_stat() dirtily fixed. Now it should get SFN for non-ascii filenames.

0.93.100709
Fixed: woodr4dldi.nds didn't work at all(back to normal r4tf_v2).
WAIO won't use autorunWithLastRom any longer (because it is just a homebrew launcher).

0.93a.100725
Recompiled with devkitARMr31/libnds 1.4.4.

0.94.100726
Added WoodR4ext. libnds back to 1.4.3recompiled.

1.00.100728
All loaders are externalized (woodr4.nds 1.09 uses 1.11 loader). GUI is compiled with libnds 1.4.4.
WoodR4LS working again.
Patch source code is much cleaner. It seems to be stable.

1.01.100820
Code base updated to 1.12. It seems WAIO gets file list much faster.
# r4loader.nds is still from official WoodR4 release.

1.02.100829
Partial support for clones. Read Limitation twice.

1.02a.100916
rpglink accepts PPSEDS and GBAldr as homebrew.

1.03.100920
Code base updated to 1.13. For Pokemon B/W freaks.

1.04.100923
Added WoodEX4(R4iLS).
Please note you have to use microSD <=4GB.

1.05.101004
Renamed WoodEX4 to WoodiLS.
Renamed WoodR4dldi to WoodR4sdhc.
Now WoodR4sdhc halts when sav is fragmented.
Added WoodEX4(for EX4DS)/WoodM3. Please note softreset is disabled in these versions.
These versions halt when nds/sav is fragmented.
WAIO checking homebrew routine improved.
Fixed header of rpgloader/r4loader/r4lsloader.nds to avoid freeze in R4 OSMenu.

Very sorry for those who are expecting WoodDSTT. I might continue investigation when I have time...
Well now that loaders other than r4loader/r4lsloader.nds show loading progress, if you see "load fail", PLEASE GIVE UP.

1.06.101008
Now rpglink can boot dslinux.
Making argv fixed.
Updated code base to 1.14.

1.06a.101014
Fixed last cluster problem again (rpglink)

1.06b.101021
Merged 1.14.2 r4loader.nds.
rpglink uses devkitARM r32 / libnds 1.4.8.

1.06c.101021
Added Super Scribblenauts support.
Loaders use devkitARM r32 / libnds 1.4.8.
Now loaders check fragments using more fuzzy method...

1.07.101028
Updated code base to 1.15 (using devkitARM r32).
Stripped unneeded code from WAIO.
To enable DLDI again in libunds, I used very special dldi.c. See patch/libunds_dldi.c to check how it is funny...

1.07a.10110x (not public)
As SOME people say r4tf.dldi isn't working, I put the original version...

1.08.101112
Based on WoodR4 1.16.
Removed rpglink.nds for a reason. This will make WAIO not functional, but I don't know.
Now copyrighted by Taiju Yamada, rather than X****.

1.17.101118
Using the same version as Original Wood*.
Based on WoodR4 1.17.
r4idsn_sd.dldi uses DLDI ID "_R4i" instead of "R4i ". (The same as official kernel)

1.20.101222
Based on WoodR4 1.20.
"saveext = .sav" is used in default.
# Special fork of akextract, akextract_wood, was created.

*** Warning ***
WoodR4 original uses 0x023c0000 as ARM9, but it kills one of fopen()/dbg_printf()/DLDI scheme.
So I changed the address to 0x023bc0000.
Please note this release is experimental for a few new games.
Also the cheat size per game is limited to 48KB, rather than 64KB.

1.20a.101224
loaders DLDI region size were decreased to 16KB, rather than 32KB, for less patching. ARM9 address is fine with 0x023c0000 now.
Also GUIs other than WoodRPG_mod/WAIO have 16KB region to decrease size.

1.20b.101230
unofficial loaders support cheats 256KB per game.

1.20c.110104
rpglink is now more stable. ARM9 is now stored in 0x023c0000.

1.20d.110106
Merged Wood* 1.21 loaders.
Rebuilded with libnds 1.4.9 release.

1.20e.110110
woodrpg_ak2i now does the same as akysload. (akaio1.6RC2).

1.22.110113
Updated code base to 1.22.
Added buildasm.sh to batch building .s and getlatestloader.sh to update official build/__rpg/*loader.nds

1.22a.110123
Fixed WoodEX4 (Overwrote with g003)
Removed debug code from WoodM3...

1.23.110125
Updated code base to 1.23.

1.24.110215
Updated code base to 1.24.

1.25.110225
Updated code base to 1.25.
Just sorry but homebrew softreset isn't available in other than woodr4sdhc/woodils.

1.25a.110416
getlatestloader.sh downloaded 1.28 for r4.

1.25b.110507
getlatestloader.sh downloaded 1.29 for r4.
Added r4liloader.nds (from decrypted WoodR4Li by r4li.com)

1.25c.110517
r4liloader.nds 1.29

1.25d.120218
r4liloader.nds 1.44
Added ak2loader.nds
Added several frontends for proprietary loaders.

1.25e.120413
Now rpglink.nds is compiled using devkitARM r38.

1.25f.120717
r4liloader.nds 1.49 (ACE3DS)
Now rpglink.nds is compiled using devkitARM r41.

1.25g.120928
r4liloader.nds 1.51 (ACE3DS)
Unfortunately 1.52 isn't working anymore.
Updated ak2loader.nds and added r2 loader.
r1 is derived from R4i3D 2012 1.49, which uses extinfo.dat.
r2 is derived from R4i3D 2012 1.50, which uses mixinfo.dat.

continue by lifehackerhansol:
r4liloader.nds 1.62 (ACE3DS)
ak2loader replaced with BL2CK loader
