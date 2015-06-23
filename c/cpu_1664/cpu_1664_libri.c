#include "cpu_1664.h"

void cpu_1664_libri(struct cpu_1664 *cpu)
{
 lista_libri(cpu->lista_imaje);

//asm 
 lista_libri(cpu->lista_imaje_asm);
 lista_libri(cpu->lista_defina_sinia);
 lista_libri(cpu->lista_defina_valua);
 lista_libri(cpu->lista_opera_sinia);
 lista_libri(cpu->lista_opera_parametre_sinia);
 lista_libri(cpu->lista_asm_opera_parametre_referi);
 lista_libri(cpu->lista_asm_opera_parametre_funsiona);
 lista_libri(cpu->lista_asm_comanda_sinia);
 lista_libri(cpu->lista_asm_comanda_funsiona);
 
 lista_2_libri(cpu->lista_inclui_curso);
 
 lista_libri(cpu->lista_eticeta_cadena);
 
//model
 lista_2_libri(cpu->lista_model);
 lista_libri(cpu->lista_model_sinia);
 
 nN i;
 for(i=0;i<cpu->lista_taxe->contador/sizeof(P);i++)
 {
  lista_2_libri(((struct cpu_1664_asm_taxe *)((struct lista **)(cpu->lista_taxe->datos))[i])->lista);
  memoria_libri((P)((struct cpu_1664_asm_taxe *)((struct lista **)(cpu->lista_taxe->datos))[i]));
 }
 lista_libri(cpu->lista_taxe);

 for(i=0;i<cpu->lista_taxe_d->contador/sizeof(P);i++)
 {
  lista_libri(((struct cpu_1664_asm_taxe_d *)((struct lista **)(cpu->lista_taxe_d->datos))[i])->lista);
  memoria_libri((P)((struct cpu_1664_asm_taxe_d *)((struct lista **)(cpu->lista_taxe_d->datos))[i]));
 }
 lista_libri(cpu->lista_taxe_d);
 
//dev
 lista_libri(cpu->lista_dev_asm_desloca);
 lista_2_libri(cpu->lista_dev_asm_cadena);
 lista_2_libri(cpu->lista_dev_opera_cadena);
 lista_libri(cpu->lista_dev_opera_parametre_referi);
 lista_libri(cpu->lista_dev_opera_parametre_funsiona);

//cpu 
 memoria_libri((void *)cpu);
}