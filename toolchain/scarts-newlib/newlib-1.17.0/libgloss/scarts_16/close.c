#include "devops.h"

extern const devops_t *devops_vec[];

int
close (int file)
{
  if (file >= NUM_DEVOPS)
    return 0;
  
  return devops_vec[file]->close (file);
}
