
#include <stdio.h>
#include <stdlib.h>

#include "bmp.h"

void BmpRead(BITMAP *bitMap){
	FILE	*fp;
	int	line;
	int	x;
	int	y;
	char	dummy;
#ifdef WIN32
	setmode( fileno(stdin), O_BINARY );
#endif
	fp = stdin;

	fread((char *)&(bitMap->bitMapFile.bfType)		,1,2,fp);
	fread((char *)&(bitMap->bitMapFile.bfSize)		,1,4,fp);
	fread((char *)&(bitMap->bitMapFile.bfReserved1)		,1,2,fp);
	fread((char *)&(bitMap->bitMapFile.bfReserved2) 	,1,2,fp);
	fread((char *)&(bitMap->bitMapFile.bfOffBits) 		,1,4,fp);
//	fprintf(stderr,"\nbitMapFile->\n");
//	fprintf(stderr,"bfType           =%d\n",bitMap->bitMapFile.bfType);
//	fprintf(stderr,"bfSize           =%ld\n",bitMap->bitMapFile.bfSize);
//	fprintf(stderr,"bfReserved       =%x\n",bitMap->bitMapFile.bfReserved1);
//	fprintf(stderr,"bfReserved       =%x\n",bitMap->bitMapFile.bfReserved2);
//	fprintf(stderr,"bfIffBits        =%lx\n",bitMap->bitMapFile.bfOffBits);

	fread((char *)&(bitMap->bitMapInfo.biSize)		,1,4,fp);
	fread((char *)&(bitMap->bitMapInfo.biWidth)		,1,4,fp);
	fread((char *)&(bitMap->bitMapInfo.biHeight)		,1,4,fp);
	fread((char *)&(bitMap->bitMapInfo.biPlanes)		,1,2,fp);
	fread((char *)&(bitMap->bitMapInfo.biBitCount)		,1,2,fp);
	fread((char *)&(bitMap->bitMapInfo.biCompression)	,1,4,fp);
	fread((char *)&(bitMap->bitMapInfo.biSizeImage)		,1,4,fp);
	fread((char *)&(bitMap->bitMapInfo.biXPixPerMeter)	,1,4,fp);
	fread((char *)&(bitMap->bitMapInfo.biYPixPerMeter)	,1,4,fp);
	fread((char *)&(bitMap->bitMapInfo.biClrUsed)		,1,4,fp);
	fread((char *)&(bitMap->bitMapInfo.biClrImporant)	,1,4,fp);
//	fprintf(stderr,"\nbitMapInfo->\n");
//	fprintf(stderr,"biSize           =%ld\n",bitMap->bitMapInfo.biSize);
//	fprintf(stderr,"biWidth          =%ld\n",bitMap->bitMapInfo.biWidth);
//	fprintf(stderr,"biHeight         =%ld\n",bitMap->bitMapInfo.biHeight);
//	fprintf(stderr,"biPlanes         =%d\n",bitMap->bitMapInfo.biPlanes);
//	fprintf(stderr,"biBitCount       =%d\n",bitMap->bitMapInfo.biBitCount);
//	fprintf(stderr,"biCopression     =%ld\n",bitMap->bitMapInfo.biCompression);
//	fprintf(stderr,"biSizeImage      =%ld\n",bitMap->bitMapInfo.biSizeImage);
//	fprintf(stderr,"biXPixPerMeter   =%ld\n",bitMap->bitMapInfo.biXPixPerMeter);
//	fprintf(stderr,"biYPixPerMeter   =%ld\n",bitMap->bitMapInfo.biYPixPerMeter);
//	fprintf(stderr,"biClrUsed        =%ld\n",bitMap->bitMapInfo.biClrUsed);
//	fprintf(stderr,"biClrImporant    =%ld\n",bitMap->bitMapInfo.biClrImporant);

	for ( y=bitMap->bitMapInfo.biHeight - 1 ; 0<=y ; y--) {
		line = (bitMap->bitMapInfo.biWidth * bitMap->bitMapInfo.biBitCount) / 8;
		if(line % 4) line = (((line / 4) + 1) * 4);
		for ( x=0 ; x < bitMap->bitMapInfo.biWidth ; x++) {
			line--;fread((char *)&(bitMap->bitColor[x][y].b),1,1,fp); //printf("[%d][%d]->r=%d",x,y,bitMap->bitColor[x][y].r);
			line--;fread((char *)&(bitMap->bitColor[x][y].g),1,1,fp); //printf("[%d][%d]->g=%d",x,y,bitMap->bitColor[x][y].g);
			line--;fread((char *)&(bitMap->bitColor[x][y].r),1,1,fp); //printf("[%d][%d]->b=%d\n",x,y,bitMap->bitColor[x][y].b);
		}
		while(line>0) {
			line--;
			fread(&dummy,1,1,fp);
		};
	}
	return;
}

void BmpWrite(BITMAP *bitMap){
	FILE	*fp;
	int	line;
	int	x;
	int	y;
	char	dummy;
#ifdef WIN32
	setmode( fileno(stdout), O_BINARY );
#endif
	fp = stdout;
	dummy = 0;

	fwrite((char *)&(bitMap->bitMapFile.bfType)		,1,2,fp);
	fwrite((char *)&(bitMap->bitMapFile.bfSize)		,1,4,fp);
	fwrite((char *)&(bitMap->bitMapFile.bfReserved1)	,1,2,fp);
	fwrite((char *)&(bitMap->bitMapFile.bfReserved2) 	,1,2,fp);
	fwrite((char *)&(bitMap->bitMapFile.bfOffBits) 		,1,4,fp);
//	fprintf(stderr,"\nbitMapFile->\n");
//	fprintf(stderr,"bfType           =%d\n",bitMap->bitMapFile.bfType);
//	fprintf(stderr,"bfSize           =%ld\n",bitMap->bitMapFile.bfSize);
//	fprintf(stderr,"bfReserved       =%x\n",bitMap->bitMapFile.bfReserved1);
//	fprintf(stderr,"bfReserved       =%x\n",bitMap->bitMapFile.bfReserved2);
//	fprintf(stderr,"bfIffBits        =%lx\n",bitMap->bitMapFile.bfOffBits);

	fwrite((char *)&(bitMap->bitMapInfo.biSize)		,1,4,fp);
	fwrite((char *)&(bitMap->bitMapInfo.biWidth)		,1,4,fp);
	fwrite((char *)&(bitMap->bitMapInfo.biHeight)		,1,4,fp);
	fwrite((char *)&(bitMap->bitMapInfo.biPlanes)		,1,2,fp);
	fwrite((char *)&(bitMap->bitMapInfo.biBitCount)		,1,2,fp);
	fwrite((char *)&(bitMap->bitMapInfo.biCompression)	,1,4,fp);
	fwrite((char *)&(bitMap->bitMapInfo.biSizeImage)	,1,4,fp);
	fwrite((char *)&(bitMap->bitMapInfo.biXPixPerMeter)	,1,4,fp);
	fwrite((char *)&(bitMap->bitMapInfo.biYPixPerMeter)	,1,4,fp);
	fwrite((char *)&(bitMap->bitMapInfo.biClrUsed)		,1,4,fp);
	fwrite((char *)&(bitMap->bitMapInfo.biClrImporant)	,1,4,fp);
//	fprintf(stderr,"\nbitMapInfo->\n");
//	fprintf(stderr,"biSize           =%ld\n",bitMap->bitMapInfo.biSize);
//	fprintf(stderr,"biWidth          =%ld\n",bitMap->bitMapInfo.biWidth);
//	fprintf(stderr,"biHeight         =%ld\n",bitMap->bitMapInfo.biHeight);
//	fprintf(stderr,"biPlanes         =%d\n",bitMap->bitMapInfo.biPlanes);
//	fprintf(stderr,"biBitCount       =%d\n",bitMap->bitMapInfo.biBitCount);
//	fprintf(stderr,"biCopression     =%ld\n",bitMap->bitMapInfo.biCompression);
//	fprintf(stderr,"biSizeImage      =%ld\n",bitMap->bitMapInfo.biSizeImage);
//	fprintf(stderr,"biXPixPerMeter   =%ld\n",bitMap->bitMapInfo.biXPixPerMeter);
//	fprintf(stderr,"biYPixPerMeter   =%ld\n",bitMap->bitMapInfo.biYPixPerMeter);
//	fprintf(stderr,"biClrUsed        =%ld\n",bitMap->bitMapInfo.biClrUsed);
//	fprintf(stderr,"biClrImporant    =%ld\n",bitMap->bitMapInfo.biClrImporant);

	for ( y=bitMap->bitMapInfo.biHeight - 1 ; 0<=y ; y--) {
		line = (bitMap->bitMapInfo.biWidth * bitMap->bitMapInfo.biBitCount) / 8;
		if(line % 4) line = (((line / 4) + 1) * 4);
		for ( x=0 ; x < bitMap->bitMapInfo.biWidth ; x++) {
			line--;fwrite((char *)&(bitMap->bitColor[x][y].b),1,1,fp);
			line--;fwrite((char *)&(bitMap->bitColor[x][y].g),1,1,fp);
			line--;fwrite((char *)&(bitMap->bitColor[x][y].r),1,1,fp);
		}
		while(line>0) {
			line--;
			fwrite(&dummy,1,1,fp);
		};
	}
	return;
}


