#include "cpu_1664.h"

void cpu_1664_opera__plu(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_plu;
 n1 rd=bait&((1<<cpu_1664_bitio_rd)-1);
 n1 rf=bait>>cpu_1664_bitio_rd;
 
 cpu_1664_sinia_t dest=cpu->sinia[rd];
 cpu->sinia[rd]+=cpu->sinia[rf];
 
 if (cpu->depende[cpu_1664_depende_bitio_depende_influe]!=0)
 {
  cpu->depende[cpu_1664_depende_z] = (cpu->sinia[rd]==0);
  cpu->depende[cpu_1664_depende_c] = (cpu->sinia[rd]<dest);
  cpu->depende[cpu_1664_depende_n] = cpu->depende[cpu_1664_depende_z]==0;
 }
}