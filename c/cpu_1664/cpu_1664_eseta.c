#include "cpu_1664.h"

void cpu_1664_eseta(struct cpu_1664 *cpu, cpu_1664_sinia_t eseta)
{
 cpu->sinia_vantaje[cpu_1664_sinia_reveni_eseta]=cpu->sinia[cpu_1664_sinia_IP];
 cpu->sinia_vantaje[cpu_1664_sinia_IP]=cpu_1664_desloca_eseta;
 cpu_1664_vantaje(cpu, 1);
 cpu->sinia[cpu_1664_sinia_eseta]=eseta<<cpu_1664_sinia_t_bitio;
}