#include "cpu_1664.h"

void cpu_1664_opera__dep(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_dep;
 n1 dest=bait&0x07;
 n1 fonte=(bait>>3)&0x07;
 n1 eleje=bait>>6; 
 n1 dep;
 cpu->depende[7]=1;
 
 switch(eleje)
 {
  case 0: //eor
   cpu->depende[dest]^=cpu->depende[fonte];
   break;
  
  case 1: //and
   cpu->depende[dest]&=cpu->depende[fonte];
   break;
  
  case 2: //or
   cpu->depende[dest]|=cpu->depende[fonte];
   break;
  
  case 3: //intercambia
   dep=cpu->depende[dest];
   cpu->depende[dest]=cpu->depende[fonte];
   cpu->depende[fonte]=dep;
   break;
 }
}