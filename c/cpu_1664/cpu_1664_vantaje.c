#include "cpu_1664.h"

void cpu_1664_vantaje(struct cpu_1664 *cpu, n1 vantaje)
{
 
 if(vantaje==1)
 {
//  cpu->sinia_vantaje[0]=cpu->sinia_usor[0];
  cpu->sinia=cpu->sinia_vantaje;
  cpu->depende=cpu->depende_vantaje;
  cpu->opera_ajusta=cpu->opera_ajusta_vantaje;
 }
 else
 {
//  cpu->sinia_usor[0]=cpu->sinia_vantaje[0];
  cpu->sinia=cpu->sinia_usor;
  cpu->depende=cpu->depende_usor;
  cpu->opera_ajusta=cpu->opera_ajusta_usor;
 }
 
 cpu->vantaje=vantaje;
}