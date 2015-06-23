#include "cpu_1664.h"

void cpu_1664_reinisia(struct cpu_1664 *cpu)
{
 nN i;
 for(i=0x10; i<0x20; i++)
 {
  cpu->opera_ajusta_vantaje[i]=i;
 }
 
 cpu_1664_eseta(cpu, cpu_1664_eseta_reinisia);
}