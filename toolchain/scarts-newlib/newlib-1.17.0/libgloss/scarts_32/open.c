#include <errno.h>
#include "devops_vec.h"

extern const devops_t *devops_vec[];

int
open (const char *file, int flags, int mode)
{
  int fd, i;

  fd = -1;
  i = 0;

  do
  {
    /* Search for 'file' in 'devops_vec'. */
    if (strcmp (devops_vec[i]->name, file) == 0)
    {
      fd = i;
      break;
    }
  }
  while (devops_vec[i++]);

  if (fd != -1)
    /* Invoke the device's open() function. */
    devops_vec[fd]->open (file, flags, mode);
  else
    errno = ENODEV;

  return fd;
}
