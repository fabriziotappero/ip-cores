
#ifndef _OR32_SELFTEST_H_
#define _OR32_SELFTEST_H_

// Static memory controller defines
#define MC_BAR_0         0x00
#define MC_AMR_0         0x04
#define MC_WTR_0         0x30
#define MC_RTR_0         0x34
#define MC_OSR           0xe8
#define MC_BAR_1         0x08
#define MC_BAR_4         0x80
#define MC_AMR_1         0x0c
#define MC_AMR_4         0x84
#define MC_CCR_1         0x24
#define MC_CCR_4         0xa0
#define MC_RATR          0xb0
#define MC_RCDR          0xc8
#define MC_RCTR          0xb4
#define MC_REFCTR        0xc4
#define MC_PTR           0xbc
#define MC_RRDR          0xb8
#define MC_RIR           0xcc
#define MC_ORR           0xe4

// Static flash defines
#define FLASH_AMR_VAL    0xf0000000
#define FLASH_WTR_VAL    0x00011009
#define FLASH_RTR_VAL    0x01002009

// Static SDRAM defines
#define SDRAM_RATR_VAL   0x00000006
#define SDRAM_RCDR_VAL   0x00000002
#define SDRAM_RCTR_VAL   0x00000006
#define SDRAM_REFCTR_VAL 0x00000006
#define SDRAM_PTR_VAL    0x00000001
#define SDRAM_RRDR_VAL   0x00000000
#define SDRAM_RIR_VAL    0x000000C0

// CPU defines
#define CPU_OP_ADR  0
#define CPU_SEL_ADR 1



// None of the TC_* defines are currently used
#define TC_RESET           0
#define TC_BRIGHT          1
#define TC_DIM             2
#define TC_UNDERLINE       3
#define TC_BLINK           4
#define TC_REVERSE         7
#define TC_HIDDEN          8

#define TC_BLACK           0
#define TC_RED             1
#define TC_GREEN           2
#define TC_YELLOW          3
#define TC_BLUE            4
#define TC_MAGENTA         5
#define TC_CYAN            6
#define TC_WHITE           7



// Prototypes  ////////////////////////////////////////////
int dbg_test();
int stall_cpus(void);
void init_mc(void);
void init_sram(void);
int test_sdram (void);
int test_sdram_2(void);
int test_sram(void);
int test_or1k_cpu0(void);
//int test_8051_cpu1(void);

#endif  // _OR32_SELFTEST_H_

