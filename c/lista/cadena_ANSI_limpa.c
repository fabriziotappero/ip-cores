#include "lista.h"

void cadena_ANSI_limpa(void *scrive(char *, nN))
{
 char sinia[]={0x1b,'[','2','J'};
 scrive(sinia, sizeof(sinia));
}