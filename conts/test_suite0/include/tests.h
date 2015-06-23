#ifndef __TESTS_H__
#define __TESTS_H__

/* Abort debugging conditions */
#define DEBUG_TESTS 0
#if DEBUG_TESTS
#define dbg_printf(...)	printf(__VA_ARGS__)
#else
#define dbg_printf(...)
#endif

int test_smp();
int test_performance();
int test_api();
int test_cli_serv();
int test_mthread();

#endif /* __TESTS_H__ */
