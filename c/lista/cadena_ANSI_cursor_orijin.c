#include "lista.h"

void cadena_ANSI_cursor_orijin(void *scrive(char *, nN))
{
 char sinia[]={0x1b,'[','H'};
 scrive(sinia, sizeof(sinia));
}