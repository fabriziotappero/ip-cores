/*
 * undeftest.c:
 * Tests to see if kernel gracefully handles the undef exception
 */

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <tests.h>
#include <errno.h>
#include INC_GLUE(memory.h)

int undeftest(void)
{
       test_printf("UNDEF: Start\n");

       /* need a way to report FAIL case */
       __asm__ __volatile__(".word 0xf1f0feed\n\t"); /* Some pattern for easy recongition */

       /* If code reaches here its passed */
       if (getpid() == parent_of_all)
	       printf("UNDEF TEST          -- PASSED --\n");

       return 0;
}
