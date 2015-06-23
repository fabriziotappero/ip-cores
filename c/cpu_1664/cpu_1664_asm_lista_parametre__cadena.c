#include "cpu_1664.h"

struct lista * cpu_1664_asm_lista_parametre__cadena(n1 *cadena)
{
 const n1 sinia[] = {cpu_1664_asm_table_sinia};
 const n1 table_clui[] = {cpu_1664_asm_table_clui};
 
 struct lista *lista=lista_nova(128);
 struct lista *lista_;
 n1 *cadena_;
 nN cuantia;
 
 while(1)
 {
  
  switch(*cadena)
  {
   case 0x00: // *** sin "nN cuantia"
   case 0x0a:
   case cpu_1664_asm_sinia_comenta:
   case '>':
   case '}':
   case ')':
   case ']':
    return lista;
   
   case 0x09:
   case ' ':
    cadena++;
    break;
   
   case '\'':
   case '"':
   case '<':
   case '{':
   case '(':
   case '[':
    cuantia=nN_cuantia_brasetida__cadena(cadena, *cadena, table_clui[*cadena]);
    lista_=lista_nova(0);
    lista_ajunta__datos(lista_, cadena, cuantia);
    lista_ajunta__P(lista, (P)lista_);
    cadena+=cuantia;
    break;
   
   default:
    lista_=lista_nova(0);
    for(cadena_=cadena;sinia[*cadena]==1;cadena++){}
    
    switch(*cadena)
    {
     case '{':
     case '(':
     case '[':
      cadena+=nN_cuantia_brasetida__cadena(cadena, *cadena, table_clui[*cadena]);
      break;
    }
    
    lista_ajunta__datos(lista_, cadena_, cadena-cadena_);
    lista_ajunta__P(lista, (P)lista_);
    break;
  } 
 }
}