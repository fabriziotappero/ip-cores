/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : ORPSoC v2
// File Name                      : bin2vmem.c
// Prepared By                    : jb, jb@orsoc.se
// Project Start                  : 2009-05-13

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
// Generates VMEM output to stdout from binary images.
// Use with redirection like: ./bin2vmem app.bin > app.vmem
// To change either the number of bytes per word or word per line, change
// the following defines.
// Currently output is WORD addressed, NOT byte addressed
// eg: @00000000 00000000 00000000 00000000 00000000
//     @00000004 00000000 00000000 00000000 00000000
//     @00000008 00000000 00000000 00000000 00000000
//     @0000000c 00000000 00000000 00000000 00000000
//     etc..
//
// OR
// 
// Output a list of the words, one per line, as Synplify appears to like
// specify this option with the -synfmt switch on the command line after
// the input file
// eg: ./bin2vmem data.bin -synfmt > data.vmem
//

#define WORDS_PER_LINE 4
#define BYTES_PER_WORD 4

#define FILENAME_CMDLINE_INDEX 1
#define FMT_CMDLINE_INDEX 2

#define FMT_WITH_ADDR 0
#define FMT_SYN 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
int main(int argc, char **argv)
{

	FILE  *fd;
	int c;
	int i = 0;
	int write_size_word=0; // Disabled by default
	unsigned int image_size;
	int output_fmt = FMT_WITH_ADDR; // 0 - standard 4 per line with address, 1 - synfmt

	// Counters keeping track of what we've printed
	int current_addr = 0;
	int word_counter = 0;
	int byte_counter = 0;

	if(argc < 2) {
	  fprintf(stderr,"\n\tInsufficient options.\n");
	  fprintf(stderr,"\tPlease specify a binary file to convert to VMEM\n");
	  fprintf(stderr,"\n\tbin2vmem - creates vmem output to stdout from bin\n");
	  fprintf(stderr,"\n\tBy default the output is word addressed 32-bit words\n");
	  fprintf(stderr,"\tSpecify -synfmt on the command line after the filename\n");
	  fprintf(stderr,"\tto output in the alterative format, which is a simple\n");
	  fprintf(stderr,"\tlist of the data words.\n");

	  fprintf(stderr,"\n");
	  exit(1);
	}

	fd = fopen( argv[FILENAME_CMDLINE_INDEX], "r" );

	if (argc > 2) // check for the -synfmt switch
	  {
	    if (strcmp("-synfmt", argv[FMT_CMDLINE_INDEX]) == 0)
	      output_fmt = FMT_SYN; // synthesis friendly format - single column, no addr
	  }

	if (fd == NULL) {
		fprintf(stderr,"failed to open input file: %s\n",argv[1]);
		exit(1);
	}

	fseek(fd, 0, SEEK_END);
	image_size = ftell(fd);
	fseek(fd,0,SEEK_SET);

	if (write_size_word)
	  {
	    // or1200 startup method of determining size of boot image we're copying by reading out
	    // the very first word in flash is used. Determine the length of this file
	    fseek(fd, 0, SEEK_END);
	    image_size = ftell(fd);
	    fseek(fd,0,SEEK_SET);
	    
	    // Now we should have the size of the file in bytes. Let's ensure it's a word multiple
	    image_size+=3;
	    image_size &= 0xfffffffc;

	    // Sanity check on image size
	    if (image_size < 8){ 
	      fprintf(stderr, "Bad binary image. Size too small\n");
	      return 1;
	    }
	    
	    // Now write out the image size
	    printf("@%8x", current_addr);
	    printf("%8x", image_size);
	    current_addr += WORDS_PER_LINE * BYTES_PER_WORD;
	  }


	// Fix for the current bootloader software! Skip the first 4 
	// bytes of application data. Hopefully it's not important. 030509 -- jb
	//for(i=0;i<4;i++)
	//  c=fgetc(fd);
	i=0;
	int starting_new_line  = 1;
	// Now write out the binary data to specified format. Either
	// more complicated, addressed format:
	// VMEM format: @ADDRESSS XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX
	// or simple, synplifyfriendly format which is just a list of
	// the words
	
	while ((c = fgetc(fd)) != EOF) {
	  
	  if (output_fmt == FMT_WITH_ADDR) // Default format
	    {
	      
	      if (starting_new_line)
		{
		  // New line - print the current addr and then increment it
		  printf("@%.8x", current_addr);
		  current_addr += WORDS_PER_LINE;
		  starting_new_line = 0;
		}
	      if (byte_counter == 0)
		printf(" ");
	      
	      printf("%.2x", (unsigned int) c); // now print the actual char
	      
	      byte_counter++;
	      
	      if (byte_counter == BYTES_PER_WORD)
		{
		  word_counter++;
		  byte_counter=0;
		}
	      if (word_counter == WORDS_PER_LINE)
		{
		  printf("\n");   
		  word_counter = 0;
		  starting_new_line = 1;
		}
	    } // End of FMT_WITH_ADDR
	  else if (output_fmt == FMT_SYN) // simple list of data words
	    {
	      printf("%.2x", (unsigned int) c); // now print the actual char
	      byte_counter++;
	      if (byte_counter == BYTES_PER_WORD)
		{
		  printf("\n");
		  byte_counter=0;
		}
	    }
	      

	}

	return 0;
}	
