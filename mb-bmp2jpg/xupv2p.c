#ifdef __XUPV2P

//  Microblaze related declaration

#include <xparameters.h>
#include <sysace_stdio.h>

#include "xio.h"

#include "ejpgl.h"

#define __MICROBLAZE
#define __BIGENDIAN

// XUPV2P board related declaration 

#define BMP_ADDRESS  0x30000000
#define BMP_MAXSIZE   4*1024*1024


SYSACE_FILE *infile;
SYSACE_FILE *outfile;

char* bmpimage;
int bmpsize;

INFOHEADER _bmpheader;
INFOHEADER *bmpheader;
JPEGHEADER _jpegheader;

int getbmpheader(INFOHEADER *header);
void writejpegfooter();


unsigned long htonl(unsigned long x) {

	return ((((x)&0xff000000)>>24) | (((x)&0x00ff0000)>>8) | (((x)&0x0000ff00)<<8) | (((x)&0x000000ff)<<24));
		
}

unsigned short hton(unsigned short x) {

	return ((((x) & 0xff00)>>8) | (((x) &0x00ff)<<8));

}


int openBMPJPG(int argc, char* bmpfilename, char* jpgfilename) {
	int jpegheadersize;
	
	bmpimage=(unsigned char*)BMP_ADDRESS;
  	bmpsize=0;

  	xil_printf("\r\nBMP2JPG Code Compiled at %s %s\r\n", __DATE__, __TIME__);
	
	bmpfilename = "image01.bmp";  // argc argv is not accepted on XUPV2P yet
	jpgfilename = "image01.jpg";

  	bmpheader=&_bmpheader;

  	if ((infile = sysace_fopen(bmpfilename, "r")) == NULL) {   // not "rb"
       	xil_printf("\n\r%s is not a valid BMP-file",bmpfilename);
	  	exit(0);
  	}

  	bmpsize = sysace_fread(bmpimage, 1, BMP_MAXSIZE, infile);
  	xil_printf("bmpsize %d\r\n", bmpsize);
  	if (bmpsize==BMP_MAXSIZE) {
       	xil_printf("\n\r%s is too large",bmpfilename);
	  	exit(0);
  	}


  	if (getbmpheader(bmpheader) == 0) { //File is a valid BMP
       	xil_printf("\r\n%s is not a valid BMP-file",bmpfilename);
	  	exit(0);
  	}
  
	xil_printf("Image width: %d pixels\r\n", bmpheader->width);
	xil_printf("Image height: %d pixels\r\n", bmpheader->height);

       outfile = sysace_fopen(jpgfilename, "w");  // not "wb"
  	if (outfile == NULL) {
       	xil_printf("\r\nerror in writing jpg header");
	  	exit(0);
  		}
  
    	jpegheadersize = writejpegheader(bmpheader, &_jpegheader);
	if (jpegheadersize == 0) return 0;
   
    	sysace_fwrite(&_jpegheader,jpegheadersize,1,outfile);
	 
  	return 1;

}

int closeBMPJPG() {
  	unsigned int col, cols, row, rows;

	rows = bmpheader->height>>4;
       cols = bmpheader->width>>4;
       xil_printf("\r\nProcessed more than %d %dx%d-blocks.",(row-1)*cols,MATRIX_SIZE,MATRIX_SIZE);  // +col
  
     	writejpegfooter();

	sysace_fclose(outfile);
	sysace_fclose(infile);

	return 0;
	
}

static unsigned char buffer[MACRO_BLOCK_SIZE*3];  // move array on main memory

void get_MB(int mb_row, int mb_col, signed char pixelmatrix[MACRO_BLOCK_SIZE][MACRO_BLOCK_SIZE*3]) {
       unsigned int row, col;
	int offset;
	
        for(row = 0;row < MACRO_BLOCK_SIZE; row++) {
//		offset = bmpsize-3*bmpheader->width*(row + 1 + mb_row*MATRIX_SIZE)+MATRIX_SIZE*3*mb_col;
//		memcpy(pixelmatrix[row], bmpimage + offset, MATRIX_SIZE*3);
		offset = bmpsize-3*bmpheader->width*(row + 1 + mb_row*MACRO_BLOCK_SIZE)+MACRO_BLOCK_SIZE*3*mb_col;
		memcpy(buffer, bmpimage + offset, MACRO_BLOCK_SIZE*3);
			for(col = 0; col < MACRO_BLOCK_SIZE*3; col++) {
				pixelmatrix[row][col] = buffer[col]- 128;
			}
        }

}

void put_char(unsigned char c) {

	sysace_fwrite(&c, 1, 1, outfile);

}


int getbmpheader(INFOHEADER *header)
{
       memcpy(header, bmpimage+14, sizeof(INFOHEADER));

#if defined(__BIGENDIAN)      // for Big Endian processors

	header->size = htonl(header->size);
	header->width = htonl(header->width);
	header->height = htonl(header->height);
	header->planes = hton(header->planes);
	header->bits = hton(header->bits);
	header->compression = htonl(header->compression);
	header->imagesize = htonl(header->imagesize);
	header->xresolution = htonl(header->xresolution);
	header->yresolution= htonl(header->yresolution);
	header->ncolours= htonl(header->ncolours);
	header->importantcolours= htonl(header->importantcolours);

#endif

        return 1;

}

void writejpegfooter()
{
        unsigned char footer[2];
        footer[0] = 0xff;
        footer[1] = 0xd9;
//        fseek(file,0,SEEK_END);
        sysace_fwrite(footer,sizeof(footer),1, outfile);

}







#endif



