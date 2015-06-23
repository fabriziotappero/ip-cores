
#ifndef __BMP_H_
#define __BMP_H_

#ifdef WIN32
#include <fcntl.h>
#endif

typedef struct tagBITMAPFILEHEADER {
	unsigned short	bfType;
	unsigned long 	bfSize;
	unsigned short 	bfReserved1;
	unsigned short	bfReserved2;
	unsigned long	bfOffBits;
} BITMAPFILEHEADER;
typedef struct tagBITMAPINFOHEADER {
	unsigned long	biSize;
	signed long	biWidth;
	signed long	biHeight;
	unsigned short	biPlanes;
	unsigned short	biBitCount;
	unsigned long	biCompression;
	unsigned long	biSizeImage;
	signed long	biXPixPerMeter;
	signed long	biYPixPerMeter;
	unsigned long	biClrUsed;
	unsigned long	biClrImporant;
} BITMAPINFOHEADER;
typedef struct tagRGBQUAD {
	unsigned char	rgbBlue;
	unsigned char	rgbGreen;
	unsigned char	rgbRed;
	unsigned char	rgbReserved;
} RGBQUAD;
typedef struct bit_color {
	unsigned char r;
	unsigned char g;
	unsigned char b;
} BITCOLOR;
typedef struct bit_map {
	BITMAPFILEHEADER	bitMapFile;
	BITMAPINFOHEADER	bitMapInfo;
	RGBQUAD			rgbQuad;
	BITCOLOR		bitColor[8192][8192];
} BITMAP;

void BmpRead(BITMAP *bitMap);
void BmpWrite(BITMAP *bitMap);

#endif

