/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : ORPSoC v2
// File Name                      : bin2srec.c
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
// Generates SREC file output to stdout from binary file
//

#include <stdio.h>
#include <stdlib.h>
 
#define SMARK "S214"
#define SADDR 0x000000
#define INIT_ADDR 0x100100
#define SCHKSUM 0xff

int main(int argc, char **argv)
{

	FILE  *fd;
	int c, j;
	unsigned long addr = INIT_ADDR;
        unsigned char chksum;

	if(argc < 2) {
		fprintf(stderr,"no input file specified\n");
		exit(1);
	}
	if(argc > 2) {
		fprintf(stderr,"too many input files (more than one) specified\n");
		exit(1);
	}

	fd = fopen( argv[1], "r" );
	if (fd == NULL) {
		fprintf(stderr,"failed to open input file: %s\n",argv[1]);
		exit(1);
	}

	while (!feof(fd)) {
                j = 0;
                chksum = SCHKSUM;
                printf("%s%.6lx", SMARK, addr);
                while (j < 16) {
			c = fgetc(fd);
                        if (c == EOF) {
                                c = 0;
                        }
                        printf("%.2x", c);
                        chksum -= c;
                        j++;
                }

                chksum -= addr & 0xff;
                chksum -= (addr >> 8) & 0xff;
                chksum -= (addr >> 16) & 0xff;
                chksum -= 0x14;
                printf("%.2x\r\n", chksum);
                addr += 16;
        }
	return 0;
}	
