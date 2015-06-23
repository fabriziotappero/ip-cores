
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
	unsigned char r,g,b;
	
	BmpRead((BITMAP*)&bitmap);

	WIDTH  = bitmap.bitMapInfo.biWidth;
	HEIGHT = bitmap.bitMapInfo.biHeight;

	for (yy=0;yy<HEIGHT;yy++) {
		for (xx=0;xx<WIDTH;xx++) {
			r = bitmap.bitColor[xx][yy].r;
			g = bitmap.bitColor[xx][yy].g;
			b = bitmap.bitColor[xx][yy].b;
			r = (r!=0x00) ? 255: 0;
			g = (g!=0x00) ? 255: 0;
			b = (b!=0x00) ? 255: 0;
			bitmap.bitColor[xx][yy].r = r;
			bitmap.bitColor[xx][yy].g = g;
			bitmap.bitColor[xx][yy].b = b;

		}
	}

	BmpWrite((BITMAP*)&bitmap);

	return 0;
}
