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

#define align4(i) (((i)+3)&~3)

unsigned int *skipstring(unsigned int *o){
	char *p=(char*)o;
	return (unsigned int*)( align4((unsigned int)p+strlen(p)+1) );
}

unsigned int *skipnote(unsigned int *o){
	char *p=(char*)o;
	p=p+strlen(p)+1; //skip title
	return (unsigned int*)( align4((unsigned int)p+strlen(p)+1) ); //skip additional note
}

int writecc(u32 *o, FILE *f){ //from updatecheat --;
	int ret=0;

	//read all o
	o=skipstring(o);
	unsigned int ocount=*o&0x0fffffff;
	//unsigned int oenable=*o&0xf0000000; //already checked
	o+=9;
	u32 i=0;
	for(;i<ocount;){
		unsigned int foldercount=1;
		int folderflag=0;
		if(*o&0x10000000){//folder
			folderflag=1;
			//fprintf(f,";@@Folder Type: %s\n",(*o&0x01000000)?"one":"multi"); //folder-choice
			foldercount=*o&0x00ffffff;
			//fprintf(f,";@@Folder Items: %d\n",foldercount);
			o++;

			//char *p=(char*)o;
			//if(*p)fprintf(f,";@@Folder Name: %s\n",p);
			//p=p+strlen(p)+1;
			//if(*p)fprintf(f,";@@Folder Note: %s\n",p);
			//fputs("\n",f);

			o=skipnote(o);
			i++;
		}
		for(;foldercount;foldercount--){
			unsigned int oflag=*o&0xff000000; //fixme
			unsigned int *onext=o+1+(*o&0x00ffffff);
			if(oflag)ret++;
			o++;
			char *p=(char*)o;
			if(oflag)fprintf(f,"%c%s\n",oflag?'@':'#',p);
			//p=p+strlen(p)+1;
			//if(*p)fprintf(f,";@Cheat Note: %s\n",p);
			o=skipnote(o);
			int cheatlen=*o;
			//fprintf(f,";@Data Length: %d\n",cheatlen);
			//fputs(";------------------\n",f);
			o++;

			int j=0;
			if(oflag)for(;j<cheatlen;j++)fprintf(f,"%08X%c",o[j],(j&1)?'\n':' ');
			if(oflag)if(cheatlen&1)fputs("\n",f);

			i++;
			o=onext;
			//fputs("\n",f);
		}
		//if(folderflag)fputs(";@@EndOfFolder\n\n",f);
	}
	return ret;
}

#include "fatx.h"
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
	ldr = fopen("fat0:/YSMenu/ak2loader.nds", "rb");
#endif
	if(ldr == NULL)	return false;
	fread((u8*)hed, 16*4, 1, ldr);
	if(memcmp(hed+3,"####",4)){
		int i=0,j=0;
		u8 *p=(u8*)hed;
		u8 *t=(u8*)"CuNt"; /////
		for(;i<64;i++)
		if(p[i])
			p[i]=p[i]!=t[j]?p[i]^t[j]:p[i],j++,j%=strlen((char*)t); //fixed in V2
	}

	fseek(ldr, hed[8], SEEK_SET);
	ldrBuf=(u8*)hed[9];
	fread(ldrBuf, hed[11], 1, ldr);
	if((ldrBuf[3]&0xf0)!=0xe0){
		int i=0,j;
		u8 *k1=(u8*)"DoNt hAx"; /////
		for(j=0;i<(int)hed[11];i++){
			ldrBuf[i]=ldrBuf[i]^k1[j++],j%=strlen((char*)k1);
		}
	}
	__NDSHeader->arm9executeAddress = hed[9];

	fseek(ldr, hed[12], SEEK_SET);
	ldrBuf=(u8*)hed[13];
	fread(ldrBuf, hed[15], 1, ldr);
	if((ldrBuf[3]&0xf0)!=0xe0){
		int i=0,j;
		u8 *k2=(u8*)"My SHitz"; /////
		for(j=0;i<(int)hed[15];i++){
			ldrBuf[i]=ldrBuf[i]^k2[j++],j%=strlen((char*)k2);
		}
	}
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
    memset((void*)0x23fda00,0,MAX_FILENAME_LENGTH*2);
    getsfnlfn(filename.c_str(),(char*)0x23fda00,NULL);
    getsfnlfn(savename.c_str(),(char*)0x23fdc00,NULL);
    *(u8*)0x023fdbff=(u8)flags;

    if((flags&2)&&cheatOffset&&cheatSize){
	FILE *f=fopen("fat0:/__rpg/cheats/usrcheat.dat","rb");
	fseek(f,cheatOffset,SEEK_SET);
	u32 *p=(u32*)malloc(cheatSize);
	if(p){
		fread(p,1,cheatSize,f);
		FILE *g=fopen("fat0:/YSMenu/akloader.cc","w");
		if(g){
			int ret=writecc(p,g);
			fclose(g);
			if(ret){
				//*(vu8*)0x023fdbff|=2; //enable cheating.
				strcpy((char*)0x023fde00,"fat1:/YSMENU/AKLOADER.CC");
			}
		}
		free(p);
	}
	fclose(f);
    }
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
