#include "cpu_1664.h"

void cpu_1664_opera__rev(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_rev;
 cpu_1664_sinia_t sinia_0;
 nN i;
 cpu_1664_sinia_t desloca;
 
 switch(bait)
 {
 
  case cpu_1664_opera_rev_reveni:
   cpu->sinia[cpu_1664_sinia_IP]=cpu->sinia[cpu_1664_sinia_reveni];
   break;
   
  case cpu_1664_opera_rev_eseta: //interompe /reveni
   if(cpu->vantaje==1)
   {
    cpu_1664_vantaje(cpu, 0);
    cpu->sinia[cpu_1664_sinia_IP]=cpu->sinia_vantaje[cpu_1664_sinia_reveni_eseta];
   }
   else
   {
    cpu_1664_eseta(cpu, cpu_1664_eseta_usor);
   }
   break;
  
  case cpu_1664_opera_rev_ajusta_protejeda:
   if(cpu->vantaje==1)
   {
    cpu->opera_ajusta_protejeda=1;
   }
   break;
  
  case cpu_1664_opera_rev_ajusta_permete:
   if(cpu->vantaje==1)
   {
    cpu->opera_ajusta_protejeda=0;
   }
   break;
  
  case cpu_1664_opera_rev_depende_influe:
   cpu->depende[cpu_1664_depende_bitio_depende_influe]=1;
   break;
  
  case cpu_1664_opera_rev_depende_inoria:
   cpu->depende[cpu_1664_depende_bitio_depende_influe]=0;
   break;
  
  case cpu_1664_opera_rev_sicle_intercambia:
   if(cpu->vantaje==1)
   {
    sinia_0=cpu->sinia[0];
    cpu->sinia[0]=cpu->contador_sicle;
    cpu->contador_sicle=sinia_0;
   }
   break;
  
  case cpu_1664_opera_rev_sicle_usor_limite_intercambia:
   if(cpu->vantaje==1)
   {
    sinia_0=cpu->sinia[0];
    cpu->sinia[0]=cpu->contador_sicle_usor_limite;
    cpu->contador_sicle_usor_limite=sinia_0;
   }
   else
   {
    cpu->sinia[0]=cpu->contador_sicle_usor_limite;
   }
   break;
  
  case cpu_1664_opera_rev_sicle_usor_intercambia:
   if(cpu->vantaje==1)
   {
    sinia_0=cpu->sinia[0];
    cpu->sinia[0]=cpu->contador_sicle_usor;
    cpu->contador_sicle_usor=sinia_0;
   }
   else
   {
    cpu->sinia[0]=cpu->contador_sicle_usor;
   }
   break;
  
  case cpu_1664_opera_rev_state_usor_restora:
   cpu->opera_sicle=16+64;
   
   if(cpu->vantaje==1)
   {
    desloca=cpu->sinia[0];
    
    for(i=0;i<(1<<cpu_1664_bitio_r);i++, desloca+=sizeof(cpu_1664_sinia_t))
    {
     cpu->sinia_usor[i]=cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_leje), sizeof(cpu_1664_sinia_t), 0);
    }
    
    for(i=0x10;i<=0x1f;i++, desloca++)
    {
     cpu->opera_ajusta_usor[i]=cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_leje), 1, 0);
    }
    
    sinia_0=cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_leje), 4, 0);
    for(i=0; i<32; i++)
    {
     cpu->depende_usor[i]|=(sinia_0&1);
     sinia_0>>=1;
    }
    
    desloca+=4;
    cpu->contador_sicle_usor=cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_leje), sizeof(cpu_1664_sinia_t), 0);
    
    desloca+=sizeof(cpu_1664_sinia_t);
    cpu->contador_sicle_usor_limite=cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_leje), sizeof(cpu_1664_sinia_t), 0);
   }
   break;
  
  case cpu_1664_opera_rev_state_usor_reteni:
   cpu->opera_sicle=16+64;
   
   if(cpu->vantaje==1)
   {
    desloca=cpu->sinia[0];
    
    for(i=0;i<(1<<cpu_1664_bitio_r);i++, desloca+=sizeof(cpu_1664_sinia_t))
    {
     cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_scrive), sizeof(cpu_1664_sinia_t), cpu->sinia_usor[i]);
    }
    
    for(i=0x10;i<=0x1f;i++, desloca++)
    {
     cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_scrive), 1, cpu->opera_ajusta_usor[i]);
    }
    
    for(sinia_0=0,i=0; i<32; i++)
    {
     sinia_0|=cpu->depende_usor[i]!=0;
     sinia_0<<=1;
    }
    
    cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_scrive), 4, sinia_0);
    desloca+=4;
    
    cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_scrive), sizeof(cpu_1664_sinia_t), cpu->contador_sicle_usor);
    
    desloca+=sizeof(cpu_1664_sinia_t);
    cpu_1664_umm(cpu, desloca, (1<<cpu_1664_umm_usor_mapa_permete_scrive), sizeof(cpu_1664_sinia_t), cpu->contador_sicle_usor_limite);
   }
   break;
   
  case cpu_1664_opera_rev_bp:
   if(cpu->vantaje==1)
   {
    cpu_1664_eseta(cpu, cpu_1664_eseta_bp_vantaje);
   }
   else
   {
    cpu_1664_eseta(cpu, cpu_1664_eseta_bp_usor);
   }
   break;
  
  case cpu_1664_opera_rev_entra:
   cpu->opera_sicle=8+32;
   cpu->sinia[cpu_1664_sinia_pila]-=32*sizeof(cpu_1664_sinia_t);
   
   for(i=0; i<32; i++)
   {
    cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_pila]+i*sizeof(cpu_1664_sinia_t), (1<<cpu_1664_umm_usor_mapa_permete_scrive), sizeof(cpu_1664_sinia_t), cpu->sinia[cpu_1664_sinia_RETENI_0+i]);
   }
   break;
   
  case cpu_1664_opera_rev_departi:
   cpu->opera_sicle=8+32;
   
   for(i=0; i<32; i++)
   {
    cpu->sinia[cpu_1664_sinia_RETENI_0+i]=cpu_1664_umm(cpu, cpu->sinia[cpu_1664_sinia_pila]+i*sizeof(cpu_1664_sinia_t), (1<<cpu_1664_umm_usor_mapa_permete_leje), sizeof(cpu_1664_sinia_t), 0);
   }
   
   cpu->sinia[cpu_1664_sinia_pila]+=32*sizeof(cpu_1664_sinia_t);
   break;
  
  case cpu_1664_opera_rev_ajusta_reinisia:
   
   if(cpu->vantaje==1||cpu->opera_ajusta_protejeda==0)
   {
    
    for(i=16;i<32;i++)
    {
     cpu->opera_ajusta[i]=i;
    }
   }
   break;
  
  default:
   cpu_1664_eseta(cpu, cpu_1664_eseta_opera_nonlegal);
   break;
 }
}