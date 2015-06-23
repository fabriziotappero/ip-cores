#include "cpu_1664.h"

void cpu_1664_opera__ylr(struct cpu_1664 *cpu, n1 bait)
{
 cpu_1664_sinia_t desloca=0;
 nN eleje=bait>>6;
 nN sinia=bait&((1<<6)-1);
 
 switch(eleje)
 {
  case 0:
   desloca=cpu->sinia[sinia];
   cpu->opera_sicle=cpu_1664_sicle_opera_yli;
   break;
  
  case 2:
   desloca=cpu->sinia[cpu_1664_sinia_IP]+cpu->sinia[sinia];
   cpu->opera_sicle=cpu_1664_sicle_opera_yli;
   break;
  
  case 1:
   desloca=cpu_1664_umm(cpu, cpu->sinia[sinia], (1<<cpu_1664_umm_usor_mapa_permete_leje), sizeof(cpu_1664_sinia_t), 0);
   
   if(sinia==cpu_1664_sinia_IP)
   {
    desloca+=cpu->sinia[cpu_1664_sinia_IP];
    cpu->sinia[cpu_1664_sinia_IP]+=sizeof(cpu_1664_sinia_t);
   }
   cpu->opera_sicle=cpu_1664_sicle_opera_yli+cpu_1664_sicle_opera_ldm;
   break;
  
  case 3:
   desloca=cpu->sinia[cpu_1664_sinia_IP]+cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_IP]+cpu->sinia[sinia], (1<<cpu_1664_umm_usor_mapa_permete_leje), sizeof(cpu_1664_sinia_t), 0);
   cpu->opera_sicle=cpu_1664_sicle_opera_yli+cpu_1664_sicle_opera_ldm;
   break;
 }
 
 cpu->sinia[cpu_1664_sinia_reveni]=cpu->sinia[cpu_1664_sinia_IP];
 cpu->sinia[cpu_1664_sinia_IP]=desloca;
}