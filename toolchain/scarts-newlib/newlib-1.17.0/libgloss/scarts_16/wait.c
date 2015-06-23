#include <errno.h>

int
wait (int *status)
{
  errno = ECHILD;
  return -1;
}
