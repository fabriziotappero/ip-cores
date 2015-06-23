#include "tipodef.h"

n1 n1__asciiexadecimal(n1 *cadena)
{
 n1 binaria = 0;;
 n1 c;
 
  c = cadena[0];
  if (c>0x39) c+=0x09;
  binaria |= (c&0x0f);
  binaria <<= 4;
  c = cadena[1];
  if (c>0x39) c+=0x09;
  binaria |= (c&0x0f);
 
 return binaria;
}