#include "xutil.h"
#include "mb_interface.h"
#include "fifo_link.h"

#include "ejpgl.h"
#include "io.h"

#define XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID 0
#define XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID 0


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

signed char pixelmatrix[MACRO_BLOCK_SIZE][MACRO_BLOCK_SIZE*3];
signed char YMatrix[MATRIX_SIZE][MATRIX_SIZE];
signed char CrMatrix[MATRIX_SIZE][MATRIX_SIZE];
signed char CbMatrix[MATRIX_SIZE][MATRIX_SIZE];

main() {
  unsigned int i,j;
  int result;
  int sample;
  int color;
  int msg;

  for (;;) {
  		read_from_fsl(msg, XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID);
		if (msg == 0xff) {
			write_into_fsl(color, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
			continue;
			}

         	for (i=0; i<MACRO_BLOCK_SIZE*MACRO_BLOCK_SIZE*3; i++) {
                	read_from_fsl(result, XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID);
         		((signed char*)pixelmatrix)[i]=result;
         		}
			
  		for(sample=0;sample<5;sample++) {
			if(sample<4) {
				RGB2YCrCb(pixelmatrix,YMatrix,CrMatrix,CbMatrix,sample);
				color = 0;						//Y-encoding
				write_into_fsl(color, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
                       	for (i=0; i<MATRIX_SIZE*MATRIX_SIZE; i++) {
              			result = ((signed char*)YMatrix)[i];
                              	write_into_fsl(result, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
                       		}
				} else {

				color = 1;						//Cr-encoding
				write_into_fsl(color, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
                       	for (i=0; i<MATRIX_SIZE*MATRIX_SIZE; i++) {
              			result = ((signed char*)CrMatrix)[i];
                              	write_into_fsl(result, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
                       		}
				color = 2;						//Cb-encoding
				write_into_fsl(color, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
							//Cb-encoding
                       	for (i=0; i<MATRIX_SIZE*MATRIX_SIZE; i++) {
              			result = ((signed char*)CbMatrix)[i];
                              	write_into_fsl(result, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
                       		}
				}

			}
       
	}

}
