#include "lista.h"

void cadena_ANSI__cursor_desende(void *scrive(char *, nN), nN cuantia)
{
 char sinia[]={0x1b,'[','B'};
 scrive(sinia, 2);
 cadena_asciidesimal__nN(scrive, cuantia);
 scrive(sinia+2, 1);
}