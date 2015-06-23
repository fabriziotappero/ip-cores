#include "cpu_1664.h"

cpu_1664_sinia_t cpu_1664_asm_n8_valua__lista(struct cpu_1664 *cpu, struct lista *lista)
{
 cpu_1664_sinia_t valua=cpu_1664_asm_n8_valua__cadena(cpu, lista->datos, lista->contador);
 
 return valua;
}