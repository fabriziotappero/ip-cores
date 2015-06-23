#include "config.h"
#if defined CONFIG_SYN_INFERRED
#define CONFIG_SYN_TECH inferred
#elif defined CONFIG_SYN_ATC18
#define CONFIG_SYN_TECH atc18
#elif defined CONFIG_SYN_AXCEL
#define CONFIG_SYN_TECH axcel
#elif defined CONFIG_SYN_PROASIC
#define CONFIG_SYN_TECH proasic
#elif defined CONFIG_SYN_VIRTEX
#define CONFIG_SYN_TECH virtex
#elif defined CONFIG_SYN_VIRTEX2
#define CONFIG_SYN_TECH virtex2
#else
#error "unknown target technology"
#endif

#if defined CONFIG_SYN_INFER_RAM
#define CFG_RAM_TECH inferred
#elif defined CONFIG_MEM_VIRAGE
#define CFG_RAM_TECH memvirage
#else
#define CFG_RAM_TECH CONFIG_SYN_TECH
#endif

#if defined CONFIG_SYN_INFER_PADS
#define CFG_PAD_TECH inferred
#else
#define CFG_PAD_TECH CONFIG_SYN_TECH
#endif

#if defined CONFIG_CLK_ALTDLL
#define CFG_CLK_TECH stratix
#elif defined CONFIG_CLK_HCLKBUF
#define CFG_CLK_TECH axcel
#elif defined CONFIG_CLK_CLKDLL
#define CFG_CLK_TECH virtex
#elif defined CONFIG_CLK_DCM
#define CFG_CLK_TECH virtex2
#else
#define CFG_CLK_TECH inferred
#endif

#ifndef CONFIG_CLK_MUL
#define CONFIG_CLK_MUL 2
#endif

#ifndef CONFIG_CLK_DIV
#define CONFIG_CLK_DIV 2
#endif

#ifndef CONFIG_PCI_CLKDLL
#define CONFIG_PCI_CLKDLL 0
#endif

#ifndef CONFIG_PCI_SYSCLK
#define CONFIG_PCI_SYSCLK 0
#endif

#ifdef CONFIG_IU_V8MULDIV
#ifdef CONFIG_IU_MUL_LATENCY_4
#define CFG_IU_V8 1
#else
#define CFG_IU_V8 2
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

#if defined CONFIG_FPU_GRFPU
#define CONFIG_FPU 1
#elif defined CONFIG_FPU_MEIKO
#define CONFIG_FPU 2
#else
#define CONFIG_FPU 0
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

#else
#define CONFIG_MMUEN 0
#define CONFIG_ITLBNUM 2
#define CONFIG_DTLBNUM 2
#define CONFIG_TLB_TYPE 1
#define CONFIG_TLB_REP 1
#endif


#ifndef CONFIG_DSU_ENABLE
#define CONFIG_DSU_ENABLE 0
#endif

#ifndef CONFIG_DSU_UART
#define CONFIG_DSU_UART 0
#endif

#ifndef CONFIG_DSU_ETH
#define CONFIG_DSU_ETH 0
#endif

#ifndef CONFIG_DSU_ETH100
#define CONFIG_DSU_ETH100 0
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

#ifndef CONFIG_DSU_ETHUDP
#define CONFIG_DSU_ETHUDP 8000
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

#if defined CONFIG_MCTRL_SMALL
#define CFG_MCTRL_TYPE 1
#ifdef CONFIG_MCTRL_SDRAM
#define CONFIG_MCTRL_SDRAM_SEPBUS 1
#endif
#elif defined CONFIG_MCTRL_LEON2
#define CFG_MCTRL_TYPE 2
#else
#define CFG_MCTRL_TYPE 0
#ifdef CONFIG_MCTRL_SDRAM
#define CONFIG_MCTRL_SDRAM_SEPBUS 1
#endif
#endif

#ifndef CONFIG_MCTRL_PROMWS
#define CONFIG_MCTRL_PROMWS 0
#endif

#ifndef CONFIG_MCTRL_RAMWS
#define CONFIG_MCTRL_RAMWS 0
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

#ifndef CONFIG_AHBRAM_START
#define CONFIG_AHBRAM_START 0
#endif

#ifndef CONFIG_ETH_ENABLE
#define CONFIG_ETH_ENABLE 0
#endif

#ifndef CONFIG_ETH_START
#define CONFIG_ETH_START B00
#endif

#if defined CONFIG_PCI_SIMPLE_TARGET
#define CFG_PCITYPE 1
#elif defined CONFIG_PCI_MASTER_TAGET
#define CFG_PCITYPE 2
#elif defined CONFIG_PCI_MASTER_TAGET_DMA
#define CFG_PCITYPE 3
#else
#define CFG_PCITYPE 0
#endif

#ifndef CONFIG_PCI_VENDORID
#define CONFIG_PCI_VENDORID 0
#endif

#ifndef CONFIG_PCI_DEVICEID
#define CONFIG_PCI_DEVICEID 0
#endif

#ifndef CONFIG_PCI_REVID
#define CONFIG_PCI_REVID 0
#endif

#if defined CONFIG_PCI_FIFO16
#define CFG_PCIFIFO 16
#elif defined CONFIG_PCI_FIFO32
#define CFG_PCIFIFO 32
#elif defined CONFIG_PCI_FIFO64
#define CFG_PCIFIFO 64
#elif defined CONFIG_PCI_FIFO128
#define CFG_PCIFIFO 128
#elif defined CONFIG_PCI_FIFO256
#define CFG_PCIFIFO 256
#else
#define CFG_PCIFIFO 8
#endif

#ifndef CONFIG_PCI_ARBITER_APB
#define CONFIG_PCI_ARBITER_APB 0
#endif

#ifndef CONFIG_PCI_ARBITER
#define CONFIG_PCI_ARBITER 0
#endif

#ifndef CONFIG_PCI_TRACE
#define CONFIG_PCI_TRACE 0
#endif

#if defined CONFIG_PCI_TRACE512
#define CFG_PCI_TRACEBUF 512
#elif defined CONFIG_PCI_TRACE1024
#define CFG_PCI_TRACEBUF 1024
#elif defined CONFIG_PCI_TRACE2048
#define CFG_PCI_TRACEBUF 2048
#elif defined CONFIG_PCI_TRACE4096
#define CFG_PCI_TRACEBUF 4096
#else
#define CFG_PCI_TRACEBUF 256
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

#ifndef CONFIG_UART2_ENABLE
#define CONFIG_UART2_ENABLE 0
#endif

#if defined CONFIG_UA2_FIFO1
#define CFG_UA2_FIFO 1
#elif defined CONFIG_UA2_FIFO2
#define CFG_UA2_FIFO 2
#elif defined CONFIG_UA2_FIFO4
#define CFG_UA2_FIFO 4
#elif defined CONFIG_UA2_FIFO8
#define CFG_UA2_FIFO 8
#elif defined CONFIG_UA2_FIFO16
#define CFG_UA2_FIFO 16
#elif defined CONFIG_UA2_FIFO32
#define CFG_UA2_FIFO 32
#else
#define CFG_UA2_FIFO 1
#endif

#ifndef CONFIG_IRQ3_ENABLE
#define CONFIG_IRQ3_ENABLE 0
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

#ifndef CONFIG_GPIO_ENABLE
#define CONFIG_GPIO_ENABLE 0
#endif

#ifndef CONFIG_GPIO_IMASK
#define CONFIG_GPIO_IMASK 0000
#endif

#ifndef CONFIG_PCI_RESETALL
#define CONFIG_PCI_RESETALL 0
#endif

#ifndef CONFIG_IU_DISAS
#define CONFIG_IU_DISAS 0
#endif

#ifndef CONFIG_CAN_ENABLE
#define CONFIG_CAN_ENABLE 0
#endif

#ifndef CONFIG_CANIO
#define CONFIG_CANIO 0
#endif

#ifndef CONFIG_CANIRQ
#define CONFIG_CANIRQ 0
#endif

#ifndef CONFIG_CANLOOP
#define CONFIG_CANLOOP 0
#endif

#ifndef CONFIG_DEBUG_UART
#define CONFIG_DEBUG_UART 0
#endif

#ifdef CONFIG_DEBUG_PC32
#define CFG_DEBUG_PC32 0 
#else
#define CFG_DEBUG_PC32 2
#endif

