#include "cpu_1664.h"

void cpu_1664_asm_opera_parametre_funsiona_ajunta(struct cpu_1664 *cpu, char *ccadena, cpu_1664_asm_opera_parametre_funsiona, cpu_1664_dev_opera_parametre_funsiona)
{
 lista_ajunta__cpu_1664_asm_sinia_t(cpu->lista_opera_parametre_sinia, cpu_1664_asm_sinia_t_sinia__cadena((n1 *)ccadena, nN_cuantia__ccadena(ccadena)));
 lista_ajunta__P(cpu->lista_asm_opera_parametre_referi, asm_opera_parametre_funsiona);
 lista_ajunta__P(cpu->lista_dev_opera_parametre_referi, dev_opera_parametre_funsiona);
}