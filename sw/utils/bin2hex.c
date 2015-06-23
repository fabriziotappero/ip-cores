/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : ORPSoC v2
// File Name                      : bin2hex.c
// Prepared By                    : 
// Project Start                  : 

/*$$COPYRIGHT NOTICE*/
/******************************************************************************/
/*                                                                            */
/*                      C O P Y R I G H T   N O T I C E                       */
/*                                                                            */
/******************************************************************************/
/*
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; 
  version 2.1 of the License, a copy of which is available from
  http://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

/*$$DESCRIPTION*/
/******************************************************************************/
/*                                                                            */
/*                           D E S C R I P T I O N                            */
/*                                                                            */
/******************************************************************************/
//
// Generates basic ASCII hex output to stdout from binary file input
// Compile and run the program with no options for usage.
//
// Modified by R. Diez in 2011 so that, when using option -size_word,
// padding zeroes are eventually appended, so that the length of
// the resulting file matches the length written in the header.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* Number of bytes before line is broken
   For example if target flash is 8 bits wide,
   define BREAK as 1. If it is 16 bits wide,
   define it as 2 etc.
*/
#define BREAK 1
 
int main(int argc, char **argv)
{

	FILE  *fd;
	int c;
	int i = 0;
	int write_size_word=0; // Disabled by default
	int filename_index=1;
	int bytes_per_line=1;
	int bytes_per_line_index=2;
    unsigned int padding_size = 0;

	if(argc < 3) {
	  fprintf(stderr,"\n\tInsufficient options.\n");
	  fprintf(stderr,"\tPlease specify, in this order: a binary file to\n");	  
	  fprintf(stderr,"\tconvert and the number of bytes of data to output\n");
	  fprintf(stderr,"\tper line.\n");
	  fprintf(stderr,"\tOptionally specify the option -size_word to output\n");
	  fprintf(stderr,"\tthe size of the image in the first 4 bytes. This is\n");
	  fprintf(stderr,"\tused by some of the new OR1k bootloaders. Note that\n");
	  fprintf(stderr,"\tpadding zeroes will be appended so that the image size\n");
      fprintf(stderr,"\tis a multiple of 4.\n\n");
	  exit(1);
	}
	
	if(argc == 4)
	  {
	    if (strcmp("-size_word", argv[3]) == 0)
	      // We will calculate the number of bytes first
	      write_size_word=1;
	  }
	
	fd = fopen( argv[filename_index], "r" );

	bytes_per_line = atoi(argv[bytes_per_line_index]);
	
	if ((bytes_per_line == 0) || (bytes_per_line > 8))
	  {
	    fprintf(stderr,"bytes per line incorrect or missing: %s\n",argv[bytes_per_line_index]);
	    exit(1);
	  }
	
	// Now subtract 1 from bytes_per_line
	//if (bytes_per_line == 2)
	//  bytes_per_line--;
	
	if (fd == NULL) {
		fprintf(stderr,"failed to open input file: %s\n",argv[1]);
		exit(1);
	}

	if (write_size_word)
	  {
        unsigned int image_size;
        
	    // or1200 startup method of determining size of boot image we're copying by reading out
	    // the very first word in flash is used. Determine the length of this file
	    fseek(fd, 0, SEEK_END);
	    image_size = ftell(fd);
	    fseek(fd,0,SEEK_SET);
	    
	    // Now we should have the size of the file in bytes. Let's ensure it's a word multiple
        padding_size = ( 4 - (image_size % 4) ) % 4;
	    image_size += padding_size;

	    // Sanity check on image size
	    if (image_size < 8){ 
	      fprintf(stderr, "Bad binary image. Size too small\n");
	      return 1;
	    }
	    
	    // Now write out the image size
	    i=0;
	    printf("%.2x",(image_size >> 24) & 0xff);
	    if(++i==bytes_per_line){ printf("\n"); i=0; }
	    printf("%.2x",(image_size >> 16) & 0xff);
	    if(++i==bytes_per_line){ printf("\n"); i=0; }
	    printf("%.2x",(image_size >> 8) & 0xff);
	    if(++i==bytes_per_line){ printf("\n"); i=0; }
	    printf("%.2x",(image_size) & 0xff);
	    if(++i==bytes_per_line){ printf("\n"); i=0; }
	  }

	// Fix for the current bootloader software! Skip the first 4 bytes of application data. Hopefully it's not important. 030509 -- jb
	for(i=0;i<4;i++)
	  c=fgetc(fd);

	i=0;

	// Now write out the binary data to hex format
	while ((c = fgetc(fd)) != EOF) {
		printf("%.2x", (unsigned int) c);
		if (++i == bytes_per_line) {
			printf("\n");
			i = 0;
		}
        }

    unsigned j;
    for ( j = 0; j < padding_size; ++j ) {
        // printf("Adding one padding byte.\n");
		printf("%.2x", 0);
		if (++i == bytes_per_line) {
			printf("\n");
			i = 0;
		}
    }

	return 0;
}	
