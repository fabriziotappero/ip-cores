#include <stdio.h>



unsigned char header[0x2A] = {
  0x00,0x01,0x01,0x00,0x00,0x08,0x00,0x18,
  0x00,0x00,0x00,0x00,0x80,0x02,0xE0,0x01,
  0x08,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,
  0x00,0xFF,0x00,0x00,0xFF,0xFF,0xC2,0x79,
  0x02,0xC2,0x5D,0xFC,0xFF,0xE8,0xA3,0xFF,
  0xFF,0xFF};


FILE *vram_dump = 0;
FILE *tgaout = 0;


unsigned char pcolor(int x, int y) {
   int addr;
   
   fseek(vram_dump, (x>>4) + ((y<<2) & 0xfffc0 ) , SEEK_SET);
   
   addr = fgetc(vram_dump);
   addr &= 0x37; // brauchma ned ?   

   addr = ((addr & 0x30) << 5) + ((y & 0x0e) << 5) + (1<<5) + ((addr & 0x07) << 2) + ((x&0xC) >> 2);

   fseek(vram_dump, addr , SEEK_SET);

   addr = fgetc(vram_dump);

 

   if(x & 0x02)
     return (addr & 0x0f);     
   else 
     return (addr & 0xf0) >> 4;
}



int main(int argc, char **argv) {
  int i; int x; int y;
  
  if(argc != 3)
    printf("usage: dump2tga [inputfile] [outputfile]\n");  


  vram_dump = fopen(argv[1], "r");
  
  if(!vram_dump) {
    printf("input file");
    exit(1);
  }
 
  tgaout = fopen(argv[2], "w+");
  
  if(!tgaout)
    printf("output file");
    exit(1);
  }
     
  for(i = 0; i < 0x2A; i++) {
    fputc(header[i],tgaout);
  }
 
  for(y = 479; y >= 0; y --)
    for(x = 0; x < 640; x++)
      fputc(pcolor(x,y), tgaout);

  close(vram_dump);
  close(tgaout);

  return 0;
}
