/* testmemcpy.c
** Ronald L. Rivest
** 5/12/08
**
** Routine to test speed of memcpy vs just a loop, for
** various size blocks to move.
**
** The cutoff for 32-bit compilation onto my laptop gives
** a cutoff of about blocksize = 16; below that the loop
** is faster; above that memcpy is faster.
*/

#include <stdio.h>
#include <stdint.h>
#include <time.h>

typedef uint64_t md6_word;

md6_word A[8092];
md6_word B[8092];

int main()
{ int blocksize;
  time_t start_time, end_time;
  int i,j;
  int ntrials = 1000000000;
  printf("ntrials = %d\n",ntrials);
  for (blocksize = 1; blocksize<= 128; blocksize += blocksize)
    {
      printf("Blocksize = %d 64-bit words\n",blocksize);

      time(&start_time);
      for (i=0;i<ntrials;i++)
	memcpy(A,B,blocksize*sizeof(md6_word));
      time(&end_time);
      printf("  memcpy: %ld seconds.\n",(long)end_time-start_time);

      time(&start_time);
      for (i=0;i<ntrials;i++)
	for (j=0;j<blocksize;j++)
	  A[j] = B[j];
      time(&end_time);
      printf("  loop: %ld seconds.\n",(long)end_time-start_time);
    }
}
