#include "cpu_1664.h"

void cpu_1664_asm_asm_comanda__m(struct cpu_1664 *cpu, n1 *cadena)
{
 struct lista *lista_parametre=cpu_1664_asm_lista_parametre__cadena(cadena);
 struct lista *model=0;
 
 if(((struct lista **)(lista_parametre->datos))[0]->datos[0]==cpu_1664_asm_sinia_model_abri)
 {
  model=((struct lista **)(lista_parametre->datos))[0];
 }
 else
 {
  cpu_1664_asm_sinia_t sinia=cpu_1664_asm_sinia_t_sinia__cadena(((struct lista **)(lista_parametre->datos))[0]->datos,((struct lista **)(lista_parametre->datos))[0]->contador);
  nN i;
  for(i=0;i<cpu->lista_model_sinia->contador/sizeof(cpu_1664_asm_sinia_t);i++)
  {
   
   if(((cpu_1664_asm_sinia_t *)(cpu->lista_model_sinia->datos))[i]==sinia)
   {
    model=((struct lista **)(cpu->lista_model->datos))[i]; break;
   }
  }
 }
 
 if(model!=0)
 {
  cpu_1664_asm_asm_model__lista(cpu, model, lista_parametre, 1);
 }
 
 lista_2_libri(lista_parametre);
}