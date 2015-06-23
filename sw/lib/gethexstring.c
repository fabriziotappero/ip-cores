#include "openfire.h"

static unsigned gethexchar(char c)
{
  if(c >= 'a') c = c - 'a' + '0' + 10;
  else if(c >= 'A') c = c - 'A' + '0' + 10;
  return c - '0';
}

static unsigned ishexdigit(char c)
{
  return (c >= '0' && c <= '9') || 
         (c >= 'a' && c <= 'f') ||
         (c >= 'A' && c <= 'F');
}

char *gethexstring(char *string, unsigned *value, unsigned maxdigits)
{
  unsigned number = 0;
  
  while( ishexdigit( string[0] ) && maxdigits > 0)
  {
    number <<= 4;
    number |= gethexchar(string[0]);
    string++;
    maxdigits--;
  }
  
  *value = number;
  return string;
}
