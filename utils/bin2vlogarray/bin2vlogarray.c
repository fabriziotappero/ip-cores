/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : ORPSoC v2
// File Name                      : bin2c.c
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
// Generate verilog lines assigning array output from binary final input
//
// Looks like this:
//
// 0 : wb_dat_o <= #1 32'h18000000;
// 1 : wb_dat_o <= #1 32'h18200000;
// 2 : wb_dat_o <= #1 32'h1880b000;
// 3 : wb_dat_o <= #1 32'ha8400051;
// 4 : wb_dat_o <= #1 32'hd8041000;
// 5 : wb_dat_o <= #1 32'h18c00000;
// 6 : wb_dat_o <= #1 32'h18e00000;
//
// etc...
//
//

#include <stdio.h>
#include <stdint.h>

#define OUT_REG_STRING "wb_dat_o"
//#define ASSIGN_STRING "<= #1"
#define ASSIGN_STRING "<= "
#define SIZE_STRING "32'h"
#define BEFORE_STRING "%d : "OUT_REG_STRING" "ASSIGN_STRING" "SIZE_STRING

//#define BEFORE_STRING "%d : wb_dat_o <= 32'h"


int main(void)
{

  int c, i = 0, word_counter=0;
  uint32_t word;
  uint8_t *wordarray = (uint8_t*) &word;

  while((c = getchar()) != EOF) {
    /* Endianess might change things here */
    wordarray[3] = c;
    wordarray[2] = getchar();
    wordarray[1] = getchar();
    wordarray[0] = getchar();
    printf(BEFORE_STRING, word_counter);
    printf("%.8x;\n", word);
    word_counter++;
  }

  return(0);
    
}
