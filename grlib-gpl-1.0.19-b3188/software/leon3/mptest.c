#include "testmod.h"

asm(
"	.text\n"
"	.align 4\n"
"	.global get_pid\n"
	
"get_sem:\n"	
"	set  mpsem, %o1\n"
"	set  0, %o0\n"
"	retl\n"
"	ldstuba [%o1] 1, %o0 \n"
/*"	swapa [%o1] 1, %o0 \n"*/

"ret_sem:\n"
/*"	set 1, %o0 \n" */
"	set 0, %o0 \n"
"	set mpsem, %o1\n"
"	retl\n"
"	st  %o0, [%o1]		\n"
		
"get_pid:\n"
"        mov  %asr17, %o0\n"
"        srl  %o0, 28, %o0\n"
"        retl\n"
"        and %o0, 0xf, %o0\n"

"mread: retl\n"
"        lda  [%o0] 1, %o0\n"

"getccfg: set 0xc, %o0\n"
"         retl\n"
"         lda [%o0] 2, %o0\n"
	
"	.data\n"
"	.align 4\n"
"	.global mpsem\n"
/*"mpsem:	.word 1\n"*/
"mpsem:	.word 0\n"
	
);

#define MPLOOPS 10

volatile int cnt = 0;

volatile int pstart[17] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};
volatile int pdone[17] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};
volatile int pindex[17] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};


static int absl(int a, int b)
{
  if (a > b)
    return(a-b);
  else
    return(b-a);
}     

static void psync(volatile int arr[], int n, int ncpu)
{
  int i, go;

  arr[n] = 1;
  do {
    go = 1;
    for (i = 0; i < ncpu; i++)
      if (!arr[i]) go = 0;
  } while (!go);
}

int mptest(volatile int *irqmp_ptr)
{
  int id, i, sem, ncpu;
  unsigned int ccfg;  

  ncpu = (((*(irqmp_ptr + 0x10/4)) >> 28) & 0x0f) + 1;
  if (ncpu == 1) return(-1);

  id = get_pid();
  report_subtest(MP_TEST + (id <<4));
  ccfg = getccfg();
  if (!((ccfg >> 27) & 1)) fail(1);
        
  
  *(irqmp_ptr + 0x10/4) = (1 << (id+1));
    
  psync(pstart, id, ncpu);

  for (pindex[id] = 0; pindex[id] < MPLOOPS; pindex[id]++)
  {
//    do {sem = get_sem();} while (!sem);
    do {sem = get_sem();} while (sem);
    for (i = 0; i < ncpu; i++)
    {
      if (absl(pindex[id], pindex[i]) > 1) fail(2);
    }
    cnt++;
    ret_sem();
  }

  psync(pdone, id, ncpu);
  if (cnt != (MPLOOPS*ncpu)) fail(3);
  if ((cnt <= 0) || (cnt > (MPLOOPS*ncpu))) fail(3);

  if (id != 0) asm("ta 0");
  return(0);

}
	



int mptest_start(volatile int *irqmp_ptr)
{
  int id, i, sem, ncpu;
  unsigned int ccfg;  

  ncpu = (((*(irqmp_ptr + 0x10/4)) >> 28) & 0x0f) + 1;
  if (ncpu == 1) return(-1);

  id = get_pid();

  if (id == 0) {
    *(irqmp_ptr + 0x10/4) = 0x0ffff;
  }
}

int mptest_end(volatile int *irqmp_ptr)
{
  int id, i, sem, ncpu;
  unsigned int ccfg;  

  ncpu = (((*(irqmp_ptr + 0x10/4)) >> 28) & 0x0f) + 1;
  if (ncpu == 1) return(-1);

  id = get_pid();
  report_subtest(MP_TEST + (id << 4));
  ccfg = getccfg();
  if (!((ccfg >> 27) & 1)) fail(1);
        
  
  psync(pstart, id, ncpu);

  for (pindex[id] = 0; pindex[id] < MPLOOPS; pindex[id]++)
  {
//    do {sem = get_sem();} while (!sem);
    do {sem = get_sem();} while (sem);
    for (i = 0; i < ncpu; i++)
    {
      if (absl(pindex[id], pindex[i]) > 1) fail(2);
    }
    cnt++;
    ret_sem();
  }

  psync(pdone, id, ncpu);
  if (cnt != (MPLOOPS*ncpu)) fail(3);
  if ((cnt <= 0) || (cnt > (MPLOOPS*ncpu))) fail(3);

  if (id != 0) asm("ta 0");
  return(0);

}
