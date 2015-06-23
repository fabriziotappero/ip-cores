// Project
//    pAVR (pipelined AVR) is an 8 bit RISC controller, compatible with Atmel's
//    AVR core, but about 3x faster in terms of both clock frequency and MIPS.
//    The increase in speed comes from a relatively deep pipeline. The original
//    AVR core has only two pipeline stages (fetch and execute), while pAVR has
//    6 pipeline stages:
//       1. PM    (read Program Memory)
//       2. INSTR (load Instruction)
//       3. RFRD  (decode Instruction and read Register File)
//       4. OPS   (load Operands)
//       5. ALU   (execute ALU opcode or access Unified Memory)
//       6. RFWR  (write Register File)
// Version
//    0.32
// Date
//    2002 August 07
// Author
//    Doru Cuturela, doruu@yahoo.com
// License
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA



// About this file...
//    This is a pAVR test that simulates waves on the surface of a liquid.
//    This uses floating point numbers.
//    Checking the result is done by simulating this program on pAVR, and
//       comparing the final mesh (read directly from Data Memory) against
//       the reference final mesh obtained by running this program on a PC.
//       To switch between the two situations, #define or not REF (see below).



//#include <stdio.h>
//#include <stdlib.h>
//#include <string.h>
//#include <sfr2313.h>
//#include <sfr8515.h>
#include <float.h>

#define NR_OX 5
#define NR_OY 5
#define NR_IT 5

// Define this when running reference test on host PC.
// Don't define this when running pAVR test simulation.
#define REF


#ifdef REF
   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>
#endif

void main() {
   #ifdef REF
   FILE *f1;
   char txt[100];
   #endif

   static float zData[NR_OX][NR_OY], vzData[NR_OX][NR_OY];
   static float tmp1, tmp2, tmp3, tmp4;
   static char cData[NR_OX][NR_OY];
   int ix, iy, it;

   for (ix=0; ix<NR_OX; ix++) {
      for (iy=0; iy<NR_OY; iy++) {
         zData[ix][iy] = 0.0;
         vzData[ix][iy] = 0.0;
      }
   }
   zData[1][1]=0.9;

//*
   for (it=0; it<NR_IT; it++) {
      for (ix=0; ix<NR_OX; ix++) {
         for (iy=0; iy<NR_OY; iy++) {
            if ((ix==0)||(iy==0)||(ix==NR_OX-1)||(iy==NR_OY-1)) {
               // Boundary conditions
               zData[ix][iy] = 0.0;
               vzData[ix][iy] = 0.0;
            }
            else {
               vzData[ix][iy] = 0.90*vzData[ix][iy] - 0.0333*(6.0*zData[ix][iy]
                                                              - (zData[ix-1][iy] + zData[ix+1][iy] + zData[ix][iy-1] + zData[ix][iy+1])
                                                              - 0.5 * (zData[ix-1][iy-1] + zData[ix-1][iy+1] + zData[ix+1][iy-1] + zData[ix+1][iy+1]));
               zData[ix][iy] = zData[ix][iy] + vzData[ix][iy];

            }
         }
      }
   }
//*/

   for (ix=0; ix<NR_OX; ix++) {
      for (iy=0; iy<NR_OY; iy++) {
         cData[ix][iy] = (char) (zData[ix][iy]*128.0);
//         if (zData[ix][iy]>=1) cData[ix][iy] =  127;
//         if (zData[ix][iy]<-1) cData[ix][iy] = -128;
      }
   }


   #ifdef REF
   // Write results
   f1 = fopen("results.dat", "wb+");
   if (f1!=NULL) {
      for (ix=0; ix<NR_OX; ix++) {
         for (iy=0; iy<NR_OY; iy++) {
            itoa(cData[ix][iy], txt, 10);
            strcat(txt, "\n");
            fwrite(txt, strlen(txt), 1, f1);
            fflush(f1);
         }
      }
   }
   else {
      printf("Could not write file.\n");
   }
   fclose(f1);
   #endif





//*/
   #ifndef REF
   while (1) {
   }
   #endif
}


