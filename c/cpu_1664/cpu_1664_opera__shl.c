#include "cpu_1664.h"

void cpu_1664_opera__shl(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_shl;
 n1 sinia_destina=bait&((1<<cpu_1664_bitio_rd)-1);
 n1 sinia_fonte=bait>>cpu_1664_bitio_rd;
 cpu_1664_sinia_t dest=cpu->sinia[sinia_destina];
 cpu_1664_sinia_t desloca;
 n1 bool_depende_c=0;
 
 if(sinia_destina==sinia_fonte)
 {
  desloca=1;
 }
 else
 {
  desloca=cpu->sinia[sinia_fonte]&((sizeof(cpu_1664_sinia_t)*8)-1);
 }
 
 if(desloca!=0)
 {
  nN i;
  for(i=desloca-1;i>31;i-=31)
  {
   dest<<=31;
  }
  dest<<=i;
  
  bool_depende_c=dest>=cpu_1664_sinia_t_di;
  dest<<=1;
 }
 
 cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)]=dest;
 
 if (cpu->depende[cpu_1664_depende_bitio_depende_influe]!=0)
 {
  cpu->depende[cpu_1664_depende_c] = bool_depende_c;
  cpu->depende[cpu_1664_depende_z] = dest==0;
  cpu->depende[cpu_1664_depende_n] = cpu->depende[cpu_1664_depende_z]==0;
 }
}