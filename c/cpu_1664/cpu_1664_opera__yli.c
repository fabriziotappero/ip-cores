#include "cpu_1664.h"

void cpu_1664_opera__yli(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_yli;
 cpu->sinia[cpu_1664_sinia_reveni]=cpu->sinia[cpu_1664_sinia_IP];
 cpu_1664_sinia_t desloca=bait<<1;
 
 if(desloca>=0x100)
 {
  desloca=(((-1)-0x1ff)|desloca); 
 }
 
 cpu->sinia[cpu_1664_sinia_IP]+=desloca-sizeof(cpu_1664_opera_t);
}