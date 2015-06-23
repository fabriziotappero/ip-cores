/************************************************************/
/* Filename   : common.c                                    */
/* Description: Commonly used functions.                    */
/* Author     : Nikolaos Kavvadias, <nkavv@physics.auth.gr> */
/* Date       : Tuesday, 09/02/2010.                        */
/* Revision   : --                                          */
/************************************************************/

#include <stdio.h>
#include <stdlib.h>   

                       
void print_vhdl_header_common(FILE *outfile)
{ 
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"---- Author: Nikolaos Kavvadias                                   ----\n");
  fprintf(outfile,"----         nkavv@physics.auth.gr                                ----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"----==============================================================----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"---- Copyright (C) 2004-2010   Nikolaos Kavvadias                 ----\n");
  fprintf(outfile,"----                    nkavv@uop.gr                              ----\n");
  fprintf(outfile,"----                    nkavv@physics.auth.gr                     ----\n");
  fprintf(outfile,"----                    nikolaos.kavvadias@gmail.com              ----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"---- This source file may be used and distributed without         ----\n");
  fprintf(outfile,"---- restriction provided that this copyright statement is not    ----\n");
  fprintf(outfile,"---- removed from the file and that any derivative work contains  ----\n");
  fprintf(outfile,"---- the original copyright notice and the associated disclaimer. ----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"---- This source file is free software; you can redistribute it   ----\n");
  fprintf(outfile,"---- and/or modify it under the terms of the GNU Lesser General   ----\n");
  fprintf(outfile,"---- Public License as published by the Free Software Foundation; ----\n");
  fprintf(outfile,"---- either version 2.1 of the License, or (at your option) any   ----\n");
  fprintf(outfile,"---- later version.                                               ----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"---- This source is distributed in the hope that it will be       ----\n");
  fprintf(outfile,"---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----\n");
  fprintf(outfile,"---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----\n");
  fprintf(outfile,"---- PURPOSE. See the GNU Lesser General Public License for more  ----\n");
  fprintf(outfile,"---- details.                                                     ----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"---- You should have received a copy of the GNU Lesser General    ----\n");
  fprintf(outfile,"---- Public License along with this source; if not, download it   ----\n");
  fprintf(outfile,"---- from <http://www.opencores.org/lgpl.shtml>                   ----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"----==============================================================----\n");
  fprintf(outfile,"--\n");                            
  fprintf(outfile,"-- CVS Revision History\n");
  fprintf(outfile,"--\n");   
  fprintf(outfile,"\n");   
}
     
unsigned ipow(unsigned x, unsigned y)
{   
  unsigned i;       
  unsigned result;
  
  result = 1;

  for (i=1; i<=y; i++)
    result = result*x;
    
  return result;
} 

unsigned dectobin(unsigned bin_data, int num_bits)
{
   int count;
   unsigned MASK;
   unsigned result;                                         
   unsigned result_arr[100];    
   
   count = num_bits;
   MASK = 1<<(count-1);
 
   result = 0;

   for (count=num_bits-1; count>-1; count--)
   {
     result_arr[count] = (( bin_data & MASK ) ? 1 : 0 );
     bin_data <<= 1;
   }                
   
   for (count=num_bits-1; count>-1; count--)
     result = ipow(10,count)*result_arr[count] + result;

   return result;
}       

/* log2 function for integers: unsigned log2(unsigned operand) */
unsigned log2(unsigned operand)
{
  unsigned temp;
  unsigned log_val;

  temp = operand-1;
  //temp = operand;
  log_val = 0;

  while (temp > 0)
  {
    temp = temp/2;
    log_val = log_val + 1;
  }

  return log_val;
}         

void print_binary_value(FILE *outfile, int i, int bw)
{
  // Print integer value
  switch (bw)
  {                                       
    case 1:
      fprintf(outfile,"%d",dectobin( i, bw ));
      break;
    case 2:
      fprintf(outfile,"%02d",dectobin( i, bw ));
      break;
    case 3:
      fprintf(outfile,"%03d",dectobin( i, bw ));
      break;
    case 4:
      fprintf(outfile,"%04d",dectobin( i, bw ));
      break;
    case 5:
      fprintf(outfile,"%05d",dectobin( i, bw ));
      break;
    case 6:
      fprintf(outfile,"%06d",dectobin( i, bw ));
      break;
    case 7:
      fprintf(outfile,"%07d",dectobin( i, bw ));
      break;
    case 8:
      fprintf(outfile,"%08d",dectobin( i, bw ));
      break;
    case 9:                                  
      fprintf(outfile,"%09d",dectobin( i, bw ));
      break;
    case 10:
      fprintf(outfile,"%10d",dectobin( i, bw ));
      break;
    case 11:
      fprintf(outfile,"%11d",dectobin( i, bw ));
      break;
    case 12:
      fprintf(outfile,"%12d",dectobin( i, bw ));
      break;
    case 13:
      fprintf(outfile,"%13d",dectobin( i, bw ));
      break;
    case 14:
      fprintf(outfile,"%14d",dectobin( i, bw ));
      break;
    case 15:
      fprintf(outfile,"%15d",dectobin( i, bw ));
      break;
    case 16:
      fprintf(outfile,"%16d",dectobin( i, bw ));
      break;
    default:
      break;
  }
}  

// Print binary value -- First bit is "one".
void print_binary_value_fbone(FILE *outfile, int i)
{
  // Print integer value
  switch ( log2(i) )
  {                                       
    // i = 1
    case 0:
      fprintf(outfile,"%d",dectobin( i, i ));
      break;
    // i = 2:3
    case 1:
      fprintf(outfile,"%d",dectobin( i, log2(i) ));
      break;
    // i = 4:7 
    case 2:
      fprintf(outfile,"%02d",dectobin( i, log2(i) ));
      break;
    // i = 8:15
    case 3:
      fprintf(outfile,"%03d",dectobin( i, log2(i) ));
      break;
    // i = 16:31
    case 4:
      fprintf(outfile,"%04d",dectobin( i, log2(i) ));
      break;
    // i = 32:63
    case 5:
      fprintf(outfile,"%05d",dectobin( i, log2(i) ));
      break;
    default:
      break;
  }
}  
