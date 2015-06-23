#include "devops.h"

extern const devops_t *devops_vec[];

int
read (int file, char *ptr, int len)
{
  if (file >= NUM_DEVOPS)
    return 0;

  return devops_vec[file]->read (file, ptr, len);
}
