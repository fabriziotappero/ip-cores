/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : ORPSoC v2
// File Name                      : bin2abs.c
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
	int j = 1;
	int line = 0;
	int filename_index=1;
	int bytes_per_line=1;
	int bytes_per_line_index=2;
	int min_num_bytes = 0;
	int min_num_bytes_index=3;
	int byte_lane=0;
	int byte_lane_index=4;
     

	if(argc < 3) {
	  fprintf(stderr,"\n\tInsufficient options.\n");
	  fprintf(stderr,"\tPlease specify, in this order: a binary file to\n");	  
	  fprintf(stderr,"\tconvert and the number of bytes of data to putput\n");
	  fprintf(stderr,"\tper line.\n");
	  exit(1);
	}
		
	fd = fopen( argv[filename_index], "r" );
	bytes_per_line = atoi(argv[bytes_per_line_index]);

	if(argc > 3) {
	min_num_bytes = atoi(argv[min_num_bytes_index]);
	}


	if(argc > 4) {
	byte_lane = atoi(argv[byte_lane_index]);
	}

	
	if ((bytes_per_line == 0) || (bytes_per_line > 8) || (byte_lane > bytes_per_line )    )
	  {
	    fprintf(stderr,"bytes per line incorrect or missing: %s\n",argv[bytes_per_line_index]);
	    exit(1);
	  }
	

	
	if (fd == NULL) {
		fprintf(stderr,"failed to open input file: %s\n",argv[1]);
		exit(1);
	}

	i=0;
        line=0;

        if(byte_lane)
	  {
	// Now write out the binary data to hex format
	while ((c = fgetc(fd)) != EOF) {
          j=i+1;
	  if(byte_lane == j)
	    {	printf("%.2x", (unsigned int) c);
	
	    }
        	if (++i == bytes_per_line) {
			printf("\n");
                        line++;
			i = 0;
		}
        }


	while (i) {
          j=i+1;
	  if(byte_lane == j)
	    {	printf("00");
	
	    }


		if (++i == bytes_per_line) {
			printf("\n");
                        line++;
			i = 0;
		}
        }



	while (line < min_num_bytes) {
		printf("00\n");
                line++;
        }
	  }
      else

	  {
	    // no byte lane
	// Now write out the binary data to hex format
	while ((c = fgetc(fd)) != EOF) {
		printf("%.2x", (unsigned int) c);
		if (++i == bytes_per_line) {
			printf("\n");
                        line++;
			i = 0;
		}
        }


	while (i) {
		printf("00");
		if (++i == bytes_per_line) {
			printf("\n");
                        line++;
			i = 0;
		}
        }



	while (line < min_num_bytes) {
		printf("00000000\n");
                line++;
        }
	  }




	return 0;
}	
