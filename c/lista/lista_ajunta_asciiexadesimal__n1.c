#include "lista.h"

void lista_ajunta_asciiexadesimal__n1(struct lista *lista, n1 binaria)
{
 const n1 sinia[]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
 lista_crese(lista, sizeof(n1)*2);
 
 lista->datos[lista->contador+1]=(sinia[binaria&0x0f]);
 lista->datos[lista->contador+0]=(sinia[(binaria>>4)&0x0f]);
 lista->contador+=sizeof(n1)*2;
}