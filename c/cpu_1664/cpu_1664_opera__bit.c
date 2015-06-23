#include "cpu_1664.h"

void cpu_1664_opera__bit(struct cpu_1664 *cpu, n1 bait)
{
 cpu_1664_sinia_t dest=cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)];
 cpu_1664_sinia_t opera=bait>>cpu_1664_bitio_r;
 
 cpu_1664_sinia_t sinia=-1;
 nN i;
 cpu_1664_sinia_t masca;
 
 switch(opera)
 {
  
  case cpu_1664_opera_bit_masima:
   
   for(masca=cpu_1664_sinia_t_di, i=0;((dest&masca)==0)&&(i<(sizeof(cpu_1664_sinia_t)*8)); i++)
   { 
    masca>>=1; 
   }
   
   sinia=i;
   break;
  
  case cpu_1664_opera_bit_minima:
   
   for(masca=1, i=0;((dest&masca)==0)&&(i<(sizeof(cpu_1664_sinia_t)*8)); i++)
   { 
    masca<<=1;
   }
   
   sinia=i;
   break;
  
  case cpu_1664_opera_bit_set:
   
   for(sinia=0, masca=1, i=0; i<(sizeof(cpu_1664_sinia_t)*8); i++) 
   { 
    if((dest&masca)!=0) { sinia++; }
    masca<<=1;
   }
   break;
  
  case cpu_1664_opera_bit_vacua:
   
   for(sinia=0, masca=1, i=0; i<(sizeof(cpu_1664_sinia_t)*8); i++) 
   { 
    if((dest&masca)==0) { sinia++; }
    masca<<=1;
   }
   break;
 }

 cpu->sinia[0]=sinia;
 cpu->opera_sicle=cpu_1664_sicle_opera_bit;
 
 if (cpu->depende[cpu_1664_depende_bitio_depende_influe]!=0)
 {
  cpu->depende[cpu_1664_depende_z] = (dest==0);
  cpu->depende[cpu_1664_depende_n] = cpu->depende[cpu_1664_depende_z]==0;
 }
}