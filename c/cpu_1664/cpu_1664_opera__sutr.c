#include "cpu_1664.h"

void cpu_1664_opera__sutr(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_sutr;
 cpu_1664_sinia_t dest=cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)];
 cpu_1664_sinia_t fonte=cpu->sinia[bait>>cpu_1664_bitio_rd];
 cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)]=fonte-dest;
 
 if (cpu->depende[cpu_1664_depende_bitio_depende_influe]!=0)
 {
  cpu->depende[cpu_1664_depende_z] = fonte==dest;
  cpu->depende[cpu_1664_depende_c] = fonte<dest;
  cpu->depende[cpu_1664_depende_n] = cpu->depende[cpu_1664_depende_z]==0;
 }
}