#include "lista.h"

void cadena_ANSI_cursor_posa_fisa(void *scrive(char *, nN))
{
 char sinia[]={0x1b,'[','s'};
 scrive(sinia, sizeof(sinia));
}