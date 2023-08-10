/*
    romloader.cpp
    Copyright (C) 2007 Acekard, www.acekard.com
    Copyright (C) 2007-2009 somebody
    Copyright (C) 2009 yellow wood goblin

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include <string.h>
#include <nds.h>
#include <elm.h>
#include "romloader.h"
#include "dbgtool.h"
//#include "akloader_arm7_bin.h"
//#include "akloader_arm9_bin.h"
#include "savechip.h"
#include "savemngr.h"
#include "../../share/fifotool.h"
#include "../../share/timetool.h"
#include "globalsettings.h"
#if defined(_STORAGE_rpg)
#include <iorpg.h>
#endif

#include "fatx.h"
#include "progresswnd.h"
#include <unistd.h>

static void resetAndLoop()
{
    // Interrupt
    REG_IME = 0;
    REG_IE = 0;
    REG_IF = ~0;

    DC_FlushAll();
    DC_InvalidateAll();

    fifoSendValue32(FIFO_USER_01,MENU_MSG_ARM7_REBOOT);
    while(true)
    {
      while(REG_IPC_FIFO_CR&IPC_FIFO_RECV_EMPTY);
      u32 res=REG_IPC_FIFO_RX;
      if(FIFO_PACK_VALUE32(FIFO_USER_01,MENU_MSG_ARM7_READY_BOOT)==res) break;
    }

    swiSoftReset();
}

#if defined(_STORAGE_rpg)
bool loadRom( const std::string & filename, u32 flags, long cheatOffset,size_t cheatSize )
#elif defined(_STORAGE_r4) || defined(_STORAGE_ak2i) || defined(_STORAGE_r4idsn)
bool loadRom( const std::string & filename, const std::string & savename, u32 flags, long cheatOffset,size_t cheatSize )
#endif
{
	FILE	*ldr = NULL;
    u32 gameCode = 0;
    tNDSHeader* hed = (tNDSHeader*)malloc(sizeof(tNDSHeader));

#if defined(_STORAGE_rpg)
    // copy filename to sram
    ALIGN(4) u8 filenameBuffer[MAX_FILENAME_LENGTH];
    memset( filenameBuffer, 0, MAX_FILENAME_LENGTH );
    memcpy( filenameBuffer, filename.c_str(), filename.length() );

    u32 address=SRAM_LOADING_FILENAME_START;
    ioRpgWriteSram( address, filenameBuffer, MAX_FILENAME_LENGTH );
    address+=MAX_FILENAME_LENGTH;
    ioRpgWriteSram( address, &flags, sizeof(flags) );
    address+=sizeof(u32);
    ioRpgWriteSram( address, &cheatOffset, sizeof(cheatOffset) );
    address+=sizeof(u32);
    ioRpgWriteSram( address, &cheatSize, sizeof(cheatSize) );
#elif defined(_STORAGE_r4) || defined(_STORAGE_ak2i) || defined(_STORAGE_r4idsn)
    /* *(u32*)0x23fd900=flags;
    *(u32*)0x23fd904=cheatOffset;
    *(u32*)0x23fd908=cheatSize;
    memset((void*)0x23fda00,0,MAX_FILENAME_LENGTH*2);
    strcpy((char*)0x23fda00,filename.c_str());
    strcpy((char*)(0x23fda00+MAX_FILENAME_LENGTH),savename.c_str());
    */
#endif
/*
    dbg_printf( "load %s\n", filename.c_str() );

    // copy loader's arm7 code
    memcpy( (void *)0x023FA000, akloader_arm7_bin, akloader_arm7_bin_size );
    __NDSHeader->arm7executeAddress = 0x023FA000;

    // copy loader's arm9 code
    memcpy( (void *)0x023c0000, akloader_arm9_bin, akloader_arm9_bin_size );
    __NDSHeader->arm9executeAddress = 0x023c0000;

    dbg_printf( "load done\n" );
*/

#if defined(_STORAGE_rpg)
	ldr = fopen("fat0:/__rpg/rpgloader.nds", "rb");
#elif defined(_STORAGE_r4)
    FILE* ROMFile = fopen(filename.c_str(), "rb");
    fseek(ROMFile, 0xC, SEEK_SET);
    fread(&gameCode, 1, 4, ROMFile);
    fclose(ROMFile);
    if(gameCode == 0x23232323) ldr = fopen("fat0:/TTMenu/ttdldi.dat", "rb");
    else ldr = fopen("fat0:/TTMenu/ttpatch.dat", "rb");
#endif
	if(ldr == NULL)	return false;
	fread(hed, sizeof(tNDSHeader), 1, ldr);

	fseek(ldr, hed->arm9romOffset, SEEK_SET);
	fread((void*)hed->arm9executeAddress, hed->arm9binarySize, 1, ldr);

	fseek(ldr, hed->arm7romOffset, SEEK_SET);
	fread((void*)hed->arm7executeAddress, hed->arm7binarySize, 1, ldr);
	fclose(ldr);
    memcpy((void*)__NDSHeader, hed, sizeof(tNDSHeader));
    free(hed);

    if(access("fat0:/ttmenu.sys", F_OK) != 0) {
        progressWnd().setTipText("Generating TTMENU.SYS...");
        progressWnd().show();
        progressWnd().setPercent(0);
        FILE* TTSYSCreate = fopen("fat0:/ttmenu.sys", "wb");
        fseek(TTSYSCreate, 0, SEEK_SET);
        fwrite((void*)0x02400000, 0x400000, 1, TTSYSCreate);
        fflush(TTSYSCreate);
        fclose(TTSYSCreate);
        progressWnd().setPercent(100);
        progressWnd().hide();
    }

    char name[0x1005];
    FILE* TTSYSFile = fopen("fat0:/ttmenu.sys", "r+b");
    fseek(TTSYSFile, 0, SEEK_SET);
    fwrite("ttds",1,4,TTSYSFile);

    fseek(TTSYSFile,0x100,SEEK_SET);
    memset(name,0,0x1005);
    getsfnlfn(filename.c_str(),name, NULL);
    fwrite(name+5,1,strlen(name) - 4,TTSYSFile);

    fseek(TTSYSFile,0x1100,SEEK_SET);
    memset(name,0,0x1006);
    getsfnlfn(savename.c_str(),name, NULL);
    fwrite(name+5,1,strlen(name) - 4,TTSYSFile);

    fseek(TTSYSFile,0x2100,SEEK_SET);
    memset(name,0,0x1006);
    strcpy(name,"/"); // Cheat file, not written for now
    fwrite(name,1,2,TTSYSFile);
    fflush(TTSYSFile);
    fclose(TTSYSFile);

    ELM_Unmount();

    // patch a loop in ARM9
    // not sure why it's there. Some sort of obfuscation mechanism?
    if (*((vu32*)(__NDSHeader->arm9executeAddress + 0xEC)) == 0xEAFFFFFE) // b #0; bad
        *((vu32*)(__NDSHeader->arm9executeAddress + 0xEC)) = 0xE3A00000; // mov r0, #0

    // ttpatch checks this for some reason
    *((vu32*)0x02FFFC20) = 0x5555AAAA;

    // set SD/SDHC flag to SDHC, right now our DLDI only does SDHC
    *((vu32*)0x02FFFC24) = ~0;

    // this int seems to be a flag to reinitialize the SD card in ttpatch
    // if this is *not* -1, ttpatch sends an SDIO CMD12 (STOP_TRANSMISSION)
    // other frontends set this to -1 by default, so let's do it too
    *((vu32*)0x02FFFC28) = ~0;

    resetAndLoop();
    return true;
}
