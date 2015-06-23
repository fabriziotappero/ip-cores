#include "lista.h"

void cadena_ANSI__cursor_sinistra(void *scrive(char *, nN), nN cuantia)
{
 char sinia[]={0x1b,'[','D'};
 scrive(sinia, 2);
 cadena_asciidesimal__nN(scrive, cuantia);
 scrive(sinia+2, 1);
}