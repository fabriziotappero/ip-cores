#include "ejpgl.h"

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

