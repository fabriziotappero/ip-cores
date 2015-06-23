#include "lista.h"

void cadena_ANSI_cursor_posa_restora(void *scrive(char *, nN))
{
 char sinia[]={0x1b,'[','u'};
 scrive(sinia, sizeof(sinia));
}