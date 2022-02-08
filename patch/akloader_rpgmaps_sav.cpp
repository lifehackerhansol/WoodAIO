/*
    rpgmaps.cpp
    Copyright (C) 2007 Acekard, www.acekard.com
    Copyright (C) 2009 somebody
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

#include <nds.h>
#include <string.h>
#include <stdio.h>
#if defined(_STORAGE_rpg)
#include <iorpg.h>
#elif defined(_STORAGE_r4)
#include <ior4.h>
#elif defined(_STORAGE_ak2i)
#include <ioak2i.h>
#elif defined(_STORAGE_r4idsn)
#include <ior4idsn.h>
#endif
#include "msgdisplay.h"
#include "rpgmaps.h"
#include "dbgtool.h"
#include <elm.h>
#include <fcntl.h>
#include <unistd.h>

#if defined(_STORAGE_rpg) || defined(_STORAGE_ak2i) || defined(_STORAGE_r4idsn)
#if defined(_STORAGE_ak2i)
#define MAP_SECTOR (clusterProt?sectorProt:sector)
#else
#define MAP_SECTOR (sector)
#endif
class cRPGMaps
{
  private:
    u32 iClusterSize;
    u32 iMapStart;
    u32 iMapEnd;
    u32 iMapCurrent;
    bool iIsSDHC;
    int iFileDes;
#if defined(_STORAGE_rpg) || defined(_STORAGE_ak2i)
    bool iProtection;
#endif
#if defined(_STORAGE_ak2i)
    u32 iHWVer;
    int iProtDes;
#endif
  private:
    void IterateFileCluster(void);
    void Write(u32 aValue);
    void Check(void);
#if defined(_STORAGE_rpg)
    void BuildFATMap(const char* aPath);
#elif defined(_STORAGE_ak2i) || defined(_STORAGE_r4idsn)
    void BuildFATMap(const char* aPath,bool aType); //false - rom, true - save
#endif
    cRPGMaps();
  public:
#if defined(_STORAGE_rpg)
    cRPGMaps(const char* aPath,bool protection);
#elif defined(_STORAGE_ak2i)
    cRPGMaps(const char* aPath,bool protection,const char* aSave);
#elif defined(_STORAGE_r4idsn)
    cRPGMaps(const char* aPath,const char* aSave);
#endif
    inline u32 ClusterSize(void) {return iClusterSize;};
};

void cRPGMaps::IterateFileCluster(void)
{
  u32 shift=iIsSDHC?0:9;
  u32 cluster=1;
#if defined(_STORAGE_ak2i)
  u32 clusterProt=(iProtDes>=0)?1:0;
#endif
  while(true)
  {
    u32 sector;
#if defined(_STORAGE_ak2i)
    u32 sectorProt;
#endif
    cluster=ELM_GetFAT(iFileDes,cluster,&sector);
    if(!cluster) break;
#if defined(_STORAGE_ak2i)
    if(clusterProt) clusterProt=ELM_GetFAT(iProtDes,clusterProt,&sectorProt);
#endif
    Write(MAP_SECTOR<<shift);
  }
}

void cRPGMaps::Check(void)
{
  if(iMapCurrent>iMapEnd)
  {
    showMsg(MSGID_LOADING,MSG_ERROR_MAP_COLOR);
    while(true) ;
  }
}
#endif

#if defined(_STORAGE_rpg)
cRPGMaps::cRPGMaps(const char* aPath,bool protection): iClusterSize(0),iFileDes(-1),iProtection(protection)
{
  BuildFATMap(aPath);
}

void cRPGMaps::Write(u32 aValue)
{
  Check();
  ioRpgWriteSram(iMapCurrent,&aValue,4);
  iMapCurrent+=4;
}

void cRPGMaps::BuildFATMap(const char* aPath)
{
  iFileDes=open(aPath,O_RDONLY);
  if(iFileDes>=0)
  {
    ioRpgSetMapTableAddress(MTN_NAND_OFFSET1,0);
    iMapStart=iMapCurrent=SRAM_FAT_START;
    iMapEnd=SRAM_FAT_END;
    iIsSDHC=((memcmp(aPath,"fat1:",5)==0)||(memcmp(aPath,"FAT1:",5)==0))&&isSDHC();

    ELM_ClusterSizeFromHandle(iFileDes,&iClusterSize);

    IterateFileCluster();
    close(iFileDes);

    if(iProtection)
    {
      char fixFilename[MAX_FILENAME_LENGTH];
      strcpy(fixFilename,aPath);
      strcat(fixFilename,".fix");
      iFileDes=open(fixFilename,O_RDONLY);
      if(iFileDes>=0)
      {
        iMapCurrent=iMapStart;
        IterateFileCluster();
        close(iFileDes);
      }
    }
  }
}

extern "C" u32 ndLog2Phy(u32 logicAddress,u32* oldPhyAddress);
static ALIGN(4) u8 cfgPage[528];
bool rpgBuildNANDMap(void)
{
  // read cfg page
  // 53 4d 54 44 4d 47 20 00 0e 00 01 06 0d (14) 03 02
  dbg_printf("cfgPage\n");
  ioRpgReadNand(0x00000000,cfgPage,528);
  for(u32 ii=0;ii<16;++ii)
  {
    dbg_printf("%02x",cfgPage[ii]);
  }
  // read zones count
  u32 totalZones=1<<(cfgPage[0x0c]-10);
  //wait_press_b();
  u32 totalLBAs=totalZones*1024; // map all blocks
  for(u32 ii=0;ii<totalLBAs;++ii)
  {
    u32 phyAddress=ndLog2Phy(ii<<17,NULL);
    ioRpgWriteSram(ii*4,&phyAddress,4);
    if(ii<16)
    {
      dbg_printf("%08x",phyAddress);
    }
  }
  return true;
}

void rpgBuildMaps(const char* path,bool protection)
{
  rpgBuildNANDMap();
  cRPGMaps maps(path,protection);
  u32 clusterSize=maps.ClusterSize();
  u32 clusterSizeShift=0;
  while(clusterSize>512)
  {
    clusterSize>>=1;
    clusterSizeShift++;
  }

  ioRpgSetMapTableAddress(MTN_NAND_OFFSET1,0);
  ioRpgSetMapTableAddress(MTN_MAP_A,SRAM_NANDLUT_START);
  ioRpgSetMapTableAddress(MTN_SAVE_TABLE,SRAM_SAVETABLE_START);
  ioRpgSetMapTableAddress(MTN_MAP_B,SRAM_FAT_START);

  if(memcmp(path,"fat0:",5)==0)
  {
    ioRpgSetDeviceStatus(0x01,0x03,clusterSizeShift,clusterSizeShift,false);
    dbg_printf("use nand cluster size %d\n",clusterSizeShift);
  }
  else
  {
    ioRpgSetDeviceStatus(0x03,0x02,clusterSizeShift,clusterSizeShift,isSDHC());
    dbg_printf("use sd cluster size %d, isSDHC %d\n",clusterSizeShift,isSDHC());
  }
}
#elif defined(_STORAGE_r4)
#include <ff.h>
#include <sys/iosupport.h>
extern "C" __handle* __get_handle(int);
extern "C" DWORD get_fat(FATFS *fs, DWORD clst);
extern "C" unsigned int clust2sect(FATFS *fs, unsigned int clst);
extern "C" int dldi(byte *nds,const int ndslen);

int fgetFragments(int fd){
	if(fd<0)return -1;
	FIL *fil=(FIL*)__get_handle(fd)->fileStruct;
	u32 ret=0;
	u32 clust,tmp,i=1;//,size=((fil->fsize+0x7fff)&~0x7fff)>>15;
	//dbg_printf("size: %d\n",size);
#if 0
	for(clust=fil->sclust;i<size;){
		tmp=get_fat(fil->fs,clust);
		if(tmp==-1)return -1;
		if(clust+1!=tmp)ret++;
		clust=tmp;
		i++;
	}
#endif
	for(clust=fil->sclust;;){
		tmp=get_fat(fil->fs,clust);
		if(tmp<2||tmp>=fil->fs->n_fatent)break;
		if(clust+1!=tmp)ret++;
		clust=tmp;
		i++;
	}
	return ret;
}
/*
int getFragments(const char *path){
	int fd=open(save,O_RDONLY);
	if(fd<0)return -1;
	int ret=fgetFragments(fd);
	close(fd);
	return ret;
}
*/

u32 GetR4Address(const char* filename)
{
  int fd=open(filename,O_RDONLY);
  if(fd<0) return 0;
  u32 result=0;
  u64 value;
  if(ELM_DirEntry(fd,&value))
  {
    result=(u32)(value&0xffffffff);
  }
  close(fd);
  return result;
}

#include <save_nand_bin.h>
#include <sd_save_bin.h>
void patchSaveAddress(u32 addr){
	u32 *save_nand=(u32*)save_nand_bin,*sd_save=(u32*)sd_save_bin;
	u32 save_nand_size=((save_nand_bin_size+3)&~3)/4,sd_save_size=((sd_save_bin_size+3)&~3)/4;
	u32 i;
	for(i=0;i<save_nand_size;i++){
		if(save_nand[i]==0xef987654)save_nand[i]=addr;
	}
	for(i=0;i<sd_save_size;i++){
		if(sd_save[i]==0xef987654)sd_save[i]=addr;
	}
}

void r4BuildMaps(const char* path,const char* save)
{
  ioR4ReadCardInfo();
  ioR4SendMap(GetR4Address(path)&0xfffffffe); //Send Rom Map
  ioR4ReadCardInfo();
/*
  ioR4SendMap(GetR4Address(save)|1); //Send Save Map
  ioR4ReadCardInfo();
*/

	int fd=open(save,O_RDONLY);
	if(fd<0||fgetFragments(fd)){
		if(fd>=0)close(fd);
		dbg_printf("sav is fragmented. Please defrag using PC.\nIf this is the first time, as sav created on NDS is likely fragmented, so MOVING to PC then copying from PC back will do.\nHalt.\n");while(1);
	}

	//patch save_nand_bin / sd_save.bin in dirty way
	FIL *fs=(FIL*)__get_handle(fd)->fileStruct;
	unsigned int sect=(unsigned int)(clust2sect(fs->fs,fs->sclust)<<9);
	close(fd);
	patchSaveAddress(sect);
}
#elif defined(_STORAGE_ak2i)
#include "ak2imaps.h"
#elif defined(_STORAGE_r4idsn)
#include "r4idsnmaps.h"
#endif
