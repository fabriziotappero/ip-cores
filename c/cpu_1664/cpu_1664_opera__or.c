#include "cpu_1664.h"

void cpu_1664_opera__or(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_or;
 cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)]|=cpu->sinia[bait>>cpu_1664_bitio_rd];
 
 if (cpu->depende[cpu_1664_depende_bitio_depende_influe]!=0)
 {
  cpu->depende[cpu_1664_depende_z] = (cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)]==0);
  cpu->depende[cpu_1664_depende_n] = cpu->depende[cpu_1664_depende_z]==0;
 }
}