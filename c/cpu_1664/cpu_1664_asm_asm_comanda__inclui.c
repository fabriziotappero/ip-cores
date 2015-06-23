#include "cpu_1664.h"
#ifndef linux
#include <stdio.h>
#endif

void cpu_1664_asm_asm_comanda__inclui(struct cpu_1664 *cpu, n1 *cadena)
{
 struct lista *lista_parametre=cpu_1664_asm_lista_parametre__cadena(cadena);
 #ifdef linux
 sN fix_enflue=-1;
 #else
 FILE *fix_enflue=0;
 #endif
 
 nN i;
 for(i=0;((fix_enflue<=0)&&(i<(cpu->lista_inclui_curso->contador/sizeof(P))));i++)
 {
  struct lista *curso=lista_nova__lista(((struct lista **)(cpu->lista_inclui_curso->datos))[i]);
  
  if((curso->datos[curso->contador-1]!='/')&&(((struct lista **)(lista_parametre->datos))[0]->datos[0]!='/'))
  {
   lista_ajunta__dato(curso, '/');
  }
  
  lista_ajunta__lista(curso, ((struct lista **)(lista_parametre->datos))[0]);
  #ifdef linux
  fix_enflue=open(curso->datos, O_RDONLY);
  #else
  fix_enflue=fopen((char *)curso->datos, "r");
  #endif
  lista_libri(curso);
 }
 
 if(fix_enflue<=0)
 {
  // eror fix_enflue
  cadena__f((P)scrive_stdout, "\neror fix_enflue inclui %s\n",((struct lista **)(lista_parametre->datos))[0]->datos);
 }
 else
 {
  #ifdef linux
  nN grandia_fix_enflue=lseek(fix_enflue, 0, SEEK_END);
  lseek(fix_enflue, 0, SEEK_SET);
  #else
  fseek(fix_enflue, 0, SEEK_END);
  nN grandia_fix_enflue=ftell(fix_enflue);
  rewind(fix_enflue);
  #endif
  
  if(grandia_fix_enflue>0)
  {
   #ifdef linux
   n1 *mmap_fix_enflue=(n1 *)memoria_nova(grandia_fix_enflue);
   read(fix_enflue, mmap_fix_enflue, grandia_fix_enflue);
   //n1 *mmap_fix_enflue=mmap(0, grandia_fix_enflue, PROT_READ, MAP_SHARED, fix_enflue, 0);
   cpu_1664_asm_ajunta__cadena(cpu, mmap_fix_enflue, grandia_fix_enflue);
   //munmap(mmap_fix_enflue, grandia_fix_enflue);
   #else
   n1 *fix_m=(n1 *)memoria_nova(grandia_fix_enflue);
   grandia_fix_enflue=fread(fix_m, 1, grandia_fix_enflue, fix_enflue);
   cpu_1664_asm_ajunta__cadena(cpu, fix_m, grandia_fix_enflue);
   memoria_libri(fix_m);
   #endif
  }
  
  #ifdef linux
  close(fix_enflue);
  #else
  fclose(fix_enflue);
  #endif
 }
 
 lista_2_libri(lista_parametre);
}