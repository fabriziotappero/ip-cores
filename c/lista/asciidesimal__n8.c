#include "lista.h"

nN asciidesimal__n8(n1 *cadena, n8 binaria)
{
 n1 c;
 nN i=0;
 n8 bdiv;
 
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