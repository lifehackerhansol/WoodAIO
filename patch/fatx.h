#include <nds.h>
#include <ff.h>

static TCHAR CvtBuf[255+1];

static TCHAR* _ELM_mbstoucs2(const char* src,size_t* len)
{
  mbstate_t ps={0};
  wchar_t tempChar;
  int bytes;
  TCHAR* dst=CvtBuf;
  while(src!='\0')
  {
    bytes=mbrtowc(&tempChar,src,MB_CUR_MAX,&ps);
    if(bytes>0)
    {
      *dst=(TCHAR)tempChar;
      src+=bytes;
      dst++;
    }
    else if(bytes==0)
    {
      break;
    }
    else
    {
      dst=CvtBuf;
      break;
    }
  }
  *dst='\0';
  if(len) *len=dst-CvtBuf;
  return CvtBuf;
}

/*
static size_t _ELM_ucs2tombs(char* dst,const TCHAR* src)
{
  mbstate_t ps={0};
  size_t count=0;
  int bytes;
  char buff[MB_CUR_MAX];
  int i;

  while(*src != '\0')
  {
    bytes=wcrtomb(buff,*src,&ps);
    if(bytes<0)
    {
      return -1;
    }
    if(bytes>0)
    {
      for(i=0;i<bytes;i++)
      {
        *dst++=buff[i];
      }
      src++;
      count+=bytes;
    }
    else
    {
      break;
    }
  }
  *dst=L'\0';
  return count;
}
*/

void getsfnlfn(const char *path,char *sfn,u16 *lfn){ //path should be in UTF8
	static char buf[256*3],ret[256*3];
	int i,len;
	FILINFO fs;
	//FILE *f=fopen("fat1:/WOOD.TXT","w");

	if(!sfn&&!lfn)return;
	memset(&buf,0,256*3);
	memset( sfn,0,256);
	memset(&ret,0,256*3);
	strcpy(sfn,"fat1:");
	len=strlen(path);
	for(i=6;i<=len;i++){
		if(path[i]=='/'||i==len){
			memset(&fs,0,sizeof(FILINFO));
			strncpy(buf,path+3,i-3);
//fputs(buf,f);
			//_consolePrintf("***%s\n",buf);
			if(f_stat(_ELM_mbstoucs2(buf,NULL),&fs)){/*_consolePrintf("\nCannot open %s.\nAccept your fate.\n",buf);*/while(1);}
			//_consolePrintf("***%s\n",fs.dirEntry.filename);
#if 0
			if(lfn){
				bool NTF_lowfn=false,NTF_lowext=false;
				char *x;
				strcat(ret,"/");
				strcpy(x=ret+strlen(ret),fs.dirEntry.filename);
/*
		//must consider LFN (from MoonShell2.00beta5 source)
		if(fs.dirEntry.entryData[DIR_ENTRY_reserved]&BIT(3)) NTF_lowfn=true;
		if(fs.dirEntry.entryData[DIR_ENTRY_reserved]&BIT(4)) NTF_lowext=true;

		if((NTF_lowfn==false)&&(NTF_lowext==false)){
			; //use alias as filename
		}else{
			u32 posperiod=(u32)-1;
			{
				u32 idx;
				for(idx=0;idx<MAX_FILENAME_LENGTH;idx++){
					char fc=x[idx];
					if(fc=='.') posperiod=idx;
					if(fc==0) break;
				}
			}
			if(posperiod==(u32)-1){ //with ext
				u32 idx;
				for(idx=0;idx<MAX_FILENAME_LENGTH;idx++){
					char fc=x[idx];
					if(NTF_lowfn==true){
						if(('A'<=fc)&&(fc<='Z')) fc+=0x20;
					}
					x[idx]=fc;
					if(fc==0) break;
				}
			}else{
				u32 idx;
				for(idx=0;idx<MAX_FILENAME_LENGTH;idx++){
					char fc=x[idx];
					if(NTF_lowfn==true){
						if(('A'<=fc)&&(fc<='Z')) fc+=0x20;
					}
					x[idx]=fc;
					if(fc=='.') break;
				}
				for(;idx<MAX_FILENAME_LENGTH;idx++){
					char fc=x[idx];
					if(NTF_lowext==true){
						if(('A'<=fc)&&(fc<='Z')) fc+=0x20;
            				}
					x[idx]=fc;
					if(fc==0) break;
				}
			}
		}
*/
			}
#endif
			if(sfn){
				int j=0,l;
				strcat(sfn,"/");
				for(l=strlen(sfn);fs.fname[j];j++)
					sfn[l+j]=fs.fname[j];
				sfn[l+j]=0;
			}
		}
	}
	//if(lfn)_FAT_directory_mbstoucs2(lfn,ret,256);
//fclose(f);
}
