#include "cpu_1664.h"

n1 cpu_1664_asm_opera_parametre_funsiona__3e3e2e(struct cpu_1664 *cpu, struct lista *lista)
{
 nN lista_cuantia=lista->contador/sizeof(P);
 nN Ae,Be,Ce;
 
 if(lista_cuantia>=3)
 {
  Ae=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista->datos))[lista_cuantia-3]);
  Be=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista->datos))[lista_cuantia-2]);
  Ce=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista->datos))[lista_cuantia-1]);
 
  if(((Ae>=8)))
  {
   //eror parametre Ae
   cpu->asm_eror=1;
   return 0;
  }
  if((Be>=8))
  {
   //eror parametre Be
   cpu->asm_eror=1;
   return 0;
  }
  if((Ce>=4))
  {
   //eror parametre Ce
   cpu->asm_eror=1;
   return 0;
  }
 }
 else
 {
  //error parametre cuantia
  cpu->asm_eror=1;
  return 0;
 }
 
 return Ae|(Be<<3)|(Ce<<6);
}