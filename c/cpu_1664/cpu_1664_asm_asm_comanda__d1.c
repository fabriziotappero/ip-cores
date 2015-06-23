#include "cpu_1664.h"

void cpu_1664_asm_asm_comanda__d1(struct cpu_1664 *cpu, n1 *cadena)
{
 struct lista *lista=cpu_1664_asm_lista_parametre__cadena(cadena);
 n8 valua;
 
 nN i;
 for(i=0;i<lista->contador/sizeof(P);i++)
 {
  cpu->avisa__no_definida=0;
  
  switch(((struct lista **)(lista->datos))[i]->datos[0])
  {
   case '"':
   case '\'':
    lista_ajunta__datos(cpu->lista_imaje_asm, ((struct lista **)(lista->datos))[i]->datos+1, ((struct lista **)(lista->datos))[i]->contador-2);
    break; 
    
   default:
    valua=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista->datos))[i]);
  
    if(cpu->avisa__no_definida!=0)
    {
     cpu_1664_asm_taxe_d_ajunta(cpu, ((struct lista **)(lista->datos))[i], 1);
    }
  
    lista_ajunta__dato(cpu->lista_imaje_asm, valua);
    break;
  }
 }
 
 lista_2_libri(lista);
}