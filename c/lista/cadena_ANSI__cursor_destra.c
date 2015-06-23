#include "lista.h"

void cadena_ANSI__cursor_destra(void *scrive(char *, nN), nN cuantia)
{
 char sinia[]={0x1b,'[','C'};
 scrive(sinia, 2);
 cadena_asciidesimal__nN(scrive, cuantia);
 scrive(sinia+2, 1);
}