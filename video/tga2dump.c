/***************************************************************************
 *   Copyright (C) 2008 by David Rigler   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#include <stdio.h>




unsigned char header[0x2A] = {
  0x00,0x01,0x01,0x00,0x00,0x08,0x00,0x18,
  0x00,0x00,0x00,0x00,0x80,0x02,0xE0,0x01,
  0x08,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,
  0x00,0xFF,0x00,0x00,0xFF,0xFF,0xC2,0x79,
  0x02,0xC2,0x5D,0xFC,0xFF,0xE8,0xA3,0xFF,
  0xFF,0xFF};


  FILE *vram_dump = 0;
  FILE *tgain = 0;

  typedef struct
  {
      unsigned int pix[4][8];
  } my_tile;

#define NR_TILES 96
#define VRAM_SIZE 8192

  int used_tiles = 0;
  my_tile tiles[96];



  unsigned char encoded(int tilenum)
  {
	int x = (tilenum%12) + 4;
	int y = tilenum/12;
    return (y << 4) | x;
  }


  
  unsigned char outoftiles = 0;
  unsigned char VRAM[VRAM_SIZE] = {0};
  unsigned char bitmap[640][480] = {0};
  
  unsigned char tileindex(int x_in, int y_in) {
    int x,y,i;
    my_tile t;
    int tilenum;

    for(y = 0; y < 8; y++){
      for(x = 0; x < 4; x++){
        t.pix[x][y] = (bitmap[x_in*8+2*x][y_in*8 + y] << 4) | bitmap[x_in*8+2*x+1][y_in*8 + y];
      }
    }

    int pissoff = 0;
    for(i = 0; i < used_tiles; i++) {
      pissoff = 0;
      for( x = 0; !pissoff && x < 4; x++)
        for( y = 0; !pissoff && y < 8; y++)
          if(tiles[i].pix[x][y] != t.pix[x][y])
            pissoff = 1;

      if(!pissoff){
        tilenum = i;
        break;
      }
    }

    if( i == used_tiles) {
		if(used_tiles >= NR_TILES) {
			tilenum = 0;
			outoftiles = 1;
		} else {
		  tilenum = used_tiles++;
		  for( x = 0;  x < 4; x++)
			for( y = 0;  y < 8; y++)
			  tiles[tilenum].pix[x][y] = t.pix[x][y];
		}
	}

    return encoded(tilenum);
  }




  int main(int argc, char **argv) {
    int i; int x; int y;

    if(argc != 3)
      printf("usage: tga2dump [inputfile] [outputfile]\n");


    tgain = fopen(argv[1], "r");

    if(!tgain) {
      printf("input file");
      return 1;
    }

    vram_dump = fopen(argv[2], "w+");

    if(!vram_dump){
      printf("output file");
      return 1;
    }

  FILE *tgaout = fopen("debug.tga", "w+");
  
  if(!tgaout){
    printf("debug file");
    exit(1);
  }

    for(i = 1; i < NR_TILES; i++)
      for(y = 0; y < 8; y++)
		 for(x = 0; x < 4; x++)
			tiles[i].pix[x][y] = 0x77;

  for(i = 0; i < 0x2A; i++) {
    fputc(header[i],tgaout);
  }

    

    fseek(tgain, 0x2A, SEEK_SET);
    
    for(y = 479; y >= 0; y--)
      for(x = 0; x < 640; x++)
        bitmap[x][y] = fgetc(tgain);


    for(y = 0; y < 60; y++)
      for(x = 0; x < 80; x++)

        VRAM[y*128 + x] = tileindex(x,y);



    for(i = 0; i < NR_TILES; i++)
      for(y = 0; y < 8; y++)
        for(x = 0; x < 4; x++)
          VRAM[128*( 8*(i/12) +y) + 80 + (i%12)*4 + x ] = tiles[i].pix[x][y];

    for(i = 0; i<VRAM_SIZE; i++)
      fputc(VRAM[i], vram_dump);


    // debug TILES
    for(i = 0; i < NR_TILES; i++)
      for(y = 0; y < 8; y++)
		 for(x = 0; x < 4; x++){
          bitmap[(i%12) * 9+2*x+1][200 + y + (i/12)*9] = tiles[i].pix[x][y] &0xf ;
		  bitmap[(i%12) * 9 + 2*x][200 + y + (i/12)*9] = tiles[i].pix[x][y]>>4; 
		 }

     for(i = 0; i < NR_TILES; i++)
      for(y = 0; y < 8; y++)
		 for(x = 0; x < 4; x++){
          bitmap[(i%12) * 8+2*x +1+ 13*9][200 + y + (i/12)*8] = tiles[i].pix[x][y] &0xf ;
		  bitmap[(i%12) * 8 + 2*x + 13*9][200 + y + (i/12)*8] = tiles[i].pix[x][y]>>4; 
		 }

   for(y = 479; y >= 0; y --)
    for(x = 0; x < 640; x++)
      fputc(bitmap[x][y], tgaout);



    fclose(vram_dump);
    fclose(tgain);
    fclose(tgaout);

	if(outoftiles) 
	  printf("to few tiles\n");

    return 0;
  }
