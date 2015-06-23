#include <errno.h>

int
unlink (char *name)
{
  errno = EMLINK;
  return -1;
}
