#include <malloc.h>

#include "tv80_env.h"

#define TEST_SIZE 200
int main ()
{
  char *foo;
  int i;
  int cksum_in, cksum_out;

  sim_ctl (SC_DUMPON);

  foo = malloc (TEST_SIZE);
  set_timeout (30000);

  print ("Memory allocated\n");

  cksum_in = 0;
  for (i=0; i<TEST_SIZE; i=i+1) {
    cksum_in += i;
    foo[i] = i;
  }

  print ("Values assigned\n");

  cksum_out = 0;
  for (i=0; i<TEST_SIZE; i++)
    cksum_out += foo[i];

  print ("Checksum computed\n");

  if (cksum_in == cksum_out)
    sim_ctl (SC_TEST_PASSED);
  else
    sim_ctl (SC_TEST_FAILED);

  return 0;
}
