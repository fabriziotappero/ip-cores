#include "sospesifada.h"

void memoria_copia(n1 *dst,n1 *fnt,nN cuantia)
{
 nN conta;
 for(conta = 0;conta<cuantia;conta++)
 {
  dst[conta]=fnt[conta];
 }
}