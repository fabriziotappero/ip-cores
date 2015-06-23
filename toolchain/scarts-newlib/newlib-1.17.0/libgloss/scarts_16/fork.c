#include <errno.h>

int
fork ()
{
  errno = EAGAIN;
  return -1;
}
