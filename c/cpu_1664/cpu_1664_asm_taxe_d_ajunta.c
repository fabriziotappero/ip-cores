#include "cpu_1664.h"

void cpu_1664_asm_taxe_d_ajunta(struct cpu_1664 *cpu, struct lista *lista, nN cuantia)
{
 struct cpu_1664_asm_taxe_d *taxe_d=(struct cpu_1664_asm_taxe_d *)memoria_nova(sizeof(struct cpu_1664_asm_taxe_d));
 taxe_d->cuantia=cuantia;
 taxe_d->desloca=cpu->lista_imaje_asm->contador;
 taxe_d->lista=lista_nova__datos(lista->datos, lista->contador);
 lista_ajunta__P(cpu->lista_taxe_d,(P)taxe_d);
}