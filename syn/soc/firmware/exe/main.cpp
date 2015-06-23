/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>

#include <io.h>
#include <sys/alt_irq.h>
#include <system.h>

typedef unsigned char  uint8;
typedef unsigned short uint16;
typedef unsigned int   uint32;


void osd_enable(bool enable) {
	IOWR(VGA_BASE, 0, 0x8000 | ((enable)? 0x4000 : 0x0000));
}

void osd_print(int position, bool invert, const char *format, ...) {
	va_list ap;

	va_start(ap, format);

	char buf[64];
	memset((void *)buf, 0, (unsigned long int)sizeof(buf));

	int written = vsnprintf(buf, sizeof(buf), format, ap);
	va_end(ap);

	for(int i=0; i<written; i++) IOWR(VGA_BASE, position+i, buf[i] | ((invert)? 0x100 : 0x000));
}

int read_byte_if_possible() {
	uint32 rd = IORD(JTAG_UART_BASE, 0);
	if((rd >> 15) & 1) return rd & 0xFF;
	return -1;
}

inline uint8 read_byte() {
	while(true) {
		unsigned int rd = IORD(JTAG_UART_BASE, 0);
		if((rd >> 15) & 1) return rd & 0xFF;
	}
}

uint32 read_int() {
	uint32 rd = 0;
	rd |= read_byte() << 0;
	rd |= read_byte() << 8;
	rd |= read_byte() << 16;
	rd |= read_byte() << 24;
	return rd;
}

void crc32(uint8 *ptr, uint32 *crc_output) {
    static uint8 crc[32];

    //do nothing
    if(ptr != NULL && crc_output != NULL) return;

    //initialize
    if(ptr == NULL && crc_output == NULL) {
    	for(int i=0; i<32; i++) crc[i] = 1;
    	return;
    }

    //output
    if(ptr == NULL && crc_output != NULL) {
    	*crc_output = 0;
		for(int i=0; i<32; i++) {
			(*crc_output) |= crc[i] << (31-i);
		}
		(*crc_output) = ~(*crc_output);
		return;
    }

    uint8 in[8];
    for(int j=0; j<8; j++) in[j] = ((*ptr) >> j) & 1;

    uint8 new_crc[32];

	new_crc[31] = in[2] ^ crc[23] ^ crc[29];
	new_crc[30] = in[0] ^ in[3] ^ crc[22] ^ crc[28] ^ crc[31];
	new_crc[29] = in[0] ^ in[1] ^ in[4] ^ crc[21] ^ crc[27] ^ crc[30] ^ crc[31];
	new_crc[28] = in[1] ^ in[2] ^ in[5] ^ crc[20] ^ crc[26] ^ crc[29] ^ crc[30];
	new_crc[27] = in[0] ^ in[2] ^ in[3] ^ in[6] ^ crc[19] ^ crc[25] ^ crc[28] ^ crc[29] ^ crc[31];
	new_crc[26] = in[1] ^ in[3] ^ in[4] ^ in[7] ^ crc[18] ^ crc[24] ^ crc[27] ^ crc[28] ^ crc[30];
	new_crc[25] = in[4] ^ in[5] ^ crc[17] ^ crc[26] ^ crc[27];
	new_crc[24] = in[0] ^ in[5] ^ in[6] ^ crc[16] ^ crc[25] ^ crc[26] ^ crc[31];
	new_crc[23] = in[1] ^ in[6] ^ in[7] ^ crc[15] ^ crc[24] ^ crc[25] ^ crc[30];
	new_crc[22] = in[7] ^ crc[14] ^ crc[24];
	new_crc[21] = in[2] ^ crc[13] ^ crc[29];
	new_crc[20] = in[3] ^ crc[12] ^ crc[28];
	new_crc[19] = in[0] ^ in[4] ^ crc[11] ^ crc[27] ^ crc[31];
	new_crc[18] = in[0] ^ in[1] ^ in[5] ^ crc[10] ^ crc[26] ^ crc[30] ^ crc[31];
	new_crc[17] = in[1] ^ in[2] ^ in[6] ^ crc[9] ^ crc[25] ^ crc[29] ^ crc[30];
	new_crc[16] = in[2] ^ in[3] ^ in[7] ^ crc[8] ^ crc[24] ^ crc[28] ^ crc[29];
	new_crc[15] = in[0] ^ in[2] ^ in[3] ^ in[4] ^ crc[7] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
	new_crc[14] = in[0] ^ in[1] ^ in[3] ^ in[4] ^ in[5] ^ crc[6] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30] ^ crc[31];
	new_crc[13] = in[0] ^ in[1] ^ in[2] ^ in[4] ^ in[5] ^ in[6] ^ crc[5] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30] ^ crc[31];
	new_crc[12] = in[1] ^ in[2] ^ in[3] ^ in[5] ^ in[6] ^ in[7] ^ crc[4] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[30];
	new_crc[11] = in[3] ^ in[4] ^ in[6] ^ in[7] ^ crc[3] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28];
	new_crc[10] = in[2] ^ in[4] ^ in[5] ^ in[7] ^ crc[2] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29];
	new_crc[9] = in[2] ^ in[3] ^ in[5] ^ in[6] ^ crc[1] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29];
	new_crc[8] = in[3] ^ in[4] ^ in[6] ^ in[7] ^ crc[0] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28];
	new_crc[7] = in[0] ^ in[2] ^ in[4] ^ in[5] ^ in[7] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[31];
	new_crc[6] = in[0] ^ in[1] ^ in[2] ^ in[3] ^ in[5] ^ in[6] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
	new_crc[5] = in[0] ^ in[1] ^ in[2] ^ in[3] ^ in[4] ^ in[6] ^ in[7] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
	new_crc[4] = in[1] ^ in[3] ^ in[4] ^ in[5] ^ in[7] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30];
	new_crc[3] = in[0] ^ in[4] ^ in[5] ^ in[6] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[31];
	new_crc[2] = in[0] ^ in[1] ^ in[5] ^ in[6] ^ in[7] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[30] ^ crc[31];
	new_crc[1] = in[0] ^ in[1] ^ in[6] ^ in[7] ^ crc[24] ^ crc[25] ^ crc[30] ^ crc[31];
	new_crc[0] = in[1] ^ in[7] ^ crc[24] ^ crc[30];

    memcpy(crc, new_crc, sizeof(crc));
}

#pragma pack(push)
#pragma pack(1)

struct entry_t {

	uint8  type;
	uint8  name[15];

	union args_t {
		struct bios_t {
			uint32 sector;
			uint32 size_in_bytes;
			uint32 destination;
			uint32 crc32;
		} bios;
		struct hdd_t {
			uint32 sector;
			uint32 cyliders;
			uint32 heads;
			uint32 spt;
		} hdd;
		struct floppy_t {
			uint32 sector;
		} floppy;
		struct end_of_list_t {
			uint32 crc32;
		} end_of_list;
	} args;
};

#pragma pack(pop)

#define ENTRIES_COUNT 128

struct entry_t entries[ENTRIES_COUNT];

#define TYPE_BIOS 		1
#define TYPE_VGABIOS 	2
#define TYPE_HDD        3
#define TYPE_FD_1_44M	16
#define TYPE_CRC32		127

#define ENTRY_ABORT     -500

int show_menu(uint8 mask, uint8 value, bool abortable) {

	int index_start = -1;
	for(int i=0; i<ENTRIES_COUNT; i++) {
		if((entries[i].type & mask) == value) {
			index_start = i;
			break;
		}
	}
	if(index_start == -1) {
		osd_print(9*16+0, true, "Index start err ");
		return -1;
	}

	int index_end = -1;
	for(int i=ENTRIES_COUNT-1; i>=0; i--) {
		if((entries[i].type & mask) == value) {
			index_end = i;
			break;
		}
	}
	if(index_start == -1) {
		osd_print(9*16+0, true, "Index end error ");
		return -2;
	}
	int index_size = index_end - index_start;

	int index = 0;
	bool zero_delay_last = true;

	while(true) {
		//print contents
		for(int i=-5; i<7; i++) {
			if((index + i < 0) || (index + i > index_size)) {
				osd_print((9+i)*16, false, "                ");
			}
			else {
				int current_index = index_start + index + i;
				bool invert = i == 0;
				osd_print((9+i)*16, invert, "                ");
				osd_print((9+i)*16, invert, " %s", entries[current_index].name);
			}
		}

		char key = 0;
		bool zero_delay = true;
		while(key == 0) {
			uint32 keys = IORD(PIO_INPUT_BASE, 0);

			if((keys & 0x1) == 0) 		key = 'v';
			else if((keys & 0x2) == 0)	key = '^';
			else if((keys & 0x4) == 0)  key = 'Y';
			else if((keys & 0x8) == 0)  key = 'N';
			else						key = 0;

			if(key == 0) zero_delay = false;
		}

		if(key == 'Y') 				return index_start + index;
		if(key == 'N' && abortable) return ENTRY_ABORT;

		if(key == '^' && index > 0) index--;
		if(key == 'v' && index < index_size) index++;

		if(zero_delay_last && zero_delay) 	usleep(100000);
		else								usleep(300000);

		zero_delay_last = zero_delay;
	}
}

int select_and_load_bios(uint8 type, uint32 position,
		const char *select_txt, const char *load_txt, const char *verify_txt, const char *verify_failed_txt, const char *verify_ok_txt)
{
	osd_print(3*16+0, false, select_txt);

	int menu_result = show_menu(0xFF, type, false);
	if(menu_result < 0) return menu_result;

	for(int i=48; i<16*16; i++) IOWR(VGA_BASE, i, 0);

	//load bios
	osd_print(16*position, false, load_txt);

	uint8 *dst_ptr = (uint8 *)entries[menu_result].args.bios.destination;
	uint32 size_in_bytes = entries[menu_result].args.bios.size_in_bytes;
	uint32 sector = entries[menu_result].args.bios.sector;

	uint8 sector_buf[4096];
	while(size_in_bytes > 0) {
		IOWR(DRIVER_SD_BASE, 0, (int)sector_buf);		//Avalon address base
		IOWR(DRIVER_SD_BASE, 1, sector);				//SD sector
		IOWR(DRIVER_SD_BASE, 2, 8);					//sector count
		IOWR(DRIVER_SD_BASE, 3, 2);					//control READ

		//wait for ready
		int sd_status = -1;
		while(sd_status != 2) {
			usleep(100000);
			sd_status = IORD(DRIVER_SD_BASE, 0);
		}

		uint32 current_size = (size_in_bytes > 4096)? 4096 : size_in_bytes;
		memcpy(dst_ptr, sector_buf, current_size);

		dst_ptr += current_size;
		size_in_bytes -= current_size;
		sector += 8;
	}

/*  //currently disable crc32 verification
	osd_print(16*position, false, verify_txt);

	dst_ptr = (uint8 *)entries[menu_result].args.bios.destination;
	size_in_bytes = entries[menu_result].args.bios.size_in_bytes;

	crc32(NULL, NULL);
	for(uint32 i=0; i<size_in_bytes; i++) {
		crc32(dst_ptr+i, NULL);
	}

	uint32 crc_calculated = 0;
	crc32(NULL, &crc_calculated);

	if(crc_calculated != entries[menu_result].args.bios.crc32) {
		osd_print(16*position, false, verify_failed_txt);
		return -1;
	}
*/
	osd_print(16*position, false, verify_ok_txt);
	return 0;
}


int floppy_index = -1;
int hdd_index    = -1;

bool floppy_is_160k = false;
bool floppy_is_180k = false;
bool floppy_is_320k = false;
bool floppy_is_360k = false;
bool floppy_is_720k = false;
bool floppy_is_1_2m = false;
bool floppy_is_1_44m= true;
bool floppy_is_2_88m= false;

bool floppy_writeprotect = true;

void runtime_menu_no_floppy() {
	osd_print(16*1, false, "No floppy");

	osd_print(16*9, false, "Insert floppy");
	for(int i=0; i<16; i++) IOWR(VGA_BASE, 16*9+i, 0x100 | (IORD(VGA_BASE, 16*9+i) & 0xFF));

	bool zero_delay_last = true;
	while(true) {
		char key = 0;
		bool zero_delay = true;
		while(key == 0) {
			uint32 keys = IORD(PIO_INPUT_BASE, 0);

			if((keys & 0x1) == 0) 		key = 'v';
			else if((keys & 0x2) == 0)	key = '^';
			else if((keys & 0x4) == 0)  key = 'Y';
			else if((keys & 0x8) == 0)  key = 'N';
			else						key = 0;

			if(key == 0) zero_delay = false;
		}

		if(key == 'Y') {
			//wait for key release
			while((IORD(PIO_INPUT_BASE, 0) & 0xF) != 0xF) { ; }

			int menu_result = show_menu(0xF0, TYPE_FD_1_44M, true);
			if(menu_result == ENTRY_ABORT) {
				return;
			}
			else if(menu_result < 0) {
				usleep(2000000);
				return;
			}

			floppy_index = menu_result;

			floppy_writeprotect = true;

			int floppy_sd_base = entries[floppy_index].args.floppy.sector;

			int floppy_media =
				(floppy_index < 0)? 0x20 :
				(floppy_is_160k)?   0x00 :
				(floppy_is_180k)?   0x00 :
				(floppy_is_320k)?   0x00 :
				(floppy_is_360k)?   0x00 :
				(floppy_is_720k)?   0xC0 :
				(floppy_is_1_2m)?   0x00 :
				(floppy_is_1_44m)?  0x80 :
				(floppy_is_2_88m)?  0x40 :
								    0x20;

			IOWR(FLOPPY_BASE, 0x0, floppy_index >= 0? 	1 : 0);
			IOWR(FLOPPY_BASE, 0x1, floppy_writeprotect? 1 : 0);
			IOWR(FLOPPY_BASE, 0x6, floppy_sd_base);
			IOWR(FLOPPY_BASE, 0xC, floppy_media);

			return;
		}

		if(key == 'N') return;

		if(zero_delay_last && zero_delay) 	usleep(100000);
		else								usleep(300000);

		zero_delay_last = zero_delay;
	}
}

void runtime_menu_floppy() {
	osd_print(16*1, false, "Floppy inserted");

	int index = 9;

	bool zero_delay_last = true;
	while(true) {
		//draw contents
		for(int i=16*2; i<16*16; i++) IOWR(VGA_BASE, i, 0);

		osd_print(16*index, false, "Eject floppy");
		osd_print(16*(index+1), false, floppy_writeprotect? "Clear writeprot" : "Set writeprotect");
		for(int i=0; i<16; i++) IOWR(VGA_BASE, 16*9+i, 0x100 | (IORD(VGA_BASE, 16*9+i) & 0xFF));

		char key = 0;
		bool zero_delay = true;
		while(key == 0) {
			uint32 keys = IORD(PIO_INPUT_BASE, 0);

			if((keys & 0x1) == 0) 		key = 'v';
			else if((keys & 0x2) == 0)	key = '^';
			else if((keys & 0x4) == 0)  key = 'Y';
			else if((keys & 0x8) == 0)  key = 'N';
			else						key = 0;

			if(key == 0) zero_delay = false;
		}

		if(key == 'Y') {
			if(index == 9) { //eject
				floppy_index = -1;

				floppy_writeprotect = true;

				int floppy_media =
					(floppy_index < 0)? 0x20 :
					(floppy_is_160k)?   0x00 :
					(floppy_is_180k)?   0x00 :
					(floppy_is_320k)?   0x00 :
					(floppy_is_360k)?   0x00 :
					(floppy_is_720k)?   0xC0 :
					(floppy_is_1_2m)?   0x00 :
					(floppy_is_1_44m)?  0x80 :
					(floppy_is_2_88m)?  0x40 :
										0x20;

				IOWR(FLOPPY_BASE, 0x0, floppy_index >= 0? 	1 : 0);
				IOWR(FLOPPY_BASE, 0x1, floppy_writeprotect? 1 : 0);
				IOWR(FLOPPY_BASE, 0xC, floppy_media);
			}
			if(index == 8) { //writeprotect
				floppy_writeprotect = !floppy_writeprotect;

				IOWR(FLOPPY_BASE, 0x1, floppy_writeprotect? 1 : 0);
			}

			return;
		}

		if(key == 'N') return;

		if(key == '^' && index == 8) index++;
		if(key == 'v' && index == 9) index--;


		if(zero_delay_last && zero_delay) 	usleep(100000);
		else								usleep(300000);

		zero_delay_last = zero_delay;
	}
}

void runtime_menu() {
	//clear osd
	for(int i=16; i<16*16; i++) IOWR(VGA_BASE, i, 0);

	osd_enable(true);

	//wait for key release
	while((IORD(PIO_INPUT_BASE, 0) & 0xF) != 0xF) { ; }

	if(floppy_index < 0) 	runtime_menu_no_floppy();
	else 					runtime_menu_floppy();

	osd_enable(false);

	//wait for key release
	while((IORD(PIO_INPUT_BASE, 0) & 0xF) != 0xF) { ; }
}

int main() {

	//pc_bus
	IOWR(PC_BUS_BASE, 0, 0x00FFF0EA);
	IOWR(PC_BUS_BASE, 1, 0x000000F0);

	//resets output
    IOWR(PIO_OUTPUT_BASE, 0, 0x01);

	//vga
	osd_enable(false);
	usleep(1000000);

	for(int i=0; i<16*16; i++) IOWR(VGA_BASE, i, 0);

	osd_enable(true);

	osd_print(0*16+0, false, "ao486 SoC ver1.0");

	osd_print(1*16+0, false, "SD init...      ");
	osd_print(2*16+0, false, "SD header chk...");

	//clear all sdram
    //for(int i=0; i<134217728/4; i++) IOWR(SDRAM_BASE, i, 0);

	//-------------------------------------------------------------------------- check sd card presence
	usleep(1000000);
	int sd_status = IORD(DRIVER_SD_BASE, 0);
	while(sd_status != 2) {
		osd_print(1*16+0, true, "SD reinit: %d    ", sd_status);

		while(sd_status == 0) {
			usleep(1000000);
			sd_status = IORD(DRIVER_SD_BASE, 0);
		}
		if(sd_status == 1) {
			IOWR(DRIVER_SD_BASE, 3, 1); //control reinit;
			IOWR(DRIVER_SD_BASE, 3, 0); //control idle;

			usleep(1000000);
			sd_status = IORD(DRIVER_SD_BASE, 0);
		}
	}
	osd_print(1*16+0, false, "SD OK           ");

	//-------------------------------------------------------------------------- SD read header

	IOWR(DRIVER_SD_BASE, 0, (int)entries); 		//Avalon address base
	IOWR(DRIVER_SD_BASE, 1, 0);					//SD sector
	IOWR(DRIVER_SD_BASE, 2, sizeof(entries)/512);	//sector count
	IOWR(DRIVER_SD_BASE, 3, 2);					//control READ

	//wait for ready
	sd_status = -1;
	while(sd_status != 2) {
		usleep(100000);
		sd_status = IORD(DRIVER_SD_BASE, 0);
	}

	//check crc32
	bool crc_ok = false;
	for(int i=0; i<ENTRIES_COUNT; i++) {
		if(entries[i].type == TYPE_CRC32) {
			uint8 *ptr_start = (uint8 *)entries;
			uint32 size = i*32;

			crc32(NULL, NULL);
			for(uint32 j=0; j<size; j++) crc32(ptr_start + j, NULL);

			uint32 crc_calculated = 0;
			crc32(NULL, &crc_calculated);

			crc_ok = crc_calculated == entries[i].args.end_of_list.crc32;
			break;
		}
	}

	if(crc_ok == false) {
		osd_print(2*16+0, true, "SD header invald");
		return 0;
	}

	osd_print(2*16+0, false, "SD header OK    ");

	//-------------------------------------------------------------------------- load bios

	for(int i=16; i<16*16; i++) IOWR(VGA_BASE, i, 0);

	int bios_result = select_and_load_bios(TYPE_BIOS, 1, "--Select BIOS:--", "Loading BIOS... ", "Verifying BIOS..", "BIOS vrfy failed", "BIOS verify OK  ");
	if(bios_result < 0) return 0;

	//-------------------------------------------------------------------------- load vgabios

	for(int i=32; i<16*16; i++) IOWR(VGA_BASE, i, 0);

	bios_result = select_and_load_bios(TYPE_VGABIOS, 2, "-Select VGABIOS:", "Loading VBIOS...", "Verfying VBIOS..", "VBIOS vrfy fail ", "VBIOS verify OK ");
	if(bios_result < 0) return 0;

	//-------------------------------------------------------------------------- select hdd

	for(int i=16; i<16*16; i++) IOWR(VGA_BASE, i, 0);

	int menu_result = show_menu(0xFF, TYPE_HDD, false);
	if(menu_result < 0) return 0;

	hdd_index = menu_result;

	//--------------------------------------------------------------------------

	osd_enable(false);

	//-------------------------------------------------------------------------- sound
	/*
	0-255.[15:0]: cycles in period
	256.[12:0]:  cycles in 80us
	257.[9:0]:   cycles in 1 sample: 96000 Hz
	*/

	double cycle_in_ns = (1000000000.0 / ALT_CPU_CPU_FREQ); //33.333333;
    for(int i=0; i<256; i++) {
        double f = 1000000.0 / (256.0-i);

        double cycles_in_period = 1000000000.0 / (f * cycle_in_ns);
        IOWR(SOUND_BASE, i, (int)cycles_in_period);
    }

	IOWR(SOUND_BASE, 256, (int)(80000.0 / (1000000000.0 / ALT_CPU_CPU_FREQ)));
	IOWR(SOUND_BASE, 257, (int)((1000000000.0/96000.0) / (1000000000.0 / ALT_CPU_CPU_FREQ)));

	//-------------------------------------------------------------------------- pit
	/*
	0.[7:0]: cycles in sysclock 1193181 Hz
	*/

	IOWR(PIT_BASE, 0, (int)((1000000000.0/1193181.0) / (1000000000.0 / ALT_CPU_CPU_FREQ)));

	//-------------------------------------------------------------------------- floppy

	int floppy_sd_base = 0;

	/*
	 0x00.[0]:      media present
	 0x01.[0]:      media writeprotect
	 0x02.[7:0]:    media cylinders
	 0x03.[7:0]:    media sectors per track
	 0x04.[31:0]:   media total sector count
	 0x05.[1:0]:    media heads
	 0x06.[31:0]:   media sd base
	 0x07.[15:0]:   media wait cycles: 200000 us / spt
     0x08.[15:0]:   media wait rate 0: 1000 us
     0x09.[15:0]:   media wait rate 1: 1666 us
     0x0A.[15:0]:   media wait rate 2: 2000 us
     0x0B.[15:0]:   media wait rate 3: 500 us
	 0x0C.[7:0]:    media type: 8'h20 none; 8'h00 old; 8'hC0 720k; 8'h80 1_44M; 8'h40 2_88M
	*/

	int floppy_cylinders = (floppy_is_2_88m || floppy_is_1_44m || floppy_is_1_2m || floppy_is_720k)? 80 : 40;
	int floppy_spt       =
			(floppy_is_160k)?  8 :
			(floppy_is_180k)?  9 :
			(floppy_is_320k)?  8 :
			(floppy_is_360k)?  9 :
			(floppy_is_720k)?  9 :
			(floppy_is_1_2m)?  15 :
			(floppy_is_1_44m)? 18 :
			(floppy_is_2_88m)? 36 :
			    			   0;
	int floppy_total_sectors =
			(floppy_is_160k)?  320 :
			(floppy_is_180k)?  360 :
			(floppy_is_320k)?  640 :
			(floppy_is_360k)?  720 :
			(floppy_is_720k)?  1440 :
			(floppy_is_1_2m)?  2400 :
			(floppy_is_1_44m)? 2880 :
			(floppy_is_2_88m)? 5760 :
							   0;
	int floppy_heads = (floppy_is_160k || floppy_is_180k)? 1 : 2;

	int floppy_wait_cycles = 200000000 / floppy_spt;

	int floppy_media =
			(floppy_index < 0)? 0x20 :
			(floppy_is_160k)?   0x00 :
			(floppy_is_180k)?   0x00 :
			(floppy_is_320k)?   0x00 :
			(floppy_is_360k)?   0x00 :
			(floppy_is_720k)?   0xC0 :
			(floppy_is_1_2m)?   0x00 :
			(floppy_is_1_44m)?  0x80 :
			(floppy_is_2_88m)?  0x40 :
							    0x20;

	IOWR(FLOPPY_BASE, 0x0, floppy_index >= 0? 	1 : 0);
	IOWR(FLOPPY_BASE, 0x1, floppy_writeprotect? 1 : 0);
	IOWR(FLOPPY_BASE, 0x2, floppy_cylinders);
	IOWR(FLOPPY_BASE, 0x3, floppy_spt);
	IOWR(FLOPPY_BASE, 0x4, floppy_total_sectors);
	IOWR(FLOPPY_BASE, 0x5, floppy_heads);
	IOWR(FLOPPY_BASE, 0x6, floppy_sd_base);
	IOWR(FLOPPY_BASE, 0x7, (int)(floppy_wait_cycles / (1000000000.0 / ALT_CPU_CPU_FREQ)));
	IOWR(FLOPPY_BASE, 0x8, (int)(1000000.0 / (1000000000.0 / ALT_CPU_CPU_FREQ)));
	IOWR(FLOPPY_BASE, 0x9, (int)(1666666.0 / (1000000000.0 / ALT_CPU_CPU_FREQ)));
	IOWR(FLOPPY_BASE, 0xA, (int)(2000000.0 / (1000000000.0 / ALT_CPU_CPU_FREQ)));
	IOWR(FLOPPY_BASE, 0xB, (int)(500000.0 / (1000000000.0 / ALT_CPU_CPU_FREQ)));
	IOWR(FLOPPY_BASE, 0xC, floppy_media);

	//-------------------------------------------------------------------------- hdd

	unsigned int hd_cylinders = entries[hdd_index].args.hdd.cyliders; //1-1024; 10 bits; implemented 16 bits
	unsigned int hd_heads     = entries[hdd_index].args.hdd.heads;    //1-16;   4 bits; at least 9 heads for cmos 0x20
	unsigned int hd_spt       = entries[hdd_index].args.hdd.spt;      //1-255;  8 bits;

	int hdd_sd_base = entries[hdd_index].args.hdd.sector;

	unsigned int hd_total_sectors = hd_cylinders * hd_heads * hd_spt;

	/*
	0x00.[31:0]:    identify write
	0x01.[16:0]:    media cylinders
	0x02.[4:0]:     media heads
	0x03.[8:0]:     media spt
	0x04.[13:0]:    media sectors per cylinder = spt * heads
	0x05.[31:0]:    media sectors total
	0x06.[31:0]:    media sd base
	*/

	unsigned int identify[256] = {
		0x0040, 										//word 0
		(hd_cylinders > 16383)? 16383 : hd_cylinders, 	//word 1
		0x0000,											//word 2 reserved
		hd_heads,										//word 3
		(unsigned short)(512 * hd_spt),					//word 4
		512,											//word 5
		hd_spt,											//word 6
		0x0000,											//word 7 vendor specific
		0x0000,											//word 8 vendor specific
		0x0000,											//word 9 vendor specific
		('A' << 8) | 'O',								//word 10
		('H' << 8) | 'D',								//word 11
		('0' << 8) | '0',								//word 12
		('0' << 8) | '0',								//word 13
		('0' << 8) | ' ',								//word 14
		(' ' << 8) | ' ',								//word 15
		(' ' << 8) | ' ',								//word 16
		(' ' << 8) | ' ',								//word 17
		(' ' << 8) | ' ',								//word 18
		(' ' << 8) | ' ',								//word 19
		3,   											//word 20 buffer type
		512,											//word 21 cache size
		4,												//word 22 number of ecc bytes
		0,0,0,0,										//words 23..26 firmware revision
		('A' << 8) | 'O',								//words 27..46 model number
		(' ' << 8) | 'H',
		('a' << 8) | 'r',
		('d' << 8) | 'd',
		('r' << 8) | 'i',
		('v' << 8) | 'e',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		(' ' << 8) | ' ',
		16,												//word 47 max multiple sectors
		1,												//word 48 dword io
		1<<9,											//word 49 lba supported
		0x0000,											//word 50 reserved
		0x0200,											//word 51 pio timing
		0x0200,											//word 52 pio timing
		0x0007,											//word 53 valid fields
		(hd_cylinders > 16383)? 16383 : hd_cylinders, 	//word 54
		hd_heads,										//word 55
		hd_spt,											//word 56
		hd_total_sectors & 0xFFFF,						//word 57
		hd_total_sectors >> 16,							//word 58
		0x0000,											//word 59 multiple sectors
		hd_total_sectors & 0xFFFF,						//word 60
		hd_total_sectors >> 16,							//word 61
		0x0000,											//word 62 single word dma modes
		0x0000,											//word 63 multiple word dma modes
		0x0000,											//word 64 pio modes
		120,120,120,120,								//word 65..68
		0,0,0,0,0,0,0,0,0,0,0,							//word 69..79
		0x007E,											//word 80 ata modes
		0x0000,											//word 81 minor version number
		1<<14,  										//word 82 supported commands
		(1<<14) | (1<<13) | (1<<12) | (1<<10),			//word 83
		1<<14,	    									//word 84
		1<<14,	 	    								//word 85
		(1<<14) | (1<<13) | (1<<12) | (1<<10),			//word 86
		1<<14,	    									//word 87
		0x0000,											//word 88
		0,0,0,0,										//word 89..92
		1 | (1<<14) | 0x2000,							//word 93
		0,0,0,0,0,0,									//word 94..99
		hd_total_sectors & 0xFFFF,						//word 100
		hd_total_sectors >> 16,							//word 101
		0,												//word 102
		0,												//word 103

		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,//word 104..127

		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,				//word 128..255
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	};


	for(int i=0; i<128; i++) IOWR(HDD_BASE, 0, ((unsigned int)identify[2*i+1] << 16) | (unsigned int)identify[2*i+0]);

	IOWR(HDD_BASE, 1, hd_cylinders);
	IOWR(HDD_BASE, 2, hd_heads);
	IOWR(HDD_BASE, 3, hd_spt);
	IOWR(HDD_BASE, 4, hd_spt * hd_heads);
	IOWR(HDD_BASE, 5, hd_spt * hd_heads * hd_cylinders);
	IOWR(HDD_BASE, 6, hdd_sd_base);

	//-------------------------------------------------------------------------- rtc

	bool boot_from_floppy = true;

	/*
    128.[26:0]: cycles in second
    129.[12:0]: cycles in 122.07031 us
    */

	IOWR(RTC_BASE, 128, (int)(1000000000.0 / (1000000000.0 / ALT_CPU_CPU_FREQ)));
	IOWR(RTC_BASE, 129, (int)(122070.0 / (1000000000.0 / ALT_CPU_CPU_FREQ)));

	unsigned char fdd_type = (floppy_is_2_88m)? 0x50 : (floppy_is_1_44m)? 0x40 : (floppy_is_720k)? 0x30 : (floppy_is_1_2m)? 0x20 : 0x10;

	bool translate_none = hd_cylinders <= 1024 && hd_heads <= 16 && hd_spt <= 63;
	bool translate_large= !translate_none && (hd_cylinders * hd_heads) <= 131072;
	bool translate_lba  = !translate_none && !translate_large;

	unsigned char translate_byte = (translate_large)? 1 : (translate_lba)? 2 : 0;

	//rtc contents 0-127
	unsigned int cmos[128] = {
		0x00, //0x00: SEC BCD
		0x00, //0x01: ALARM SEC BCD
		0x00, //0x02: MIN BCD
		0x00, //0x03: ALARM MIN BCD
		0x12, //0x04: HOUR BCD 24h
		0x12, //0x05: ALARM HOUR BCD 24h
		0x01, //0x06: DAY OF WEEK Sunday=1
		0x03, //0x07: DAY OF MONTH BCD from 1
		0x11, //0x08: MONTH BCD from 1
		0x13, //0x09: YEAR BCD
		0x26, //0x0A: REG A
		0x02, //0x0B: REG B
		0x00, //0x0C: REG C
		0x80, //0x0D: REG D
		0x00, //0x0E: REG E - POST status
		0x00, //0x0F: REG F - shutdown status

		fdd_type, //0x10: floppy drive type; 0-none, 1-360K, 2-1.2M, 3-720K, 4-1.44M, 5-2.88M
		0x00, //0x11: configuration bits; not used
		0xF0, //0x12: hard disk types; 0-none, 1:E-type, F-type 16+
		0x00, //0x13: advanced configuration bits; not used
		0x0D, //0x14: equipment bits
		0x80, //0x15: base memory in 1k LSB
		0x02, //0x16: base memory in 1k MSB
		0x00, //0x17: memory size above 1m in 1k LSB
		0xFC, //0x18: memory size above 1m in 1k MSB
		0x2F, //0x19: extended hd types 1/2; type 47d
		0x00, //0x1A: extended hd types 2/2

		hd_cylinders & 0xFF, 		//0x1B: hd 0 configuration 1/9; cylinders low
		(hd_cylinders >> 8) & 0xFF, //0x1C: hd 0 configuration 2/9; cylinders high
		hd_heads, 					//0x1D: hd 0 configuration 3/9; heads
		0xFF, 						//0x1E: hd 0 configuration 4/9; write pre-comp low
		0xFF, 						//0x1F: hd 0 configuration 5/9; write pre-comp high
		0xC8, 						//0x20: hd 0 configuration 6/9; retries/bad map/heads>8
		hd_cylinders & 0xFF, 		//0x21: hd 0 configuration 7/9; landing zone low
		(hd_cylinders >> 8) & 0xFF, //0x22: hd 0 configuration 8/9; landing zone high
		hd_spt, 					//0x23: hd 0 configuration 9/9; sectors/track

		0x00, //0x24: hd 1 configuration 1/9
		0x00, //0x25: hd 1 configuration 2/9
		0x00, //0x26: hd 1 configuration 3/9
		0x00, //0x27: hd 1 configuration 4/9
		0x00, //0x28: hd 1 configuration 5/9
		0x00, //0x29: hd 1 configuration 6/9
		0x00, //0x2A: hd 1 configuration 7/9
		0x00, //0x2B: hd 1 configuration 8/9
		0x00, //0x2C: hd 1 configuration 9/9

		(boot_from_floppy)? 0x20u : 0x00u, //0x2D: boot sequence

		0x00, //0x2E: checksum MSB
		0x00, //0x2F: checksum LSB

		0x00, //0x30: memory size above 1m in 1k LSB
		0xFC, //0x31: memory size above 1m in 1k MSB

		0x20, //0x32: IBM century
		0x00, //0x33: ?

		0x00, //0x34: memory size above 16m in 64k LSB
		0x07, //0x35: memory size above 16m in 64k MSB; 128 MB

		0x00, //0x36: ?
		0x20, //0x37: IBM PS/2 century

		0x00, 			//0x38: eltorito boot sequence; not used
		translate_byte, //0x39: ata translation policy 1/2
		0x00, 			//0x3A: ata translation policy 2/2

		0x00, //0x3B: ?
		0x00, //0x3C: ?

		0x00, //0x3D: eltorito boot sequence; not used

		0x00, //0x3E: ?
		0x00, //0x3F: ?

		0, 0, 0, 0, 0, 0, 0, 0,	0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,	0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,	0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0,	0, 0, 0, 0, 0, 0, 0, 0
	};

	//count checksum
	unsigned short sum = 0;
	for(int i=0x10; i<=0x2D; i++) sum += cmos[i];

	cmos[0x2E] = sum >> 8;
	cmos[0x2F] = sum & 0xFF;

	for(unsigned int i=0; i<sizeof(cmos)/sizeof(unsigned int); i++) IOWR(RTC_BASE, i, cmos[i]);

	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------

	alt_irq_disable_all();
	
	runtime_menu();
	
	//reset cycle - start executing
	IOWR(PIO_OUTPUT_BASE, 0, 0x00);
	
	while(true) {
		uint32 keys = IORD(PIO_INPUT_BASE, 0);
		if((keys & 0x4) == 0) runtime_menu();

		int cmd = read_byte_if_possible();
		if(cmd < 0) continue;

		if(cmd == 0) {
			unsigned int offset = read_int();
			unsigned int size   = read_int();

			crc32(NULL, NULL);
			unsigned char *ptr = (unsigned char *)(SDRAM_BASE + offset);

			for(unsigned int i=0; i<size; i++) {
				ptr[i] = read_byte();
				crc32(ptr + i, NULL);
				if((i%1024) == 0) printf("%08x - %d%%\n", (unsigned int)(ptr+i), (i*100/size));
			}

			unsigned int recv_crc = read_int();
			unsigned int copy_crc = 0;
			crc32(NULL, &copy_crc);

			unsigned int local_crc = 0;
			crc32(NULL, NULL);
			for(unsigned int i=0; i<size; i++) crc32(ptr + i, NULL);
			crc32(NULL, &local_crc);

			IOWR(JTAG_UART_BASE, 0, (recv_crc == copy_crc && recv_crc == local_crc)? 'Y' : 'N');
		}
		else if(cmd == 's') {
			printf("\nStarting ao486...");
			//release reset
			IOWR(PIO_OUTPUT_BASE, 0, 0x00);

			IOWR(JTAG_UART_BASE, 0, '\n');

		}
		else if(cmd == 'd') {
			printf("\nStopping ao486...");

			//release reset
			IOWR(PIO_OUTPUT_BASE, 0, 0x01);

			IOWR(JTAG_UART_BASE, 0, '\n');
		}
		else if(cmd == 'v') {
			osd_enable(true);
		}
		else if(cmd == 'b') {
			osd_enable(false);
		}
		else if(cmd == 'j') {
			printf("\nJTAG: %08x\n", IORD(JTAG_UART_BASE, 1));
		}
		else {
			IOWR(JTAG_UART_BASE, 0, 'N');
		}
	}

	//--------------------------------------------------------------------------

	return 0;
}
