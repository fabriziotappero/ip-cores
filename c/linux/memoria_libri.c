#include "sospesifada.h"
#include "sys/mman.h"

void memoria_libri(n1 * _mapa)
{
 nN * mapa = (nN *)(_mapa-sizeof(P));
 nN cuantia = *mapa;
 munmap(mapa, cuantia);
}