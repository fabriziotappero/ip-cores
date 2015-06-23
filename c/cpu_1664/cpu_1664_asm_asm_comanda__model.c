#include "cpu_1664.h"

void cpu_1664_asm_asm_comanda__model(struct cpu_1664 *cpu, n1 *cadena)
{
 struct lista *lista_parametre=cpu_1664_asm_lista_parametre__cadena(cadena);
 struct lista *lista=lista_nova__datos(((struct lista **)(lista_parametre->datos))[1]->datos,((struct lista **)(lista_parametre->datos))[1]->contador);
 cpu_1664_asm_sinia_t sinia=cpu_1664_asm_sinia_t_sinia__cadena(((struct lista **)(lista_parametre->datos))[0]->datos,((struct lista **)(lista_parametre->datos))[0]->contador);
 lista_ajunta__P(cpu->lista_model, lista);
 lista_ajunta__cpu_1664_asm_sinia_t(cpu->lista_model_sinia, sinia);
 lista_2_libri(lista_parametre);
}