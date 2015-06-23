#include <stdio.h>
#include "xutil.h"
#include "mb_interface.h"
#include "fifo_link.h"

#include "ejpgl.h"
#include "io.h"

#define XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID 0
#define XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID 0

void put_char(unsigned char c);

int cc_init_start() {

	return 0;
	
}

void check_fsl() {
	unsigned long result;
	unsigned long status;
	unsigned char ch;

	for (;;) {
       	microblaze_nbread_datafsl(result, 0);
       	asm volatile ("mfs %0, rmsr" : "=d" (status));
       	if (status & 0x80000000) return;
//       	xil_printf("-->%x-%x\r\n", result, status);
       	ch = result;
       	put_char(ch);
		}
	return;

}

void RGB2YCrCb(signed char pixelmatrix[MACRO_BLOCK_SIZE][MACRO_BLOCK_SIZE*3],signed char YMatrix[MATRIX_SIZE][MATRIX_SIZE],signed char CrMatrix[MATRIX_SIZE][MATRIX_SIZE],signed char CbMatrix[MATRIX_SIZE][MATRIX_SIZE], unsigned int sample)
{
	int i;
	int result;
	int msg;

	msg = 0;
       write_into_fsl(msg, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	

	for (i=0; i<MACRO_BLOCK_SIZE*MACRO_BLOCK_SIZE*3; i++) {
 	   	check_fsl();
		result = ((signed char*)pixelmatrix)[i];
        	write_into_fsl(result, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
		}
	   	check_fsl();

}

int cc_end_done() {
	int msg;

	msg=0xff;

	write_into_fsl(msg, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
	return 0;

}

#if 0

#define RGB2Y(r, g, b)     (((66*r + 129*g + 25*b + 128)>>8)+128)
#define RGB2Cr(r, g, b)    (((-38*r - 74*g + 112*b + 128)>>8)+128)
#define RGB2Cb(r, g, b)   (((112*r - 94*g - 18*b + 128)>>8)+128)

void RGB2YCrCb(signed char pixelmatrix[MACRO_BLOCK_SIZE][MACRO_BLOCK_SIZE*3],signed char YMatrix[MATRIX_SIZE][MATRIX_SIZE],signed char CrMatrix[MATRIX_SIZE][MATRIX_SIZE],signed char CbMatrix[MATRIX_SIZE][MATRIX_SIZE], unsigned int sample)
{
	unsigned int row, col, rowoffset, coloffset, xoffset, yoffset;
	for(row = 0;row < MATRIX_SIZE; row++) {
		for(col = 0; col < MATRIX_SIZE; col++) {
			coloffset = (sample&0x01)*8;
			rowoffset = (sample&0x02)*4;
			YMatrix[row][col] = RGB2Y(pixelmatrix[row+rowoffset][(col+coloffset)*3+2],pixelmatrix[row+rowoffset][(col+coloffset)*3+1],pixelmatrix[row+rowoffset][(col+coloffset)*3]) - 128;
			if (col%2==0) {
				yoffset = (sample&0x01)*4;
				xoffset = (sample&0x02)*2;
				if (row%2==0) {
					CrMatrix[xoffset+(row>>1)][yoffset+(col>>1)] = RGB2Cr(pixelmatrix[row+rowoffset][(col+coloffset)*3+2],pixelmatrix[row+rowoffset][(col+coloffset)*3+1],pixelmatrix[row+rowoffset][(col+coloffset)*3]) - 128;
				} else {
					CbMatrix[xoffset+((row)>>2)][yoffset+(col>>2)] = RGB2Cb(pixelmatrix[row+rowoffset][(col+coloffset)*3+2],pixelmatrix[row+rowoffset][(col+coloffset)*3+1],pixelmatrix[row+rowoffset][(col+coloffset)*3]) - 128;
				}
			}
		}
	}
}

#endif

