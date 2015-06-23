#include "cpu_1664.h"

void cpu_1664_asm_asm_opera__lista_2(struct cpu_1664 *cpu, struct lista *lista_parametre)
{
 cpu_1664_opera_t parola;
 n1 depende;
 n1 opera_sifri,opera_desifri;
 nN opera_parametre_indise;
 n1 parametre;
 cpu->avisa__no_definida=0;
 
 opera_desifri=cpu_1664_asm_n1_opera_valua__lista(cpu, ((struct lista **)(lista_parametre->datos))[0]);
 
 if (opera_desifri!=0xff)
 {
  depende=0x07;
  opera_parametre_indise=1;
 }
 else if((lista_parametre->contador/sizeof(P))>1)
 {
  depende=cpu_1664_asm_n8_valua__lista(cpu,((struct lista **)(lista_parametre->datos))[0]);
  opera_desifri=cpu_1664_asm_n1_opera_valua__lista(cpu, ((struct lista **)(lista_parametre->datos))[1]);
  opera_parametre_indise=2;
 }
 
 if(opera_desifri!=0xff)
 {
  opera_sifri=cpu->opera_ajusta_asm[opera_desifri];
  
  if(opera_sifri==0)
  {
   n1 opera_ajusta=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista_parametre->datos))[(lista_parametre->contador/sizeof(P))-2]);
   
   if((opera_ajusta<0x10)||(opera_ajusta>0x1f))
   {
    cadena__f((P)scrive_stdout, "eror opera ajusta %x 0x00..0x10\n",opera_ajusta);
    cpu->asm_eror=1;
   }
   else
   {
    opera_ajusta-=0x10;
   }
   n1 opera_sustitua=cpu_1664_asm_n1_opera_valua__lista(cpu, ((struct lista **)(lista_parametre->datos))[(lista_parametre->contador/sizeof(P))-1]);
   
   if (opera_sustitua==0xff)
   {
    opera_sustitua=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista_parametre->datos))[(lista_parametre->contador/sizeof(P))-1]);
   }
   parola=opera_sifri+(opera_ajusta<<(cpu_1664_bitio_opera))+(opera_sustitua<<(cpu_1664_bitio_opera+cpu_1664_bitio_co));
  }
  else
  {
  
   lista_ajunta__cpu_1664_sinia_t(cpu->lista_dev_asm_desloca, cpu->lista_imaje_asm->contador); //*__ ? + imaje->contador
   lista_ajunta__P(cpu->lista_dev_asm_cadena, lista_2_nova__lista_2(lista_parametre));
   
   parametre=(((n1 (**)(struct cpu_1664 *, struct lista *))(cpu->lista_asm_opera_parametre_funsiona->datos))[opera_desifri](cpu, lista_parametre));
   parola=(opera_sifri|(depende<<cpu_1664_bitio_opera))|(parametre<<8);
  }
  if(cpu->avisa__no_definida!=0)
  {
   struct cpu_1664_asm_taxe *taxe=(struct cpu_1664_asm_taxe *)memoria_nova(sizeof(struct cpu_1664_asm_taxe));
   taxe->parola=parola;
   taxe->asm_opera_parametre_funsiona=((n1 (**)(struct cpu_1664 *, struct lista *))(cpu->lista_asm_opera_parametre_funsiona->datos))[opera_desifri];
   taxe->desloca=cpu->lista_imaje_asm->contador;
   taxe->lista=lista_2_nova__lista_2(lista_parametre);
   lista_ajunta__P(cpu->lista_taxe, (P)taxe);
  }
  
  lista_ajunta__cpu_1664_asm_parola_t(cpu->lista_imaje_asm, parola);
 }
 else
 {
  cpu_1664_asm_sinia_t sinia=cpu_1664_asm_sinia_t_sinia__cadena(((struct lista **)(lista_parametre->datos))[0]->datos,((struct lista **)(lista_parametre->datos))[0]->contador);
  cpu_1664_asm_sinia_t valua;
  
  if((lista_parametre->contador/sizeof(P))>1)
  {
   valua=cpu_1664_asm_n8_valua__lista(cpu, ((struct lista **)(lista_parametre->datos))[1]);
  }
  else
  {
   valua=cpu->lista_imaje_asm->contador;
  }
  
  cpu_1664_asm_defina_valua(cpu, sinia, valua);
  
  //eror opera_sifri
  //cadena__f((P)scrive_stdout, "\neror opera_sifri\n");
  //cpu->asm_eror=1;
 }
}