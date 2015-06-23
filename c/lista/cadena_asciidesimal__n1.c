#include "lista.h"

void cadena_asciidesimal__nN(void *scrive(n1 *, nN), n1 binaria)
{
 n1 d[24];
 n1 c;
 nN i;
 n1 bdiv;
   
 do
 {
  bdiv=binaria/10;
  c=binaria-((bdiv<<3)+(bdiv<<1));
  d[31-i++]=c|'0';
  binaria=bdiv;
 } while(bdiv!=0);
 
 scrive((d+31)-i, i);
}