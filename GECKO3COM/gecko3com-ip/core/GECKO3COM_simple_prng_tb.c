/* GECKO3COM
 *
 * Copyright (C) 2010 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Bern University of Applied Sciences
 *  |  _ <'|  _) |  _  |   School of Engineering and
 *  | (_) )| |   | | | |   Information Technology
 *  (____/'(_)   (_) (_)
 *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details. 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*********************************************************************/
/** \file     GECKO3COM_simple_prng_tb.c
 *********************************************************************
 * \brief     simple programm to fill a file with a desired length value 
 *
 *  to change the length of the value simply change the type of the value 
 *  variable.
 *
 *  compile with: 
 *  "gcc -o GECKO3COM_simple_prng_tb GECKO3COM_simple_prng_tb.c"
 *
 * \author    Christoph Zimmermann bfh.ch
 * \date      26. February 2010
 *
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

int main (void)
{
  /*--------------------------------------------------------------------------*/
  /* start of user configuration values */

  /* variable type of the desired value */
  uint32_t prng_data = 0x55555555; 
  
  /* desired filename */
  const char* FILENAME = "GECKO3COM_simple_prng_tb.hex"; 
  
  /* how many times should the datablock repeated in the file */
  int16_t loop = 4096;

  /* end of configuration values */
  /*--------------------------------------------------------------------------*/

  FILE *output;
  uint64_t i,j;

  uint32_t prng_feedback;

  printf("Hello, this programm will write values with a bit length of %d to the file %s\n", sizeof(prng_data)*8, FILENAME);

  output = fopen(FILENAME, "w+b");

  /* create the desired number of data blocks */
  for(j=0; j<loop;j++) {

    if(!fwrite(&prng_data, sizeof(prng_data), 1, output)) {
      printf("ERROR writing to the file\n");
      return 0;
    }

    prng_feedback = prng_data >> 10;
    prng_feedback ^= prng_data >> 12;
    prng_feedback ^= prng_data >> 13;
    prng_feedback ^= prng_data >> 15;

    prng_feedback &= 0x00000001;

    prng_data = prng_data << 1;
    prng_data |= prng_feedback;
  }

  fclose(output);
  return 1;
}
