#include "cpu_1664.h"

void cpu_1664_opera__stm(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_stm;
 nN sinia=(bait&((1<<cpu_1664_opera_ldm_sinia)-1));
 cpu_1664_sinia_t cuantia = 1<<((bait&(3<<cpu_1664_opera_ldm_bitio_estende0))>>cpu_1664_opera_ldm_bitio_estende0);
 cpu_1664_sinia_t desloca=cpu->sinia[sinia];
 
 if(((bait&(1<<cpu_1664_opera_ldm_bitio_ajusta))!=0))
 {
  cpu->sinia[sinia]+=((bait&(1<<cpu_1664_opera_ldm_bitio_orienta))==0) ? -cuantia : cuantia;
  
  if((bait&(1<<cpu_1664_opera_ldm_bitio_ordina))==0)
  {
   desloca=cpu->sinia[sinia];
  }
 }
 
 cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_scrive), cuantia, cpu->sinia[0]);
}