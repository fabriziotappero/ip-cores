#include "devops.h"

extern const devops_t *devops_vec[];

int
write (int file, char *ptr, int len)
{
  if (file >= NUM_DEVOPS)
    return 0;

  return devops_vec[file]->write (file, ptr, len);
}
