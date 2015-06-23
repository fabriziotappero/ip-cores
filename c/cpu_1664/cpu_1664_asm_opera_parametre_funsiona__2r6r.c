#include "cpu_1664.h"

n1 cpu_1664_asm_opera_parametre_funsiona__2r6r(struct cpu_1664 *cpu, struct lista *lista)
{
 nN lista_cuantia=lista->contador/sizeof(P);
 nN Ar,Br;
 
 if(lista_cuantia>=2)
 {
  Ar=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista->datos))[lista_cuantia-2]);
  Br=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista->datos))[lista_cuantia-1]);
 
  if(((Ar>=(1<<cpu_1664_bitio_rd))))
  {
   //eror parametre Ar
   cpu->asm_eror=1;
   return 0;
  }
  if((Br>=(1<<(8-cpu_1664_bitio_rd))))
  {
   //eror parametre Br
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
 
 return Ar|(Br<<cpu_1664_bitio_rd);
}