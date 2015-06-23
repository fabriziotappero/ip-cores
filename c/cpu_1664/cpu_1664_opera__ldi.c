#include "cpu_1664.h"

void cpu_1664_opera__ldi(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_ldi;
 cpu->sinia[0]=(((cpu->sinia[0]|0xff)^0xff)|bait);
}