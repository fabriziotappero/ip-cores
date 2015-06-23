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

const unsigned char ID_STR[] = "HUCE-microlab,GECKO4COM,0,1.0";

void to_bin( int value ) {
   int mask;
   
   mask = 1<<4;
   while (mask > 0) {
      if ((value&mask) != 0)
         printf("1");
      else
         printf("0");
      mask >>= 1;
   }
}

int main() {
   int loop,index,len,mask;
   unsigned char buffer[32];
   
   len = strlen(ID_STR);
   if (len > 31) {
      printf( "ERROR: ID string too long!\n" );
      return -1;
   }
   index = 0;
   buffer[index]=len;
   for (loop = 0 ; loop < len ; loop++)
      buffer[loop+1] = ID_STR[loop];
   index = len;
   printf( "   done     <= s_done;\n" );
   printf( "   push     <= '1' WHEN s_rom_index(5) = '0' ELSE '0';\n" );
   printf( "   size_bit <= '1' WHEN s_rom_index = \"000000\" ELSE '0';\n\n " );
   printf( "   s_done <= '1' WHEN s_rom_index = \"0");
   to_bin(index);
   printf( "\" ELSE '0';\n\n" );
   printf( "   make_rom_index : PROCESS( clock , start , reset , s_done )\n" );
   printf( "   BEGIN\n      IF (clock'event AND (clock = '1')) THEN\n" );
   printf( "         IF (reset = '1' OR s_done = '1') THEN \n" );
   printf( "            s_rom_index <= (OTHERS => '1');\n" );
   printf( "         ELSIF (start = '1') THEN\n" );
   printf( "            s_rom_index <= (OTHERS => '0');\n" );
   printf( "         ELSEIF (s_rom_index(5) = '0') THEN \n" );
   printf( "            s_rom_index <= unsigned(s_rom_index) + 1;\n" );
   printf( "         END IF;\n      END IF;\n   END PROCESS make_rom_index;\n\n");
   printf( "   make_rom_data : PROCESS( s_rom_index )\n" );
   printf( "   BEGIN\n      CASE (s_rom_index) IS\n" );
   while (index > -1) {
      printf( "         WHEN \"0" );
      to_bin(index);
      printf( "\" => push_data <= X\"%02X\";\n" , buffer[index--] );
   }
   printf( "         WHEN OTHERS   => push_data <= X\"00\";\n" );
   printf( "      END CASE;\n   END PROCESS make_rom_data;\n" );
}
