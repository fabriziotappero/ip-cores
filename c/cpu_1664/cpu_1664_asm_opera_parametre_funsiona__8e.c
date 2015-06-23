#include "cpu_1664.h"

n1 cpu_1664_asm_opera_parametre_funsiona__8e(struct cpu_1664 * cpu, struct lista *lista)
{
 n1 bait=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista->datos))[(lista->contador/sizeof(P))-1]);
 
 return bait;
}