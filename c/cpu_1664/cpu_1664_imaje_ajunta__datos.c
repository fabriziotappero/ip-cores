#include "cpu_1664.h"

void cpu_1664_imaje_ajunta__datos(struct cpu_1664 *cpu, n1 *datos, nN cuantia)
{
 lista_ajunta__datos(cpu->lista_imaje, datos, cuantia);
 cpu_1664_reinisia(cpu); 
}