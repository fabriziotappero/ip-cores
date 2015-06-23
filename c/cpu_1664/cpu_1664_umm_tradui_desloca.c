#include "cpu_1664.h"

cpu_1664_sinia_t cpu_1664_umm_tradui_desloca(struct cpu_1664 *cpu, cpu_1664_sinia_t desloca_esije)
{
 cpu_1664_sinia_t *mapa=(cpu_1664_sinia_t *)(cpu->lista_imaje->datos+cpu->umm_memoria[cpu_1664_umm_desloca_usor_mapa]);
 cpu_1664_sinia_t desloca_real=-1;
 
  if((cpu->umm_memoria[cpu_1664_umm_desloca_usor_mapa]+sizeof(cpu_1664_sinia_t)*3)>=cpu->lista_imaje->capasia)
  {
   cadena__f((P)scrive_stdout, "\neseta usor : memoria asede sin mapa usor [%.*x] %*.x -> IP %.*x\n",sizeof(cpu_1664_sinia_t)*2,desloca_esije,sizeof(cpu_1664_sinia_t)*2,mapa,sizeof(cpu_1664_sinia_t)*2,cpu->sinia[cpu_1664_sinia_IP]);
   cpu_1664_eseta(cpu, cpu_1664_eseta_umm_limite);
   return -1;
  }
  
  while(*mapa!=0)
  {
   cpu_1664_sinia_t cuantia=(mapa[cpu_1664_umm_usor_mapa_cuantia]&(((cpu_1664_sinia_t)(-1))-0x07));
   
   if((desloca_esije>=mapa[cpu_1664_umm_usor_mapa_desloca_usor])&&(desloca_esije<(mapa[cpu_1664_umm_usor_mapa_desloca_usor]+cuantia)))
   {
    desloca_real=desloca_esije-mapa[cpu_1664_umm_usor_mapa_desloca_usor]+mapa[cpu_1664_umm_usor_mapa_desloca_real];
    break;
   }
   
   mapa+=3;
  }
  
  if(*mapa==0)
  {
   cadena__f((P)scrive_stdout, "\neseta usor : memoria asede sin mapa usor desloca esije [%.*x] -> IP %.*x\n",sizeof(cpu_1664_sinia_t)*2,desloca_esije,sizeof(cpu_1664_sinia_t)*2,cpu->sinia[cpu_1664_sinia_IP]);
   cpu_1664_eseta(cpu, cpu_1664_eseta_umm_limite);
   return -1;
  }
   
  return desloca_real;
}
