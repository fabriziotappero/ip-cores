#include "cpu_1664.h"

void cpu_1664_asm_asm_comanda__implicada(struct cpu_1664 *cpu, n1 *cadena)
{
 //valua inisial ajusta 16..31
 
 nN i;
 for(i=0x10;i<(1<<cpu_1664_bitio_opera);i++)
 {
  cpu->opera_ajusta_asm[i]=i;
 }
}