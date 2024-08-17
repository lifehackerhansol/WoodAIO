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

// non-woodrpg headers
#include "fatx.h"
#include "progresswnd.h"
#include "../../../akloader/share/flags.h"
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

// TODO: what are the unknowns?
// YSMenu doesn't seem to manipulate them
typedef struct {
    char TTSYSMagic[4];
    u32 unk1;
    u32 softReset;
    u32 useCheats;
    u32 unk2;
    u32 DMA;
    u8 reserved[232];
} PACKED TTSYSHeader;

#if defined(_STORAGE_rpg)
bool loadRom( const std::string & filename, u32 flags, long cheatOffset,size_t cheatSize )
#elif defined(_STORAGE_r4) || defined(_STORAGE_ak2i) || defined(_STORAGE_r4idsn)
bool loadRom( const std::string & filename, const std::string & savename, u32 flags, long cheatOffset,size_t cheatSize )
#endif
{
	u32	hed[16];
	u8	*ldrBuf;
	FILE	*ldr=NULL;

#if defined(_STORAGE_rpg)
	ldr = fopen("fat0:/__rpg/rpgloader.nds", "rb");
#elif defined(_STORAGE_r4)
	ldr = fopen("fat0:/__rpg/ttloader.nds", "rb");
#endif
	if(ldr == NULL)	return false;
	fread((u8*)hed, 16*4, 1, ldr);

	fseek(ldr, hed[8], SEEK_SET);
	ldrBuf=(u8*)hed[9];
	fread(ldrBuf, hed[11], 1, ldr);
	__NDSHeader->arm9executeAddress = hed[9];

	fseek(ldr, hed[12], SEEK_SET);
	ldrBuf=(u8*)hed[13];
	fread(ldrBuf, hed[15], 1, ldr);
	__NDSHeader->arm7executeAddress = hed[13];
	fclose(ldr);

    // Create TTMENU.SYS if it don't exist
    if(access("fat0:/system.sys", F_OK) != 0) {
        progressWnd().setTipText("Generating SYSTEM.SYS...");
        progressWnd().show();
        progressWnd().setPercent(0);
        FILE *TTSYSCreate = fopen("fat0:/system.sys", "wb");
        fseek(TTSYSCreate, 0, SEEK_SET);
        // memdump. Actually just expanding the file seems to crash, but this works totally fine...
        fwrite((void*)0x02400000, 0x400000, 1, TTSYSCreate);
        fflush(TTSYSCreate);
        fclose(TTSYSCreate);
        progressWnd().setPercent(100);
        progressWnd().hide();
    }

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

    TTSYSHeader* ttsys_header = (TTSYSHeader* ) malloc(sizeof(TTSYSHeader));
    ttsys_header->TTSYSMagic = {'t', 't', 'd', 's'};
    ttsys_header->unk1 = 0;
    ttsys_header->softReset = flags & PATCH_SOFT_RESET ? 1 : 0;
    //ttsys_header->useCheats = flags & PATCH_CHEATS ? 1 : 0;
    ttsys_header->useCheats = 0; // cheats untested for now
    ttsys_header->unk2 = 0;
    ttsys_header->DMA = flags & PATCH_DMA ? 1 : 0;

    FILE* TTSYSFile = fopen("fat0:/system.sys", "r+b");
    fseek(TTSYSFile, 0, SEEK_SET);
    fwrite(ttsys_header, sizeof(TTSYSHeader), 1, TTSYSFile);
    free(ttsys_header);

    char name[0x1005];
    memset(name,0,0x1005);
    getsfnlfn(filename.c_str(),name, NULL);
    fseek(TTSYSFile,0x100,SEEK_SET);
    fwrite(name+5,1,strlen(name) - 4,TTSYSFile);

    memset(name,0,0x1006);
    getsfnlfn(savename.c_str(),name, NULL);
    fseek(TTSYSFile,0x1100,SEEK_SET);
    fwrite(name+5,1,strlen(name) - 4,TTSYSFile);

    memset(name,0,0x1006);
    strcpy(name,"/"); // Cheat file, not written for now
    fseek(TTSYSFile,0x2100,SEEK_SET);
    fwrite(name,1,2,TTSYSFile);
    fflush(TTSYSFile);
    fclose(TTSYSFile);

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
    ELM_Unmount();

    // place ARM9 in passme loop
    *(u32*)0x027FFE08 = 0xE59FF014; // ldr pc, [pc, #0x14]
    __NDSHeader->arm9executeAddress = 0x027FFE08;
    resetAndLoop();
    return true;
}
