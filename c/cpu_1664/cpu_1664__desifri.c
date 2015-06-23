#include "cpu_1664.h"

void cpu_1664__desifri(struct cpu_1664 *cpu, cpu_1664_opera_t parola)
{
 n1 c=(parola>>cpu_1664_bitio_opera)&((1<<cpu_1664_bitio_c)-1);
 n1 opera_sifri=(parola&((1<<cpu_1664_bitio_opera)-1));
 n1 opera_desifri=cpu->opera_ajusta[opera_sifri];
 
 if(opera_desifri==cpu_1664_opera_ajusta)
 {
  cpu_1664_opera__ajusta(cpu, parola);
 }
 else if((cpu->depende[c]==1)||(c==7))
 {
  n1 bait=parola>>(cpu_1664_bitio_opera+cpu_1664_bitio_c)&\
   ((1<<(16-((cpu_1664_bitio_opera+cpu_1664_bitio_c))))-1);
  cpu->opera_lista[opera_desifri](cpu, bait);
 }
}