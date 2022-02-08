/*
	dldipatch aka dlditool public domain
	under Creative Commons CC0

	According to ndsdis2 -NH9 0x00 dldi_startup_patch.o (from NDS_loader build result):
	:00000040 E3A00001 mov  r0,#0x1 ;r0=1(0x1)
	:00000044 E12FFF1E bx r14 (Jump to addr_00000000?)
	So the corresponding memory value is "\x01\x00\xa0\xe3\x1e\xff\x2f\xe1" (8 bytes).

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include "dbgtool.h"

//ARM7 not officially supported
#if defined(ARM9) || defined(ARM7)
#include <nds.h>
//#include "_console.h"
#define printf dbg_printf
#else
typedef unsigned int u32;
typedef unsigned char byte;
#endif

///
#define magicString	0x00
#define dldiVersion	0x0c
#define driverSize	0x0d
#define fixSections	0x0e
#define allocatedSpace	0x0f
#define friendlyName 0x10

#define dataStart	0x40
#define dataEnd	0x44
#define glueStart	0x48
#define glueEnd	0x4c
#define gotStart	0x50
#define gotEnd	0x54
#define bssStart	0x58
#define bssEnd	0x5c

#define ioType	0x60
#define dldiFeatures	0x64
#define dldiStartup	0x68
#define isInserted	0x6c
#define readSectors	0x70
#define writeSectors	0x74
#define clearStatus	0x78
#define shutdown	0x7c
#define dldiData	0x80

#define fixAll	0x01
#define fixGlue	0x02
#define fixGot	0x04
#define fixBss	0x08

extern const byte *dldimagic;

extern const byte *_io_dldi;
extern const byte *io_dldi_data;
///

const byte *dldimagic=(byte*)"\xed\xa5\x8d\xbf Chishm";

unsigned int read32(const void *p){
	const unsigned char *x=(const unsigned char*)p;
	return x[0]|(x[1]<<8)|(x[2]<<16)|(x[3]<<24);
}

void write32(void *p, const unsigned int n){
	unsigned char *x=(unsigned char*)p;
	x[0]=n&0xff,x[1]=(n>>8)&0xff,x[2]=(n>>16)&0xff,x[3]=(n>>24)&0xff;
}

//OK now we are prepared. DLDI routine follows.

#if defined(ARM9) || defined(ARM7)
int tunedldi(const char *name, const char *id, int *size, byte **p, int checkstart){
	FILE *f;
	byte *x;
	struct stat st;
	if(!(f=fopen(name,"rb")))return 1;
	fstat(fileno(f),&st);
	if(st.st_size<0x80||!(x=(byte*)malloc(st.st_size))){fclose(f);return 2;}
	fread(x,1,st.st_size,f);
	fclose(f);
	if(memcmp(x+ioType,id,4)){free(x);return 3;}
	if(checkstart&&!memcmp(x+(*(u32*)(x+dldiStartup)-*(u32*)(x+dataStart)),"\x01\x00\xa0\xe3\x1e\xff\x2f\xe1",8)){free(x);return 4;}
	*p=x;*size=*((u32*)(x+bssStart))-*((u32*)(x+dataStart));return 0;
}
#endif

#define torelative(n) (read32(pA+n)-pAdata)

int dldi(byte *nds,const int ndslen
#if !defined(ARM9) && !defined(ARM7)
	,const byte *pD,const int dldilen
#endif
){
#if defined(ARM9) || defined(ARM7)
	byte *pD=NULL;
	int dldilen;
	const byte *DLDIDATA=io_dldi_data;
	//const byte *DLDIDATA=((u32*)(&_io_dldi))-24;
#endif

	byte *pA=NULL,id[5],space;
	u32 reloc,pAdata,pDdata,pDbssEnd,fix;
	int i,ittr;

	for(i=0;i<ndslen-0x80;i+=4){
		if(!memcmp(nds+i,dldimagic,12)&&(read32(nds+i+dldiVersion)&0xe0f0e0ff)==1){pA=nds+i;break;}
	}
	if(!pA){//printf("not found valid dldi section\n");
return 1;}

#if defined(ARM9) || defined(ARM7)
	//Now we have to tune in the dldi...
	pD=(byte*)DLDIDATA;
	memcpy(id,pD+ioType,4);id[4]=0;
/*
	{
		int idx=0;
		for(;idx<32*1024/4;idx++)
			if(pD[idx]!=0)dldilen=(idx+1)*4; //BackupDLDIBody() in MoonShell 2.00beta5
	}
*/
	dldilen=*((u32*)(pD+bssStart))-*((u32*)(pD+dataStart)); //DLDITool 0.32.4

	if(memcmp(*(void**)(pD+dldiStartup),"\x01\x00\xa0\xe3\x1e\xff\x2f\xe1",8)) //z=="mov r0,#1;bx lr"
		goto done;

	printf("Startup is nullified. Cannot be used for patching. Trying to fall back to MoonShell2.\n");
	if(memcmp(pD+(*(u32*)(pD+dldiStartup)-*(u32*)(pD+dataStart)),"\x01\x00\xa0\xe3\x1e\xff\x2f\xe1",8))while(1);
		//{printf("Startup is not nullified by alternative calculation. Something is strange. Halted.\n");die();}
	tunedldi("/MOONSHL2/DLDIBODY.BIN",(char*)id,&dldilen,&pD,1);
	//printf("Tuned. Now we selected dldi file to patch with.\n");
done:
#endif

	if(*((u32*)(pD+bssEnd))-*((u32*)(pD+dataStart)) > 1<<pA[allocatedSpace])
		{//printf("not enough space. available %d bytes, need %d bytes\n",1<<pA[allocatedSpace],*((u32*)(pD+bssEnd))-*((u32*)(pD+dataStart)));
return 2;}
	space=pA[allocatedSpace];

	pAdata=read32(pA+dataStart);if(!pAdata)pAdata=read32(pA+dldiStartup)-dldiData;
	memcpy(id,pA+ioType,4);id[4]=0;
	printf("Old ID=%s, Interface=0x%08x,\nName=%s\n",id,pAdata,pA+friendlyName);
	memcpy(id,pD+ioType,4);id[4]=0;
	printf("New ID=%s, Interface=0x%08x,\nName=%s\n",id,pDdata=read32(pD+dataStart),pD+friendlyName);
	printf("Relocation=0x%08x, Fix=0x%02x\n",reloc=pAdata-pDdata,fix=pD[fixSections]); //pAdata=pDdata+reloc
	printf("dldiFileSize=0x%04x, dldiMemSize=0x%04x\n",dldilen,*((u32*)(pD+bssEnd))-*((u32*)(pD+dataStart)));

	memcpy(pA,pD,dldilen);pA[allocatedSpace]=space;
	for(ittr=dataStart;ittr<ioType;ittr+=4)write32(pA+ittr,read32(pA+ittr)+reloc);
	for(ittr=dldiStartup;ittr<dldiData;ittr+=4)write32(pA+ittr,read32(pA+ittr)+reloc);
	pAdata=read32(pA+dataStart);pDbssEnd=read32(pD+bssEnd);

	if(fix&fixAll)
		for(ittr=torelative(dataStart);ittr<torelative(dataEnd);ittr+=4)
			if(pDdata<=read32(pA+ittr)&&read32(pA+ittr)<pDbssEnd){
				printf("All  0x%04x: 0x%08x -> 0x%08x\n",ittr,read32(pA+ittr),read32(pA+ittr)+reloc);
				write32(pA+ittr,read32(pA+ittr)+reloc);
			}
	if(fix&fixGlue)
		for(ittr=torelative(glueStart);ittr<torelative(glueEnd);ittr+=4)
			if(pDdata<=read32(pA+ittr)&&read32(pA+ittr)<pDbssEnd){
				printf("Glue 0x%04x: 0x%08x -> 0x%08x\n",ittr,read32(pA+ittr),read32(pA+ittr)+reloc);
				write32(pA+ittr,read32(pA+ittr)+reloc);
			}
	if(fix&fixGot)
		for(ittr=torelative(gotStart);ittr<torelative(gotEnd);ittr+=4)
			if(pDdata<=read32(pA+ittr)&&read32(pA+ittr)<pDbssEnd){
				printf("Got  0x%04x: 0x%08x -> 0x%08x\n",ittr,read32(pA+ittr),read32(pA+ittr)+reloc);
				write32(pA+ittr,read32(pA+ittr)+reloc);
			}
	if(fix&fixBss)
		memset(pA+torelative(bssStart),0,pDbssEnd-read32(pD+bssStart));

#if defined(ARM9) || defined(ARM7)
	if(pD&&pD!=DLDIDATA)free(pD);
#endif

	//printf("Patched successfully\n");
	return 0;
}

#if !defined(ARM9) && !defined(ARM7)
int main(int argc, char **argv){ //for PC main()
	int i;
	FILE *f,*fdldi;
	struct stat st,stdldi;
	byte *p,*pdldi;

	if(argc<3){
		printf("dldipatch aka dlditool public domain v2\n");
		printf("dldipatch dldi homebrew...\n");
		return 1;
	}
	if(!(fdldi=fopen(argv[1],"rb"))){printf("cannot open %s\n",argv[1]);return 2;}
	fstat(fileno(fdldi),&stdldi);
	if(!(pdldi=malloc(stdldi.st_size))){fclose(fdldi);printf("cannot allocate %d bytes for dldi\n",(int)stdldi.st_size);return 3;}
	fread(pdldi,1,stdldi.st_size,fdldi);fclose(fdldi);
	if(memcmp(pdldi,dldimagic,11)||pdldi[dldiVersion]!=1){printf("the dldi file is invalid\n");return 4;}

	for(i=2;i<argc;i++){
		printf("Patching %s...\n",argv[i]);
		if(!(f=fopen(argv[i],"rb+"))){printf("cannot open %s\n",argv[i]);continue;}
		fstat(fileno(f),&st);
		if(!(p=malloc(st.st_size))){printf("cannot allocate %d bytes for %s\n",(int)st.st_size,argv[i]);continue;}
		fread(p,1,st.st_size,f);
		rewind(f);
		if(!dldi(p,st.st_size,pdldi,stdldi.st_size))fwrite(p,1,st.st_size,f);
		fclose(f);
	}
	free(pdldi);return 0;
}
#endif
