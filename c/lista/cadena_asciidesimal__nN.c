#include "lista.h"

void cadena_asciidesimal__nN(void *scrive(char *, nN), nN binaria)
{
 #define cuantia 24
 char d[cuantia];
 n1 c;
 nN i=0;
 nN bdiv;
   
 do
 {
  bdiv=binaria/10;
  c=binaria-((bdiv<<3)+(bdiv<<1));
  d[(cuantia-1)-i++]=c|'0';
  binaria=bdiv;
 } while(bdiv!=0);
 
 scrive((d+(cuantia))-i, i);
}