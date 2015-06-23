#include "lista.h"

n8 asciiexadesimal__n8(n1 *cadena, n8 binaria)
{
 const n1 sinia[]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
 
 nN i=0;
 n1 n;
 
 do
 {
  n=sinia[binaria&0x0f];
  *cadena=n;
  cadena--;
  i++;
  binaria>>=4;
 } while(binaria!=0);
 
 return i;
}