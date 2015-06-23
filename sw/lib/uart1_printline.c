#include "openfire.h"

void uart1_printline(char *txt)
{
  while( *(unsigned char *)txt ) uart1_printchar( (unsigned char) *(txt++));
}
