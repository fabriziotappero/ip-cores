#include "lista.h"

void cadena_ANSI__3atribuida(void *scrive(char *, nN),n1 a_0,n1 a_1,n1 a_2)
{
 char sinia[]={0x1b,'[',';','m'};
 scrive(sinia, 2);
 cadena_asciidesimal__nN(scrive, a_0);
 scrive(sinia+2, 1);
 cadena_asciidesimal__nN(scrive, a_1);
 scrive(sinia+2, 1);
 cadena_asciidesimal__nN(scrive, a_2);
 scrive(sinia+3, 1);
}