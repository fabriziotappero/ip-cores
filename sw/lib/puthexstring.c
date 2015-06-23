#include "openfire.h"

static char puthexchar(unsigned n)
{
  n &= 0xF;
  return n + (n < 10 ? '0' : 'A' - 10);
}

void puthexstring(char *string, unsigned number, unsigned size)
{
  int n = size - 1;
  while(number && n >= 0)		// hex 2 ascii right to left
  {
    string[n] = puthexchar(number & 0xf);
    number >>= 4;
    n--;
  }
  while(n >= 0) string[n--] = '0';	// left padding with 0
}
