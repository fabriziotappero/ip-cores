#ifndef _IO_H
#define _IO_H 1

#include "ejpgl.h"

typedef struct {
   unsigned int size;               /* Header size in bytes      */
   int width,height;                /* Width and height of image */
   unsigned short int planes;       /* Number of colour planes   */
   unsigned short int bits;         /* Bits per pixel            */
   unsigned int compression;        /* Compression type          */
   unsigned int imagesize;          /* Image size in bytes       */
   int xresolution,yresolution;     /* Pixels per meter          */
   unsigned int ncolours;           /* Number of colours         */
   unsigned int importantcolours;   /* Important colours         */
   unsigned char palette[1024];      /* Storage for palette       */
} INFOHEADER;

typedef struct {
   int restofheader; //TODO
   INFOHEADER info;                 /* Information header        */
} BMPHEADER;

typedef struct {
   unsigned int row;     /* Width and height of image */
   unsigned int col;   /* Width and height of image */
} BLOCKINFO;

typedef struct {
        unsigned char QTMarker[2];
        unsigned char Length[2];
        unsigned char QTInfo[130]; //bit 0..3: number of QT (0..3, otherwise error)
                                //     bit 4..7: precision of QT, 0 = 8 bit, otherwise 16 bit
    //    unsigned char ValuesQT[]; //max 192 values. 64*(precision+1) bytes
} QTINFO;

typedef struct {
            unsigned char HTMarker[2];
            unsigned char Length[2];
            unsigned char HuffmanInfo[416]; //Array containing ALL huffman information
            //For each color component holds:
                    //First byte is used as info byte, followed by 16 bytes with values used
                    //for counting the different huffman codes, finally the corresponding
                    //huffman codes will follow. This sequence can repeat it self for
                    //different Huffman tables, both DC or AC tables.

                    //The structure of the information byte is as follows:
                    //bit 0..3 : number of HT (0..3, otherwise error)
                    //bit 4     : type of HT, 0 = DC table, 1 = AC table
                    //bit 5..7 : not used, must be 0 (Used for  progressive scan JPEG)
} HTINFO;


typedef struct {
            unsigned char APP0Marker[2];
            unsigned char Length[2];
            unsigned char Identifier[5];
            unsigned char Version[2];
            unsigned char Units;
            unsigned char XDensity[2];
            unsigned char YDensity[2];
            unsigned char ThumbWidth;
            unsigned char ThumbHeight;
} APP0INFO;

typedef struct {
            unsigned char SOF0Marker[2];
            unsigned char Length[2];
            unsigned char DataPrecision; //This is in bits/sample, usually 8 (12 and 16 not supported by most software).
            unsigned char ImageHeight[2];
            unsigned char ImageWidth[2];
            unsigned char Components; //Usually 1 = grey scaled, 3 = color YcbCr or YIQ 4 = color CMYK
            unsigned char ComponentInfo[3][3]; //Read each component data of 3 bytes. It contains,
                                       //(component Id(1byte)(1 = Y, 2 = Cb, 3 = Cr, 4 = I, 5 = Q),
                                         //sampling factors (1byte) (bit 0-3 vertical., 4-7 horizontal.),
                                           //quantization table number (1 byte)).
} SOF0INFO;

typedef struct {
            unsigned char SOSMarker[2];
            unsigned char Length[2]; //This must be equal to 6+2*(number of components in scan).
            unsigned char ComponentCount; //This must be >= 1 and <=4 (otherwise error), usually 1 or 3
            unsigned char Component[3][2]; // For each component, read 2 bytes. It contains,
                                          //1 byte   Component Id (1=Y, 2=Cb, 3=Cr, 4=I, 5=Q),
                                            //1 byte   Huffman table to use :
                                              //bit 0..3 : AC table (0..3)
                                                //bit 4..7 : DC table (0..3)
            unsigned char Ignore[3]; //We have to skip 3 bytes
} SOSINFO;

typedef struct {
            unsigned char DRIMarker[2];
            unsigned char Length[2];
            unsigned char RestartInteral[2]; // Interval of the restart markers
} DRIINFO;

typedef struct {
            unsigned char SOIMarker[2]; //Start of image marker
            APP0INFO app0;
            QTINFO qt;
            SOF0INFO sof0;
            HTINFO ht;
//            DRIINFO dri;
            SOSINFO sos;
} JPEGHEADER;

/*
 * Read BMP header and return it in header, for now only the width and height
 * are returned, since the other values are of no use.
 */
int getbmpheader(FILE * file, INFOHEADER *header);

int getjpegheader(FILE * file, JPEGHEADER *header);

void writebmpheader(FILE * file, BMPHEADER *header);

void writejpegheader(FILE * file, INFOHEADER *header);

void writejpegfooter(FILE * file);

/*
 * Read BMP to retrieve 8*8 block starting at horizontal position mcol*8, and
 * vertical position mrow*8 in the image. This block is returned in pixelmatrix.
 *
 */
void RGB2YCrCb(signed char pixelmatrix[MACRO_BLOCK_SIZE][MACRO_BLOCK_SIZE*3],signed char YMatrix[MATRIX_SIZE][MATRIX_SIZE],signed char CrMatrix[MATRIX_SIZE][MATRIX_SIZE],signed char CbMatrix[MATRIX_SIZE][MATRIX_SIZE], unsigned int sample);

void readjpegfile(FILE * file, unsigned char bitstream[]);

void writebmpfile(FILE * file, unsigned char pixelmatrix[MATRIX_SIZE][MATRIX_SIZE], unsigned int mrow, unsigned int mcol, unsigned int width);

void writejpegfile(FILE * file, unsigned char bitstream[]);
#else
#error "ERROR file io.h multiple times included"
#endif /* --- _IO_H --- */

