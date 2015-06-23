#include "cpu_1664.h"

struct cpu_1664 * cpu_1664_nova(nN cuantia)
{
 struct cpu_1664 *cpu=(struct cpu_1664 *)memoria_nova(sizeof(struct cpu_1664));
 cpu->lista_imaje=lista_nova(cuantia);
 
 nN i;
 for(i=0;i<(1<<cpu_1664_bitio_opera);i++)
 {
  cpu->opera_ajusta_vantaje[i]=i;
  cpu->opera_ajusta_usor[i]=i;
 }
  
 //cpu->opera_lista[cpu_1664_opera_ajusta]=cpu_1664_opera__ajusta;
 for(i=1; i<(1<<cpu_1664_bitio_ao); i++)
 {
  cpu->opera_lista[i]=cpu_1664_opera___; //opera nonlegal
 }
 
 cpu->opera_lista[cpu_1664_opera_yli]=cpu_1664_opera__yli;
 cpu->opera_lista[cpu_1664_opera_ylr]=cpu_1664_opera__ylr;
 cpu->opera_lista[cpu_1664_opera_ldi]=cpu_1664_opera__ldi;
 cpu->opera_lista[cpu_1664_opera_ldis]=cpu_1664_opera__ldis;
 cpu->opera_lista[cpu_1664_opera_ldm]=cpu_1664_opera__ldm;
 cpu->opera_lista[cpu_1664_opera_stm]=cpu_1664_opera__stm;
 cpu->opera_lista[cpu_1664_opera_ldr]=cpu_1664_opera__ldr;
 cpu->opera_lista[cpu_1664_opera_str]=cpu_1664_opera__str;
 cpu->opera_lista[cpu_1664_opera_cam]=cpu_1664_opera__cam;
 cpu->opera_lista[cpu_1664_opera_ldb]=cpu_1664_opera__ldb;
 cpu->opera_lista[cpu_1664_opera_stb]=cpu_1664_opera__stb;
 cpu->opera_lista[cpu_1664_opera_cmp]=cpu_1664_opera__cmp;
 cpu->opera_lista[cpu_1664_opera_dep]=cpu_1664_opera__dep;
 cpu->opera_lista[cpu_1664_opera_bit]=cpu_1664_opera__bit;
 cpu->opera_lista[cpu_1664_opera_rev]=cpu_1664_opera__rev;
 
 cpu->opera_lista[cpu_1664_opera_and]=cpu_1664_opera__and;
 cpu->opera_lista[cpu_1664_opera_or]=cpu_1664_opera__or;
 cpu->opera_lista[cpu_1664_opera_eor]=cpu_1664_opera__eor;
 cpu->opera_lista[cpu_1664_opera_mul]=cpu_1664_opera__mul;
 cpu->opera_lista[cpu_1664_opera_plu]=cpu_1664_opera__plu;
 cpu->opera_lista[cpu_1664_opera_sut]=cpu_1664_opera__sut;
 cpu->opera_lista[cpu_1664_opera_sutr]=cpu_1664_opera__sutr;
 cpu->opera_lista[cpu_1664_opera_div]=cpu_1664_opera__div;
 cpu->opera_lista[cpu_1664_opera_shl]=cpu_1664_opera__shl;
 cpu->opera_lista[cpu_1664_opera_shr]=cpu_1664_opera__shr;
 cpu->opera_lista[cpu_1664_opera_sar]=cpu_1664_opera__sar;
 
 cpu_1664_vantaje(cpu,1);
 
 for(i=0;i<1<<cpu_1664_bitio_r;i++)
 {
  cpu->sinia_vantaje[i]=0;
  cpu->sinia_usor[i]=0;
 }
 
 for(i=0;i<32;i++)
 {
  cpu->depende[i]=0;
 }
 
 for(i=0;i<32;i++)
 {
  cpu->opera_ajusta_vantaje[i]=i;
  cpu->opera_ajusta_usor[i]=i;
  cpu->opera_ajusta_asm[i]=i;
 }
// cpu->opera_ajusta_protejeda=0;
// cpu->depende_opera_influe_vantaje=0;
// cpu->depende_opera_influe_usor=0;
// cpu->sinia[cpu_1664_sinia_eseta]=0;
 
 cpu->opera_sicle=0;
 cpu->contador_sicle=0;
 cpu->contador_sicle_usor=0;
 cpu->contador_sicle_usor_limite=0;

 //asm
 cpu->asm_eror=0;
 cpu->lista_imaje_asm=lista_nova(0);
 cpu->lista_defina_sinia=lista_nova(0);
 cpu->lista_defina_valua=lista_nova(0);
 cpu->lista_opera_sinia=lista_nova(0);
// cpu->lista_opera_ajusta=lista_nova(0);
 cpu->lista_opera_parametre_sinia=lista_nova(0);
 cpu->lista_asm_opera_parametre_referi=lista_nova(0);
 cpu->lista_asm_opera_parametre_funsiona=lista_nova(0);
 cpu->lista_asm_comanda_sinia=lista_nova(0);
 cpu->lista_asm_comanda_funsiona=lista_nova(0);
 cpu->lista_taxe=lista_nova(0);
 cpu->lista_taxe_d=lista_nova(0);
 
 cpu->lista_eticeta_cadena=lista_nova(0);
 
  //inclui
  cpu->lista_inclui_curso=lista_nova(0);
  lista_ajunta__P(cpu->lista_inclui_curso, lista_nova__ccadena("/"));
 
 
 //model
 cpu->lista_model=lista_nova(0);
 cpu->lista_model_sinia=lista_nova(0);

 cpu->avisa__no_definida=0;
 
 //dev
 cpu->lista_dev_asm_desloca=lista_nova(0);
 cpu->lista_dev_asm_cadena=lista_nova(0);
 cpu->lista_dev_opera_cadena=lista_nova(0);
 cpu->lista_dev_opera_parametre_referi=lista_nova(0);
 cpu->lista_dev_opera_parametre_funsiona=lista_nova(0);
 
//a ordina frecuentia
 cpu_1664_asm_opera_parametre_funsiona_ajunta(cpu, "2r6r", cpu_1664_asm_opera_parametre_funsiona__2r6r, cpu_1664_dev_opera_parametre_funsiona__2r6r);
 cpu_1664_asm_opera_parametre_funsiona_ajunta(cpu, "8e", cpu_1664_asm_opera_parametre_funsiona__8e, cpu_1664_dev_opera_parametre_funsiona__8e);
 cpu_1664_asm_opera_parametre_funsiona_ajunta(cpu, "8y", cpu_1664_asm_opera_parametre_funsiona__8y, cpu_1664_dev_opera_parametre_funsiona__8y);
 cpu_1664_asm_opera_parametre_funsiona_ajunta(cpu, "8ylr", cpu_1664_asm_opera_parametre_funsiona__8ylr, cpu_1664_dev_opera_parametre_funsiona__8ylr);
 cpu_1664_asm_opera_parametre_funsiona_ajunta(cpu, "m", cpu_1664_asm_opera_parametre_funsiona__m, cpu_1664_dev_opera_parametre_funsiona__m);
 cpu_1664_asm_opera_parametre_funsiona_ajunta(cpu, "6r2r", cpu_1664_asm_opera_parametre_funsiona__6r2r, cpu_1664_dev_opera_parametre_funsiona__6r2r);
 cpu_1664_asm_opera_parametre_funsiona_ajunta(cpu, "3e3e2e", cpu_1664_asm_opera_parametre_funsiona__3e3e2e, cpu_1664_dev_opera_parametre_funsiona__3e3e2e);
 cpu_1664_asm_opera_parametre_funsiona_ajunta(cpu, "ajusta_vacua", 0, 0);
 
//a ordina frecuentia
 cpu_1664_asm_asm_comanda_ajunta(cpu, "m", cpu_1664_asm_asm_comanda__m);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "defina", cpu_1664_asm_asm_comanda__defina);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "ajusta", cpu_1664_asm_asm_comanda__ajusta);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "implicada", cpu_1664_asm_asm_comanda__implicada);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "ds", cpu_1664_asm_asm_comanda__ds);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "d1", cpu_1664_asm_asm_comanda__d1);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "d4", cpu_1664_asm_asm_comanda__d4);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "do", cpu_1664_asm_asm_comanda__do);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "d2", cpu_1664_asm_asm_comanda__d2);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "model", cpu_1664_asm_asm_comanda__model);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "inclui", cpu_1664_asm_asm_comanda__inclui);
 cpu_1664_asm_asm_comanda_ajunta(cpu, "opera", cpu_1664_asm_asm_comanda__opera);
 
 cpu_1664_asm_ajunta__ccadena(cpu, ".opera ajusta ajusta_vacua"); //opera 'falsa' - pseudo op
 
 return cpu;
}