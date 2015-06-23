#include "xparameters.h"
#include "xutil.h"
#include "mb_interface.h"
#include "fifo_link.h"

#include "ejpgl.h"
#include "mb-dct.h"
#include "mb-weights.h"

signed short dctresult[MATRIX_SIZE][MATRIX_SIZE];

#define XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID 0
#define XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID 0

int dct_init_start() {

	return 0;

}

/*
	Function Name: dct

	Operation: Find the 8x8 DCT of an array using separable DCT
	First, finds 1-d DCT along rows, storing the result in inter[][]
	Then, 1-d DCT along columns of inter[][] is found

	Input: pixels is the 8x8 input array

	Output: dct is the 8x8 output array
*/

void dct(signed char pixels[8][8], int color)
{
        FILE * file;
	int inr, inc; 		/* rows and columns of input image */
	int intr, intc;		/* rows and columns of intermediate image */
	int outr, outc;		/* rows and columns of dct */
	int f_val;		/* cumulative sum */
	int inter[8][8];	/* stores intermediate result */
	int i,j,k;
        k=0;
    //    file = fopen("weights.h","w+");
      //  fprintf(file,"double weights1[512] = {");
	/* find 1-d dct along rows */
 	for (intr=0; intr<8; intr++)
		for (intc=0; intc<8; intc++) {
			for (i=0,f_val=0; i<8; i++) {

			      	f_val += (pixels[intr][i]* weights[k]);//cos((double)(2*i+1)*(double)intc*PI/16);
                                k++;
                          //     fprintf(file, "\n%.0f,",cos((double)(2*i+1)*(double)intc*PI/16)*16384);
			}
                        if (intc!=0)
                                inter[intr][intc] =  f_val>>15;
                        else
                                inter[intr][intc] =  (11585*(f_val>>14))>>15;

                }
   //     fprintf(file,"\n};");
   //     fclose(file);
         k=0;
	/* find 1-d dct along columns */
 	for (outc=0; outc<8; outc++)
		for (outr=0; outr<8; outr++) {
			for (i=0,f_val=0; i<8; i++) {
				f_val += (inter[i][outc] *weights[k]);
                                k++;
			}
                        if (outr!=0)
			        dctresult[outr][outc] = f_val>>15;
                        else
                                dctresult[outr][outc] = (11585*(f_val>>14)>>15);
		}

}



/*****************************************************************
    UNCOMMENT THIS SECTION TO TEST 2D DCT 
*****************************************************************/

signed char ipixels[8][8];

main()
{
  
  unsigned int i,j;
  int result;
  int color;

  dct_init_start();

  for (;;) {
	read_from_fsl(color, XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID);

	if (color==0xff) {
         	write_into_fsl(color, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
		}
	else {
         	for (i=0; i<64; i++) {
                	read_from_fsl(result, XPAR_FSL_FIFO_LINK_0_INPUT_SLOT_ID);
         		((signed char*)ipixels)[i]=result;
         		}
         
              dct(ipixels, color);
         
         	write_into_fsl(color, XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
         	
         	for (i=0; i<64; i++) {
                	write_into_fsl(((short*)dctresult)[i], XPAR_FSL_FIFO_LINK_0_OUTPUT_SLOT_ID);	
         		}
           	}

	}

}
