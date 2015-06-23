#include "lista.h"

nN asciidesimal__nN(n1 *cadena, nN binaria)
{
 n1 c;
 nN i=0;
 nN bdiv;
 
 do
 {
  bdiv=binaria/10;
  c=binaria-((bdiv<<3)+(bdiv<<1));
  *cadena=c|'0';
  cadena--;
  i++;
  binaria=bdiv;
 } while(bdiv!=0); 
 
 return i;
}