/******************************************************************************/
/*            _   _            __   ____                                      */
/*           / / | |          / _| |  __|                                     */
/*           | |_| |  _   _  / /   | |_                                       */
/*           |  _  | | | | | | |   |  _|                                      */
/*           | | | | | |_| | \ \_  | |__                                      */
/*           |_| |_| \_____|  \__| |____| microLab                            */
/*                                                                            */
/*           Bern University of Applied Sciences (BFH)                        */
/*           Quellgasse 21                                                    */
/*           Room HG 4.33                                                     */
/*           2501 Biel/Bienne                                                 */
/*           Switzerland                                                      */
/*                                                                            */
/*           http://www.microlab.ch                                           */
/******************************************************************************/
/*   GECKO4com
    
     2010/2011 Dr. Theo Kluter
    
     This program is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     (at your option) any later version.
    
     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details. 
     You should have received a copy of the GNU General Public License
     along with these sources.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char *left_screen_strs[16] = {
"            _   _            __   ____  ",
"           / / | |          / _| |  __| ",
"           | |_| |  _   _  / /   | |_   ",
"           |  _  | | | | | | |   |  _|  ",
"           | | | | | |_| | \\ \\_  | |__  ",
"           |_| |_| \\_____|  \\__| |____| microLab",
" ",
"           Bern University of Applied Sciences (BFH)",
"           Quellgasse 21",
"           Room HG 4.33",
"           2501 Biel/Bienne",
"           Switzerland",
" ",
"           http://www.microlab.ch",
"                        ________________",
"                       /USBTMC messages:\\"};

const char *right_screen_strs[16] = {
" ",
"                    GECKO4main and GECKO4com",
"                    ------------------------",
" The GECKO system is a general purpose hardware/software co-",
" design environment for real-time information processing or",
" for system-on-chip (SoC) solutions. The GECKO project supports",
" a new design methodology for system-on-chips, which",
" necessitates co-design of software, fast hardware and",
" dedicated real-time signal processing hardware. Within the",
" GECKO project, the GECKO4main module represents an experimental",
" platform, which offers the necessary computing power for speed",
" intensive real-time algorithms as well as the necessary",
" flexibility for control intensive software tasks.",
" For more information see: http://gecko.microlab.ch",
"                         ______________",
"                        /FPGA messages:\\"};


int main() {
   unsigned char rom[2048];
   int loop,index,chars,sort;
   
   index = 0;
   for (loop = 0 ; loop < 16 ; loop++) {
      if (strlen(left_screen_strs[loop]) > 64) {
         printf("Too long string found!\n" );
         return -1;
      }
      for (chars = 0 ; chars < strlen(left_screen_strs[loop]) ; chars++)
         rom[index++] = left_screen_strs[loop][chars];
      while(chars < 64) {
         chars++;
         rom[index++] = 32;
      }
      if (strlen(right_screen_strs[loop]) > 64) {
         printf("Too long string found!\n" );
         return -1;
      }
      for (chars = 0 ; chars < strlen(right_screen_strs[loop]) ; chars++)
         rom[index++] = right_screen_strs[loop][chars];
      while(chars < 64) {
         chars++;
         rom[index++] = 32;
      }
   }
   if (index != 2048) {
      printf( "ERROR!\n" );
      return -1;
   }
   for (loop = 0 ; loop < 64 ; loop++) {
       if (loop == 0) {
         printf( "      GENERIC MAP ( INIT_00 => X\"" );
      } else {
         printf( "                    INIT_%02X => X\"" , loop );
      }
      for (sort = 31 ; sort > -1 ; sort--) {
         printf("%02X",rom[loop*32+sort] );
      }
      if (loop != 63) {
         printf( "\",\n" );
      } else {
         printf( "\")\n" );
      }
   }
   return 0;
}
