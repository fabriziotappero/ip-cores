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

const char *strings[32] = {
"Xilinx Spartan 3 XC3S1000FGG676, not configured\n",
"Xilinx Spartan 3 XC3S1500FGG676, not configured\n",
"Xilinx Spartan 3 XC3S2000FGG676, not configured\n",
"Xilinx Spartan 3 XC3S4000FGG676, not configured\n",
"Xilinx Spartan 3 XC3S5000FGG676, not configured\n",
"No FPGA mounted or unknown FPGA type\n",
"No FPGA mounted or unknown FPGA type\n",
"No FPGA mounted or unknown FPGA type\n",
"Xilinx Spartan 3 XC3S1000FGG676, running\n",
"Xilinx Spartan 3 XC3S1500FGG676, running\n",
"Xilinx Spartan 3 XC3S2000FGG676, running\n",
"Xilinx Spartan 3 XC3S4000FGG676, running\n",
"Xilinx Spartan 3 XC3S5000FGG676, running\n",
"No FPGA mounted or unknown FPGA type\n",
"No FPGA mounted or unknown FPGA type\n",
"No FPGA mounted or unknown FPGA type\n",
"Undefined State, soldering problem?\n",
"GECKO4main: USB supplied, powering BUS, Flash programmed\n",
"Undefined State, soldering problem?\n",
"GECKO4main: USB supplied, Flash programmed\n",
"GECKO4main: GENIO1 supplied, powering BUS, Flash programmed\n",
"Undefined State, soldering problem?\n",
"GECKO4main: GENIO1 supplied, Flash programmed\n",
"Undefined State, soldering problem?\n",
"Undefined State, soldering problem?\n",
"GECKO4main: USB supplied, powering BUS, Flash empty\n",
"Undefined State, soldering problem?\n",
"GECKO4main: USB supplied, Flash empty\n",
"GECKO4main: GENIO1 supplied, powering BUS, Flash empty\n",
"Undefined State, soldering problem?\n",
"GECKO4main: GENIO1 supplied, Flash empty\n",
"Undefined State, soldering problem?\n"};

int main () {
   unsigned char rom[2048];
   int loop,charcnt,index,sort;
   
   for (loop = 0 ; loop < 32 ; loop++) {
      if (strlen(strings[loop]) > 62) {
         printf ("Too long string found!\n");
         return -1;
      }
      rom[loop*64] = strlen(strings[loop])+128;
      index = 1;
      for (charcnt = 0 ; charcnt < strlen(strings[loop]) ; charcnt++) {
         rom[(loop*64)+index++] = strings[loop][charcnt];
         printf("%c",strings[loop][charcnt]);
      }
      while (index < 64) {
         rom[(loop*64)+index++] = 0;
      }
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
