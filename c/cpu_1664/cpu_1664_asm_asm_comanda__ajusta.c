#include "cpu_1664.h"

void cpu_1664_asm_asm_comanda__ajusta(struct cpu_1664 *cpu, n1 *cadena)
{
 struct lista *lista_parametre=cpu_1664_asm_lista_parametre__cadena(cadena);
 cpu_1664_asm_sinia_t sinia=cpu_1664_asm_sinia_t_sinia__cadena(((struct lista **)(lista_parametre->datos))[1]->datos,((struct lista **)(lista_parametre->datos))[1]->contador);
 n1 ajusta=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista_parametre->datos))[0]);
 
 if((ajusta<16)||(ajusta>31))
 {
  cadena__f((P)scrive_stdout, ".ajusta %s 0x%x no legal @ %x\n", ((struct lista **)(lista_parametre->datos))[0]->datos, ajusta, cpu->lista_imaje_asm->contador);
 }
 else
 {
  
  if(ajusta<(1<<cpu_1664_bitio_ao))
  {
   nN i;
  
   for(i=0;i<(cpu->lista_opera_sinia->contador/sizeof(cpu_1664_asm_sinia_t));i++)
   {
  
    if(((cpu_1664_asm_sinia_t *)(cpu->lista_opera_sinia->datos))[i]==sinia)
    {
     cpu->opera_ajusta_asm[i]=ajusta;
     break;
    }
   }
  }
 }
 
 lista_2_libri(lista_parametre);
}