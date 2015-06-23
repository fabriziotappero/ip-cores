#include "lista.h"

void lista_ajunta_asciiexadesimal__n2(struct lista *lista, n2 binaria)
{
 const n1 sinia[]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
 lista_crese(lista, sizeof(n2)*2);
 
 nN i;
 for(i=0;i<sizeof(n2);i++)
 {
  lista->datos[(lista->contador+sizeof(n2)*2)-2*(i+1)+1]=(sinia[binaria&0x0f]);
  lista->datos[(lista->contador+sizeof(n2)*2)-2*(i+1)]=(sinia[(binaria>>4)&0x0f]);
  binaria>>=8;
 } 
 
 lista->contador+=sizeof(n2)*2;
}