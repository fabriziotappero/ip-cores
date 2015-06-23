#include <stdio.h>
#include <stdlib.h>

#include "ejpgl.h"
#include "mb.h"

#include "zzq.h" 
#include "io.h"
#include "huffman.h"
#include "dct.h"

#ifndef __MICROBLAZE
#error This code is for Micrblaze processor only
#endif

char* bmpimage;
int bmpsize;

INFOHEADER _bmpheader;
INFOHEADER *bmpheader;
JPEGHEADER _jpegheader;
JPEGHEADER *jpegheader;

SYSACE_FILE *infile;
SYSACE_FILE *outfile;

unsigned char qtable[64] = {16, 8, 8, 16, 12, 8, 16, 16, 16, 16, 16, 16, 16, 16,
16, 32, 32, 16, 16, 16, 16, 32, 32, 32, 32, 32, 64, 64, 64, 64, 64, 64, 64, 64, 64,
64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 128, 64, 64, 128, 128, 128, 128, 128, 64, 64,
128, 128, 128, 128, 128, 64, 128, 128, 128};

unsigned char huffmancount[4][16] = {{0x00,0x01,0x05,0x01,0x01,0x01,0x01,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00},  //standard DC table count
                                    {0x00,0x02,0x01,0x03,0x03,0x02,0x04,0x03,0x05,0x05,0x04,0x04,0x00,0x00,0x01,0x7D},   //standard AC table count
                                    {0x00,0x01,0x05,0x01,0x01,0x01,0x01,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00},  //standard DC table count
                                    {0x00,0x02,0x01,0x03,0x03,0x02,0x04,0x03,0x05,0x05,0x04,0x04,0x00,0x00,0x01,0x7D}};  //standard AC table count

unsigned char huffDCvalues[12] ={0x00,  0x01,  0x02,  0x03,  0x04,  0x05,  0x06,  0x07,  0x08,  0x09,  0x0a,  0x0b};// {0x00, 0x02, 0x03, 0x04, 0x05, 0x06, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E};
unsigned char huffACvalues[162] = {0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21, 0x31, 0x41, 0x06, 0x13, 0x51, 0x61, 0x07, 0x22, 0x71,
                                0x14, 0x32, 0x81, 0x91, 0xA1, 0x08, 0x23, 0x42, 0xB1, 0xC1, 0x15, 0x52, 0xD1, 0xF0, 0x24, 0x33, 0x62, 0x72, 0x82,
                                0x09, 0x0A, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39,
                                0x3A, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x63, 0x64,
                                0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x83, 0x84, 0x85, 0x86, 0x87,
                                0x88, 0x89, 0x8A, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8,
                                0xA9, 0xAA, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xB9, 0xBA, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9,
                                0xCA, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9,
                                0xEA, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA};


signed char pixelmatrix[MACRO_BLOCK_SIZE][MACRO_BLOCK_SIZE*3];
signed char YMatrix[MATRIX_SIZE][MATRIX_SIZE];
signed char CrMatrix[MATRIX_SIZE][MATRIX_SIZE];
signed char CbMatrix[MATRIX_SIZE][MATRIX_SIZE];

int ejpgl_error(int errno, void* remark);

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

unsigned long htonl(unsigned long x) {

	return ((((x)&0xff000000)>>24) | (((x)&0x00ff0000)>>8) | (((x)&0x0000ff00)<<8) | (((x)&0x000000ff)<<24));
		
}

unsigned short hton(unsigned short x) {

	return ((((x) & 0xff00)>>8) | (((x) &0x00ff)<<8));

}


int main()
{
  SYSACE_FILE* outfile2;
  
  int i;
  unsigned int col, cols, row, rows;
  int compression;
  int sample;
  char* bmpfilename = "image01.bmp";
  char* jpgfilename = "image01.jpg";
  int bmpsizelimit = 2*1024*1024;

  compression = 0;
 
//  bmpimage=(unsigned char*)0x70000000;
  bmpimage=(unsigned char*)0x30000000;
  bmpsize=0;

  xil_printf("\r\nBMP2JPG Code Compiled at %s %s\r\n", __DATE__, __TIME__);

  bmpheader=&_bmpheader;

  if ((infile = sysace_fopen(bmpfilename, "r")) == NULL) {
  	ejpgl_error(eOPENINPUT_FILE, 0);
  	}

  xil_printf("File name %s\r\n", bmpfilename);
  bmpsize = sysace_fread(bmpimage, 1, bmpsizelimit, infile);
  xil_printf("bmpsize %d\r\n", bmpsize);
  if (bmpsize==bmpsizelimit) {
  	ejpgl_error(eLARGE_INPUTFILE, 0);
  	}

/*  if ((outfile2 = sysace_fopen("image01b.bmp", "w")) == NULL) {   // see if the BMP file is correctly read into memory
	ejpgl_error(eOPENOUTPUT_FILE, 0);
  	}
  
  sysace_fwrite(bmpimage, 1, bmpsize, outfile2);
  sysace_fclose(outfile2); */
  
  if (getbmpheader(infile,bmpheader) == 0) { //File is a valid BMP
  	ejpgl_error(eINVALID_BMP, 0);
  	}
  
  xil_printf("Image width: %d pixels\r\n", bmpheader->width);
  xil_printf("Image height: %d pixels\r\n", bmpheader->height);

  rows = bmpheader->height>>4; // 3;
  cols = bmpheader->width>>4; // 3;

  if ((outfile = sysace_fopen(jpgfilename, "w")) == NULL) {
  	ejpgl_error(eOPENOUTPUT_FILE, 0);
 	} 
  
  writejpegheader(outfile,bmpheader);

  dct_init_start();
  zzq_encode_init_start(compression);
  vlc_init_start();

   for (row = 0; row < rows; row++) {
   	for (col = 0; col < cols; col++) {
		get_MB(row, col, pixelmatrix);

		RGB2YCrCb(pixelmatrix,YMatrix,CrMatrix,CbMatrix,sample);


#if 0

// dct->zz/q->vlc		dct call zz/q call vlc

/*		RGB2Y_matrix(pixelmatrix, pmatrix2);
		dct(pmatrix2, 0);
		RGB2Cr_matrix(pixelmatrix, pmatrix2);
		dct(pmatrix2, 1);
		RGB2Cb_matrix(pixelmatrix, pmatrix2);
		dct(pmatrix2, 2); */
					for(sample=0;sample<5;sample++) {
						if(sample<4) {
							RGB2YCrCb(pixelmatrix,YMatrix,CrMatrix,CbMatrix,sample);
							//Y-encoding
							dct(YMatrix,0);
						} else {
							//Cr-encoding
							dct(CrMatrix,1);
							//Cb-encoding
							dct(CbMatrix,2);							
						}
					}
#endif		
	}
   }
						
   vlc_end_done();
   zzq_encode_end_done();
   dct_end_done();
   cc_end_done();


   xil_printf("\r\nProcessed %d %dx%d-blocks.\r\n",(row-1)*cols+col,MATRIX_SIZE,MATRIX_SIZE);
   writejpegfooter(outfile);
   
   
   sysace_fclose(outfile);
   sysace_fclose(infile);
   return 0;

}

int ejpgl_error(int errno, void* remark) {

	xil_printf("--> Error %d\r\n", errno);
	exit(1);

}

int getbmpheader(FILE * file, INFOHEADER *header)
{
       memcpy(header, bmpimage+14, sizeof(INFOHEADER));

#if defined(__MICROBLAZE)      // for Big Endian processors

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

void writejpegheader(FILE * file, INFOHEADER *header)
{
        JPEGHEADER *jpegheader;
        unsigned int headersize, huffmantablesize, previoussize;
        unsigned char QTcount, i, j, components, id, huffmantablecount;
        unsigned short length, headerlength;

        //Number of Quatization Tables
        QTcount = 2;
        headerlength = 12; //12 bytes are needed for the markers
        huffmantablecount = 4;  //2 AC and 2 DC tables
        huffmantablesize = 0;
        jpegheader = &_jpegheader;//(JPEGHEADER *)malloc(550);

        jpegheader->SOIMarker[0] = 0xff;
        jpegheader->SOIMarker[1] = 0xd8;

        //APP0 segment
        jpegheader->app0.APP0Marker[0] = 0xff;
        jpegheader->app0.APP0Marker[1] = 0xe0;

        headerlength += 16; //APP0 marker is always 16 bytes long
        jpegheader->app0.Length[0] = 0x00;
        jpegheader->app0.Length[1] = 0x10;
        jpegheader->app0.Identifier[0] = 0x4a;
        jpegheader->app0.Identifier[1] = 0x46;
        jpegheader->app0.Identifier[2] = 0x49;
        jpegheader->app0.Identifier[3] = 0x46;
        jpegheader->app0.Identifier[4] = 0x00;
        jpegheader->app0.Version[0] = 0x01;
        jpegheader->app0.Version[1] = 0x00;
        jpegheader->app0.Units = 0x00;
        jpegheader->app0.XDensity[0] = 0x00;
        jpegheader->app0.XDensity[1] = 0x01;
        jpegheader->app0.YDensity[0] = 0x00;
		jpegheader->app0.YDensity[1] = 0x01;
        jpegheader->app0.ThumbWidth = 0x00;
        jpegheader->app0.ThumbHeight = 0x00;

        //Quantization Table Segment
        jpegheader->qt.QTMarker[0] = 0xff;
        jpegheader->qt.QTMarker[1] = 0xdb;
        length = (QTcount<<6) + QTcount + 2;
        headerlength += length;
        jpegheader->qt.Length[0] = (length & 0xff00)>>8;
        jpegheader->qt.Length[1] = length & 0xff;
       // jpegheader->qt.QTInfo = 0x00; // index = 0, precision = 0
        //write Quantization table to header
        i = 0;
    /*     jpegheader->qt.QTInfo[0] = 0;
        for(i=0;i<64;i++) {
                jpegheader->qt.QTInfo[i+1] = qtable[i];
        }
        jpegheader->qt.QTInfo[65] = 1;
        for(i=0;i<64;i++) {
                jpegheader->qt.QTInfo[i+66] = qtable[i];
        }  */
        for (id=0; id<QTcount; id++) {
                jpegheader->qt.QTInfo[(id<<6)+id] = id;
                for(i=0;i<64;i++) {
                        jpegheader->qt.QTInfo[i+1+id+(id<<6)] = qtable[i];
                }
        }

        //Start of Frame segment
        jpegheader->sof0.SOF0Marker[0] = 0xff;
        jpegheader->sof0.SOF0Marker[1] = 0xc0;
        if(header->bits == 8) {
                components = 0x01;
        }
        else {
                components = 0x03;
		}
        length = 8 + 3*components;
        headerlength += length;
        jpegheader->sof0.Length[0] = (length & 0xff00) >> 8;
        jpegheader->sof0.Length[1] = length & 0xff;
        jpegheader->sof0.DataPrecision = 0x08;
        jpegheader->sof0.ImageHeight[0] = (header->height & 0xff00) >> 8;
        jpegheader->sof0.ImageHeight[1] = header->height & 0xff;
        jpegheader->sof0.ImageWidth[0] = (header->width & 0xff00) >> 8;
        jpegheader->sof0.ImageWidth[1] = header->width & 0xff;
        jpegheader->sof0.Components  = components;
        for (i=0; i < components; i++) {
			jpegheader->sof0.ComponentInfo[i][0] = i+1; //color component
			if(i==0) {
				jpegheader->sof0.ComponentInfo[i][1] = 0x22; //4:2:0 subsampling
			} else {
				jpegheader->sof0.ComponentInfo[i][1] = 0x11; //4:2:0 subsampling
			}
            jpegheader->sof0.ComponentInfo[i][2] = (i==0)? 0x00 : 0x01; //quantization table ID
		}
        //Start of Huffman Table Segment

        jpegheader->ht.HTMarker[0] = 0xff;
        jpegheader->ht.HTMarker[1] = 0xc4;

        //Set dummy HT segment length
        length = 0;//tablecount*17;
        jpegheader->ht.Length[0] = (length & 0xff00) >> 8;
        jpegheader->ht.Length[1] = length & 0xff;
        previoussize = 0;
        for (id=0; id < huffmantablecount; id++) {
            huffmantablesize = 0;
            switch (id) {
            case 0 : jpegheader->ht.HuffmanInfo[previoussize] = 0x00;
                     break;
            case 1 : jpegheader->ht.HuffmanInfo[previoussize] = 0x10;
                     break;
            case 2 : jpegheader->ht.HuffmanInfo[previoussize] = 0x01;
                     break;
            case 3 : jpegheader->ht.HuffmanInfo[previoussize] = 0x11;
                     break;
			}
            for (i=1; i <= 16; i++) {
                    jpegheader->ht.HuffmanInfo[i+previoussize] =  huffmancount[id][i-1];
                    huffmantablesize += huffmancount[id][i-1];
            }

            for (i=0; i < huffmantablesize; i++) {
                    jpegheader->ht.HuffmanInfo[i+previoussize+17] = (id%2 == 1)? huffACvalues[i] : huffDCvalues[i];
            }
            previoussize += huffmantablesize + 17;
        }
        //Set real HT segment length
        length = 2+previoussize;
        headerlength += length;
        jpegheader->ht.Length[0] = (length & 0xff00) >> 8;
        jpegheader->ht.Length[1] = length & 0xff;
        //Reset marker segment
      /*  jpegheader->dri.DRIMarker[0] = 0xff;
        jpegheader->dri.DRIMarker[1] = 0xdd;
        jpegheader->dri.Length[0] = 0x00;
        jpegheader->dri.Length[1] = 0x04;
        jpegheader->dri.RestartInteral[0] = 0x00; //no restart markers
        jpegheader->dri.RestartInteral[1] = 0x00; //no restart markers
        headerlength  += 6;  //length of DRI segment
       */
        //Start of Scan Header Segment
        jpegheader->sos.SOSMarker[0] = 0xff;
        jpegheader->sos.SOSMarker[1] = 0xda;
        length = 6 + (components<<1);
        headerlength += length;
        jpegheader->sos.Length[0] = (length & 0xff00) >> 8;
        jpegheader->sos.Length[1] =  length & 0xff;
        jpegheader->sos.ComponentCount = components; //number of color components in the image
        jpegheader->sos.Component[0][0] = 0x01; //Y component
        jpegheader->sos.Component[0][1] = 0x00; //indexes of huffman tables for Y-component
        if (components == 0x03) {
                jpegheader->sos.Component[1][0] = 0x02; //the CB component
				jpegheader->sos.Component[1][1] = 0x11; //indexes of huffman tables for CB-component
                jpegheader->sos.Component[2][0] = 0x03; //The CR component
                jpegheader->sos.Component[2][1] = 0x11; //indexes of huffman tables for CR-component
        }
        //following bytes are ignored since progressive scan is not to be implemented
        jpegheader->sos.Ignore[0] = 0x00;
        jpegheader->sos.Ignore[1] = 0x3f;
        jpegheader->sos.Ignore[2] = 0x00;

	sysace_fwrite(jpegheader, 1, headerlength, file);
	xil_printf("jpeg header size %x\r\n", headerlength);
	
}

void writejpegfooter(FILE * file)
{
        unsigned char footer[2];
        footer[0] = 0xff;
        footer[1] = 0xd9;
//        fseek(file,0,SEEK_END);
        sysace_fwrite(footer,sizeof(footer),1,file);
}




