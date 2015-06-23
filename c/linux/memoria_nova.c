#include "sospesifada.h"

void * memoria_nova(nN cuantia)
{
 n1 * mapa = mmap(0,cuantia+sizeof(P),PROT_READ|PROT_WRITE,MAP_ANONYMOUS|MAP_PRIVATE,0,0);
 *(nN *)mapa=cuantia;
 return mapa+sizeof(nN);
}