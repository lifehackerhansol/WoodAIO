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

extern const byte *io_dldi_data;
void SCDS_SetSDHCModeForDSTT(){
	u8 command[8];
	u32 addr=0x7f9e0,ret;
	if(*(u32*)(io_dldi_data+0x60)!=0x53444353)return;

	command[7] = 0xb9;
	command[6] = (addr >> 24) & 0xff;
	command[5] = (addr >> 16) & 0xff;
	command[4] = (addr >> 8)  & 0xff;
	command[3] =  addr        & 0xff;
	command[2] = 0;
	command[1] = 0;
	command[0] = 0;
	cardPolledTransfer(0xa7180000, &ret, 1, command);
	if(ret!=0x32564353)return; //SCV2

	command[7] = 0x70;
	cardPolledTransfer(0xa7180000, &ret, 1, command);
	*(u32*)0x023ffc24=ret?1:0; //hack done.
}

#if defined(_STORAGE_rpg)
bool loadRom( const std::string & filename, u32 flags, long cheatOffset,size_t cheatSize )
#elif defined(_STORAGE_r4) || defined(_STORAGE_ak2i) || defined(_STORAGE_r4idsn)
bool loadRom( const std::string & filename, const std::string & savename, u32 flags, long cheatOffset,size_t cheatSize )
#endif
{
	u32	hed[16];
	u8	*ldrBuf;
	FILE	*ldr=NULL;

	SCDS_SetSDHCModeForDSTT();

#if defined(_STORAGE_rpg)
	ldr = fopen("fat0:/__rpg/rpgloader.nds", "rb");
#elif defined(_STORAGE_r4)
	ldr = fopen(*(u32*)0x023ffc24?"fat0:/__rpg/dsttloader.nds":"fat0:/__rpg/dsttsdloader.nds", "rb");
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
    *(u32*)0x23fd900=flags;
    *(u32*)0x23fd904=cheatOffset;
    *(u32*)0x23fd908=cheatSize;
    memset((void*)0x23fda00,0,MAX_FILENAME_LENGTH*2);
    strcpy((char*)0x23fda00,filename.c_str());
    strcpy((char*)(0x23fda00+MAX_FILENAME_LENGTH),savename.c_str());
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

    resetAndLoop();
    return true;
}
