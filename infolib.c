/*
	TTMenu infolib.dat parser
	R4iTT disassembly result
	Copyright (C) 2022 lifehackerhansol

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
*/

/*
	infolib comes in 3 sections.
	0h - 100h: header. See infolib_header_t struct for the relevant details.

	Then there are two tables present in infolib.
	Table 1: entry title.
		- It consists of the gamecode (from NDSHeader, 4 chars) and the u32 header crc32.
			- Which area of the header the checksum calculates is currently unknown.
		- Each entry is 8 bytes, and is aligned as such.
		- The first entry is always a null entry of 0xFF bytes.
		- TTdT (TT databse Tool), a closed-source GUI to modify infolib, appears to add
		  further null entries at the end of table 1, presumably to align the data.
			- Whether this is necessary is unknown.
	Table 2: data
		- The data tables start from the data offset, described in infolib_header_t. 
		- The first entry, just like the entry title table, is all 0xFF.
		- The size of each entry is infolib_header_t->data_size << 2.
		- The order in which this table is sorted is relative to Table 1.
			- Thus, the first table's first element is the second table's first element, and so on.
		- The behaviour of what happens if the data size is expanded is currently unknown, but 
		  this kind of change is unlikely to happen as data_size has remained 0x18 since 2011.
		- TTdT (TT databse Tool), just like table 1, adds further null entries at the end of table 2,
		  presumably to align the data.

	TODO: figure out what this data actually does
*/

#include <stdint.h>
#include <stdbool.h>

#define u32	uint32_t
#define u8	uint8_t

/*
	infolib_header_t

	Present at 0x0 of file. Size 0x100.

	u32 magic:		header magic, usually 0x66891123
	u32 unk:		value not understood at the time, no known parsers implement it.
	u32 dataOffset:	(start of the data table - header size (0x100)) / 8. i.e. if data_offset is 0x1e18, then 0x1e18 * 8 + 0x100 = table 2 location
					Note: TTMenu seems to incorrectly implement this when malloc'ing to read the entry tables; it reads `dataOffset` << 3 instead,
					but this is wrong as it adds another 0x100 of memory. Well, it wouldn't cause a heap overflow, at least :P
	u32 dataSize:	Each item in a data entry is a u32. This variable counts how many u32s are in the data.
					This variable is backwards-compatible: this means, if in the future, a loader were to implement more data at 0x20, then the 
					existing data from 0x18 and lower must not change. All known loaders implement a check where `dataSize` must be >= the loader's 
					currently implemented values.
*/
typedef struct {
	u32 magic;
	u32 unk;
	u32 dataOffset;
	u32 dataSize;
	u8 pad[0xF0];
} infolib_header_t;

/*
	infolib_entry_title_t

	The first table, which are the game entries, comprise of this struct.

	char gameCode[4]:	the gamecode of the ROM. 0xC of NDSHeader. i.e. ABXK
	u32 headerCRC32:	ROM NDSHeader's CRC32. Which area this CRC32 value checks is unknown.
						Hints from YSMenu seem to suggest that this is the CRC32 of the ARM9 binary.
*/
typedef struct {
	char gameCode[4];
	u32 headerCRC32;
} infolib_entry_title_t;


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
	example: fetching data
	a buffer must have been allocated previously. One can just assume the buffer is 0x60
		in size as that has been the default for a decade now.
	buflen is basically data_size, so also >> 2 of actual val
*/
bool infolib_fetch(char* path, void* buf, u32 buflen, char* aGameCode, int aHeaderCRC32) {
	FILE* f = fopen(path, "rb");
	if(!f) {
		printf("fopen fail\n");
		return false;
	}

	infolib_header_t *infoheader = malloc(sizeof(infolib_header_t));
	fseek(f, 0, SEEK_SET);
	fread(infoheader, 0x100, 1, f);
	if(!(infoheader->magic == 0x66891123 && infoheader->dataSize <= buflen)) {
		free(infoheader);
		printf("infolib corrupt, or buffer too small\n");
		return false;
	}

	fseek(f, 0x100, SEEK_SET);
	u32 data_start = infoheader->dataOffset * 8 + 0x100;
	u32 num_entries = (data_start - 0x100) / 8;
	printf("number of entries: %d\n", num_entries);
	infolib_entry_title_t *entry = malloc(sizeof(infolib_entry_title_t));
	for(u32 i = 0; i < num_entries; i++) {
		memset(entry, 0, sizeof(entry));
		fseek(f, 0x100+(i*8), SEEK_SET);
		fread(entry, sizeof(infolib_entry_title_t), 1, f);
		printf("%.*s\n0x%02x\n", 4, entry->gameCode, entry->headerCRC32);
		if(memcmp(entry->gameCode, aGameCode, 4) == 0 && entry->headerCRC32 == aHeaderCRC32) {
			u32 data_location = i * (infoheader->dataSize<<2) + data_start;
			fseek(f, data_location, SEEK_SET);
			fread(buf, buflen, 1, f);
			fclose(f);
			free(entry);
			free(infoheader);
			return true;
		}
	}
	free(entry);
	free(infoheader);
	printf("entry not found\n");
	return false;
}

#include <unistd.h>
int main(int argc, char** argv) {
	printf("hello world\n");
	u8 buffer[0x60];
	// example game
	bool test = infolib_fetch(argv[1], buffer, 0x18, "YZYE", 0xFC9910E5);
	if (!test) {
		printf("failed to fetch data\n");
		return -1;
	}
	FILE* f = fopen("try.bin", "wb");
	if(!f){
		printf("failed to open try.bin\n");
		return -1;
	}
	fwrite(buffer, 0x60, 1, f);
	fclose(f);
	return 0;
}
