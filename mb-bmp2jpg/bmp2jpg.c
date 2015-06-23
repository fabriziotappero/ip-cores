#include <stdio.h>
#include "ejpgl.h"

extern INFOHEADER *bmpheader;

signed char pixelmatrix[MACRO_BLOCK_SIZE][MACRO_BLOCK_SIZE*3];
signed char YMatrix[MATRIX_SIZE][MATRIX_SIZE];
signed char CrMatrix[MATRIX_SIZE][MATRIX_SIZE];
signed char CbMatrix[MATRIX_SIZE][MATRIX_SIZE];


int main(int argc, char* argv[])
{
	int compression,sample;
	unsigned int col, cols, row, rows;

  	openBMPJPG(argc, argv[1], argv[2]);
 
	rows = bmpheader->height>>4;
       cols = bmpheader->width>>4;

	dct_init_start();
	zzq_encode_init_start(compression);
	vlc_init_start();
				 
       for (row = 0; row < rows; row++) {
      		for (col = 0; col < cols; col++) {
			get_MB(row, col, pixelmatrix);
			for(sample=0;sample<5;sample++) {
				if(sample<4) {
					RGB2YCrCb(pixelmatrix,YMatrix,CrMatrix,CbMatrix,sample);  		
					dct(YMatrix,0);
				} else {
					dct(CrMatrix,1);					
					dct(CbMatrix,2);						
				}
			}
		}
         }
	
	dct_stop_done();
	zzq_encode_stop_done();
	vlc_stop_done();

	closeBMPJPG();
	return 0;
	
}


