#include "lista.h"

void cadena_ANSI__cursor_posa(void *scrive(char *, nN),nN x,nN y)
{
 char sinia[]={0x1b,'[',';','f'};
 scrive(sinia, 2);
 cadena_asciidesimal__nN(scrive, y);
 scrive(sinia+2, 1);
 cadena_asciidesimal__nN(scrive, x);
 scrive(sinia+3, 1);
}