/*
 * Automatically generated C config: don't edit
 */
#define AUTOCONF_INCLUDED
#define CONFIG_PERI_LCONF 1
/*
 * Synthesis 
 */
#undef  CONFIG_SYN_GENERIC
#undef  CONFIG_SYN_ATC35
#undef  CONFIG_SYN_ATC25
#undef  CONFIG_SYN_ATC18
#undef  CONFIG_SYN_FS90
#undef  CONFIG_SYN_UMC018
#undef  CONFIG_SYN_TSMC025
#undef  CONFIG_SYN_PROASIC
#undef  CONFIG_SYN_AXCEL
#undef  CONFIG_SYN_VIRTEX
#define CONFIG_SYN_VIRTEX2 1
#undef  CONFIG_SYN_INFER_RAM
#undef  CONFIG_SYN_INFER_REGF
#undef  CONFIG_SYN_INFER_ROM
#undef  CONFIG_SYN_INFER_PCI_PADS
#define CONFIG_SYN_INFER_MULT 1
#define CONFIG_SYN_RFTYPE 1
#define CONFIG_SYN_TRACE_DPRAM 1
/*
 * Clock generation
 */
#undef  CONFIG_CLK_VIRTEX
#define CONFIG_CLK_VIRTEX2 1
#undef  CONFIG_DCM_2_3
#undef  CONFIG_DCM_3_4
#undef  CONFIG_DCM_4_5
#define CONFIG_DCM_1_1 1
#undef  CONFIG_DCM_5_4
#undef  CONFIG_DCM_4_3
#undef  CONFIG_DCM_3_2
#undef  CONFIG_DCM_5_3
#undef  CONFIG_DCM_2_1
#undef  CONFIG_DCM_3_1
#undef  CONFIG_DCM_4_1
#undef  CONFIG_PCI_DLL
#undef  CONFIG_PCI_SYSCLK
/*
 * Processor            
 */
/*
 * Integer unit                                           
 */
#define CONFIG_IU_NWINDOWS (8)
#define CONFIG_IU_V8MULDIV 1
#undef  CONFIG_IU_MUL_LATENCY_1
#undef  CONFIG_IU_MUL_LATENCY_2
#define CONFIG_IU_MUL_LATENCY_4 1
#undef  CONFIG_IU_MUL_LATENCY_5
#undef  CONFIG_IU_MUL_LATENCY_35
#undef  CONFIG_IU_MUL_MAC
#define CONFIG_IU_LDELAY (1)
#define CONFIG_IU_FASTJUMP 1
#define CONFIG_IU_ICCHOLD 1
#define CONFIG_IU_FASTDECODE 1
#define CONFIG_IU_WATCHPOINTS (2)
/*
 * Floating-point unit
 */
#undef  CONFIG_FPU_ENABLE
/*
 * Co-processor
 */
#undef  CONFIG_CP_ENABLE
/*
 * Cache system              
 */
/*
 * Instruction cache                              
 */
#define CONFIG_ICACHE_ASSO1 1
#undef  CONFIG_ICACHE_ASSO2
#undef  CONFIG_ICACHE_ASSO3
#undef  CONFIG_ICACHE_ASSO4
#undef  CONFIG_ICACHE_SZ1
#undef  CONFIG_ICACHE_SZ2
#define CONFIG_ICACHE_SZ4 1
#undef  CONFIG_ICACHE_SZ8
#undef  CONFIG_ICACHE_SZ16
#undef  CONFIG_ICACHE_SZ32
#undef  CONFIG_ICACHE_SZ64
#undef  CONFIG_ICACHE_LZ16
#define CONFIG_ICACHE_LZ32 1
/*
 * Data cache
 */
#define CONFIG_DCACHE_ASSO1 1
#undef  CONFIG_DCACHE_ASSO2
#undef  CONFIG_DCACHE_ASSO3
#undef  CONFIG_DCACHE_ASSO4
#undef  CONFIG_DCACHE_SZ1
#undef  CONFIG_DCACHE_SZ2
#define CONFIG_DCACHE_SZ4 1
#undef  CONFIG_DCACHE_SZ8
#undef  CONFIG_DCACHE_SZ16
#undef  CONFIG_DCACHE_SZ32
#undef  CONFIG_DCACHE_SZ64
#undef  CONFIG_DCACHE_LZ16
#define CONFIG_DCACHE_LZ32 1
#define CONFIG_DCACHE_SNOOP 1
#define CONFIG_DCACHE_SNOOP_SLOW 1
#undef  CONFIG_DCACHE_SNOOP_FAST
#undef  CONFIG_DCACHE_LRAM
/*
 * MMU
 */
#undef  CONFIG_MMU_ENABLE
/*
 * Debug support unit          
 */
#define CONFIG_DSU_ENABLE 1
#define CONFIG_DSU_TRACEBUF 1
#define CONFIG_DSU_MIXED_TRACE 1
#undef  CONFIG_DSU_TRACESZ64
#undef  CONFIG_DSU_TRACESZ128
#define CONFIG_DSU_TRACESZ256 1
#undef  CONFIG_DSU_TRACESZ512
#undef  CONFIG_DSU_TRACESZ1024
/*
 * AMBA configuration
 */
#define CONFIG_AHB_DEFMST (0)
#undef  CONFIG_AHB_SPLIT
/*
 * Memory controller
 */
#undef  CONFIG_MCTRL_8BIT
#undef  CONFIG_MCTRL_16BIT
#undef  CONFIG_PERI_WPROT
#undef  CONFIG_MCTRL_WFB
#undef  CONFIG_MCTRL_5CS
#define CONFIG_MCTRL_SDRAM 1
#undef  CONFIG_MCTRL_SDRAM_INVCLK
#define CONFIG_MCTRL_SDRAM_SEPBUS 1
/*
 * Peripherals        
 */
#define CONFIG_PERI_LCONF 1
#undef  CONFIG_PERI_IRQ2
#undef  CONFIG_PERI_WDOG
#define CONFIG_PERI_AHBSTAT 1
#undef  CONFIG_AHBRAM_ENABLE
/*
 * Ethernet interface          
 */
#define CONFIG_ETH_ENABLE 1
#define CONFIG_ETH_TXFIFO (8)
#define CONFIG_ETH_RXFIFO (8)
#define CONFIG_ETH_BURST (4)
/*
 * PCI interface          
 */
#undef  CONFIG_PCI_ENABLE
/*
 * Boot options
 */
#define CONFIG_BOOT_EXTPROM 1
#undef  CONFIG_BOOT_INTPROM
#undef  CONFIG_BOOT_MIXPROM
/*
 * VHDL Debugging        
 */
#undef  CONFIG_DEBUG_UART
#undef  CONFIG_DEBUG_IURF
#undef  CONFIG_DEBUG_NOHALT
#undef  CONFIG_DEBUG_PC32
