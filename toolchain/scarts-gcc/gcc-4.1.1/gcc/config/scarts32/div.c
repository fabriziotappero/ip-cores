#include "stdlib.h"

div_t div(int x, int y)
{
  div_t retval;
  retval.quot = x/y;
  retval.rem = x%y;
  return retval;
}

ldiv_t ldiv(long x, long y)
{
  ldiv_t retval;
  retval.quot = x/y;
  retval.rem = x%y;
  return retval;
}

lldiv_t lldiv(long long x, long long y)
{
  lldiv_t retval;
  retval.quot = x/y;
  retval.rem = x%y;
  return retval;
}
