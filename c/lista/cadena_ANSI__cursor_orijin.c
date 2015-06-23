#include "lista.h"

void cadena_ANSI__cursor_orijin(void *scrive(n1 *, nN))
{
 n1 sinia[]={0x1b,'[','H'};
 scrive(sinia, sizeof(sinia));
}