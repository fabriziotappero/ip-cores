#include "cpu_1664.h"

n1 cpu_1664_asm_opera_parametre_funsiona__8ylr(struct cpu_1664 * cpu, struct lista *lista)
{
 
 struct lista *parametre=((struct lista **)(lista->datos))[(lista->contador/sizeof(P))-1];
 n1 bool_nondireta;
 n1 bool_indise=0;
 nN i=0,j;
 n1 sinia;
 
 if(parametre->datos[0]=='[')
 {
  bool_nondireta=1;
  i++;
 }
 else
 {
  bool_nondireta=0;
 }
 
 j=i;
 while(j<parametre->contador)
 {
  
  if(parametre->datos[j++]=='+')
  {
   bool_indise=1;
   i=j;
   break;
  }
 }
 
 j=i;
 while(parametre->datos[i]!=']'&&i<parametre->contador) { i++; }
 sinia=cpu_1664_asm_n8_valua__cadena(cpu, parametre->datos+j, i-j);
 return sinia+((bool_nondireta+(bool_indise<<1))<<6);
}