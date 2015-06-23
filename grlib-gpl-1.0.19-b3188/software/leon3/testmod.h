
#define START_TEST   0
#define STOP_TEST    1
#define TEST_FAIL    2
#define REGFILE      3
#define MUL_TEST     4
#define DIV_TEST     5
#define CACHE_TEST   6
#define MP_TEST      7
#define FPU_TEST     8
#define ITAG_TEST    9
#define DTAG_TEST    10
#define IDAT_TEST    11
#define DDAT_TEST    12
#define GRFPU_TEST   13
#define MMU_TEST     14

#define APBUART_TEST 7 
#define FTSRCTRL     8 
#define GPIO         9
#define CMEM_TEST    10
#define IRQ_TEST     11
#define SPW_TEST     12

#define MCTRL_BYTE   3
#define MCTRL_EDAC   4
#define MCTRL_WPROT  5

#define SPW_SNOOP_TEST  1
#define SPW_NOSNOOP_TEST  2
#define SPW_RMAP_TEST  3
#define SPW_TIME_TEST  4

#ifndef __ASSEMBLER__

extern report_device();
extern report_subtest();
extern fail();
extern int irqmp_addr;
extern void (*mpfunc[16])(int index);

#endif

