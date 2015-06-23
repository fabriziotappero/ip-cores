#include <errno.h>

int
kill (int pid, int sig)
{
  errno = EINVAL;
  return -1;
}
