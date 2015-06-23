#include "cpu_1664.h"

void cpu_1664_opera__ajusta(struct cpu_1664 *cpu, cpu_1664_opera_t parola)
{
 if((cpu->vantaje==1)||(cpu->opera_ajusta_protejeda==0))
 {
  cpu->opera_ajusta[0x10|((parola>>5)&0x0f)]=((parola>>9)&0x7f);
 }
 
 cpu->opera_sicle=cpu_1664_sicle_opera_ajusta;
}