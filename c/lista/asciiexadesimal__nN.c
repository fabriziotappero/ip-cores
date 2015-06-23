#include "lista.h"

nN asciiexadesimal__nN(n1 *cadena, nN binaria)
{
 const n1 sinia[]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
 
 nN i=0;
 nN n;
 
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