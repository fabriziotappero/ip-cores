#include "cpu_1664.h"

void cpu_1664_opera__cmp(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_cmp;
 cpu_1664_sinia_t dest=cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)];
 cpu_1664_sinia_t fonte=cpu->sinia[bait>>cpu_1664_bitio_rd];
 cpu->depende[cpu_1664_depende_z]=(dest==fonte);
 cpu->depende[cpu_1664_depende_c]=(dest>fonte);
 cpu->depende[cpu_1664_depende_o]=(dest<fonte);
 cpu->depende[cpu_1664_depende_n]=(dest!=fonte);
}