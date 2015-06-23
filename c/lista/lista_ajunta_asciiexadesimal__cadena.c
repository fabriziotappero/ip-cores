#include "lista.h"

void lista_ajunta_asciiexadesimal__cadena(struct lista *lista, n1 *cadena, nN cuantia)
{
 const n1 sinia[]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
 lista_crese(lista, cuantia*2);

 nN i;
 for(i=0;i<cuantia;i++)
 {
  lista->datos[(lista->contador+cuantia*2)-2*(i+1)+1]=(sinia[cadena[i]&0x0f]);
  lista->datos[(lista->contador+cuantia*2)-2*(i+1)]=(sinia[(cadena[i]>>4)&0x0f]);
 } 
 
 lista->contador+=cuantia*2;
}