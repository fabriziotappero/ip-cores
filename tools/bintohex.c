/*bintohex by Steve Rhoads 5/29/02*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define BUF_SIZE (1024*1024)

int main(int argc, char *argv[])
{
   FILE *file;
   unsigned char *buf;
   unsigned long size, mem_size = 1024 * 4, i, j, k, sum;
   char filename[80];

   if(argc < 2)
   {
      printf ("usage: bintohex infile\n");
      return -1;
   }
   file = fopen(argv[1], "rb");
   if(file == NULL)
   {
      printf("Can't open %s\n", argv[1]);
      return -1;
   }

   buf = (unsigned char *)malloc(BUF_SIZE);
   memset(buf, 0, BUF_SIZE);
   size = fread(buf, 1, BUF_SIZE, file);
   mem_size = size;
   if(size > mem_size)
   {
      printf("FILE TOO LARGE!!!!!!!!!!!\n");
      return -1;
   }
   fclose(file);
   strcpy(filename, "codeX.hex");

   for(i = 0; i < 4; ++i)
   {
      filename[4] = '0' + i;
      file = fopen(filename, "wb");
      for(j = 0; i + j * 4 * 16 < mem_size; ++j)
      {
         k = j * 16;
         fprintf(file, ":10%4.4x00", (int)k);
         sum = 0x10 + (k >> 8) + (k & 0xff);
         for(k = 0; k < 16; ++k)
         {
            fprintf(file, "%2.2x", buf[i + j * 4 * 16 + k * 4]);
            sum += buf[i + j * 4 * 16 + k * 4];
         }
         sum &= 0xff;
         sum = 0x100 - sum;
         sum &= 0xff;
         fprintf(file, "%2.2x\n", (int)sum);
      }
      fprintf(file, ":00000001ff\n");
      fclose(file);
   }
   free(buf);
   return 0;
}

