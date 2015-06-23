
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "bmp.h"

int WIDTH;
int HEIGHT;

int		xx,yy;
BITMAP		bitmap;

int main(int,char **);
void start_blue(void);

int main(int argc,char *argv[]){
	unsigned short int r,g,b,rgb565;
	
	if (argc!=2) {fprintf(stderr,"argc error%d\n",argc); return -1;}
	
	BmpRead((BITMAP*)&bitmap);

	WIDTH  = bitmap.bitMapInfo.biWidth;
	HEIGHT = bitmap.bitMapInfo.biHeight;

	fprintf(stdout,"\n");
	fprintf(stdout,"#include \"image.h\"\n");
	fprintf(stdout,"\n");

	{
		char temp[256];
		strcpy(temp,argv[1]);
		strupr(temp);
		fprintf(stdout,"\n");
		fprintf(stdout,"#define %s_SRC_SIZE %d\n",temp,WIDTH*HEIGHT);
		fprintf(stdout,"\n");
	}

	fprintf(stdout,"const unsigned short int %s_src[%d][%d] = {\n",argv[1],HEIGHT,WIDTH);
	for (yy=0;yy<HEIGHT;yy++) {
		fprintf(stdout,"\t{ // line:%d",yy);
		for (xx=0;xx<WIDTH;xx++) {
			r = (unsigned short int)bitmap.bitColor[xx][yy].r;
			g = (unsigned short int)bitmap.bitColor[xx][yy].g;
			b = (unsigned short int)bitmap.bitColor[xx][yy].b;
			r = ( (0x0004==(r&0x0004)) ) ? r + 1: r;
			g = ( (0x0008==(g&0x0008)) ) ? g + 1: g;
			b = ( (0x0004==(b&0x0004)) ) ? b + 1: b;
			r = (r>255) ? 255: r;
			g = (g>255) ? 255: g;
			b = (b>255) ? 255: b;
			r = (r<<8)&0xf800;
			g = (g<<3)&0x07e0;
			b = (b>>3)&0x001f;
			rgb565 = r + g + b;
			if (0==xx%16) fprintf(stdout,"\n\t\t");
			fprintf(stdout,"0x%04x",rgb565);
			if (xx!=(WIDTH-1)) fprintf(stdout,",");
		}
		fprintf(stdout,"\n\t}");
		if (yy!=(HEIGHT-1)) fprintf(stdout,",");
		fprintf(stdout,"\n");
	}
	fprintf(stdout,"};\n");
	fprintf(stdout,"\n");
	
	fprintf(stdout,"const IMAGE %s = { %d , %d , (void *)%s_src };\n",argv[1],WIDTH,HEIGHT,argv[1]);
	fprintf(stdout,"\n");

	return 0;
}
