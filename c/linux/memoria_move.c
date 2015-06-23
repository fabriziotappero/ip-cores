#include "sospesifada.h"

void memoria_move(n1 *dst, n1 *fnt, nN cuantia)
{
 sN i;
 for(i=cuantia;i>=0;i--)
 {
  dst[i]=fnt[i];
 }
}