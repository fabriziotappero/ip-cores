#include <errno.h>

int
execve (char *name, char *argv[], char *env[])
{
  errno = ENOMEM;
  return -1;
}
