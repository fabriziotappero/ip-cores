#include "cpu_1664.h"

void cpu_1664_asm_asm_opera__cadena(struct cpu_1664 *cpu, n1 *cadena)
{
 struct lista *lista=cpu_1664_asm_lista_parametre__cadena(cadena);
 cpu_1664_asm_asm_opera__lista_2(cpu, lista);
 lista_2_libri(lista);
}