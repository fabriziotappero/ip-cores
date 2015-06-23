/* mkdevice.c, a utility to generate LEON device.vhd from a config file.
   Written by Jiri Gaisler, jiri@gaisler.com
   Copyright Gaisler Research, all rights reserved.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>


#define	VAL(x)	strtoul(x,(char **)NULL,0)

FILE *fp;

char false[] = "false";
char true[] = "true";

/* Synthesis options */

char CONFIG_CFG_NAME[16] = "config";
char CFG_SYN_TARGET_TECH[128] = "gen";
char *CONFIG_SYN_INFER_PADS = false;
char *CONFIG_SYN_INFER_PCI_PADS = false;
char *CONFIG_SYN_INFER_RAM = false;
char *CONFIG_SYN_INFER_ROM = false;
char *CONFIG_SYN_INFER_REGF = false;
char *CONFIG_SYN_INFER_MULT = false;
int CONFIG_SYN_RFTYPE = 1;
char CONFIG_TARGET_CLK[128] = "gen";
int CONFIG_PLL_CLK_MUL = 1;
int CONFIG_PLL_CLK_DIV = 1;
char *CONFIG_PCI_CLKDLL = false;
char *CONFIG_PCI_SYSCLK = false;

/* IU options */

int CONFIG_IU_NWINDOWS = 8;
char CFG_IU_MUL_TYPE[16] = "none";
char CFG_IU_DIVIDER[16] = "none";
char *CONFIG_IU_MUL_MAC = false;
char *CONFIG_IU_MULPIPE = false;
char *CONFIG_IU_FASTJUMP = false;
char *CONFIG_IU_ICCHOLD = false;
char *CONFIG_IU_FASTDECODE = false;
char *CONFIG_IU_RFPOW = false;
int CONFIG_IU_LDELAY = 1;
int CONFIG_IU_WATCHPOINTS = 0;

/* FPU config */

int CONFIG_FPU_ENABLE = 0;
char *CFG_FPU_CORE = "meiko";
char *CFG_FPU_IF = "none";
int CONFIG_FPU_REGS = 32;
int CONFIG_FPU_VER = 0;

/* CP config */

char CONFIG_CP_CFG[128] = "cp_none";

/* cache configuration */

int CFG_ICACHE_SZ = 2;
int CFG_ICACHE_LSZ = 16;
int CFG_ICACHE_ASSO = 1;
char *CFG_ICACHE_ALGO = "rnd";
int CFG_ICACHE_LOCK = 0;
int CFG_DCACHE_SZ = 1;
int CFG_DCACHE_LSZ = 16;
char *CFG_DCACHE_SNOOP = "none";
int CFG_DCACHE_ASSO = 1;
char *CFG_DCACHE_ALGO = "rnd";
int CFG_DCACHE_LOCK = 0;
char *CFG_DCACHE_RFAST = false;
char *CFG_DCACHE_WFAST = false;
char *CFG_DCACHE_LRAM  = false;
int CFG_DCACHE_LRSZ = 1;
int CFG_DCACHE_LRSTART = 0x8f;

/* MMU config */

int CFG_MMU_ENABLE = 0;
char *CFG_MMU_TYPE = "combinedtlb";
char *CFG_MMU_REP = "replruarray";
int CFG_MMU_I = 8;
int CFG_MMU_D = 8;
char *CFG_MMU_DIAG = false;

/* Memory controller config */

char *CONFIG_MCTRL_8BIT = false;
char *CONFIG_MCTRL_16BIT = false;
char *CONFIG_MCTRL_5CS = false;
char *CONFIG_MCTRL_WFB = false;
char *CONFIG_MCTRL_SDRAM = false;
char *CONFIG_MCTRL_SDRAM_INVCLK = false;
char *CONFIG_MCTRL_SDRAM_SEPBUS = false;

/* Peripherals */
char *CONFIG_PERI_LCONF = false;
char *CONFIG_PERI_AHBSTAT = false;
char *CONFIG_PERI_WPROT = false;
char *CONFIG_PERI_WDOG = false;
char *CONFIG_PERI_IRQ2 = false;

/* AHB */

int CONFIG_AHB_DEFMST = 0;
char *CONFIG_AHB_SPLIT = false;
char *CONFIG_AHBRAM_ENABLE = false;
int CFG_AHBRAM_SZ = 4;

/* Debug */
char *CONFIG_DEBUG_UART = false;
char *CONFIG_DEBUG_IURF = false;
char *CONFIG_DEBUG_FPURF = false;
char *CONFIG_DEBUG_NOHALT = false;
int CFG_DEBUG_PCLOW = 2;
char *CONFIG_DEBUG_RFERR = false;
char *CONFIG_DEBUG_CACHEMEMERR = false;

/* DSU */
char *CONFIG_DSU_ENABLE = false;
char *CONFIG_DSU_TRACEBUF = false;
char *CONFIG_DSU_MIXED_TRACE = false;
char *CONFIG_SYN_TRACE_DPRAM = false;
int CFG_DSU_TRACE_SZ = 64;

/* Boot */
char *CFG_BOOT_SOURCE = "memory";
int CONFIG_BOOT_RWS = 0;
int CONFIG_BOOT_WWS = 0;
int CONFIG_BOOT_SYSCLK = 25000000;
int CONFIG_BOOT_BAUDRATE = 19200;
char *CONFIG_BOOT_EXTBAUD = false;
int CONFIG_BOOT_PROMABITS = 11;

/* Ethernet */
char *CONFIG_ETH_ENABLE = false;
int CONFIG_ETH_TXFIFO = 8;
int CONFIG_ETH_RXFIFO = 8;
int CONFIG_ETH_BURST = 4;

/* PCI */
char *CFG_PCI_CORE = "none";
char *CONFIG_PCI_ENABLE = false;
int CONFIG_PCI_VENDORID = 0;
int CONFIG_PCI_DEVICEID = 0;
int CONFIG_PCI_SUBSYSID = 0;
int CONFIG_PCI_REVID = 0;
int CONFIG_PCI_CLASSCODE = 0;
int CFG_PCI_FIFO = 8;
int CFG_PCI_TDEPTH = 256;
char *CONFIG_PCI_TRACE = false;
char *CONFIG_PCI_PMEPADS = false;
char *CONFIG_PCI_P66PAD = false;
char *CONFIG_PCI_RESETALL = false;
char *CONFIG_PCI_ARBEN = false;
int pciahbmst = 0;

/* FT */

int CONFIG_FT_ENABLE = 0;
char *CONFIG_FT_RF_ENABLE = false;
char *CONFIG_FT_RF_PARITY = false;
char *CONFIG_FT_RF_EDAC = false;
int CONFIG_FT_RF_PARBITS = 0;
char *CONFIG_FT_RF_WRFAST = false;
char *CONFIG_FT_TMR_REG = false;
char *CONFIG_FT_TMR_CLK = false;
char *CONFIG_FT_MC = false;
char *CONFIG_FT_MEMEDAC = false;
char *CONFIG_FT_CACHEMEM_ENABLE = false;
int CONFIG_FT_CACHEMEM_PARBITS = 0;
char *CONFIG_FT_CACHEMEM_APAR = false;


int dsuen, pcien, ahbram, ethen;
char tmps[32];
int ahbmst = 1;

int log2(int x)
{
    int i;

    x--;
    for (i=0; x!=0; i++) x >>= 1;
    return(i);
}

main()
{

    char lbuf[1024], *value;

    fp = fopen("device.vhd", "w+");
    if (!fp) {
	printf("could not open file device.vhd\n");
	exit(1);
    }
    while (!feof(stdin))
      {
	  lbuf[0] = 0;
	  fgets (lbuf, 1023, stdin);
	  if (strncmp(lbuf, "CONFIG", 6) == 0) {
		value = strchr(lbuf,'=');
		value[0] = 0;
		value++;
	      	while ((strlen (value) > 0) && 
		  ((value[strlen (value) - 1] == '\n')
		   || (value[strlen (value) - 1] == '\r')
		   || (value[strlen (value) - 1] == '"')
		)) value[strlen (value) - 1] = 0;
	      	if ((strlen (value) > 0) && (value[0] == '"')) {
		   value++;
		  }

		/* synthesis options */
	      else if (strcmp("CONFIG_SYN_GENERIC", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "gen");
	      else if (strcmp("CONFIG_SYN_ATC35", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "atc35");
	      else if (strcmp("CONFIG_SYN_ATC25", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "atc25");
	      else if (strcmp("CONFIG_SYN_ATC18", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "atc18");
	      else if (strcmp("CONFIG_SYN_FS90", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "fs90");
	      else if (strcmp("CONFIG_SYN_UMC018", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "umc18");
	      else if (strcmp("CONFIG_SYN_TSMC025", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "tsmc25");
	      else if (strcmp("CONFIG_SYN_PROASIC", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "proasic");
	      else if (strcmp("CONFIG_SYN_AXCEL", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "axcel");
	      else if (strcmp("CONFIG_SYN_VIRTEX", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "virtex");
	      else if (strcmp("CONFIG_SYN_VIRTEX2", lbuf) == 0)
		strcpy(CFG_SYN_TARGET_TECH, "virtex2");
	      else if (strcmp("CONFIG_SYN_INFER_PADS", lbuf) == 0)
		CONFIG_SYN_INFER_PADS = true;
	      else if (strcmp("CONFIG_SYN_INFER_PCI_PADS", lbuf) == 0)
		CONFIG_SYN_INFER_PCI_PADS = true;
	      else if (strcmp("CONFIG_SYN_INFER_RAM", lbuf) == 0)
		CONFIG_SYN_INFER_RAM = true;
	      else if (strcmp("CONFIG_SYN_INFER_ROM", lbuf) == 0)
		CONFIG_SYN_INFER_ROM = true;
	      else if (strcmp("CONFIG_SYN_INFER_REGF", lbuf) == 0)
		CONFIG_SYN_INFER_REGF = true;
	      else if (strcmp("CONFIG_SYN_INFER_MULT", lbuf) == 0)
		CONFIG_SYN_INFER_MULT = true;
	      else if (strcmp("CONFIG_SYN_RFTYPE", lbuf) == 0)
		CONFIG_SYN_RFTYPE = 2;
	      else if (strcmp("CONFIG_SYN_TRACE_DPRAM", lbuf) == 0)
		CONFIG_SYN_TRACE_DPRAM = true;
	      else if (strcmp("CONFIG_CLK_VIRTEX", lbuf) == 0)
		strcpy(CONFIG_TARGET_CLK, "virtex");
	      else if (strcmp("CONFIG_AXCEL_HCLKBUF", lbuf) == 0)
		strcpy(CONFIG_TARGET_CLK, "axcel");
	      else if (strcmp("CONFIG_CLKDLL_1_2", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 1; CONFIG_PLL_CLK_DIV = 2;
	      } else if (strcmp("CONFIG_CLKDLL_1_1", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 1; CONFIG_PLL_CLK_DIV = 1;
	      } else if (strcmp("CONFIG_CLKDLL_2_1", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 2; CONFIG_PLL_CLK_DIV = 1;
	      } else if (strcmp("CONFIG_CLK_VIRTEX2", lbuf) == 0)
		strcpy(CONFIG_TARGET_CLK, "virtex2");
	      else if (strcmp("CONFIG_DCM_2_3", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 2; CONFIG_PLL_CLK_DIV = 3;
	      } else if (strcmp("CONFIG_DCM_3_4", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 3; CONFIG_PLL_CLK_DIV = 4;
	      } else if (strcmp("CONFIG_DCM_4_5", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 4; CONFIG_PLL_CLK_DIV = 5;
	      } else if (strcmp("CONFIG_DCM_1_1", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 2; CONFIG_PLL_CLK_DIV = 2;
	      } else if (strcmp("CONFIG_DCM_5_4", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 5; CONFIG_PLL_CLK_DIV = 4;
	      } else if (strcmp("CONFIG_DCM_4_3", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 4; CONFIG_PLL_CLK_DIV = 3;
	      } else if (strcmp("CONFIG_DCM_3_2", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 3; CONFIG_PLL_CLK_DIV = 2;
	      } else if (strcmp("CONFIG_DCM_5_3", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 5; CONFIG_PLL_CLK_DIV = 3;
	      } else if (strcmp("CONFIG_DCM_2_1", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 2; CONFIG_PLL_CLK_DIV = 1;
	      } else if (strcmp("CONFIG_DCM_3_1", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 3; CONFIG_PLL_CLK_DIV = 1;
	      } else if (strcmp("CONFIG_DCM_4_1", lbuf) == 0) {
		CONFIG_PLL_CLK_MUL = 4; CONFIG_PLL_CLK_DIV = 1;
	      } else if (strcmp("CONFIG_PCI_DLL", lbuf) == 0)
		CONFIG_PCI_CLKDLL = true;
	      else if (strcmp("CONFIG_PCI_SYSCLK", lbuf) == 0)
		CONFIG_PCI_SYSCLK = true;
		/* IU options */
	      else if (strcmp("CONFIG_IU_NWINDOWS", lbuf) == 0) {
		CONFIG_IU_NWINDOWS = VAL(value);
                if ((CONFIG_IU_NWINDOWS > 32) || (CONFIG_IU_NWINDOWS < 1))
                  CONFIG_IU_NWINDOWS = 8;
	      } else if (strcmp("CONFIG_IU_V8MULDIV", lbuf) == 0) 
		strcpy(CFG_IU_DIVIDER, "radix2");
	      else if (strcmp("CONFIG_IU_MUL_LATENCY_1", lbuf) == 0) 
		strcpy(CFG_IU_MUL_TYPE, "m32x32");
	      else if (strcmp("CONFIG_IU_MUL_LATENCY_2", lbuf) == 0) 
		strcpy(CFG_IU_MUL_TYPE, "m32x16");
	      else if (strcmp("CONFIG_IU_MUL_LATENCY_4", lbuf) == 0) 
		strcpy(CFG_IU_MUL_TYPE, "m16x16");
	      else if (strcmp("CONFIG_IU_MUL_LATENCY_5", lbuf) == 0) {
		strcpy(CFG_IU_MUL_TYPE, "m16x16");
		CONFIG_IU_MULPIPE = true;
	      }
	      else if (strcmp("CONFIG_IU_MUL_LATENCY_35", lbuf) == 0) 
		strcpy(CFG_IU_MUL_TYPE, "iterative");
	      else if (strcmp("CONFIG_IU_MUL_MAC", lbuf) == 0)  {
		strcpy(CFG_IU_MUL_TYPE, "m16x16");
		CONFIG_IU_MUL_MAC = true;
	      }
	      else if (strcmp("CONFIG_IU_FASTJUMP", lbuf) == 0)
		CONFIG_IU_FASTJUMP = true;
	      else if (strcmp("CONFIG_IU_FASTDECODE", lbuf) == 0)
		CONFIG_IU_FASTDECODE = true;
	      else if (strcmp("CONFIG_IU_RFPOW", lbuf) == 0)
		CONFIG_IU_RFPOW = true;
	      else if (strcmp("CONFIG_IU_ICCHOLD", lbuf) == 0)
		CONFIG_IU_ICCHOLD = true;
	      else if (strcmp("CONFIG_IU_LDELAY", lbuf) == 0) {
		CONFIG_IU_LDELAY = VAL(value);
  	        if ((CONFIG_IU_LDELAY > 2) || (CONFIG_IU_LDELAY < 1))
    	          CONFIG_IU_LDELAY = 2;
	      } else if (strcmp("CONFIG_IU_WATCHPOINTS", lbuf) == 0) {
		CONFIG_IU_WATCHPOINTS = VAL(value);
  	        if ((CONFIG_IU_WATCHPOINTS > 4) || (CONFIG_IU_WATCHPOINTS < 0))
    	        CONFIG_IU_WATCHPOINTS = 0;
		/* FPU config */
	      } else if (strcmp("CONFIG_FPU_ENABLE", lbuf) == 0) 
		CONFIG_FPU_ENABLE = 1;
	      else if (strcmp("CONFIG_FPU_GRFPU", lbuf) == 0) {
		CFG_FPU_CORE = "grfpu"; CFG_FPU_IF = "parallel";
		CONFIG_FPU_REGS = 0;
	      } else if (strcmp("CONFIG_FPU_MEIKO", lbuf) == 0) { 
		CFG_FPU_CORE = "meiko"; CFG_FPU_IF = "serial";
	      } else if (strcmp("CONFIG_FPU_LTH", lbuf) == 0) {
		CFG_FPU_CORE = "lth"; CFG_FPU_IF = "serial";
	      } else if (strcmp("CONFIG_FPU_VER", lbuf) == 0)
		CONFIG_FPU_VER = VAL(value) & 0x07;
	      /* CP config */
	      else if (strcmp("CONFIG_CP_ENABLE", lbuf) == 0)  {}
	      else if (strcmp("CONFIG_CP_CFG", lbuf) == 0) 
		strcpy(CONFIG_CP_CFG, value);
	      /* cache config */
	      else if (strcmp("CONFIG_ICACHE_ASSO1", lbuf) == 0) 
		CFG_ICACHE_ASSO = 1;
	      else if (strcmp("CONFIG_ICACHE_ASSO2", lbuf) == 0) 
		CFG_ICACHE_ASSO = 2;
	      else if (strcmp("CONFIG_ICACHE_ASSO3", lbuf) == 0) 
		CFG_ICACHE_ASSO = 3;
	      else if (strcmp("CONFIG_ICACHE_ASSO4", lbuf) == 0) 
		CFG_ICACHE_ASSO = 4;
	      else if (strcmp("CONFIG_ICACHE_ALGORND", lbuf) == 0) 
		CFG_ICACHE_ALGO = "rnd";
	      else if (strcmp("CONFIG_ICACHE_ALGOLRR", lbuf) == 0) 
		CFG_ICACHE_ALGO = "lrr";
	      else if (strcmp("CONFIG_ICACHE_ALGOLRU", lbuf) == 0) 
		CFG_ICACHE_ALGO = "lru";
	      else if (strcmp("CONFIG_ICACHE_LOCK", lbuf) == 0) 
		CFG_ICACHE_LOCK = 1;
	      else if (strcmp("CONFIG_ICACHE_SZ1", lbuf) == 0) 
		CFG_ICACHE_SZ = 1;
	      else if (strcmp("CONFIG_ICACHE_SZ2", lbuf) == 0) 
		CFG_ICACHE_SZ = 2;
	      else if (strcmp("CONFIG_ICACHE_SZ4", lbuf) == 0) 
		CFG_ICACHE_SZ = 4;
	      else if (strcmp("CONFIG_ICACHE_SZ8", lbuf) == 0) 
		CFG_ICACHE_SZ = 8;
	      else if (strcmp("CONFIG_ICACHE_SZ16", lbuf) == 0) 
		CFG_ICACHE_SZ = 16;
	      else if (strcmp("CONFIG_ICACHE_SZ32", lbuf) == 0) 
		CFG_ICACHE_SZ = 32;
	      else if (strcmp("CONFIG_ICACHE_SZ64", lbuf) == 0) 
		CFG_ICACHE_SZ = 64;
	      else if (strcmp("CONFIG_ICACHE_LZ16", lbuf) == 0) 
		CFG_ICACHE_LSZ = 16;
	      else if (strcmp("CONFIG_ICACHE_LZ32", lbuf) == 0) 
		CFG_ICACHE_LSZ = 32;
	      else if (strcmp("CONFIG_DCACHE_SZ1", lbuf) == 0) 
		CFG_DCACHE_SZ = 1;
	      else if (strcmp("CONFIG_DCACHE_SZ2", lbuf) == 0) 
		CFG_DCACHE_SZ = 2;
	      else if (strcmp("CONFIG_DCACHE_SZ4", lbuf) == 0) 
		CFG_DCACHE_SZ = 4;
	      else if (strcmp("CONFIG_DCACHE_SZ8", lbuf) == 0) 
		CFG_DCACHE_SZ = 8;
	      else if (strcmp("CONFIG_DCACHE_SZ16", lbuf) == 0) 
		CFG_DCACHE_SZ = 16;
	      else if (strcmp("CONFIG_DCACHE_SZ32", lbuf) == 0) 
		CFG_DCACHE_SZ = 32;
	      else if (strcmp("CONFIG_DCACHE_SZ64", lbuf) == 0) 
		CFG_DCACHE_SZ = 64;
	      else if (strcmp("CONFIG_DCACHE_LZ16", lbuf) == 0) 
		CFG_DCACHE_LSZ = 16;
	      else if (strcmp("CONFIG_DCACHE_LZ32", lbuf) == 0) 
		CFG_DCACHE_LSZ = 32;
	      else if (strcmp("CONFIG_DCACHE_SNOOP_SLOW", lbuf) == 0) 
		CFG_DCACHE_SNOOP = "slow";
	      else if (strcmp("CONFIG_DCACHE_SNOOP_FAST", lbuf) == 0) 
		CFG_DCACHE_SNOOP = "fast";
	      else if (strcmp("CONFIG_DCACHE_SNOOP", lbuf) == 0)  {}
	      else if (strcmp("CONFIG_DCACHE_ASSO1", lbuf) == 0) 
		CFG_DCACHE_ASSO = 1;
	      else if (strcmp("CONFIG_DCACHE_ASSO2", lbuf) == 0) 
		CFG_DCACHE_ASSO = 2;
	      else if (strcmp("CONFIG_DCACHE_ASSO3", lbuf) == 0) 
		CFG_DCACHE_ASSO = 3;
	      else if (strcmp("CONFIG_DCACHE_ASSO4", lbuf) == 0) 
		CFG_DCACHE_ASSO = 4;
	      else if (strcmp("CONFIG_DCACHE_ALGORND", lbuf) == 0) 
		CFG_DCACHE_ALGO = "rnd";
	      else if (strcmp("CONFIG_DCACHE_ALGOLRR", lbuf) == 0) 
		CFG_DCACHE_ALGO = "lrr";
	      else if (strcmp("CONFIG_DCACHE_ALGOLRU", lbuf) == 0) 
		CFG_DCACHE_ALGO = "lru";
	      else if (strcmp("CONFIG_DCACHE_LOCK", lbuf) == 0) 
		CFG_DCACHE_LOCK = 1;
	      else if (strcmp("CONFIG_DCACHE_RFAST", lbuf) == 0) 
		CFG_DCACHE_RFAST = true;
	      else if (strcmp("CONFIG_DCACHE_WFAST", lbuf) == 0) 
		CFG_DCACHE_WFAST = true;
	      else if (strcmp("CONFIG_DCACHE_LRAM", lbuf) == 0) 
		CFG_DCACHE_LRAM = true;
	      else if (strcmp("CONFIG_DCACHE_LRAM_SZ1", lbuf) == 0) 
		CFG_DCACHE_LRSZ = 1;
	      else if (strcmp("CONFIG_DCACHE_LRAM_SZ2", lbuf) == 0) 
		CFG_DCACHE_LRSZ = 2;
	      else if (strcmp("CONFIG_DCACHE_LRAM_SZ4", lbuf) == 0) 
		CFG_DCACHE_LRSZ = 4;
	      else if (strcmp("CONFIG_DCACHE_LRAM_SZ8", lbuf) == 0) 
		CFG_DCACHE_LRSZ = 8;
	      else if (strcmp("CONFIG_DCACHE_LRAM_SZ16", lbuf) == 0) 
		CFG_DCACHE_LRSZ = 16;
	      else if (strcmp("CONFIG_DCACHE_LRAM_SZ32", lbuf) == 0) 
		CFG_DCACHE_LRSZ = 32;
	      else if (strcmp("CONFIG_DCACHE_LRAM_SZ64", lbuf) == 0) 
		CFG_DCACHE_LRSZ = 64;
	      else if (strcmp("CONFIG_DCACHE_LRSTART", lbuf) == 0) {
		strcpy(tmps, "0x"); strcat(tmps, value);
		CFG_DCACHE_LRSTART = VAL(tmps) & 0x0ff;
	      } else if (strcmp("CONFIG_MMU_ENABLE", lbuf) == 0) 
		CFG_MMU_ENABLE = 1;
	      else if (strcmp("CONFIG_MMU_DIAG", lbuf) == 0) 
		CFG_MMU_DIAG = true;
	      else if (strcmp("CONFIG_MMU_SPLIT", lbuf) == 0) 
                CFG_MMU_TYPE = "splittlb";
	      else if (strcmp("CONFIG_MMU_COMBINED", lbuf) == 0) 
		CFG_MMU_TYPE = "combinedtlb";
              else if (strcmp("CONFIG_MMU_REPARRAY", lbuf) == 0) 
		CFG_MMU_REP = "replruarray";
	      else if (strcmp("CONFIG_MMU_REPINCREMENT", lbuf) == 0) 
		CFG_MMU_REP = "repincrement";
	      else if (strcmp("CONFIG_MMU_I2", lbuf) == 0) 
	        CFG_MMU_I = 2;
	      else if (strcmp("CONFIG_MMU_I4", lbuf) == 0) 
		CFG_MMU_I = 4;
	      else if (strcmp("CONFIG_MMU_I8", lbuf) == 0) 
		CFG_MMU_I = 8;
	      else if (strcmp("CONFIG_MMU_I16", lbuf) == 0) 
		CFG_MMU_I = 16;
	      else if (strcmp("CONFIG_MMU_I32", lbuf) == 0) 
		CFG_MMU_I = 32;
	      else if (strcmp("CONFIG_MMU_D1", lbuf) == 0) 
		CFG_MMU_D = 1;
	      else if (strcmp("CONFIG_MMU_D2", lbuf) == 0) 
		CFG_MMU_D = 2;
	      else if (strcmp("CONFIG_MMU_D4", lbuf) == 0) 
		CFG_MMU_D = 4;
	      else if (strcmp("CONFIG_MMU_D8", lbuf) == 0) 
		CFG_MMU_D = 8;
	      else if (strcmp("CONFIG_MMU_D16", lbuf) == 0) 
		CFG_MMU_D = 16;
	      else if (strcmp("CONFIG_MMU_D32", lbuf) == 0) 
		CFG_MMU_D = 32;

	      /* CP config */
	      else if (strcmp("CONFIG_CP_ENABLE", lbuf) == 0)  {}
	      /* Memory controller */
	      else if (strcmp("CONFIG_MCTRL_8BIT", lbuf) == 0) 
		CONFIG_MCTRL_8BIT = true;
	      else if (strcmp("CONFIG_MCTRL_16BIT", lbuf) == 0) 
		CONFIG_MCTRL_16BIT = true;
	      else if (strcmp("CONFIG_MCTRL_5CS", lbuf) == 0) 
		CONFIG_MCTRL_5CS = true;
	      else if (strcmp("CONFIG_MCTRL_WFB", lbuf) == 0) 
		CONFIG_MCTRL_WFB = true;
	      else if (strcmp("CONFIG_MCTRL_SDRAM", lbuf) == 0) 
		CONFIG_MCTRL_SDRAM = true;
	      else if (strcmp("CONFIG_MCTRL_SDRAM_INVCLK", lbuf) == 0) 
		CONFIG_MCTRL_SDRAM_INVCLK = true;
	      else if (strcmp("CONFIG_MCTRL_SDRAM_SEPBUS", lbuf) == 0) 
		CONFIG_MCTRL_SDRAM_SEPBUS = true;
	      /* Peripherals */
	      else if (strcmp("CONFIG_PERI_LCONF", lbuf) == 0) 
		CONFIG_PERI_LCONF = true;
	      else if (strcmp("CONFIG_PERI_AHBSTAT", lbuf) == 0) 
		CONFIG_PERI_AHBSTAT = true;
	      else if (strcmp("CONFIG_PERI_WPROT", lbuf) == 0) 
		CONFIG_PERI_WPROT = true;
	      else if (strcmp("CONFIG_PERI_WDOG", lbuf) == 0) 
		CONFIG_PERI_WDOG = true;
	      else if (strcmp("CONFIG_PERI_IRQ2", lbuf) == 0)
		CONFIG_PERI_IRQ2 = true;
	      /* AHB */
	      else if (strcmp("CONFIG_AHB_DEFMST", lbuf) == 0)
		CONFIG_AHB_DEFMST = VAL(value);
	      else if (strcmp("CONFIG_AHB_SPLIT", lbuf) == 0)
		CONFIG_AHB_SPLIT = true;
	      else if (strcmp("CONFIG_AHBRAM_ENABLE", lbuf) == 0)
		CONFIG_AHBRAM_ENABLE = true;
	      else if (strcmp("CONFIG_AHBRAM_SZ1", lbuf) == 0) 
		CFG_AHBRAM_SZ = 1;
	      else if (strcmp("CONFIG_AHBRAM_SZ2", lbuf) == 0) 
		CFG_AHBRAM_SZ = 2;
	      else if (strcmp("CONFIG_AHBRAM_SZ4", lbuf) == 0) 
		CFG_AHBRAM_SZ = 3;
	      else if (strcmp("CONFIG_AHBRAM_SZ8", lbuf) == 0) 
		CFG_AHBRAM_SZ = 4;
	      else if (strcmp("CONFIG_AHBRAM_SZ16", lbuf) == 0) 
		CFG_AHBRAM_SZ = 5;
	      else if (strcmp("CONFIG_AHBRAM_SZ32", lbuf) == 0) 
		CFG_AHBRAM_SZ = 6;
	      else if (strcmp("CONFIG_AHBRAM_SZ64", lbuf) == 0) 
		CFG_AHBRAM_SZ = 7;
		/* Debug */
	      else if (strcmp("CONFIG_DEBUG_UART", lbuf) == 0) 
		CONFIG_DEBUG_UART = true;
	      else if (strcmp("CONFIG_DEBUG_IURF", lbuf) == 0) 
		CONFIG_DEBUG_IURF = true;
	      else if (strcmp("CONFIG_DEBUG_FPURF", lbuf) == 0) 
		CONFIG_DEBUG_FPURF = true;
	      else if (strcmp("CONFIG_DEBUG_NOHALT", lbuf) == 0) 
		CONFIG_DEBUG_NOHALT = true;
	      else if (strcmp("CONFIG_DEBUG_PC32", lbuf) == 0)
    	        CFG_DEBUG_PCLOW = 0;
	      else if (strcmp("CONFIG_DEBUG_RFERR", lbuf) == 0) 
		CONFIG_DEBUG_RFERR = true;
	      else if (strcmp("CONFIG_DEBUG_CACHEMEMERR", lbuf) == 0) 
		CONFIG_DEBUG_CACHEMEMERR = true;
		/* DSU */
	      else if (strcmp("CONFIG_DSU_ENABLE", lbuf) == 0) 
		{CONFIG_DSU_ENABLE = true; ahbmst ++;}
	      else if (strcmp("CONFIG_DSU_TRACEBUF", lbuf) == 0) 
		CONFIG_DSU_TRACEBUF = true;
	      else if (strcmp("CONFIG_DSU_MIXED_TRACE", lbuf) == 0) 
		CONFIG_DSU_MIXED_TRACE = true;
	      else if (strcmp("CONFIG_DSU_TRACESZ64", lbuf) == 0) 
		CFG_DSU_TRACE_SZ = 64;
	      else if (strcmp("CONFIG_DSU_TRACESZ128", lbuf) == 0) 
		CFG_DSU_TRACE_SZ = 128;
	      else if (strcmp("CONFIG_DSU_TRACESZ256", lbuf) == 0) 
		CFG_DSU_TRACE_SZ = 256;
	      else if (strcmp("CONFIG_DSU_TRACESZ512", lbuf) == 0) 
		CFG_DSU_TRACE_SZ = 512;
	      else if (strcmp("CONFIG_DSU_TRACESZ1024", lbuf) == 0) 
		CFG_DSU_TRACE_SZ = 1024;
		/* Boot */
	      else if (strcmp("CONFIG_BOOT_EXTPROM", lbuf) == 0) 
		CFG_BOOT_SOURCE = "memory";
	      else if (strcmp("CONFIG_BOOT_INTPROM", lbuf) == 0) 
		CFG_BOOT_SOURCE = "prom";
	      else if (strcmp("CONFIG_BOOT_MIXPROM", lbuf) == 0) 
		CFG_BOOT_SOURCE = "dual";
	      else if (strcmp("CONFIG_BOOT_RWS", lbuf) == 0)
		CONFIG_BOOT_RWS = VAL(value) & 0x3;
	      else if (strcmp("CONFIG_BOOT_WWS", lbuf) == 0)
		CONFIG_BOOT_WWS = VAL(value) & 0x3;
	      else if (strcmp("CONFIG_BOOT_SYSCLK", lbuf) == 0)
		CONFIG_BOOT_SYSCLK = VAL(value);
	      else if (strcmp("CONFIG_BOOT_BAUDRATE", lbuf) == 0)
		CONFIG_BOOT_BAUDRATE = VAL(value) & 0x3fffff;
	      else if (strcmp("CONFIG_BOOT_EXTBAUD", lbuf) == 0)
		CONFIG_BOOT_EXTBAUD = true;
	      else if (strcmp("CONFIG_BOOT_PROMABITS", lbuf) == 0)
		CONFIG_BOOT_PROMABITS = VAL(value) & 0x3f;
	      /* Ethernet */
	      else if (strcmp("CONFIG_ETH_ENABLE", lbuf) == 0)
		{ CONFIG_ETH_ENABLE = true; ahbmst++;}
	      else if (strcmp("CONFIG_ETH_TXFIFO", lbuf) == 0) 
	        { CONFIG_ETH_TXFIFO = VAL(value) & 0x0ffff; }
	      else if (strcmp("CONFIG_ETH_RXFIFO", lbuf) == 0) 
	        { CONFIG_ETH_RXFIFO = VAL(value) & 0x0ffff; }
	      else if (strcmp("CONFIG_ETH_BURST", lbuf) == 0) 
	        { CONFIG_ETH_BURST = VAL(value) & 0x0ffff; }
	      /* PCI */
	      else if (strcmp("CONFIG_PCI_ENABLE", lbuf) == 0)
		CONFIG_PCI_ENABLE = true;
	      else if (strcmp("CONFIG_PCI_SIMPLE_TARGET", lbuf) == 0) 
		{
		CFG_PCI_CORE = "simple_target"; ahbmst++; pciahbmst = 1;
		}
	      else if (strcmp("CONFIG_PCI_FAST_TARGET", lbuf) == 0) 
		{
		CFG_PCI_CORE = "fast_target"; ahbmst++; pciahbmst = 1;
		}
	      else if (strcmp("CONFIG_PCI_MASTER_TARGET", lbuf) == 0) 
		{
		CFG_PCI_CORE = "master_target"; ahbmst++; pciahbmst = 1;
		}
	      else if (strcmp("CONFIG_PCI_VENDORID", lbuf) == 0) 
	        {
		strcpy(tmps, "0x"); strcat(tmps, value);
		CONFIG_PCI_VENDORID = VAL(tmps) & 0x0ffff;
	        }
	      else if (strcmp("CONFIG_PCI_DEVICEID", lbuf) == 0)
	        {
		strcpy(tmps, "0x"); strcat(tmps, value);
		CONFIG_PCI_DEVICEID = VAL(tmps) & 0x0ffff;
	        }
	      else if (strcmp("CONFIG_PCI_SUBSYSID", lbuf) == 0)
	        {
		strcpy(tmps, "0x"); strcat(tmps, value);
		CONFIG_PCI_SUBSYSID = VAL(tmps) & 0x0ffff;
	        }
	      else if (strcmp("CONFIG_PCI_REVID", lbuf) == 0)
	        {
		strcpy(tmps, "0x"); strcat(tmps, value);
		CONFIG_PCI_REVID = VAL(tmps) & 0x0ff;
	        }
	      else if (strcmp("CONFIG_PCI_CLASSCODE", lbuf) == 0)
	        {
		strcpy(tmps, "0x"); strcat(tmps, value);
		CONFIG_PCI_CLASSCODE = VAL(tmps) & 0x0ffffff;
	        }
	      else if (strcmp("CONFIG_PCI_TRACE256", lbuf) == 0)
		CFG_PCI_TDEPTH = 8;
	      else if (strcmp("CONFIG_PCI_TRACE512", lbuf) == 0)
		CFG_PCI_TDEPTH = 9;
	      else if (strcmp("CONFIG_PCI_TRACE1024", lbuf) == 0)
		CFG_PCI_TDEPTH = 10;
	      else if (strcmp("CONFIG_PCI_TRACE2048", lbuf) == 0)
		CFG_PCI_TDEPTH = 11;
	      else if (strcmp("CONFIG_PCI_TRACE4096", lbuf) == 0)
		CFG_PCI_TDEPTH = 12;
	      else if (strcmp("CONFIG_PCI_TRACE", lbuf) == 0) 
		CONFIG_PCI_TRACE = true;
	      else if (strcmp("CONFIG_PCI_FIFO2", lbuf) == 0) 
		CFG_PCI_FIFO = 1;
	      else if (strcmp("CONFIG_PCI_FIFO4", lbuf) == 0) 
		CFG_PCI_FIFO = 2;
	      else if (strcmp("CONFIG_PCI_FIFO8", lbuf) == 0) 
		CFG_PCI_FIFO = 3;
	      else if (strcmp("CONFIG_PCI_FIFO16", lbuf) == 0) 
		CFG_PCI_FIFO = 4;
	      else if (strcmp("CONFIG_PCI_FIFO32", lbuf) == 0) 
		CFG_PCI_FIFO = 5;
	      else if (strcmp("CONFIG_PCI_FIFO64", lbuf) == 0) 
		CFG_PCI_FIFO = 6;
	      else if (strcmp("CONFIG_PCI_FIFO128", lbuf) == 0) 
		CFG_PCI_FIFO = 7;
	      else if (strcmp("CONFIG_PCI_PMEPADS", lbuf) == 0)
		CONFIG_PCI_PMEPADS = true;
	      else if (strcmp("CONFIG_PCI_P66PAD", lbuf) == 0)
		CONFIG_PCI_P66PAD = true;
	      else if (strcmp("CONFIG_PCI_RESETALL", lbuf) == 0)
		CONFIG_PCI_RESETALL = true;
	      else if (strcmp("CONFIG_PCI_ARBEN", lbuf) == 0)
		CONFIG_PCI_ARBEN = true;
	      /* FT */
	      else if (strcmp("CONFIG_FT_ENABLE", lbuf) == 0)
		CONFIG_FT_ENABLE = 1;
	      else if (strcmp("CONFIG_FT_RF_ENABLE", lbuf) == 0)
		CONFIG_FT_RF_ENABLE = true;
	      else if (strcmp("CONFIG_FT_RF_PARITY", lbuf) == 0)
		CONFIG_FT_RF_PARITY = true;
	      else if (strcmp("CONFIG_FT_RF_EDAC", lbuf) == 0)
		CONFIG_FT_RF_PARBITS = 7;
	      else if (strcmp("CONFIG_FT_RF_PARBITS", lbuf) == 0)
		CONFIG_FT_RF_PARBITS = abs(VAL(value) % 3) ;
	      else if (strcmp("CONFIG_FT_RF_WRFAST", lbuf) == 0)
		CONFIG_FT_RF_WRFAST = true;
	      else if (strcmp("CONFIG_FT_TMR_REG", lbuf) == 0)
		CONFIG_FT_TMR_REG = true;
	      else if (strcmp("CONFIG_FT_TMR_CLK", lbuf) == 0)
		CONFIG_FT_TMR_CLK = true;
	      else if (strcmp("CONFIG_FT_MC", lbuf) == 0)
		CONFIG_FT_MC = true;
	      else if (strcmp("CONFIG_FT_MEMEDAC", lbuf) == 0)
		CONFIG_FT_MEMEDAC = true;
	      else if (strcmp("CONFIG_FT_CACHEMEM_ENABLE", lbuf) == 0)
		CONFIG_FT_CACHEMEM_ENABLE = true;
	      else if (strcmp("CONFIG_FT_CACHEMEM_PARBITS", lbuf) == 0)
		CONFIG_FT_CACHEMEM_PARBITS = abs(VAL(value) % 3) ;
	      else if (strcmp("CONFIG_FT_CACHEMEM_APAR", lbuf) == 0)
		CONFIG_FT_CACHEMEM_APAR = true;
	      else if (strcmp("CONFIG_FT_CACHEMEM_ENABLE", lbuf) == 0) {}
	      else
	        fprintf(stderr, "unknown config option: %s = %s\n", lbuf, value);
		
	  }
      }
	
  fprintf(fp, "\n\
----------------------------------------------------------------------------\n\
--  This file is a part of the LEON VHDL model\n\
--  Copyright (C) 1999  European Space Agency (ESA)\n\
--\n\
--  This library is free software; you can redistribute it and/or\n\
--  modify it under the terms of the GNU Lesser General Public\n\
--  License as published by the Free Software Foundation; either\n\
--  version 2 of the License, or (at your option) any later version.\n\
--\n\
--  See the file COPYING.LGPL for the full details of the license.\n\
\n\
\n\
-----------------------------------------------------------------------------\n\
-- Entity: 	device\n\
-- File:	device.vhd\n\
-- Author:	Jiri Gaisler - Gaisler Research\n\
-- Description:	package to select current device configuration\n\
------------------------------------------------------------------------------\n\
\n\
library IEEE;\n\
use IEEE.std_logic_1164.all;\n\
use work.target.all;\n\
\n\
package device is\n\
\n\
-----------------------------------------------------------------------------\n\
-- Automatically generated by tkonfig/mkdevice\n\
-----------------------------------------------------------------------------\n\
");

  if (CONFIG_AHBRAM_ENABLE == true) ahbram = 4; else ahbram = 0;
  if (CONFIG_DSU_ENABLE == true) dsuen = 2; else dsuen = 7;
  if (CONFIG_PCI_ENABLE == true) pcien = 3; else pcien = 7;
  if (CONFIG_ETH_ENABLE == true) ethen = 5; else ethen = 7;

  fprintf(fp, "\n\
  constant syn_%s : syn_config_type := (  \n\
    targettech => %s , infer_pads => %s, infer_pci => %s,\n\
    infer_ram => %s, infer_regf => %s, infer_rom => %s,\n\
    infer_mult => %s, rftype => %d, targetclk => %s,\n\
    clk_mul => %d, clk_div => %d, pci_dll => %s, pci_sysclk => %s );\n\
", CONFIG_CFG_NAME, CFG_SYN_TARGET_TECH, CONFIG_SYN_INFER_PADS, CONFIG_SYN_INFER_PCI_PADS, \
   CONFIG_SYN_INFER_RAM, CONFIG_SYN_INFER_REGF, CONFIG_SYN_INFER_ROM,\
   CONFIG_SYN_INFER_MULT, CONFIG_SYN_RFTYPE, CONFIG_TARGET_CLK,
   CONFIG_PLL_CLK_MUL, CONFIG_PLL_CLK_DIV, CONFIG_PCI_CLKDLL,
   CONFIG_PCI_SYSCLK);

  fprintf(fp, "\n\
  constant iu_%s : iu_config_type := (\n\
    nwindows => %d, multiplier => %s, mulpipe => %s, \n\
    divider => %s, mac => %s, fpuen => %d, cpen => false, \n\
    fastjump => %s, icchold => %s, lddelay => %d, fastdecode => %s, \n\
    rflowpow => %s, watchpoints => %d);\n\
", CONFIG_CFG_NAME, CONFIG_IU_NWINDOWS, CFG_IU_MUL_TYPE, CONFIG_IU_MULPIPE,
   CFG_IU_DIVIDER, CONFIG_IU_MUL_MAC, CONFIG_FPU_ENABLE, CONFIG_IU_FASTJUMP,
   CONFIG_IU_ICCHOLD, CONFIG_IU_LDELAY, CONFIG_IU_FASTDECODE, CONFIG_IU_RFPOW,
   CONFIG_IU_WATCHPOINTS);

  fprintf(fp, "\n\
  constant fpu_%s : fpu_config_type := \n\
    (core => %s, interface => %s, fregs => %d, version => %d);\n\
", CONFIG_CFG_NAME, CFG_FPU_CORE, CFG_FPU_IF, CONFIG_FPU_ENABLE*CONFIG_FPU_REGS,
   CONFIG_FPU_VER);

   /*
  if ((CFG_ICACHE_SZ > 4) && (CFG_MMU_TYPE != false)) {
	CFG_ICACHE_SZ = 4;
	printf("Warning: maximum iset size 4 kbyte when MMU enabled (fixed)\n");
  }
  if ((CFG_DCACHE_SZ > 4) && (CFG_MMU_TYPE != false)) {
	CFG_DCACHE_SZ = 4;
	printf("Warning: maximum dset size 4 kbyte when MMU enabled (fixed)\n");
  }
  */

  if ((strcmp(CFG_ICACHE_ALGO,"lrr") == 0) && (CFG_ICACHE_ASSO > 2))
    CFG_ICACHE_ALGO = "rnd";
  if ((strcmp(CFG_DCACHE_ALGO,"lrr") == 0) && (CFG_DCACHE_ASSO > 2))
    CFG_DCACHE_ALGO = "rnd";

  fprintf(fp, "\n\
  constant cache_%s : cache_config_type := (\n\
    isets => %d, isetsize => %d, ilinesize => %d, ireplace => %s, ilock => %d,\n\
    dsets => %d, dsetsize => %d, dlinesize => %d, dreplace => %s, dlock => %d,\n\
    dsnoop => %s, drfast => %s, dwfast => %s, dlram => %s, \n\
    dlramsize => %d, dlramaddr => 16#%02X#);\n\
", CONFIG_CFG_NAME,
   CFG_ICACHE_ASSO, CFG_ICACHE_SZ, CFG_ICACHE_LSZ/4, CFG_ICACHE_ALGO, CFG_ICACHE_LOCK,
   CFG_DCACHE_ASSO, CFG_DCACHE_SZ, CFG_DCACHE_LSZ/4, CFG_DCACHE_ALGO, CFG_DCACHE_LOCK,
   CFG_DCACHE_SNOOP, CFG_DCACHE_RFAST, CFG_DCACHE_WFAST, CFG_DCACHE_LRAM,
   CFG_DCACHE_LRSZ, CFG_DCACHE_LRSTART);

  fprintf (fp, "\n\
  constant mmu_%s : mmu_config_type := (\n\
    enable => %d, itlbnum => %d, dtlbnum => %d, tlb_type => %s, \n\
    tlb_rep => %s, tlb_diag => %s );\n\
", CONFIG_CFG_NAME, CFG_MMU_ENABLE, CFG_MMU_I, CFG_MMU_D,
   CFG_MMU_TYPE, CFG_MMU_REP, CFG_MMU_DIAG);

  fprintf(fp, "\n\
  constant ahbrange_config  : ahbslv_addr_type := \n\
        (0,0,0,0,0,0,%d,0,1,%d,%d,%d,%d,%d,%d,%d);\n\
", ahbram, dsuen, pcien, ethen, pcien, pcien, pcien, pcien);

  fprintf(fp, "\n\
  constant ahb_%s : ahb_config_type := ( masters => %d, defmst => %d,\n\
    split => %s, testmod => false);\n\
", CONFIG_CFG_NAME, ahbmst, CONFIG_AHB_DEFMST % ahbmst, CONFIG_AHB_SPLIT);

  fprintf(fp, "\n\
  constant mctrl_%s : mctrl_config_type := (\n\
    bus8en => %s, bus16en => %s, wendfb => %s, ramsel5 => %s,\n\
    sdramen => %s, sdinvclk => %s, sdsepbus => %s);\n\
", CONFIG_CFG_NAME, CONFIG_MCTRL_8BIT, CONFIG_MCTRL_16BIT, CONFIG_MCTRL_WFB, 
   CONFIG_MCTRL_5CS, 
   CONFIG_MCTRL_SDRAM, CONFIG_MCTRL_SDRAM_INVCLK, CONFIG_MCTRL_SDRAM_SEPBUS);
   
  fprintf(fp, "\n\
  constant peri_%s : peri_config_type := (\n\
    cfgreg => %s, ahbstat => %s, wprot => %s, wdog => %s, \n\
    irq2en => %s, ahbram => %s, ahbrambits => %d, ethen => %s );\n\
", CONFIG_CFG_NAME, CONFIG_PERI_LCONF, CONFIG_PERI_AHBSTAT, CONFIG_PERI_WPROT,
   CONFIG_PERI_WDOG, CONFIG_PERI_IRQ2, CONFIG_AHBRAM_ENABLE, 7 + CFG_AHBRAM_SZ,
   CONFIG_ETH_ENABLE);

  fprintf(fp, "\n\
  constant debug_%s : debug_config_type := ( enable => true, uart => %s, \n\
    iureg => %s, fpureg => %s, nohalt => %s, pclow => %d,\n\
    dsuenable => %s, dsutrace => %s, dsumixed => %s,\n\
    dsudpram => %s, tracelines => %d);\n\
", CONFIG_CFG_NAME, CONFIG_DEBUG_UART, CONFIG_DEBUG_IURF, CONFIG_DEBUG_FPURF,
   CONFIG_DEBUG_NOHALT, CFG_DEBUG_PCLOW, CONFIG_DSU_ENABLE, CONFIG_DSU_TRACEBUF,
   CONFIG_DSU_MIXED_TRACE, CONFIG_SYN_TRACE_DPRAM, CFG_DSU_TRACE_SZ);

  fprintf(fp, "\n\
  constant boot_%s : boot_config_type := (boot => %s, ramrws => %d,\n\
    ramwws => %d, sysclk => %d, baud => %d, extbaud => %s,\n\
    pabits => %d);\n\
", CONFIG_CFG_NAME, CFG_BOOT_SOURCE, CONFIG_BOOT_RWS, CONFIG_BOOT_WWS,
   CONFIG_BOOT_SYSCLK, CONFIG_BOOT_BAUDRATE, CONFIG_BOOT_EXTBAUD, 
   CONFIG_BOOT_PROMABITS);

  fprintf(fp, "\n\
  constant pci_%s : pci_config_type := (\n\
    pcicore => %s , ahbmasters => %d, fifodepth => %d,\n\
    arbiter => %s, fixpri => false, prilevels => 4, pcimasters => 4,\n\
    vendorid => 16#%04X#, deviceid => 16#%04X#, subsysid => 16#%04X#,\n\
    revisionid => 16#%02X#, classcode =>16#%06X#, pmepads => %s,\n\
    p66pad => %s, pcirstall => %s, trace => %s, tracedepth => %d);\n\
", CONFIG_CFG_NAME, CFG_PCI_CORE, pciahbmst, CFG_PCI_FIFO, CONFIG_PCI_ARBEN,
   CONFIG_PCI_VENDORID, CONFIG_PCI_DEVICEID, CONFIG_PCI_SUBSYSID, 
   CONFIG_PCI_REVID, CONFIG_PCI_CLASSCODE, CONFIG_PCI_PMEPADS, 
   CONFIG_PCI_P66PAD, CONFIG_PCI_RESETALL, CONFIG_PCI_TRACE, CFG_PCI_TDEPTH);

  fprintf(fp, "\n\
  constant irq2cfg : irq2type := irq2none;\n\
");

  if (CONFIG_FT_ENABLE)
  fprintf(fp, "\n\
  constant ft_%s : ft_config_type := ( rfpbits => %d, tmrreg => %s,\n\
    tmrclk => %s, mscheck => %s, memedac => %s, \n\
    rfwropt => %s, cparbits => %d, caddrpar => %s, regferr => %s,\n\
    cacheerr => %s);\n\
", CONFIG_CFG_NAME, CONFIG_FT_RF_PARBITS, CONFIG_FT_TMR_REG, CONFIG_FT_TMR_CLK,
   CONFIG_FT_MC, CONFIG_FT_MEMEDAC, CONFIG_FT_RF_WRFAST,
   CONFIG_FT_CACHEMEM_PARBITS, CONFIG_FT_CACHEMEM_APAR, CONFIG_DEBUG_RFERR,
   CONFIG_DEBUG_CACHEMEMERR);

  fprintf(fp, "\n\
\n\
-----------------------------------------------------------------------------\n\
-- end of automatic configuration\n\
-----------------------------------------------------------------------------\n\
\n\
end;\n\
");
  close(fp);
  fp = fopen("device.v", "w+");
  if (!fp) {
	printf("could not open file device.v\n");
	exit(1);
  }
  fprintf(fp, "\n\
`define HEADER_VENDOR_ID    16'h%04X\n\
`define HEADER_DEVICE_ID    16'h%04X\n\
`define HEADER_REVISION_ID  8'h%02X\n\
", CONFIG_PCI_VENDORID, CONFIG_PCI_DEVICEID, CONFIG_PCI_REVID);

  if ((CONFIG_SYN_INFER_RAM == false) && (!((strcmp(CFG_SYN_TARGET_TECH, "virtex")) && 
      (strcmp(CFG_SYN_TARGET_TECH, "virtex2"))))) {
    fprintf(fp, "\n\
`define FPGA\n\
`define XILINX\n\
`define WBW_ADDR_LENGTH 7\n\
`define WBR_ADDR_LENGTH 7\n\
`define PCIW_ADDR_LENGTH 7\n\
`define PCIR_ADDR_LENGTH 7\n\
`define PCI_FIFO_RAM_ADDR_LENGTH 8 \n\
`define WB_FIFO_RAM_ADDR_LENGTH 8    \n\
");
  } else 
    fprintf(fp, "\n\
`define WB_RAM_DONT_SHARE\n\
`define PCI_RAM_DONT_SHARE\n\
`define WBW_ADDR_LENGTH %d\n\
`define WBR_ADDR_LENGTH %d\n\
`define PCIW_ADDR_LENGTH %d\n\
`define PCIR_ADDR_LENGTH %d\n\
`define PCI_FIFO_RAM_ADDR_LENGTH %d \n\
`define WB_FIFO_RAM_ADDR_LENGTH %d    \n\
", CFG_PCI_FIFO, CFG_PCI_FIFO, CFG_PCI_FIFO, CFG_PCI_FIFO,
   CFG_PCI_FIFO, CFG_PCI_FIFO);

  fprintf(fp, "\n\
`define ETH_WISHBONE_B3\n\
\n\
`define ETH_TX_FIFO_CNT_WIDTH  %d\n\
`define ETH_TX_FIFO_DEPTH      %d\n\
\n\
`define ETH_RX_FIFO_CNT_WIDTH  %d\n\
`define ETH_RX_FIFO_DEPTH      %d\n\
\n\
`define ETH_BURST_CNT_WIDTH    %d\n\
`define ETH_BURST_LENGTH       %d\n",
  log2(CONFIG_ETH_TXFIFO)+1, CONFIG_ETH_TXFIFO,
  log2(CONFIG_ETH_RXFIFO)+1, CONFIG_ETH_RXFIFO,
  log2(CONFIG_ETH_BURST)+1, CONFIG_ETH_BURST);

  close(fp);
  return(0);
}
