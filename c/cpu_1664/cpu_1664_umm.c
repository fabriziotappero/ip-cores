#include "cpu_1664.h"

cpu_1664_sinia_t cpu_1664_umm(struct cpu_1664 *cpu, cpu_1664_sinia_t desloca_esije, n1 permete_esije, n1 cuantia, cpu_1664_sinia_t valua)
{
 cpu_1664_sinia_t valua_leje[1]={0};
 cpu_1664_sinia_t valua_scrive[1]={valua};
 cpu_1664_sinia_t *mapa;
 cpu_1664_sinia_t desloca_real;
 n1 permete_leje=(cpu->vantaje!=0);
 n1 permete_scrive=(cpu->vantaje!=0);
 n1 permete_esecuta=(cpu->vantaje!=0);
 n1 esije_leje=((permete_esije&(1<<cpu_1664_umm_usor_mapa_permete_leje))!=0);
 n1 esije_scrive=((permete_esije&(1<<cpu_1664_umm_usor_mapa_permete_scrive))!=0);
 n1 esije_esecuta=((permete_esije&(1<<cpu_1664_umm_usor_mapa_permete_esecuta))!=0);
 
 if(cpu->vantaje!=0)
 {
  desloca_real=desloca_esije;
  
  if((desloca_esije&cpu_1664_umm_desloca)==cpu_1664_umm_desloca)
  {
   if (esije_scrive!=0)
   {
    cpu->umm_memoria[desloca_esije&cpu_1664_umm_desloca_masca]=valua;
    return 0;
   }
   else 
   { 
    return cpu->umm_memoria[desloca_esije&cpu_1664_umm_desloca_masca]; 
   }
  }
 }
 else
 {
  mapa=(cpu_1664_sinia_t *)(cpu->lista_imaje->datos+cpu->umm_memoria[cpu_1664_umm_desloca_usor_mapa]);
  
  if((cpu->umm_memoria[cpu_1664_umm_desloca_usor_mapa]+sizeof(cpu_1664_sinia_t)*3)>=cpu->lista_imaje->capasia)
  {
   cadena__f((P)scrive_stdout, "\neseta usor : memoria asede sin mapa usor [%.*x] %.*x -> IP %x\n",sizeof(cpu_1664_sinia_t)*2,(n8)desloca_esije,sizeof(cpu_1664_sinia_t)*2,mapa,(n8)cpu->sinia[cpu_1664_sinia_IP]);
   cpu_1664_eseta(cpu, cpu_1664_eseta_umm_limite);
   return 0;
  }
  
  while(*mapa!=0)
  {
   n1 permete=mapa[cpu_1664_umm_usor_mapa_cuantia]&0x07;
   cpu_1664_sinia_t mapa_cuantia=(mapa[cpu_1664_umm_usor_mapa_cuantia]>>3)<<3;
   
   if((desloca_esije>=mapa[cpu_1664_umm_usor_mapa_desloca_usor])&&(desloca_esije<(mapa[cpu_1664_umm_usor_mapa_desloca_usor]+mapa_cuantia)))
   {
    desloca_real=desloca_esije-mapa[cpu_1664_umm_usor_mapa_desloca_usor]+mapa[cpu_1664_umm_usor_mapa_desloca_real];
    
    if((permete&permete_esije)!=permete_esije)
    {
     cadena__f((P)scrive_stdout, "\neseta asede esije [%.*x] no permete [%.*x] desloca real [%.*x] IP %.*x\n",sizeof(cpu_1664_sinia_t)*2,(n8)permete_esije,sizeof(cpu_1664_sinia_t)*2,(n8)permete,sizeof(cpu_1664_sinia_t)*2,(n8)desloca_real,sizeof(cpu_1664_sinia_t)*2,(n8)cpu->sinia[cpu_1664_sinia_IP]);
     cpu_1664_eseta(cpu, cpu_1664_eseta_umm_limite);
     return 0;
    }
    
    permete_leje=((permete&(1<<cpu_1664_umm_usor_mapa_permete_leje))!=0);
    permete_scrive=((permete&(1<<cpu_1664_umm_usor_mapa_permete_scrive))!=0);
    permete_esecuta=((permete&(1<<cpu_1664_umm_usor_mapa_permete_esecuta))!=0);
    break;
   }
   
   mapa+=3;
  }
  
  if(*mapa==0)
  {
   cadena__f((P)scrive_stdout, "\neseta usor : memoria asede sin mapa usor desloca [%.*x] -> IP %.*x\n",sizeof(cpu_1664_sinia_t)*2,(n8)desloca_esije,sizeof(cpu_1664_sinia_t)*2,(n8)cpu->sinia[cpu_1664_sinia_IP]);
   cpu_1664_eseta(cpu, cpu_1664_eseta_umm_limite);
   return 0;
  }
 }
 
 if((nN)(desloca_real+cuantia)>=cpu->lista_imaje->capasia) // *__ : (nN <- cpu_1664_sinia_t) >= nN
 {
  cadena__f((P)scrive_stdout, "\neseta : memoria asede : desloca [%.*x] suprapasa capasia (%x) -> IP %.*x\n",sizeof(cpu_1664_sinia_t)*2,(n8)(desloca_real+cuantia),(n8)cpu->lista_imaje->capasia,sizeof(cpu_1664_sinia_t)*2,(n8)cpu->sinia[cpu_1664_sinia_IP]);
  cpu_1664_eseta(cpu, cpu_1664_eseta_umm_limite);
  return 0;
 }
 else
 {
  nN i;
  
  if(esije_leje)
  {
   
   if(permete_leje)
   {
    
    for(i=0;i<cuantia;i++)
    {
     ((n1 *)(valua_leje))[i]=((n1 *)(cpu->lista_imaje->datos+desloca_real))[i];
    }
    return valua_leje[0];
   }
   else
   {
    cadena__f((P)scrive_stdout, "\neseta asede leje no permete @ %.*x\n",sizeof(cpu_1664_sinia_t)*2,cpu->sinia[cpu_1664_sinia_IP]);
    cpu_1664_eseta(cpu, cpu_1664_eseta_umm_leje);
    return 0;
   }
  }
  if(esije_esecuta)
  {
   
   if(permete_esecuta)
   {
    for(i=0;i<cuantia;i++)
    {
     ((n1 *)(valua_leje))[i]=((n1 *)(cpu->lista_imaje->datos+desloca_real))[i];
    }
    
    return valua_leje[0];
   }
   else
   {
    cadena__f((P)scrive_stdout, "\neseta asede esecuta no permete @ %.*x\n",sizeof(cpu_1664_sinia_t)*2,cpu->sinia[cpu_1664_sinia_IP]);
    cpu_1664_eseta(cpu, cpu_1664_eseta_umm_esecuta);
    return 0;
   }
  }
  if(esije_scrive)
  {
   
   if(permete_scrive)
   {
    for(i=0;i<cuantia;i++)
    {
     ((n1 *)(cpu->lista_imaje->datos+desloca_real))[i]=((n1 *)(valua_scrive))[i];
    }
    
    return 0;
   }
   else
   {
    cadena__f((P)scrive_stdout, "\neseta asede escrive no permete @ %.*x\n",sizeof(cpu_1664_sinia_t)*2,cpu->sinia[cpu_1664_sinia_IP]);
    cpu_1664_eseta(cpu, cpu_1664_eseta_umm_scrive);
    return 0;
   }
  }
 }
 
 cadena__f((P)scrive_stdout, "\n**-\n"); return 0; 
}