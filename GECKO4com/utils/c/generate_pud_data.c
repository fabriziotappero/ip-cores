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

unsigned char* strs[13] = {
" ",
"This is a static user window of 13 lines x 64 chars",
"It is stored in the last 832 locations of the",
"PUD memory an can be used to display for example",
"user logos.",
" ",
"It's contents can be written with the *PUD command",
" ",
"For further information see http://gecko.microlab.ch",
" ",
"This is GECKO4main and GECKO4com",
" ",
"Dr. Theo Kluter 2011"};


int main() {
   unsigned char data[2048];
   int loop,index,line,fill;
   FILE *ofile;
   
   for (loop = 0 ; loop < 2048 ; loop++)
      data[loop] = 0xFF;
   index=2048-832;
   for (loop = 0 ; loop < 13 ; loop++) {
      line = 0;
      for (fill = 0  ; fill <(64-strlen(strs[loop])) / 2; fill++) {
         data[index++] = 0x20;
         line++;
      }
      for (fill = 0 ; fill < strlen(strs[loop]) ; fill++) {
         data[index++] = strs[loop][fill];
         line++;
      }
      while (line < 64) {
         data[index++] = 0x20;
         line++;
      }
   }
   printf("%d\n" , index );
   ofile=fopen("pud.cmd","w");
   fprintf( ofile , "*pud " );
   for (loop = 0 ; loop < 2048 ; loop++)
      fputc(data[loop],ofile);
}
