#include "cpu_1664.h"

void cpu_1664_asm_asm_comanda__defina(struct cpu_1664 *cpu, n1 *cadena)
{
 struct lista *lista_parametre=cpu_1664_asm_lista_parametre__cadena(cadena);
 cpu_1664_asm_sinia_t sinia=cpu_1664_asm_sinia_t_sinia__cadena(((struct lista **)(lista_parametre->datos))[0]->datos,((struct lista **)(lista_parametre->datos))[0]->contador);
 cpu_1664_sinia_t valua;
 
 if(lista_parametre->contador/sizeof(P)>1)
 {
  valua=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista_parametre->datos))[1]);
 }
 else
 {
  valua=1;
 }
 cpu_1664_asm_defina_valua(cpu, sinia, valua);
 lista_2_libri(lista_parametre);
}