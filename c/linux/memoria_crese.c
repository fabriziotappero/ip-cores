#include "sospesifada.h"

void * memoria_crese(n1 *memoria, nN grandia)
{
 nN *mapa=(nN *)(memoria-sizeof(nN));
 n1 *remapa=mremap(mapa,*mapa,grandia+sizeof(nN),MREMAP_MAYMOVE);
 *(nN *)remapa=grandia;
 return remapa+sizeof(nN);
}