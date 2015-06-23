#if defined CONFIG_SYN_INFERRED
#define CONFIG_SYN_TECH inferred
#elif defined CONFIG_SYN_UMC
#define CONFIG_SYN_TECH umc
#elif defined CONFIG_SYN_RHUMC
#define CONFIG_SYN_TECH rhumc
#elif defined CONFIG_SYN_ATC18
#define CONFIG_SYN_TECH atc18s
#elif defined CONFIG_SYN_ATC18RHA
#define CONFIG_SYN_TECH atc18rha
#elif defined CONFIG_SYN_AXCEL
#define CONFIG_SYN_TECH axcel
#elif defined CONFIG_SYN_PROASICPLUS
#define CONFIG_SYN_TECH proasic
#elif defined CONFIG_SYN_ALTERA
#define CONFIG_SYN_TECH altera
#elif defined CONFIG_SYN_STRATIX
#define CONFIG_SYN_TECH stratix1
#elif defined CONFIG_SYN_STRATIXII
#define CONFIG_SYN_TECH stratix2
#elif defined CONFIG_SYN_STRATIXIII
#define CONFIG_SYN_TECH stratix3
#elif defined CONFIG_SYN_CYCLONEIII
#define CONFIG_SYN_TECH cyclone3
#elif defined CONFIG_SYN_EASIC90
#define CONFIG_SYN_TECH easic90
#elif defined CONFIG_SYN_IHP25
#define CONFIG_SYN_TECH ihp25
#elif defined CONFIG_SYN_IHP25RH
#define CONFIG_SYN_TECH ihp25rh
#elif defined CONFIG_SYN_LATTICE
#define CONFIG_SYN_TECH lattice
#elif defined CONFIG_SYN_ECLIPSE
#define CONFIG_SYN_TECH eclipse
#elif defined CONFIG_SYN_PEREGRINE
#define CONFIG_SYN_TECH peregrine
#elif defined CONFIG_SYN_PROASIC
#define CONFIG_SYN_TECH proasic
#elif defined CONFIG_SYN_PROASIC3
#define CONFIG_SYN_TECH apa3
#elif defined CONFIG_SYN_SPARTAN2
#define CONFIG_SYN_TECH virtex
#elif defined CONFIG_SYN_VIRTEX
#define CONFIG_SYN_TECH virtex
#elif defined CONFIG_SYN_VIRTEXE
#define CONFIG_SYN_TECH virtex
#elif defined CONFIG_SYN_SPARTAN3
#define CONFIG_SYN_TECH spartan3
#elif defined CONFIG_SYN_SPARTAN3E
#define CONFIG_SYN_TECH spartan3e
#elif defined CONFIG_SYN_VIRTEX2
#define CONFIG_SYN_TECH virtex2
#elif defined CONFIG_SYN_VIRTEX4
#define CONFIG_SYN_TECH virtex4
#elif defined CONFIG_SYN_VIRTEX5
#define CONFIG_SYN_TECH virtex5
#elif defined CONFIG_SYN_RH_LIB18T
#define CONFIG_SYN_TECH rhlib18t
#elif defined CONFIG_SYN_UT025CRH
#define CONFIG_SYN_TECH ut25
#elif defined CONFIG_SYN_TSMC90
#define CONFIG_SYN_TECH tsmc90
#elif defined CONFIG_SYN_CUSTOM1
#define CONFIG_SYN_TECH custom1
#else
#error "unknown target technology"
#endif

#if defined CONFIG_SYN_INFER_RAM
#define CFG_RAM_TECH inferred
#elif defined CONFIG_MEM_UMC
#define CFG_RAM_TECH umc
#elif defined CONFIG_MEM_RHUMC
#define CFG_RAM_TECH rhumc
#elif defined CONFIG_MEM_VIRAGE
#define CFG_RAM_TECH memvirage
#elif defined CONFIG_MEM_ARTISAN
#define CFG_RAM_TECH memartisan
#elif defined CONFIG_MEM_CUSTOM1
#define CFG_RAM_TECH custom1
#elif defined CONFIG_MEM_VIRAGE90
#define CFG_RAM_TECH memvirage90
#elif defined CONFIG_MEM_INFERRED
#define CFG_RAM_TECH inferred
#else
#define CFG_RAM_TECH CONFIG_SYN_TECH
#endif

#if defined CONFIG_SYN_INFER_PADS
#define CFG_PAD_TECH inferred
#else
#define CFG_PAD_TECH CONFIG_SYN_TECH
#endif

#ifndef CONFIG_SYN_NO_ASYNC
#define CONFIG_SYN_NO_ASYNC 0
#endif

#ifndef CONFIG_SYN_SCAN
#define CONFIG_SYN_SCAN 0
#endif


#if defined CONFIG_CLK_ALTDLL
#define CFG_CLK_TECH CONFIG_SYN_TECH
#elif defined CONFIG_CLK_HCLKBUF
#define CFG_CLK_TECH axcel
#elif defined CONFIG_CLK_LATDLL
#define CFG_CLK_TECH lattice
#elif defined CONFIG_CLK_PRO3PLL
#define CFG_CLK_TECH apa3
#elif defined CONFIG_CLK_CLKDLL
#define CFG_CLK_TECH virtex
#elif defined CONFIG_CLK_DCM
#define CFG_CLK_TECH CONFIG_SYN_TECH
#elif defined CONFIG_CLK_LIB18T
#define CFG_CLK_TECH rhlib18t
#elif defined CONFIG_CLK_RHUMC
#define CFG_CLK_TECH rhumc
#else
#define CFG_CLK_TECH inferred
#endif

#ifndef CONFIG_CLK_MUL
#define CONFIG_CLK_MUL 2
#endif

#ifndef CONFIG_CLK_DIV
#define CONFIG_CLK_DIV 2
#endif

#ifndef CONFIG_OCLK_DIV
#define CONFIG_OCLK_DIV 2
#endif

#ifndef CONFIG_PCI_CLKDLL
#define CONFIG_PCI_CLKDLL 0
#endif

#ifndef CONFIG_PCI_SYSCLK
#define CONFIG_PCI_SYSCLK 0
#endif

#ifndef CONFIG_CLK_NOFB
#define CONFIG_CLK_NOFB 0
#endif
#ifndef CONFIG_LEON3
#define CONFIG_LEON3 0
#endif

#ifndef CONFIG_PROC_NUM
#define CONFIG_PROC_NUM 1
#endif

#ifndef CONFIG_IU_NWINDOWS
#define CONFIG_IU_NWINDOWS 8
#endif

#ifndef CONFIG_IU_RSTADDR
#define CONFIG_IU_RSTADDR 8
#endif

#ifndef CONFIG_IU_LDELAY
#define CONFIG_IU_LDELAY 1
#endif

#ifndef CONFIG_IU_WATCHPOINTS
#define CONFIG_IU_WATCHPOINTS 0
#endif

#ifdef CONFIG_IU_V8MULDIV
#ifdef CONFIG_IU_MUL_LATENCY_4
#define CFG_IU_V8 1
#elif defined CONFIG_IU_MUL_LATENCY_5
#define CFG_IU_V8 2
#elif defined CONFIG_IU_MUL_LATENCY_2
#define CFG_IU_V8 16#32#
#endif
#else
#define CFG_IU_V8 0
#endif

#ifndef CONFIG_PWD
#define CONFIG_PWD 0
#endif

#ifndef CONFIG_IU_MUL_MAC
#define CONFIG_IU_MUL_MAC 0
#endif

#ifndef CONFIG_IU_SVT
#define CONFIG_IU_SVT 0
#endif

#if defined CONFIG_FPU_GRFPC1
#define CONFIG_FPU_GRFPC 1
#elif defined CONFIG_FPU_GRFPC2
#define CONFIG_FPU_GRFPC 2
#else
#define CONFIG_FPU_GRFPC 0
#endif

#if defined CONFIG_FPU_GRFPU_INFMUL
#define CONFIG_FPU_GRFPU_MUL 0
#elif defined CONFIG_FPU_GRFPU_DWMUL
#define CONFIG_FPU_GRFPU_MUL 1
#elif defined CONFIG_FPU_GRFPU_MODGEN 
#define CONFIG_FPU_GRFPU_MUL 2
#else
#define CONFIG_FPU_GRFPU_MUL 0
#endif

#if defined CONFIG_FPU_GRFPU_SH
#define CONFIG_FPU_GRFPU_SHARED 1
#else
#define CONFIG_FPU_GRFPU_SHARED 0
#endif

#if defined CONFIG_FPU_GRFPU
#define CONFIG_FPU (1+CONFIG_FPU_GRFPU_MUL)
#elif defined CONFIG_FPU_MEIKO
#define CONFIG_FPU 15
#elif defined CONFIG_FPU_GRFPULITE
#define CONFIG_FPU (8+CONFIG_FPU_GRFPC)
#else
#define CONFIG_FPU 0
#endif

#ifndef CONFIG_FPU_NETLIST
#define CONFIG_FPU_NETLIST 0
#endif

#ifndef CONFIG_ICACHE_ENABLE
#define CONFIG_ICACHE_ENABLE 0
#endif

#if defined CONFIG_ICACHE_ASSO1
#define CFG_IU_ISETS 1
#elif defined CONFIG_ICACHE_ASSO2
#define CFG_IU_ISETS 2
#elif defined CONFIG_ICACHE_ASSO3
#define CFG_IU_ISETS 3
#elif defined CONFIG_ICACHE_ASSO4
#define CFG_IU_ISETS 4
#else
#define CFG_IU_ISETS 1
#endif

#if defined CONFIG_ICACHE_SZ1
#define CFG_ICACHE_SZ 1
#elif defined CONFIG_ICACHE_SZ2
#define CFG_ICACHE_SZ 2
#elif defined CONFIG_ICACHE_SZ4
#define CFG_ICACHE_SZ 4
#elif defined CONFIG_ICACHE_SZ8
#define CFG_ICACHE_SZ 8
#elif defined CONFIG_ICACHE_SZ16
#define CFG_ICACHE_SZ 16
#elif defined CONFIG_ICACHE_SZ32
#define CFG_ICACHE_SZ 32
#elif defined CONFIG_ICACHE_SZ64
#define CFG_ICACHE_SZ 64
#elif defined CONFIG_ICACHE_SZ128
#define CFG_ICACHE_SZ 128
#elif defined CONFIG_ICACHE_SZ256
#define CFG_ICACHE_SZ 256
#else
#define CFG_ICACHE_SZ 1
#endif

#ifdef CONFIG_ICACHE_LZ16
#define CFG_ILINE_SZ 4
#else
#define CFG_ILINE_SZ 8
#endif

#if defined CONFIG_ICACHE_ALGORND
#define CFG_ICACHE_ALGORND 2
#elif defined CONFIG_ICACHE_ALGOLRR
#define CFG_ICACHE_ALGORND 1
#else
#define CFG_ICACHE_ALGORND 0
#endif

#ifndef CONFIG_ICACHE_LOCK
#define CONFIG_ICACHE_LOCK 0
#endif

#ifndef CONFIG_ICACHE_LRAM
#define CONFIG_ICACHE_LRAM 0
#endif

#ifndef CONFIG_ICACHE_LRSTART
#define CONFIG_ICACHE_LRSTART 8E
#endif

#if defined CONFIG_ICACHE_LRAM_SZ2
#define CFG_ILRAM_SIZE 2
#elif defined CONFIG_ICACHE_LRAM_SZ4
#define CFG_ILRAM_SIZE 4
#elif defined CONFIG_ICACHE_LRAM_SZ8
#define CFG_ILRAM_SIZE 8
#elif defined CONFIG_ICACHE_LRAM_SZ16
#define CFG_ILRAM_SIZE 16
#elif defined CONFIG_ICACHE_LRAM_SZ32
#define CFG_ILRAM_SIZE 32
#elif defined CONFIG_ICACHE_LRAM_SZ64
#define CFG_ILRAM_SIZE 64
#elif defined CONFIG_ICACHE_LRAM_SZ128
#define CFG_ILRAM_SIZE 128
#elif defined CONFIG_ICACHE_LRAM_SZ256
#define CFG_ILRAM_SIZE 256
#else
#define CFG_ILRAM_SIZE 1
#endif


#ifndef CONFIG_DCACHE_ENABLE
#define CONFIG_DCACHE_ENABLE 0
#endif

#if defined CONFIG_DCACHE_ASSO1
#define CFG_IU_DSETS 1
#elif defined CONFIG_DCACHE_ASSO2
#define CFG_IU_DSETS 2
#elif defined CONFIG_DCACHE_ASSO3
#define CFG_IU_DSETS 3
#elif defined CONFIG_DCACHE_ASSO4
#define CFG_IU_DSETS 4
#else
#define CFG_IU_DSETS 1
#endif

#if defined CONFIG_DCACHE_SZ1
#define CFG_DCACHE_SZ 1
#elif defined CONFIG_DCACHE_SZ2
#define CFG_DCACHE_SZ 2
#elif defined CONFIG_DCACHE_SZ4
#define CFG_DCACHE_SZ 4
#elif defined CONFIG_DCACHE_SZ8
#define CFG_DCACHE_SZ 8
#elif defined CONFIG_DCACHE_SZ16
#define CFG_DCACHE_SZ 16
#elif defined CONFIG_DCACHE_SZ32
#define CFG_DCACHE_SZ 32
#elif defined CONFIG_DCACHE_SZ64
#define CFG_DCACHE_SZ 64
#elif defined CONFIG_DCACHE_SZ128
#define CFG_DCACHE_SZ 128
#elif defined CONFIG_DCACHE_SZ256
#define CFG_DCACHE_SZ 256
#else
#define CFG_DCACHE_SZ 1
#endif

#ifdef CONFIG_DCACHE_LZ16
#define CFG_DLINE_SZ 4
#else
#define CFG_DLINE_SZ 8
#endif

#if defined CONFIG_DCACHE_ALGORND
#define CFG_DCACHE_ALGORND 2
#elif defined CONFIG_DCACHE_ALGOLRR
#define CFG_DCACHE_ALGORND 1
#else
#define CFG_DCACHE_ALGORND 0
#endif

#ifndef CONFIG_DCACHE_LOCK
#define CONFIG_DCACHE_LOCK 0
#endif

#ifndef CONFIG_DCACHE_SNOOP
#define CONFIG_DCACHE_SNOOP 0
#endif

#ifndef CONFIG_DCACHE_SNOOP_FAST
#define CONFIG_DCACHE_SNOOP_FAST 0
#endif

#ifndef CONFIG_DCACHE_SNOOP_SEPTAG
#define CONFIG_DCACHE_SNOOP_SEPTAG 0
#endif

#ifndef CONFIG_CACHE_FIXED
#define CONFIG_CACHE_FIXED 0
#endif

#ifndef CONFIG_DCACHE_LRAM
#define CONFIG_DCACHE_LRAM 0
#endif

#ifndef CONFIG_DCACHE_LRSTART
#define CONFIG_DCACHE_LRSTART 8F
#endif

#if defined CONFIG_DCACHE_LRAM_SZ2
#define CFG_DLRAM_SIZE 2
#elif defined CONFIG_DCACHE_LRAM_SZ4
#define CFG_DLRAM_SIZE 4
#elif defined CONFIG_DCACHE_LRAM_SZ8
#define CFG_DLRAM_SIZE 8
#elif defined CONFIG_DCACHE_LRAM_SZ16
#define CFG_DLRAM_SIZE 16
#elif defined CONFIG_DCACHE_LRAM_SZ32
#define CFG_DLRAM_SIZE 32
#elif defined CONFIG_DCACHE_LRAM_SZ64
#define CFG_DLRAM_SIZE 64
#elif defined CONFIG_DCACHE_LRAM_SZ128
#define CFG_DLRAM_SIZE 128
#elif defined CONFIG_DCACHE_LRAM_SZ256
#define CFG_DLRAM_SIZE 256
#else
#define CFG_DLRAM_SIZE 1
#endif


#ifdef CONFIG_MMU_ENABLE
#define CONFIG_MMUEN 1

#ifdef CONFIG_MMU_SPLIT
#define CONFIG_TLB_TYPE 0
#endif
#ifdef CONFIG_MMU_COMBINED
#define CONFIG_TLB_TYPE 1
#endif

#ifdef CONFIG_MMU_REPARRAY
#define CONFIG_TLB_REP 0
#endif
#ifdef CONFIG_MMU_REPINCREMENT
#define CONFIG_TLB_REP 1
#endif

#ifdef CONFIG_MMU_I2 
#define CONFIG_ITLBNUM 2
#endif
#ifdef CONFIG_MMU_I4 
#define CONFIG_ITLBNUM 4
#endif
#ifdef CONFIG_MMU_I8 
#define CONFIG_ITLBNUM 8
#endif
#ifdef CONFIG_MMU_I16 
#define CONFIG_ITLBNUM 16
#endif
#ifdef CONFIG_MMU_I32
#define CONFIG_ITLBNUM 32
#endif

#define CONFIG_DTLBNUM 2
#ifdef CONFIG_MMU_D2 
#undef CONFIG_DTLBNUM 
#define CONFIG_DTLBNUM 2
#endif
#ifdef CONFIG_MMU_D4 
#undef CONFIG_DTLBNUM 
#define CONFIG_DTLBNUM 4
#endif
#ifdef CONFIG_MMU_D8 
#undef CONFIG_DTLBNUM 
#define CONFIG_DTLBNUM 8
#endif
#ifdef CONFIG_MMU_D16 
#undef CONFIG_DTLBNUM 
#define CONFIG_DTLBNUM 16
#endif
#ifdef CONFIG_MMU_D32
#undef CONFIG_DTLBNUM 
#define CONFIG_DTLBNUM 32
#endif
#ifdef CONFIG_MMU_FASTWB
#define CFG_MMU_FASTWB 1
#else
#define CFG_MMU_FASTWB 0
#endif

#else
#define CONFIG_MMUEN 0
#define CONFIG_ITLBNUM 2
#define CONFIG_DTLBNUM 2
#define CONFIG_TLB_TYPE 1
#define CONFIG_TLB_REP 1
#define CFG_MMU_FASTWB 0
#endif

#ifndef CONFIG_DSU_ENABLE
#define CONFIG_DSU_ENABLE 0
#endif

#if defined CONFIG_DSU_ITRACESZ1
#define CFG_DSU_ITB 1
#elif CONFIG_DSU_ITRACESZ2
#define CFG_DSU_ITB 2
#elif CONFIG_DSU_ITRACESZ4
#define CFG_DSU_ITB 4
#elif CONFIG_DSU_ITRACESZ8
#define CFG_DSU_ITB 8
#elif CONFIG_DSU_ITRACESZ16
#define CFG_DSU_ITB 16
#else
#define CFG_DSU_ITB 0
#endif

#if defined CONFIG_DSU_ATRACESZ1
#define CFG_DSU_ATB 1
#elif CONFIG_DSU_ATRACESZ2
#define CFG_DSU_ATB 2
#elif CONFIG_DSU_ATRACESZ4
#define CFG_DSU_ATB 4
#elif CONFIG_DSU_ATRACESZ8
#define CFG_DSU_ATB 8
#elif CONFIG_DSU_ATRACESZ16
#define CFG_DSU_ATB 16
#else
#define CFG_DSU_ATB 0
#endif

#ifndef CONFIG_LEON3FT_EN
#define CONFIG_LEON3FT_EN 0
#endif

#if defined CONFIG_IUFT_PAR
#define CONFIG_IUFT_EN 1
#elif defined CONFIG_IUFT_DMR
#define CONFIG_IUFT_EN 2
#elif defined CONFIG_IUFT_BCH
#define CONFIG_IUFT_EN 3
#elif defined CONFIG_IUFT_TMR
#define CONFIG_IUFT_EN 4
#else
#define CONFIG_IUFT_EN 0
#endif
#ifndef CONFIG_RF_ERRINJ
#define CONFIG_RF_ERRINJ 0
#endif

#ifndef CONFIG_FPUFT_EN
#define CONFIG_FPUFT 0
#else
#ifdef CONFIG_FPU_GRFPU
#define CONFIG_FPUFT 2
#else
#define CONFIG_FPUFT 1
#endif
#endif

#ifndef CONFIG_CACHE_FT_EN
#define CONFIG_CACHE_FT_EN 0
#endif
#ifndef CONFIG_CACHE_ERRINJ
#define CONFIG_CACHE_ERRINJ 0
#endif

#ifndef CONFIG_LEON3_NETLIST
#define CONFIG_LEON3_NETLIST 0
#endif

#ifdef CONFIG_DEBUG_PC32
#define CFG_DEBUG_PC32 0 
#else
#define CFG_DEBUG_PC32 2
#endif
#ifndef CONFIG_IU_DISAS
#define CONFIG_IU_DISAS 0
#endif
#ifndef CONFIG_IU_DISAS_NET
#define CONFIG_IU_DISAS_NET 0
#endif


#ifndef CONFIG_AHB_SPLIT
#define CONFIG_AHB_SPLIT 0
#endif

#ifndef CONFIG_AHB_RROBIN
#define CONFIG_AHB_RROBIN 0
#endif

#ifndef CONFIG_AHB_IOADDR
#define CONFIG_AHB_IOADDR FFF
#endif

#ifndef CONFIG_APB_HADDR
#define CONFIG_APB_HADDR 800
#endif

#ifndef CONFIG_AHB_MON
#define CONFIG_AHB_MON 0
#endif

#ifndef CONFIG_AHB_MONERR
#define CONFIG_AHB_MONERR 0
#endif

#ifndef CONFIG_AHB_MONWAR
#define CONFIG_AHB_MONWAR 0
#endif

#ifndef CONFIG_DSU_UART
#define CONFIG_DSU_UART 0
#endif


#ifndef CONFIG_DSU_JTAG
#define CONFIG_DSU_JTAG 0
#endif

#ifndef CONFIG_DSU_ETH
#define CONFIG_DSU_ETH 0
#endif

#ifndef CONFIG_DSU_IPMSB
#define CONFIG_DSU_IPMSB C0A8
#endif

#ifndef CONFIG_DSU_IPLSB
#define CONFIG_DSU_IPLSB 0033
#endif

#ifndef CONFIG_DSU_ETHMSB
#define CONFIG_DSU_ETHMSB 00007A
#endif

#ifndef CONFIG_DSU_ETHLSB
#define CONFIG_DSU_ETHLSB CC0001
#endif

#if defined CONFIG_DSU_ETHSZ1
#define CFG_DSU_ETHB 1
#elif CONFIG_DSU_ETHSZ2
#define CFG_DSU_ETHB 2
#elif CONFIG_DSU_ETHSZ4
#define CFG_DSU_ETHB 4
#elif CONFIG_DSU_ETHSZ8
#define CFG_DSU_ETHB 8
#elif CONFIG_DSU_ETHSZ16
#define CFG_DSU_ETHB 16
#elif CONFIG_DSU_ETHSZ32
#define CFG_DSU_ETHB 32
#else
#define CFG_DSU_ETHB 1
#endif

#ifndef CONFIG_DSU_ETH_PROG
#define CONFIG_DSU_ETH_PROG 0
#endif

#ifndef CONFIG_MCTRL_LEON2
#define CONFIG_MCTRL_LEON2 0
#endif

#ifndef CONFIG_MCTRL_SDRAM
#define CONFIG_MCTRL_SDRAM 0
#endif

#ifndef CONFIG_MCTRL_SDRAM_SEPBUS
#define CONFIG_MCTRL_SDRAM_SEPBUS 0
#endif

#ifndef CONFIG_MCTRL_SDRAM_INVCLK
#define CONFIG_MCTRL_SDRAM_INVCLK 0
#endif

#ifndef CONFIG_MCTRL_SDRAM_BUS64
#define CONFIG_MCTRL_SDRAM_BUS64 0
#endif

#ifndef CONFIG_MCTRL_8BIT
#define CONFIG_MCTRL_8BIT 0
#endif

#ifndef CONFIG_MCTRL_16BIT
#define CONFIG_MCTRL_16BIT 0
#endif

#ifndef CONFIG_MCTRL_5CS
#define CONFIG_MCTRL_5CS 0
#endif

#ifndef CONFIG_MCTRL_EDAC
#define CONFIG_MCTRL_EDAC 0
#endif

#ifndef CONFIG_MCTRL_PAGE
#define CONFIG_MCTRL_PAGE 0
#endif

#ifndef CONFIG_MCTRL_PROGPAGE
#define CONFIG_MCTRL_PROGPAGE 0
#endif

#ifndef CONFIG_DDRSP
#define CONFIG_DDRSP 0
#endif

#ifndef CONFIG_DDRSP_INIT
#define CONFIG_DDRSP_INIT 0
#endif

#ifndef CONFIG_DDRSP_FREQ
#define CONFIG_DDRSP_FREQ 100
#endif

#ifndef CONFIG_DDRSP_COL
#define CONFIG_DDRSP_COL 9
#endif

#ifndef CONFIG_DDRSP_MBYTE
#define CONFIG_DDRSP_MBYTE 8
#endif

#ifndef CONFIG_DDRSP_RSKEW
#define CONFIG_DDRSP_RSKEW 0
#endif
#ifndef CONFIG_AHBROM_ENABLE
#define CONFIG_AHBROM_ENABLE 0
#endif

#ifndef CONFIG_AHBROM_START
#define CONFIG_AHBROM_START 000
#endif

#ifndef CONFIG_AHBROM_PIPE
#define CONFIG_AHBROM_PIPE 0
#endif

#if (CONFIG_AHBROM_START == 0) && (CONFIG_AHBROM_ENABLE == 1)
#define CONFIG_ROM_START 100
#else
#define CONFIG_ROM_START 000
#endif


#ifndef CONFIG_AHBRAM_ENABLE
#define CONFIG_AHBRAM_ENABLE 0
#endif

#ifndef CONFIG_AHBRAM_START
#define CONFIG_AHBRAM_START A00
#endif

#if defined CONFIG_AHBRAM_SZ1
#define CFG_AHBRAMSZ 1
#elif CONFIG_AHBRAM_SZ2
#define CFG_AHBRAMSZ 2
#elif CONFIG_AHBRAM_SZ4
#define CFG_AHBRAMSZ 4
#elif CONFIG_AHBRAM_SZ8
#define CFG_AHBRAMSZ 8
#elif CONFIG_AHBRAM_SZ16
#define CFG_AHBRAMSZ 16
#elif CONFIG_AHBRAM_SZ32
#define CFG_AHBRAMSZ 32
#elif CONFIG_AHBRAM_SZ64
#define CFG_AHBRAMSZ 64
#else
#define CFG_AHBRAMSZ 1
#endif

#ifndef CONFIG_GRETH_ENABLE
#define CONFIG_GRETH_ENABLE 0
#endif

#ifndef CONFIG_GRETH_GIGA
#define CONFIG_GRETH_GIGA 0
#endif

#if defined CONFIG_GRETH_FIFO4
#define CFG_GRETH_FIFO 4
#elif defined CONFIG_GRETH_FIFO8
#define CFG_GRETH_FIFO 8
#elif defined CONFIG_GRETH_FIFO16
#define CFG_GRETH_FIFO 16
#elif defined CONFIG_GRETH_FIFO32
#define CFG_GRETH_FIFO 32
#elif defined CONFIG_GRETH_FIFO64
#define CFG_GRETH_FIFO 64
#else
#define CFG_GRETH_FIFO 8
#endif

#ifndef CONFIG_UART1_ENABLE
#define CONFIG_UART1_ENABLE 0
#endif

#if defined CONFIG_UA1_FIFO1
#define CFG_UA1_FIFO 1
#elif defined CONFIG_UA1_FIFO2
#define CFG_UA1_FIFO 2
#elif defined CONFIG_UA1_FIFO4
#define CFG_UA1_FIFO 4
#elif defined CONFIG_UA1_FIFO8
#define CFG_UA1_FIFO 8
#elif defined CONFIG_UA1_FIFO16
#define CFG_UA1_FIFO 16
#elif defined CONFIG_UA1_FIFO32
#define CFG_UA1_FIFO 32
#else
#define CFG_UA1_FIFO 1
#endif

#ifndef CONFIG_IRQ3_ENABLE
#define CONFIG_IRQ3_ENABLE 0
#endif
#ifndef CONFIG_IRQ3_NSEC
#define CONFIG_IRQ3_NSEC 0
#endif
#ifndef CONFIG_GPT_ENABLE
#define CONFIG_GPT_ENABLE 0
#endif

#ifndef CONFIG_GPT_NTIM
#define CONFIG_GPT_NTIM 1
#endif

#ifndef CONFIG_GPT_SW
#define CONFIG_GPT_SW 8
#endif

#ifndef CONFIG_GPT_TW
#define CONFIG_GPT_TW 8
#endif

#ifndef CONFIG_GPT_IRQ
#define CONFIG_GPT_IRQ 8
#endif

#ifndef CONFIG_GPT_SEPIRQ
#define CONFIG_GPT_SEPIRQ 0
#endif
#ifndef CONFIG_GPT_ENABLE
#define CONFIG_GPT_ENABLE 0
#endif

#ifndef CONFIG_GPT_NTIM
#define CONFIG_GPT_NTIM 1
#endif

#ifndef CONFIG_GPT_SW
#define CONFIG_GPT_SW 8
#endif

#ifndef CONFIG_GPT_TW
#define CONFIG_GPT_TW 8
#endif

#ifndef CONFIG_GPT_IRQ
#define CONFIG_GPT_IRQ 8
#endif

#ifndef CONFIG_GPT_SEPIRQ
#define CONFIG_GPT_SEPIRQ 0
#endif

#ifndef CONFIG_GPT_WDOGEN
#define CONFIG_GPT_WDOGEN 0
#endif

#ifndef CONFIG_GPT_WDOG
#define CONFIG_GPT_WDOG 0
#endif

#ifndef CONFIG_GRGPIO_ENABLE
#define CONFIG_GRGPIO_ENABLE 0
#endif
#ifndef CONFIG_GRGPIO_IMASK
#define CONFIG_GRGPIO_IMASK 0000
#endif
#ifndef CONFIG_GRGPIO_WIDTH
#define CONFIG_GRGPIO_WIDTH 1
#endif


#ifndef CONFIG_DEBUG_UART
#define CONFIG_DEBUG_UART 0
#endif
