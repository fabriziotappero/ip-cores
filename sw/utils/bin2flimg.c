/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : ORPSoC v2
// File Name                      : bin2flimg.c
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
// Generate flimg output to stdout from binary file input
//

#include <stdio.h>
#include <stdlib.h>
 
int main(int argc, char **argv)
{

	FILE  *fd;
	int c, j, width;
	unsigned long word;

	if(argc < 3) {
		fprintf(stderr,"no input file specified\n");
		exit(1);
	}
	if(argc > 3) {
		fprintf(stderr,"too many input files (more than one) specified\n");
		exit(1);
	}
	
	width = atoi(argv[1]);

	fd = fopen( argv[2], "r" );
	if (fd == NULL) {
		fprintf(stderr,"failed to open input file: %s\n",argv[1]);
		exit(1);
	}

	while (!feof(fd)) {
                j = 0;
		word = 0;
                while (j < width) {
			c = fgetc(fd);
                        if (c == EOF) {
                                c = 0;
                        }
			word = (word << 8) + c;
                        j++;
                }
		if(width == 1)	
			printf("%.2lx\n", word);
		else if(width == 2)
			printf("%.4lx\n", word);
		else
			printf("%.8lx\n", word);
        }
	return 0;
}	
