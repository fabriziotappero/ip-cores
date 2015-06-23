#include "sim.h"

extern int exit_status;

void
nonfatal (msg)
     const char *msg;
{
  bfd_nonfatal (msg);
  exit_status = 1;
}
