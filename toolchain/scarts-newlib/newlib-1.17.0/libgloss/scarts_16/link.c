#include <errno.h>

int
link (char *old, char *new)
{
  errno = EMLINK;
  return -1;
}
