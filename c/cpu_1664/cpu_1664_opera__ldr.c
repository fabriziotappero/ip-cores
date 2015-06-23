#include "cpu_1664.h"

void cpu_1664_opera__ldr(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_ldr;
 cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)]=cpu->sinia[bait>>cpu_1664_bitio_rd];
}