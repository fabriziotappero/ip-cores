#include "cpu_1664.h"

void cpu_1664__pasi(struct cpu_1664 *cpu, n8 pasi)
{
 
 n8 i;
 cpu_1664_opera_t parola;
 
 for(i=0;i<pasi;i++)
 {
  
  if(cpu->umm_memoria[cpu_1664_umm_desloca_interompe_capasi]!=0)
  {
   cpu_1664_sinia_t masca=cpu->umm_memoria[cpu_1664_umm_desloca_interompe_masca];
   cpu_1664_sinia_t ativa=cpu->umm_memoria[cpu_1664_umm_desloca_interompe_ativa];
   
   if((ativa&masca)!=0)
   {
    cpu->umm_memoria[cpu_1664_umm_desloca_interompe_capasi]=0;
    cpu_1664_eseta(cpu, cpu_1664_eseta_umm_interompe);
   }
  }
  
  parola=cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_IP], (1<<cpu_1664_umm_usor_mapa_permete_esecuta), sizeof(cpu_1664_opera_t), 0);
  cpu->sinia[cpu_1664_sinia_IP]+=sizeof(cpu_1664_opera_t);
  cpu->opera_sicle=1;
  cpu_1664__desifri(cpu, parola);
  
  cpu_1664_sinia_t sicle=cpu->opera_sicle;
  
  if(cpu->vantaje==1)
  {
   cpu->contador_sicle+=sicle;
  }
  else
  {
   
   if(cpu->contador_sicle_usor_limite!=cpu_1664_sinia_t_di)
   {
    
    if(cpu->contador_sicle_usor_limite<cpu_1664_sinia_t_di)
    {
     cpu->contador_sicle_usor+=sicle;
     cpu->contador_sicle_usor_limite-=sicle;
    }
    else
    {
     cpu_1664_eseta(cpu, cpu_1664_eseta_sicle_usor_limite);
    } 
   }
  }
 }
}