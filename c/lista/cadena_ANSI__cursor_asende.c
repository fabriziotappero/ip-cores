#include "lista.h"

void cadena_ANSI__cursor_asende(void *scrive(char *, nN), nN cuantia)
{
 char sinia[]={0x1b,'[','A'};
 scrive(sinia, 2);
 cadena_asciidesimal__nN(scrive, cuantia);
 scrive(sinia+2, 1);
}