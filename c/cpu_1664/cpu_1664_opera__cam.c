#include "cpu_1664.h"

void cpu_1664_opera__cam(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_cam;
 cpu_1664_sinia_t dest=cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)];
 cpu_1664_sinia_t fonte=cpu->sinia[bait>>cpu_1664_bitio_rd];
 cpu->sinia[bait&((1<<cpu_1664_bitio_rd)-1)]=fonte;
 cpu->sinia[bait>>cpu_1664_bitio_rd]=dest;
}