#include "xparameters.h"
#include "xutil.h"
#include "mb_interface.h"
#include "fifo_link.h"

#include "ejpgl.h"
#include "mb-zzq.h"

#define XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID 0
#define XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID 0


unsigned char quantization_table[MATRIX_SIZE][MATRIX_SIZE] ={
        {4, 3, 3, 4, 4, 5, 6, 6},
        {3, 3, 4, 4, 5, 6, 6, 6},
        {4, 4, 4, 4, 5, 6, 6, 6},
        {4, 4, 4, 5, 6, 6, 6, 6},
        {4, 4, 5, 6, 6, 7, 7, 6},
        {4, 5, 6, 6, 6, 7, 7, 6},
        {6, 6, 6, 6, 7, 7, 7, 7},
        {6, 6, 6, 7, 7, 7, 7, 7}
    };

signed char bitstream[NUMBER_OF_PIXELS] ;

int zzq_encode_init_start(int compression) {

	return 0;
	
}

void zzq_encode(signed short pixelmatrix[MATRIX_SIZE][MATRIX_SIZE], int color)
{
    int i, x, y, jumped, deltax, deltay;
    
    x = y = deltax = deltay = jumped = 0;

    for(i=0;i<NUMBER_OF_PIXELS;i++)
    {
                if(pixelmatrix[y][x]>0)
                        bitstream[i] = (pixelmatrix[y][x]>>quantization_table[y][x]);
                else
                        bitstream[i] = -((-pixelmatrix[y][x])>>quantization_table[y][x]);

        if((y == 0) || (y == MATRIX_SIZE-1)) { //on top or bottom side of matrix
                if(!jumped) { //first jump to element on the right
                        x++;
                        jumped = 1;
                } else { //modify direction
                        if(i<(NUMBER_OF_PIXELS>>1)) {
                                deltax = -1;
                                deltay = 1;
                        } else {
                                deltax = 1;
                                deltay = -1;
                        }
                        x += deltax;
                        y += deltay;
                        jumped = 0;
                }
        } else if ((x == 0) || (x == MATRIX_SIZE-1)) { //on left or right side of matrix
                if(!jumped) { //jump to element below
                        y++;
                        jumped = 1;
                } else { //modify direction
                        if(i<(NUMBER_OF_PIXELS>>1)) {
                                deltax = 1;
                                deltay = -1;
                        } else {
                                deltax = -1;
                                deltay = 1;
                        }
                        x += deltax;
                        y += deltay;
                        jumped = 0;
                }
        }
        else {//not on the edges of the matrix
                x += deltax;
                y += deltay;
        }
    }

    EncodeDataUnit(bitstream, color);

}
//---------------------------------------------------------------------------

signed short dctresult[MATRIX_SIZE][MATRIX_SIZE];

int main() {
	int i;
	int result;
	int color;

  zzq_encode_init_start(0);
  vlc_init_start(0);

  for (;;) {

	read_from_fsl(color, XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID);

	if (color == 0xff) {
		HuffmanEncodeFinishSend();
		}
	else {
       	for (i=0; i<64; i++){
              	read_from_fsl(result, XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID);
       		((short*)dctresult)[i] = result;
       		}
       
       	zzq_encode(dctresult, color);
		}

  	}

}
 
