#include "cpu_1664.h"

void cpu_1664_opera__ldb(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_ldb;
 n1 sinia_destina=bait&((1<<cpu_1664_bitio_rd)-1);
 n1 desloca=bait>>cpu_1664_bitio_rd;
 
 cpu_1664_sinia_t masca;
 
 nN i;
 for(masca=1,i=desloca; i>31; i-=31)
 {
  masca<<=31;
 }
 masca<<=i;

 cpu->depende[0]=(cpu->sinia[sinia_destina]&masca)!=0;
}