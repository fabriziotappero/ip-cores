/*----------------------------------------------------------------
//                                                              //
//  amber-bin2mem.c                                             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Read in a binary file from tcpdump and write it out in      //
//  in Verilog readmem format.                                  //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/


#include <stdio.h>
#include <stdlib.h>
#include "../boot-loader-serial/boot-loader.h"

/* Function prototypes */
int fsize(FILE *f);
int conv_hstring(char*, unsigned int*);
unsigned int buf_uint (unsigned char *buf);


int main(int argc,char *argv[])
{
   FILE *infile;
   char filename_mem[80], filename_nopath[80];
   unsigned char *buf;
   FILE *file_mem;
   int infile_size, buf_size, i, j;
   int ret;
   int buf_pos;
   unsigned int incl_len;
   unsigned int orig_len;
   int mem_pos = 0;
   
   if (argc<2){
      fprintf(stderr, "ERROR: no input file specified. Quitting\n");
      exit(1);
      }


   infile=fopen(argv[1],"rb");
   if(infile==NULL) {
      fprintf(stderr, "ERROR: Can't open %s. Quitting\n", argv[1]);
      exit(1);
   }
   infile_size = fsize(infile);
   
   buf=(unsigned char*)malloc(infile_size);
   buf_size=fread(buf,1,infile_size,infile);
   fclose(infile);

   if ( buf_size != infile_size ) {
      fprintf(stderr, "%s ERROR: Input %s file length is %d bytes long, buffer read buf_size %d\n", 
      argv[0], argv[1], infile_size, buf_size);
      exit(1);
      }
      
      
   if ( infile_size > 0x1000000 ) {
      fprintf(stderr, "%s WARNING: Input %s file length is %d bytes long, greater than boot-loader can handle \n", 
      argv[0], argv[1], infile_size);
      }
      
      
   /* Start of file */
   buf_pos = 6*4;
   
   /* Main loop. once per packet */
   while (buf_pos < infile_size) {
      buf_pos=buf_pos+8;
      incl_len = buf_uint(&buf[buf_pos]); buf_pos+=4;
      orig_len = buf_uint(&buf[buf_pos]); buf_pos+=4;
   
      /* error check included packet length */
      if (incl_len != orig_len) {
         fprintf(stderr, "Warning: the full packet was not captured in the tcpdump file\n");
         fprintf(stderr, "incl_len %d != orig_len %d\n", incl_len, orig_len);
         //goto error_return;
         }

      /* error check max packet length */
      if (orig_len > 255) {
         fprintf(stderr, "Error: the packet is too long. Max length is 255 bytes\n");
         fprintf(stderr, "orig_len %d\n", orig_len);
         goto error_return;
         }

      /* check if full packet is contained in file */
      if (buf_pos + incl_len > infile_size) {
         fprintf(stderr, "Error: end of current packet is after the end of the buffer\n");
         goto error_return;
         }
       
       
      printf("// incl_len %d, orig_len %d\n", incl_len, orig_len);
      printf("// ip-sa %d.%d.%d.%d, ip-da %d.%d.%d.%d, protocol %d\n", 
               buf[buf_pos+26], buf[buf_pos+27], buf[buf_pos+28], buf[buf_pos+29],  
               buf[buf_pos+30], buf[buf_pos+31], buf[buf_pos+32], buf[buf_pos+33],
               buf[buf_pos+23]
               );
                 
      /* First byte gives the packet length */           
      printf("@%04x %02x\n",   mem_pos++, orig_len);
      for (i=buf_pos;i<buf_pos+incl_len;i++,mem_pos++) {
          printf("@%04x %02x\n", mem_pos, buf[i]);
          }
      
      /* pad out any missing bytes */
      if (orig_len > incl_len) {
         for (i=incl_len;i<orig_len;i++,mem_pos++) {
            printf("@%04x 00\n", mem_pos);
            }      
      }
           
      /* advance to the start of the next entry */     
      buf_pos += incl_len;
      }
   
   free(buf);
   return 0;


   error_return:
      free(buf);
      return 1;
}



unsigned int buf_uint (unsigned char *buf)
{
    return buf[3]<<24 | buf[2]<<16 | buf[1]<<8 | buf[0];
}


/* Return the buf_size of a file in bytes */
int fsize( FILE *f )
{
    int end;

    /* Set current position at end of file */
    fseek( f, 0, SEEK_END );

    /* File buf_size in bytes */
    end = ftell( f );

    /* Set current position at start of file */
    fseek( f, 0, SEEK_SET );

    return end;
}


int conv_hstring ( char *string, unsigned int * num)
{
int pos = 0;
*num = 0;

while (((string[pos] >= '0' && string[pos] <= '9') || 
       (string[pos] >= 'a' && string[pos] <= 'f')) && pos < 9) {
    if (string[pos] >= '0' && string[pos] <= '9')
        *num =  (*num << 4) + ( string[pos++] - '0' );
    else
        *num =  (*num << 4) + ( string[pos++] - 'a' ) + 10;
    }
    
return pos;
}

