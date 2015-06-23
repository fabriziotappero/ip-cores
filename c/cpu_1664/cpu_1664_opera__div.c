#include "cpu_1664.h"

void cpu_1664_opera__div(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_div;
 cpu_1664_sinia_t masima=cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)];
 cpu_1664_sinia_t minima=cpu->sinia[bait>>cpu_1664_bitio_rd];
 cpu_1664_sinia_t desloca_masima;
 cpu_1664_sinia_t desloca_minima;
 cpu_1664_sinia_t masca;
 
 if(minima==0)
 {
  cpu_1664_eseta(cpu, cpu_1664_eseta_div_zero);
  return;
 }
 else
 {
  nN i;
  for(masca=-1, i=0;((masima&masca)!=0);i++)
  {
   masca<<=1;
  }
  desloca_masima=(sizeof(cpu_1664_sinia_t)*8)-i;
  
  for(masca=1, i=0; ((minima&masca)==0); i++)
  {
   masca<<=1;
  }
  desloca_minima=i;

//x86-64
  for(i=desloca_masima; i>31; i-=31)
  {
   masima<<=31;
  }
  masima<<=i;
 
  for(i=desloca_minima; i>31; i-=31)
  {
   minima>>=31;
  }
  minima>>=i;
 
  cpu_1664_sinia_t loca_div;
  cpu_1664_sinia_t div=masima/minima;
 
  for(masca=-1, i=0; ((div&masca)!=0); i++)
  {
   masca<<=1;
  }
  loca_div=(sizeof(cpu_1664_sinia_t)*8)-i;
 
  for(i=loca_div; i>31; i-=31)
  {
   div<<=31;
  }
  div<<=i;
  
  cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)]=div;
  cpu->sinia[cpu_1664_sinia_desloca]+=loca_div+desloca_minima+desloca_masima;
 }
}