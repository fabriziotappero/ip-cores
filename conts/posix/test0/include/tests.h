#ifndef __TEST0_TESTS_H__
#define __TEST0_TESTS_H__

#define __TASKNAME__			"test0"

#include L4LIB_INC_ARCH(syslib.h)

// #define TEST_VERBOSE_PRINT
#if defined (TEST_VERBOSE_PRINT)
#define test_printf(...)	printf(__VA_ARGS__)
#else
#define test_printf(...)
#endif

#include <sys/types.h>
extern pid_t parent_of_all;

void ipc_full_test(void);
void ipc_extended_test(void);

int shmtest(void);
int forktest(void);
int mmaptest(void);
int dirtest(void);
int fileio(void);
int clonetest(void);
int exectest(pid_t);
int user_mutex_test(void);
int small_io_test(void);
int undeftest(void);

#endif /* __TEST0_TESTS_H__ */
