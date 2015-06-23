#pragma argsused
/*
Only encoder
This version works correctly, it is tested with testcase.jpg
The translation into real huffman codes works.
Changed: If huffman wants to send 0xFFxx (FF in one byte) than there must be 0x00 inserted between FF and xx
possible fault in finish send:
-must it be filled up with zeros?          YES
-must it be filled up to one bye? or 2 byte? --> in this code there is filled up to 2 bytes, but I (joris) thinks this must be filled up to 1 byte.
 still dont know
- 24-11-05 code clean up
- 24-11-05 tables added for color



Block numbers:
Y = 0
cb =1
cr= 2
*/
//---------------------------------------------------------------------------
#include "xparameters.h"
#include "xutil.h"
#include "mb_interface.h"
#include "fifo_link.h"

#include "ejpgl.h"


#define XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID 0
#define XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID 0


static unsigned int vlc_remaining;
static unsigned char vlc_amount_remaining;
static unsigned char dcvalue[4];   // 3 is enough

int vlc_init_start() {

       vlc_remaining=0x00;
       vlc_amount_remaining=0x00;
	memset(dcvalue, 0, 4);
	return 0;
	
}

#if 0
#define vlc_output_byte(c)             put_char(c)
#endif

void vlc_output_byte(unsigned char c) {
	unsigned long result;

	result = c;
	write_into_fsl(result, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
	return;

}

#ifdef __MULTI_TASK

void vlc_task() {


}

#endif

#ifdef __MULTI_PROCESSOR

int main() {

	for (;;) {


		}

}

#endif

static unsigned char convertDCMagnitudeCLengthTable[16] = {
  0x02, 0x02, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
  0x08, 0x09, 0x0a, 0x0b, 0x00, 0x00, 0x00, 0x00
};

static unsigned short convertDCMagnitudeCOutTable[16] = {
	0x0000, 0x0001, 0x0002, 0x0006, 0x000e, 0x001e, 0x003e, 0x007e,
	0x00fe, 0x01fe, 0x03fe, 0x07fe, 0x0000, 0x0000, 0x0000, 0x0000
};

void ConvertDCMagnitudeC(unsigned char magnitude,unsigned short int *out, unsigned short int *lenght)
{
	unsigned char len;
	
	if ((magnitude>16) || ((len=convertDCMagnitudeCLengthTable[magnitude])==0)) {
#ifndef __MICROBLAZE
		printf("WAARDE STAAT NIET IN TABEL!!!!!!!!!!!!!!!!!!!!\n");
#endif
		}
	*lenght = len;
	*out = convertDCMagnitudeCOutTable[magnitude];

#if 0	
        switch (magnitude) {
                case 0x00 : *out=0x0000; *lenght=2; break;
                case 0x01 : *out=0x0001; *lenght=2; break;
		case 0x02 : *out=0x0002; *lenght=2; break;
		case 0x03 : *out=0x0006; *lenght=3; break;
		case 0x04 : *out=0x000e; *lenght=4; break;
		case 0x05 : *out=0x001e; *lenght=5; break;
		case 0x06 : *out=0x003e; *lenght=6; break;
		case 0x07 : *out=0x007e; *lenght=7; break;
		case 0x08 : *out=0x00fe; *lenght=8; break;
		case 0x09 : *out=0x01fe; *lenght=9; break;
		case 0x0a : *out=0x03fe; *lenght=10; break;
		case 0x0b : *out=0x07fe; *lenght=11; break;
        }
#endif

}

static unsigned char convertACMagnitudeCLengthTable[256] = {
0x02, 0x02, 0x03, 0x04, 0x05, 0x05, 0x06, 0x07, 0x09, 0x0a, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00,    // 00 - 0f
0x00, 0x04, 0x06, 0x08, 0x09, 0x0b, 0x0c, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 10 - 1f
0x00, 0x05, 0x08, 0x0a, 0x0c, 0x0f, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 20 - 2f
0x00, 0x05, 0x08, 0x0a, 0x0c, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 30 - 3f
0x00, 0x06, 0x09, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 40 - 4f
0x00, 0x06, 0x0a, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 50 - 5f
0x00, 0x07, 0x0b, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 60 - 6f
0x00, 0x07, 0x0b, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 70 - 7f
0x00, 0x08, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 80 - 8f
0x00, 0x09, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 90 - 9f
0x00, 0x09, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // a0 - af
0x00, 0x09, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // b0 - bf
0x00, 0x09, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // c0 - cf
0x00, 0x0b, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // d0 - df
0x00, 0x0e, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // e0 - ef
0x0a, 0x0f, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00
};

static unsigned short convertACMagnitudeCOutTable[256] = {
0x0000, 0x0001, 0x0004, 0x000a, 0x0018, 0x0019, 0x0038, 0x0078, 0x01f4, 0x03f6, 0x0ff4, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 00 - 0f
0x0000, 0x000b, 0x0039, 0x00f6, 0x01f5, 0x07f6, 0x0ff5, 0xff88, 0xff89, 0xff8a, 0xff8b, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 10 - 1f
0x0000, 0x001a, 0x00f7, 0x03f7, 0x0ff6, 0x7fc2, 0xff8c, 0xff8d, 0xff8e, 0xff8f, 0xff90, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 20 - 2f
0x0000, 0x001b, 0x00f8, 0x03f8, 0x0ff7, 0xff91, 0xff92, 0xff93, 0xff94, 0xff95, 0xff96, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 30 - 3f
0x0000, 0x003a, 0x01f6, 0xff97, 0xff98, 0xff99, 0xff9a, 0xff9b, 0xff9c, 0xff9d, 0xff9e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 40 - 4f
0x0000, 0x003b, 0x03f9, 0xff9f, 0xffa0, 0xffa1, 0xFFA2, 0xFFA3, 0xFFA4, 0xFFA5, 0xFFA6, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 50 - 5f
0x0000, 0x0079, 0x07f7, 0xffa7, 0xffa8, 0xffa9, 0xffaa, 0xffab, 0xFFAc, 0xFFAf, 0xFFAe, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 60 - 6f
0x0000, 0x007a, 0x07f8, 0xffaf, 0xffb0, 0xFFB1, 0xFFB2, 0xFFB3, 0xFFB4, 0xFFB5, 0xFFB6, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 70 - 7f
0x0000, 0x00f9, 0xffb7, 0xFFB8, 0xFFB9, 0xFFBa, 0xFFBb, 0xFFBc, 0xFFBd, 0xFFBe, 0xFFBf, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 80 - 8f
0x0000, 0x01f7, 0xffc0, 0xffc1, 0xFFC2, 0xFFC3, 0xFFC4, 0xFFC5, 0xFFC6, 0xFFC7, 0xFFC8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 90 - 9f
0x0000, 0x01f8, 0xffc9, 0xFFCa, 0xFFCb, 0xFFCc, 0xFFCd, 0xFFCe, 0xFFCf, 0xFFd0, 0xFFd1, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // a0 - af
0x0000, 0x01f9, 0xFFD2, 0xFFD3, 0xFFD4, 0xFFD5, 0xFFD6, 0xFFD7, 0xFFD8, 0xFFD9, 0xFFDa, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // b0 - bf
0x0000, 0x01fa, 0xFFDb, 0xFFDc, 0xFFDd, 0xFFDe, 0xFFDf, 0xFFe0, 0xFFe1, 0xFFe2, 0xFFe3, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // c0 - cf
0x0000, 0x07f9, 0xFFE4, 0xFFE5, 0xFFE6, 0xFFE7, 0xFFE8, 0xFFE9, 0xFFEa, 0xFFEb, 0xFFEc, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // d0 - df
0x0000, 0x3fe0, 0xffed, 0xFFEe, 0xFFEf, 0xFFf0, 0xFFF1, 0xFFF2, 0xFFF3, 0xFFF4, 0xFFF5, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // e0 - ef
0x03fa, 0x7fc3, 0xFFF6, 0xFFF7, 0xFFF8, 0xFFF9, 0xFFFA, 0xFFFB, 0xFFFC, 0xFFFD, 0xFFFE, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 
};

//===========================================================================
void ConvertACMagnitudeC(unsigned char magnitude,unsigned short int *out, unsigned short int *lenght)
{
	unsigned char len;
	
	len = convertACMagnitudeCLengthTable[magnitude];
	if (!len) {
#ifndef __MICROBLAZE
		printf("WAARDE STAAT NIET IN TABEL!!!!!!!!!!!!!!!!!!!!\n");
#endif
		}
	*lenght = len;
	*out = convertACMagnitudeCOutTable[magnitude];
	
#if 0
        switch (magnitude) {
case 0x00 :  *lenght=0x02; *out=0x0000; break; //1010
case 0x01 :  *lenght=0x02; *out=0x0001; break; //00
case 0x02 :  *lenght=0x03; *out=0x0004; break; //01
case 0x03 :  *lenght=0x04; *out=0x000a; break; //100
case 0x04 :  *lenght=0x05; *out=0x0018; break; //1011
case 0x05 :  *lenght=0x05; *out=0x0019; break; //11010
case 0x06 :  *lenght=0x06; *out=0x0038; break; //1111000
case 0x07 :  *lenght=0x07; *out=0x0078; break; //11111000
case 0x08 :  *lenght=0x09; *out=0x01f4; break; //1111110110
case 0x09 :  *lenght=0x0a; *out=0x03f6; break; //1111111110000010
case 0x0A :  *lenght=0x0c; *out=0x0ff4; break; //1111111110000011
case 0x11 :  *lenght=0x04; *out=0x000b; break; //1100
case 0x12 :  *lenght=0x06; *out=0x0039; break; //11011
case 0x13 :  *lenght=0x08; *out=0x00f6; break; //1111001
case 0x14 :  *lenght=0x09; *out=0x01f5; break; //111110110
case 0x15 :  *lenght=0x0b; *out=0x07f6; break; //11111110110
case 0x16 :  *lenght=0x0c; *out=0x0ff5; break; //1111111110000100
case 0x17 :  *lenght=0x10; *out=0xff88; break; //1111111110000101
case 0x18 :  *lenght=0x10; *out=0xff89; break; //1111111110000110
case 0x19 :  *lenght=0x10; *out=0xff8a; break; //1111111110000111
case 0x1A :  *lenght=0x10; *out=0xff8b; break; //1111111110001000
case 0x21 :  *lenght=0x05; *out=0x001a; break; //11100
case 0x22 :  *lenght=0x08; *out=0x00f7; break; //11111001
case 0x23 :  *lenght=0x0a; *out=0x03f7; break; //1111110111
case 0x24 :  *lenght=0x0c; *out=0x0ff6; break; //111111110100
case 0x25 :  *lenght=0x0f; *out=0x7fc2; break; //1111111110001001
case 0x26 :  *lenght=0x10; *out=0xff8c; break; //1111111110001010
case 0x27 :  *lenght=0x10; *out=0xff8d; break; //1111111110001011
case 0x28 :  *lenght=0x10; *out=0xff8e; break; //1111111110001100
case 0x29 :  *lenght=0x10; *out=0xff8f; break; //1111111110001101
case 0x2A :  *lenght=0x10; *out=0xff90; break; //1111111110001110
case 0x31 :  *lenght=0x05; *out=0x001b; break; //111010
case 0x32 :  *lenght=0x08; *out=0x00f8; break; //111110111
case 0x33 :  *lenght=0x0a; *out=0x03f8; break; //111111110101
case 0x34 :  *lenght=0x0c; *out=0x0ff7; break; //1111111110001111
case 0x35 :  *lenght=0x10; *out=0xff91; break; //1111111110010000
case 0x36 :  *lenght=0x10; *out=0xff92; break; //1111111110010001
case 0x37 :  *lenght=0x10; *out=0xff93; break; //1111111110010010
case 0x38 :  *lenght=0x10; *out=0xff94; break; //1111111110010011
case 0x39 :  *lenght=0x10; *out=0xff95; break; //1111111110010100
case 0x3A :  *lenght=0x10; *out=0xff96; break; //1111111110010101
case 0x41 :  *lenght=0x06; *out=0x003a; break; //111011
case 0x42 :  *lenght=0x09; *out=0x01f6; break; //1111111000
case 0x43 :  *lenght=0x10; *out=0xff97; break; //1111111110010110
case 0x44 :  *lenght=0x10; *out=0xff98; break; //1111111110010111
case 0x45 :  *lenght=0x10; *out=0xff99; break; //1111111110011000
case 0x46 :  *lenght=0x10; *out=0xff9a; break; //1111111110011001
case 0x47 :  *lenght=0x10; *out=0xff9b; break; //1111111110011010
case 0x48 :  *lenght=0x10; *out=0xff9c; break; //1111111110011011
case 0x49 :  *lenght=0x10; *out=0xff9d; break; //1111111110011100
case 0x4A :  *lenght=0x10; *out=0xff9e; break; //1111111110011101
case 0x51 :  *lenght=0x06; *out=0x003b; break; //1111010
case 0x52 :  *lenght=0x0a; *out=0x03f9; break; //11111110111
case 0x53 :  *lenght=0x10; *out=0xff9f; break; //1111111110011110
case 0x54 :  *lenght=0x10; *out=0xffa0; break; //1111111110011111
case 0x55 :  *lenght=0x10; *out=0xffa1; break; //1111111110100000
case 0x56 :  *lenght=0x10; *out=0xFFA2; break; //1111111110100001
case 0x57 :  *lenght=0x10; *out=0xFFA3; break; //1111111110100010
case 0x58 :  *lenght=0x10; *out=0xFFA4; break; //1111111110100011
case 0x59 :  *lenght=0x10; *out=0xFFA5; break; //1111111110100100
case 0x5A :  *lenght=0x10; *out=0xFFA6; break; //1111111110100101
case 0x61 :  *lenght=0x07; *out=0x0079; break; //1111011
case 0x62 :  *lenght=0x0b; *out=0x07f7; break; //111111110110
case 0x63 :  *lenght=0x10; *out=0xffa7; break; //1111111110100110
case 0x64 :  *lenght=0x10; *out=0xffa8; break; //1111111110100111
case 0x65 :  *lenght=0x10; *out=0xffa9; break; //1111111110101000
case 0x66 :  *lenght=0x10; *out=0xffaa; break; //1111111110101001
case 0x67 :  *lenght=0x10; *out=0xffab; break; //1111111110101010
case 0x68 :  *lenght=0x10; *out=0xFFAc; break; //1111111110101011
case 0x69 :  *lenght=0x10; *out=0xFFAf; break; //1111111110101100
case 0x6A :  *lenght=0x10; *out=0xFFAe; break; //1111111110101101
case 0x71 :  *lenght=0x07; *out=0x007a; break; //11111010
case 0x72 :  *lenght=0x0b; *out=0x07f8; break; //111111110111
case 0x73 :  *lenght=0x10; *out=0xffaf; break; //1111111110101110
case 0x74 :  *lenght=0x10; *out=0xffb0; break; //1111111110101111
case 0x75 :  *lenght=0x10; *out=0xFFB1; break; //1111111110110000
case 0x76 :  *lenght=0x10; *out=0xFFB2; break; //111111110110001
case 0x77 :  *lenght=0x10; *out=0xFFB3; break; //111111110110010
case 0x78 :  *lenght=0x10; *out=0xFFB4; break; //111111110110011
case 0x79 :  *lenght=0x10; *out=0xFFB5; break; //1111111110110100
case 0x7A :  *lenght=0x10; *out=0xFFB6; break; //1111111110110101
case 0x81 :  *lenght=0x08; *out=0x00f9; break; //111111000
case 0x82 :  *lenght=0x10; *out=0xffb7; break; //111111111000000
case 0x83 :  *lenght=0x10; *out=0xFFB8; break; //1111111110110110
case 0x84 :  *lenght=0x10; *out=0xFFB9; break; //1111111110110111
case 0x85 :  *lenght=0x10; *out=0xFFBa; break; //1111111110111000
case 0x86 :  *lenght=0x10; *out=0xFFBb; break; //1111111110111001
case 0x87 :  *lenght=0x10; *out=0xFFBc; break; //1111111110111010
case 0x88 :  *lenght=0x10; *out=0xFFBd; break; //1111111110111011
case 0x89 :  *lenght=0x10; *out=0xFFBe; break; //1111111110111100
case 0x8A :  *lenght=0x10; *out=0xFFBf; break; //1111111110111101
case 0x91 :  *lenght=0x09; *out=0x01f7; break; //111111001
case 0x92 :  *lenght=0x10; *out=0xffc0; break; //1111111110111110
case 0x93 :  *lenght=0x10; *out=0xffc1; break; //1111111110111111
case 0x94 :  *lenght=0x10; *out=0xFFC2; break; //1111111111000000
case 0x95 :  *lenght=0x10; *out=0xFFC3; break; //1111111111000001
case 0x96 :  *lenght=0x10; *out=0xFFC4; break; //1111111111000010
case 0x97 :  *lenght=0x10; *out=0xFFC5; break; //1111111111000011
case 0x98 :  *lenght=0x10; *out=0xFFC6; break; //1111111111000100
case 0x99 :  *lenght=0x10; *out=0xFFC7; break; //1111111111000101
case 0x9A :  *lenght=0x10; *out=0xFFC8; break; //1111111111000110
case 0xA1 :  *lenght=0x09; *out=0x01f8; break; //111111010
case 0xA2 :  *lenght=0x10; *out=0xffc9; break; //1111111111000111
case 0xA3 :  *lenght=0x10; *out=0xFFCa; break; //1111111111001000
case 0xA4 :  *lenght=0x10; *out=0xFFCb; break; //1111111111001001
case 0xA5 :  *lenght=0x10; *out=0xFFCc; break; //1111111111001010
case 0xA6 :  *lenght=0x10; *out=0xFFCd; break; //1111111111001011
case 0xA7 :  *lenght=0x10; *out=0xFFCe; break; //1111111111001100
case 0xA8 :  *lenght=0x10; *out=0xFFCf; break; //1111111111001101
case 0xA9 :  *lenght=0x10; *out=0xFFd0; break; //1111111111001110
case 0xAA :  *lenght=0x10; *out=0xFFd1; break; //1111111111001111
case 0xB1 :  *lenght=0x09; *out=0x01f9; break; //1111111001
case 0xB2 :  *lenght=0x10; *out=0xFFD2; break; //1111111111010000
case 0xB3 :  *lenght=0x10; *out=0xFFD3; break; //1111111111010001
case 0xB4 :  *lenght=0x10; *out=0xFFD4; break; //1111111111010010
case 0xB5 :  *lenght=0x10; *out=0xFFD5; break; //1111111111010011
case 0xB6 :  *lenght=0x10; *out=0xFFD6; break; //1111111111010100
case 0xB7 :  *lenght=0x10; *out=0xFFD7; break; //1111111111010101
case 0xB8 :  *lenght=0x10; *out=0xFFD8; break; //1111111111010110
case 0xB9 :  *lenght=0x10; *out=0xFFD9; break; //1111111111010111
case 0xBA :  *lenght=0x10; *out=0xFFDa; break; //1111111111011000
case 0xC1 :  *lenght=0x09; *out=0x01fa; break; //1111111010
case 0xC2 :  *lenght=0x10; *out=0xFFDb; break; //1111111111011001
case 0xC3 :  *lenght=0x10; *out=0xFFDc; break; //1111111111011010
case 0xC4 :  *lenght=0x10; *out=0xFFDd; break; //1111111111011011
case 0xC5 :  *lenght=0x10; *out=0xFFDe; break; //1111111111011100
case 0xC6 :  *lenght=0x10; *out=0xFFDf; break; //1111111111011101
case 0xC7 :  *lenght=0x10; *out=0xFFe0; break; //1111111111011110
case 0xC8 :  *lenght=0x10; *out=0xFFe1; break; //1111111111011111
case 0xC9 :  *lenght=0x10; *out=0xFFe2; break; //1111111111100000
case 0xCA :  *lenght=0x10; *out=0xFFe3; break; //1111111111100001
case 0xD1 :  *lenght=0x0b; *out=0x07f9; break; //11111111000
case 0xD2 :  *lenght=0x10; *out=0xFFE4; break; //1111111111100010
case 0xD3 :  *lenght=0x10; *out=0xFFE5; break; //1111111111100011
case 0xD4 :  *lenght=0x10; *out=0xFFE6; break; //1111111111100100
case 0xD5 :  *lenght=0x10; *out=0xFFE7; break; //1111111111100101
case 0xD6 :  *lenght=0x10; *out=0xFFE8; break; //1111111111100110
case 0xD7 :  *lenght=0x10; *out=0xFFE9; break; //1111111111100111
case 0xD8 :  *lenght=0x10; *out=0xFFEa; break; //1111111111101000
case 0xD9 :  *lenght=0x10; *out=0xFFEb; break; //1111111111101001
case 0xDA :  *lenght=0x10; *out=0xFFEc; break; //1111111111101010
case 0xE1 :  *lenght=0x0e; *out=0x3fe0; break; //1111111111101011
case 0xE2 :  *lenght=0x10; *out=0xffed; break; //1111111111101100
case 0xE3 :  *lenght=0x10; *out=0xFFEe; break; //1111111111101101
case 0xE4 :  *lenght=0x10; *out=0xFFEf; break; //1111111111101110
case 0xE5 :  *lenght=0x10; *out=0xFFf0; break; //1111111111101111
case 0xE6 :  *lenght=0x10; *out=0xFFF1; break; //1111111111110000
case 0xE7 :  *lenght=0x10; *out=0xFFF2; break; //1111111111110001
case 0xE8 :  *lenght=0x10; *out=0xFFF3; break; //1111111111110010
case 0xE9 :  *lenght=0x10; *out=0xFFF4; break; //1111111111110011
case 0xEA :  *lenght=0x10; *out=0xFFF5; break; //1111111111110100
case 0xF0 :  *lenght=0x0a; *out=0x03fa; break; //11111111001
case 0xF1 :  *lenght=0x0f; *out=0x7fc3; break; //1111111111110101
case 0xF2 :  *lenght=0x10; *out=0xFFF6; break; //1111111111110110
case 0xF3 :  *lenght=0x10; *out=0xFFF7; break; //1111111111110111
case 0xF4 :  *lenght=0x10; *out=0xFFF8; break; //1111111111111000
case 0xF5 :  *lenght=0x10; *out=0xFFF9; break; //1111111111111001
case 0xF6 :  *lenght=0x10; *out=0xFFFA; break; //1111111111111010
case 0xF7 :  *lenght=0x10; *out=0xFFFB; break; //1111111111111011
case 0xF8 :  *lenght=0x10; *out=0xFFFC; break; //1111111111111100
case 0xF9 :  *lenght=0x10; *out=0xFFFD; break; //1111111111111101
case 0xFA :  *lenght=0x10; *out=0xFFFE; break; //1111111111111110
#ifndef __MICROBLAZE
default : printf("WAARDE STAAT NIET IN TABEL!!!!!!!!!!!!!!!!!!!!\n");break;
#endif
        }
  //      printf("magnitude= %x out= %x lenght= %d \n",magnitude,*out,*lenght);
        return;
#endif

	
}

static unsigned char convertDCMagnitudeYLengthTable[16] = {
0x02, 0x03, 0x03, 0x03, 0x03, 0x03, 0x04, 0x05,
0x06, 0x07, 0x08, 0x09, 0x00, 0x00, 0x00, 0x00
};

static unsigned short convertDCMagnitudeYOutTable[16] = {
0x0000, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x000e, 0x001e,
0x003e, 0x007e, 0x00fe, 0x01fe, 0x0000, 0x0000, 0x0000, 0x0000
};

//===========================================================================
void ConvertDCMagnitudeY(unsigned char magnitude,unsigned short int *out, unsigned short int *lenght)
{
	unsigned char len;
	
	if ((magnitude>16) || ((len=convertDCMagnitudeYLengthTable[magnitude])==0)) {
#ifndef __MICROBLAZE
		printf("WAARDE STAAT NIET IN TABEL!!!!!!!!!!!!!!!!!!!!\n");
#endif
		}
	*lenght = len;
	*out = convertDCMagnitudeYOutTable[magnitude];
#if 0
        switch (magnitude) {
                case 0x00 : *out=0x0000; *lenght=2; break;
                case 0x01 : *out=0x0002; *lenght=3; break;
		case 0x02 : *out=0x0003; *lenght=3; break;
		case 0x03 : *out=0x0004; *lenght=3; break;
		case 0x04 : *out=0x0005; *lenght=3; break;
		case 0x05 : *out=0x0006; *lenght=3; break;
		case 0x06 : *out=0x000e; *lenght=4; break;
		case 0x07 : *out=0x001e; *lenght=5; break;
		case 0x08 : *out=0x003e; *lenght=6; break;
		case 0x09 : *out=0x007e; *lenght=7; break;
		case 0x0a : *out=0x00fe; *lenght=8; break;
		case 0x0b : *out=0x01fe; *lenght=9; break;
        }
#endif		
}

static unsigned char convertACMagnitudeYLength[256] = {
0x04, 0x02, 0x02, 0x03, 0x04, 0x05, 0x07, 0x08, 0x0a, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 00 - 0f
0x00, 0x04, 0x05, 0x07, 0x09, 0x0b, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 10 - 1f
0x00, 0x05, 0x08, 0x0a, 0x0c, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 20 - 2f
0x00, 0x06, 0x09, 0x0c, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 30 - 3f
0x00, 0x06, 0x0a, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 40 - 4f
0x00, 0x07, 0x0b, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 50 - 5f
0x00, 0x07, 0x0c, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 60 - 6f
0x00, 0x08, 0x0c, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 70 - 7f
0x00, 0x09, 0x0f, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 80 - 8f
0x00, 0x09, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // 90 - 9f
0x00, 0x09, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // a0 - af
0x00, 0x0a, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // b0 - bf
0x00, 0x0a, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // c0 - cf
0x00, 0x0b, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // d0 - df
0x00, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,    // e0 - ef
0x0b, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00
};

static unsigned short convertACMagnitudeYOut[256] = {
0xFFFA, 0xFFF0, 0xFFF1, 0xFFF4, 0xFFFB, 0xFFFA, 0xFFF8, 0xFFF8, 0xFFF6, 0xFF82, 0xFF83, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 00 - 0f
0x0000, 0xFFFC, 0xFFFB, 0xFFF9, 0xFFF6, 0xFFF6, 0xFF84, 0xFF85, 0xFF86, 0xFF87, 0xFF88, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 10 - 1f
0x0000, 0xFFFC, 0xFFF9, 0xFFF7, 0xFFF4, 0xFF89, 0xFF8A, 0xFF8B, 0xFF8C, 0xFF8D, 0xFF8E, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 20 - 2f
0x0000, 0xFFFA, 0xFFF7, 0xFFF5, 0xFF8F, 0xFF90, 0xFF91, 0xFF92, 0xFF93, 0xFF94, 0xFF95, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 30 - 3f
0x0000, 0xFFFB, 0xFFF8, 0xFF96, 0xFF97, 0xFF98, 0xFF99, 0xFF9A, 0xFF9B, 0xFF9C, 0xFF9D, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 40 - 4f
0x0000, 0xFFFA, 0xFFF7, 0xFF9E, 0xFF9F, 0xFFA0, 0xFFA1, 0xFFA2, 0xFFA3, 0xFFA4, 0xFFA5, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 50 - 5f
0x0000, 0xFFFB, 0xFFF6, 0xFFA6, 0xFFA7, 0xFFA8, 0xFFA9, 0xFFAA, 0xFFAB, 0xFFAC, 0xFFAD, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 60 - 6f
0x0000, 0xFFFA, 0xFFF7, 0xFFAE, 0xFFAF, 0xFFB0, 0xFFB1, 0xFFB2, 0xFFB3, 0xFFB4, 0xFFB5, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 70 - 7f
0x0000, 0xFFF8, 0xFFC0, 0xFFB6, 0xFFB7, 0xFFB8, 0xFFB9, 0xFFBA, 0xFFBB, 0xFFBC, 0xFFBD, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 80 - 8f
0x0000, 0xFFF9, 0xFFBE, 0xFFBF, 0xFFC0, 0xFFC1, 0xFFC2, 0xFFC3, 0xFFC4, 0xFFC5, 0xFFC6, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // 90 - 9f
0x0000, 0xFFFA, 0xFFC7, 0xFFC8, 0xFFC9, 0xFFCA, 0xFFCB, 0xFFCC, 0xFFCD, 0xFFCE, 0xFFCF, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // a0 - af
0x0000, 0xFFF9, 0xFFD0, 0xFFD1, 0xFFD2, 0xFFD3, 0xFFD4, 0xFFD5, 0xFFD6, 0xFFD7, 0xFFD8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // b0 - bf
0x0000, 0xFFFA, 0xFFD9, 0xFFDA, 0xFFDB, 0xFFDC, 0xFFDD, 0xFFDE, 0xFFDF, 0xFFE0, 0xFFE1, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // c0 - cf
0x0000, 0xFFF8, 0xFFE2, 0xFFE3, 0xFFE4, 0xFFE5, 0xFFE6, 0xFFE7, 0xFFE8, 0xFFE9, 0xFFEA, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // d0 - df
0x0000, 0xFFEB, 0xFFEC, 0xFFED, 0xFFEE, 0xFFEF, 0xFFF0, 0xFFF1, 0xFFF2, 0xFFF3, 0xFFF4, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,    // e0 - ef
0xFFF9, 0xFFF5, 0xFFF6, 0xFFF7, 0xFFF8, 0xFFF9, 0xFFFA, 0xFFFB, 0xFFFC, 0xFFFD, 0xFFFE, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
};

//===========================================================================
void ConvertACMagnitudeY(unsigned char magnitude,unsigned short int *out, unsigned short int *lenght)
{
	unsigned char len;

	len = convertACMagnitudeYLength[magnitude];
	if (!len) {
#ifndef __MICROBLAZE
	printf("WAARDE STAAT NIET IN TABEL!!!!!!!!!!!!!!!!!!!!\n");
#endif
		}
	*lenght = len;
	*out = convertACMagnitudeYOut[magnitude];
	
#if 0
        switch (magnitude) {
case 0x00 :  *lenght=4;  *out=0xFFFA; break; //1010
case 0x01 :  *lenght=2;  *out=0xFFF0; break; //00
case 0x02 :  *lenght=2;  *out=0xFFF1; break; //01
case 0x03 :  *lenght=3;  *out=0xFFF4; break; //100
case 0x04 :  *lenght=4;  *out=0xFFFB; break; //1011
case 0x05 :  *lenght=5;  *out=0xFFFA; break; //11010
case 0x06 :  *lenght=7;  *out=0xFFF8; break; //1111000
case 0x07 :  *lenght=8;  *out=0xFFF8; break; //11111000
case 0x08 :  *lenght=10; *out=0xFFF6; break; //1111110110
case 0x09 :  *lenght=16; *out=0xFF82; break; //1111111110000010
case 0x0A :  *lenght=16; *out=0xFF83; break; //1111111110000011
case 0x11 :  *lenght=4;  *out=0xFFFC; break; //1100
case 0x12 :  *lenght=5;  *out=0xFFFB; break; //11011
case 0x13 :  *lenght=7;  *out=0xFFF9; break; //1111001
case 0x14 :  *lenght=9;  *out=0xFFF6; break; //111110110
case 0x15 :  *lenght=11; *out=0xFFF6; break; //11111110110
case 0x16 :  *lenght=16; *out=0xFF84; break; //1111111110000100
case 0x17 :  *lenght=16; *out=0xFF85; break; //1111111110000101
case 0x18 :  *lenght=16; *out=0xFF86; break; //1111111110000110
case 0x19 :  *lenght=16; *out=0xFF87; break; //1111111110000111
case 0x1A :  *lenght=16; *out=0xFF88; break; //1111111110001000
case 0x21 :  *lenght=5;  *out=0xFFFC; break; //11100
case 0x22 :  *lenght=8;  *out=0xFFF9; break; //11111001
case 0x23 :  *lenght=10; *out=0xFFF7; break; //1111110111
case 0x24 :  *lenght=12; *out=0xFFF4; break; //111111110100
case 0x25 :  *lenght=16; *out=0xFF89; break; //1111111110001001
case 0x26 :  *lenght=16; *out=0xFF8A; break; //1111111110001010
case 0x27 :  *lenght=16; *out=0xFF8B; break; //1111111110001011
case 0x28 :  *lenght=16; *out=0xFF8C; break; //1111111110001100
case 0x29 :  *lenght=16; *out=0xFF8D; break; //1111111110001101
case 0x2A :  *lenght=16; *out=0xFF8E; break; //1111111110001110
case 0x31 :  *lenght=6;  *out=0xFFFA; break; //111010
case 0x32 :  *lenght=9;  *out=0xFFF7; break; //111110111
case 0x33 :  *lenght=12; *out=0xFFF5; break; //111111110101
case 0x34 :  *lenght=16; *out=0xFF8F; break; //1111111110001111
case 0x35 :  *lenght=16; *out=0xFF90; break; //1111111110010000
case 0x36 :  *lenght=16; *out=0xFF91; break; //1111111110010001
case 0x37 :  *lenght=16; *out=0xFF92; break; //1111111110010010
case 0x38 :  *lenght=16; *out=0xFF93; break; //1111111110010011
case 0x39 :  *lenght=16; *out=0xFF94; break; //1111111110010100
case 0x3A :  *lenght=16; *out=0xFF95; break; //1111111110010101
case 0x41 :  *lenght=6;  *out=0xFFFB; break; //111011
case 0x42 :  *lenght=10; *out=0xFFF8; break; //1111111000
case 0x43 :  *lenght=16; *out=0xFF96; break; //1111111110010110
case 0x44 :  *lenght=16; *out=0xFF97; break; //1111111110010111
case 0x45 :  *lenght=16; *out=0xFF98; break; //1111111110011000
case 0x46 :  *lenght=16; *out=0xFF99; break; //1111111110011001
case 0x47 :  *lenght=16; *out=0xFF9A; break; //1111111110011010
case 0x48 :  *lenght=16; *out=0xFF9B; break; //1111111110011011
case 0x49 :  *lenght=16; *out=0xFF9C; break; //1111111110011100
case 0x4A :  *lenght=16; *out=0xFF9D; break; //1111111110011101
case 0x51 :  *lenght=7;  *out=0xFFFA; break; //1111010
case 0x52 :  *lenght=11; *out=0xFFF7; break; //11111110111
case 0x53 :  *lenght=16; *out=0xFF9E; break; //1111111110011110
case 0x54 :  *lenght=16; *out=0xFF9F; break; //1111111110011111
case 0x55 :  *lenght=16; *out=0xFFA0; break; //1111111110100000
case 0x56 :  *lenght=16; *out=0xFFA1; break; //1111111110100001
case 0x57 :  *lenght=16; *out=0xFFA2; break; //1111111110100010
case 0x58 :  *lenght=16; *out=0xFFA3; break; //1111111110100011
case 0x59 :  *lenght=16; *out=0xFFA4; break; //1111111110100100
case 0x5A :  *lenght=16; *out=0xFFA5; break; //1111111110100101
case 0x61 :  *lenght=7;  *out=0xFFFB; break; //1111011
case 0x62 :  *lenght=12; *out=0xFFF6; break; //111111110110
case 0x63 :  *lenght=16; *out=0xFFA6; break; //1111111110100110
case 0x64 :  *lenght=16; *out=0xFFA7; break; //1111111110100111
case 0x65 :  *lenght=16; *out=0xFFA8; break; //1111111110101000
case 0x66 :  *lenght=16; *out=0xFFA9; break; //1111111110101001
case 0x67 :  *lenght=16; *out=0xFFAA; break; //1111111110101010
case 0x68 :  *lenght=16; *out=0xFFAB; break; //1111111110101011
case 0x69 :  *lenght=16; *out=0xFFAC; break; //1111111110101100
case 0x6A :  *lenght=16; *out=0xFFAD; break; //1111111110101101
case 0x71 :  *lenght=8;  *out=0xFFFA; break; //11111010
case 0x72 :  *lenght=12; *out=0xFFF7; break; //111111110111
case 0x73 :  *lenght=16; *out=0xFFAE; break; //1111111110101110
case 0x74 :  *lenght=16; *out=0xFFAF; break; //1111111110101111
case 0x75 :  *lenght=16; *out=0xFFB0; break; //1111111110110000
case 0x76 :  *lenght=16; *out=0xFFB1; break; //111111110110001
case 0x77 :  *lenght=16; *out=0xFFB2; break; //111111110110010
case 0x78 :  *lenght=16; *out=0xFFB3; break; //111111110110011
case 0x79 :  *lenght=16; *out=0xFFB4; break; //1111111110110100
case 0x7A :  *lenght=16; *out=0xFFB5; break; //1111111110110101
case 0x81 :  *lenght=9;  *out=0xFFF8; break; //111111000
case 0x82 :  *lenght=15; *out=0xFFC0; break; //111111111000000
case 0x83 :  *lenght=16; *out=0xFFB6; break; //1111111110110110
case 0x84 :  *lenght=16; *out=0xFFB7; break; //1111111110110111
case 0x85 :  *lenght=16; *out=0xFFB8; break; //1111111110111000
case 0x86 :  *lenght=16; *out=0xFFB9; break; //1111111110111001
case 0x87 :  *lenght=16; *out=0xFFBA; break; //1111111110111010
case 0x88 :  *lenght=16; *out=0xFFBB; break; //1111111110111011
case 0x89 :  *lenght=16; *out=0xFFBC; break; //1111111110111100
case 0x8A :  *lenght=16; *out=0xFFBD; break; //1111111110111101
case 0x91 :  *lenght=9;  *out=0xFFF9; break; //111111001
case 0x92 :  *lenght=16; *out=0xFFBE; break; //1111111110111110
case 0x93 :  *lenght=16; *out=0xFFBF; break; //1111111110111111
case 0x94 :  *lenght=16; *out=0xFFC0; break; //1111111111000000
case 0x95 :  *lenght=16; *out=0xFFC1; break; //1111111111000001
case 0x96 :  *lenght=16; *out=0xFFC2; break; //1111111111000010
case 0x97 :  *lenght=16; *out=0xFFC3; break; //1111111111000011
case 0x98 :  *lenght=16; *out=0xFFC4; break; //1111111111000100
case 0x99 :  *lenght=16; *out=0xFFC5; break; //1111111111000101
case 0x9A :  *lenght=16; *out=0xFFC6; break; //1111111111000110
case 0xA1 :  *lenght=9;  *out=0xFFFA; break; //111111010
case 0xA2 :  *lenght=16; *out=0xFFC7; break; //1111111111000111
case 0xA3 :  *lenght=16; *out=0xFFC8; break; //1111111111001000
case 0xA4 :  *lenght=16; *out=0xFFC9; break; //1111111111001001
case 0xA5 :  *lenght=16; *out=0xFFCA; break; //1111111111001010
case 0xA6 :  *lenght=16; *out=0xFFCB; break; //1111111111001011
case 0xA7 :  *lenght=16; *out=0xFFCC; break; //1111111111001100
case 0xA8 :  *lenght=16; *out=0xFFCD; break; //1111111111001101
case 0xA9 :  *lenght=16; *out=0xFFCE; break; //1111111111001110
case 0xAA :  *lenght=16; *out=0xFFCF; break; //1111111111001111
case 0xB1 :  *lenght=10; *out=0xFFF9; break; //1111111001
case 0xB2 :  *lenght=16; *out=0xFFD0; break; //1111111111010000
case 0xB3 :  *lenght=16; *out=0xFFD1; break; //1111111111010001
case 0xB4 :  *lenght=16; *out=0xFFD2; break; //1111111111010010
case 0xB5 :  *lenght=16; *out=0xFFD3; break; //1111111111010011
case 0xB6 :  *lenght=16; *out=0xFFD4; break; //1111111111010100
case 0xB7 :  *lenght=16; *out=0xFFD5; break; //1111111111010101
case 0xB8 :  *lenght=16; *out=0xFFD6; break; //1111111111010110
case 0xB9 :  *lenght=16; *out=0xFFD7; break; //1111111111010111
case 0xBA :  *lenght=16; *out=0xFFD8; break; //1111111111011000
case 0xC1 :  *lenght=10; *out=0xFFFA; break; //1111111010
case 0xC2 :  *lenght=16; *out=0xFFD9; break; //1111111111011001
case 0xC3 :  *lenght=16; *out=0xFFDA; break; //1111111111011010
case 0xC4 :  *lenght=16; *out=0xFFDB; break; //1111111111011011
case 0xC5 :  *lenght=16; *out=0xFFDC; break; //1111111111011100
case 0xC6 :  *lenght=16; *out=0xFFDD; break; //1111111111011101
case 0xC7 :  *lenght=16; *out=0xFFDE; break; //1111111111011110
case 0xC8 :  *lenght=16; *out=0xFFDF; break; //1111111111011111
case 0xC9 :  *lenght=16; *out=0xFFE0; break; //1111111111100000
case 0xCA :  *lenght=16; *out=0xFFE1; break; //1111111111100001
case 0xD1 :  *lenght=11; *out=0xFFF8; break; //11111111000
case 0xD2 :  *lenght=16; *out=0xFFE2; break; //1111111111100010
case 0xD3 :  *lenght=16; *out=0xFFE3; break; //1111111111100011
case 0xD4 :  *lenght=16; *out=0xFFE4; break; //1111111111100100
case 0xD5 :  *lenght=16; *out=0xFFE5; break; //1111111111100101
case 0xD6 :  *lenght=16; *out=0xFFE6; break; //1111111111100110
case 0xD7 :  *lenght=16; *out=0xFFE7; break; //1111111111100111
case 0xD8 :  *lenght=16; *out=0xFFE8; break; //1111111111101000
case 0xD9 :  *lenght=16; *out=0xFFE9; break; //1111111111101001
case 0xDA :  *lenght=16; *out=0xFFEA; break; //1111111111101010
case 0xE1 :  *lenght=16; *out=0xFFEB; break; //1111111111101011
case 0xE2 :  *lenght=16; *out=0xFFEC; break; //1111111111101100
case 0xE3 :  *lenght=16; *out=0xFFED; break; //1111111111101101
case 0xE4 :  *lenght=16; *out=0xFFEE; break; //1111111111101110
case 0xE5 :  *lenght=16; *out=0xFFEF; break; //1111111111101111
case 0xE6 :  *lenght=16; *out=0xFFF0; break; //1111111111110000
case 0xE7 :  *lenght=16; *out=0xFFF1; break; //1111111111110001
case 0xE8 :  *lenght=16; *out=0xFFF2; break; //1111111111110010
case 0xE9 :  *lenght=16; *out=0xFFF3; break; //1111111111110011
case 0xEA :  *lenght=16; *out=0xFFF4; break; //1111111111110100
case 0xF0 :  *lenght=11; *out=0xFFF9; break; //11111111001
case 0xF1 :  *lenght=16; *out=0xFFF5; break; //1111111111110101
case 0xF2 :  *lenght=16; *out=0xFFF6; break; //1111111111110110
case 0xF3 :  *lenght=16; *out=0xFFF7; break; //1111111111110111
case 0xF4 :  *lenght=16; *out=0xFFF8; break; //1111111111111000
case 0xF5 :  *lenght=16; *out=0xFFF9; break; //1111111111111001
case 0xF6 :  *lenght=16; *out=0xFFFA; break; //1111111111111010
case 0xF7 :  *lenght=16; *out=0xFFFB; break; //1111111111111011
case 0xF8 :  *lenght=16; *out=0xFFFC; break; //1111111111111100
case 0xF9 :  *lenght=16; *out=0xFFFD; break; //1111111111111101
case 0xFA :  *lenght=16; *out=0xFFFE; break; //1111111111111110
#ifndef __MICROBLAZE
default : printf("WAARDE STAAT NIET IN TABEL!!!!!!!!!!!!!!!!!!!!\n");break;
#endif
        }
  //      printf("magnitude= %x out= %x lenght= %d \n",magnitude,*out,*lenght);
        return;
 #endif
  
}
//===========================================================================
char Extend (char additional, unsigned char magnitude)
{
        int vt= 1 << (magnitude-1);
        if ( additional < vt ) return (additional + (-1 << magnitude) + 1);
        else return additional;
}
//===========================================================================
void ReverseExtend (char value, unsigned char *magnitude, unsigned char *bits)
{
 //	printf("reverseextend value= %d\n",*magnitude);
	if (value >=0)
	{
		*bits=value;
	}
	else
	{
		value=-value;
		*bits=~value;
	}
	*magnitude=0;
	while (value !=0)
	{
		value>>=1;
		++*magnitude;
	}
 //	printf("reverseextend magnitude= %d bits= %d",magnitude,bits);
	return;
}
//===========================================================================
void WriteRawBits16(unsigned char amount_bits, unsigned int bits)     //*remaining needs bo be more than 8 bits because 8 bits could be added and ther ecould already be up ot 7 bits in *remaining
// this function collects bits to send
// if there less than 16 bits collected, nothing is send and these bits are stored in *remaining. In *amount_remaining there is stated how much bits are stored in *remaining
// if more than 16 bits are collected, 16 bits are send and the remaining bits are stored again
{
        unsigned short int send;
        unsigned int mask;
        unsigned char send2;
        int count;
        mask=0x00;                                                              //init mask
        vlc_remaining=(vlc_remaining<<amount_bits);                                   //shift to make place for the new bits
        for (count=amount_bits; count>0; count--) mask=(mask<<1)|0x01;          //create mask for adding bit
        vlc_remaining=vlc_remaining | (bits&mask);                                    //add bits
        vlc_amount_remaining=vlc_amount_remaining + amount_bits;                      //change *amount_remaining to the correct new value
        if (vlc_amount_remaining >= 16)                                            //are there more than 16 bits in buffer, send 16 bits
        {
#ifndef __MICROBLAZE        
if (vlc_amount_remaining >= 32 ) printf("ERROR, more bits to send %d",vlc_amount_remaining);
#endif
                send=vlc_remaining>>(vlc_amount_remaining-16);                        //this value can be send/stored (in art this can be dony by selecting bits)
                send2=(send & 0xFF00) >>8;
		  vlc_output_byte(send2);
//                fwrite(&send2,1,1,file);
                if (send2==0xFF)
                {
                        send2=0x00;
		  vlc_output_byte(send2);
//                        fwrite(&send2,1,1,file);
                }
                send2=send & 0xFF;
		  vlc_output_byte(send2);
//                fwrite(&send2,1,1,file);
                if (send2==0xFF)
                {
                        send2=0x00;
		  	   vlc_output_byte(send2);
//                        fwrite(&send2,1,1,file);
                }
                vlc_amount_remaining=vlc_amount_remaining-16;                         //descrease by 16 because these are send
        }
        return;
}
//===========================================================================
void HuffmanEncodeFinishSend()
// There are still some bits left to send at the end of the 8x8 matrix (or maybe the file),
// the remaining bits are filled up with ones and send
// possible fault: -must it be filled up with ones?
{
        unsigned short int send;
        unsigned int mask;
        int  count;
        mask=0x00;                                                              //init mask
        if (vlc_amount_remaining >= 8)                                             //2 bytes to send, send first byte
        {
                send=vlc_remaining>>(vlc_amount_remaining-8);                         //shift so that first byte is ready to send
		  vlc_output_byte(send&0xff);
//                fwrite(&send,1,1,file);
                if (send==0xFF)                                                 //is this still needed????
                {
                        send=0x00;
			   vlc_output_byte(send&0xff);
//                        fwrite(&send,1,1,file);
                }
                vlc_amount_remaining=vlc_amount_remaining -8;                         // lower the value to the amount of bits that still needs to be send
        }
        if (vlc_amount_remaining >= 0)                                             //there is a last byte to send
        {
                send=vlc_remaining<<(8-vlc_amount_remaining);                         //shift the last bits to send to the front of the byte
                mask=0x00;                                                      //init mask
                for (count=(8-vlc_amount_remaining); count>0; count--) mask=(mask<<1)|0x01; //create mask to fill byte up with ones
                send=send | mask;                                               //add the ones to the byte
                vlc_output_byte(send&0xff);
//                fwrite(&send,1,1,file);
                vlc_amount_remaining=0x00;                                         //is this needed?
        }
        return;
}
//===========================================================================
void HuffmanEncodeUsingDCTable(unsigned char magnitude)
// Translate magnitude into needed data (from table) and send it
{
        unsigned char send;
        unsigned short int huffmancode, huffmanlengt;
        ConvertDCMagnitudeY(magnitude, &huffmancode, &huffmanlengt);
        WriteRawBits16(huffmanlengt,huffmancode);
   	//printf("Write DC magnitude= %2x \n",magnitude);
        //WriteRawBits16(0x08,magnitude,remaining,amount_remaining, file);
        return;
}
//===========================================================================
void HuffmanEncodeUsingACTable(unsigned char mag)
// Translate magnitude into needed data (from table) and send it
{
        unsigned char send;
        unsigned short int huffmancode, huffmanlengt;
        ConvertACMagnitudeY(mag, &huffmancode, &huffmanlengt);
        WriteRawBits16(huffmanlengt,huffmancode);
        return;
}
//===========================================================================
char EncodeDataUnit(char dataunit[64], unsigned int color)
{
	char difference;
        unsigned char magnitude,zerorun,ii,ert;
        unsigned int bits;
	unsigned char bit_char;
	 char last_dc_value;
                                         //init
  //    PrintMatrix(dataunit) ;
  	last_dc_value = dcvalue[color];
	difference = dataunit[0] - last_dc_value;
	last_dc_value=dataunit[0];
	ReverseExtend(difference, &magnitude,&bit_char);
	bits = bit_char;
	HuffmanEncodeUsingDCTable(magnitude);
        WriteRawBits16(magnitude,bits);
	zerorun=0;
	ii=1;
  	while ( ii < 64 )
	{
		if (dataunit[ii] != 0 )
		{
			while ( zerorun >= 16 )
			{
				HuffmanEncodeUsingACTable(0xF0);
                                zerorun=zerorun-16;
                            //    printf("16 zeros:  %d\n",zerorun);
			}
			ReverseExtend(dataunit[ii],&magnitude,&bit_char);
			bits=bit_char;
                        ert= ((int)zerorun *16);                                     //ERROR !!!!!!!!!!!
                        ert=ert + magnitude;
			HuffmanEncodeUsingACTable(ert);
			WriteRawBits16(magnitude,bits);
                        zerorun=0;
		}
		else zerorun=zerorun+1;
                ii++;
	}
	if ( zerorun != 0 )
        {
                HuffmanEncodeUsingACTable(0x00);
//                printf("NUL DE REST IS NUL\n");
        }
 //       HuffmanEncodeFinishSend(remaining,amount_remaining,file);
 	dcvalue[color] = last_dc_value;
        return 0;
}
