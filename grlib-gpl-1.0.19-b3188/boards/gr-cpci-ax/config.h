/*
 * Automatically generated C config: don't edit
 */
#define AUTOCONF_INCLUDED
#define CONFIG_MCTRL_RMW 1
/*
 * Synthesis 
 */
#undef  CONFIG_SYN_INFERRED
#define CONFIG_SYN_AXCEL 1
#undef  CONFIG_SYN_INFER_RAM
#undef  CONFIG_SYN_INFER_PADS
/*
 * Clock generation
 */
#undef  CONFIG_CLK_INFERRED
#define CONFIG_CLK_HCLKBUF 1
#define CONFIG_PROC_NUM (1)
/*
 * Processor            
 */
/*
 * Integer unit                                           
 */
#define CONFIG_IU_NWINDOWS (8)
#undef  CONFIG_IU_V8MULDIV
#define CONFIG_IU_LDELAY (1)
#define CONFIG_IU_WATCHPOINTS (0)
#undef  CONFIG_PWD
/*
 * Floating-point unit
 */
#undef  CONFIG_FPU_ENABLE
/*
 * Cache system
 */
#define CONFIG_ICACHE_ENABLE 1
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
#undef  CONFIG_ICACHE_LRAM
#define CONFIG_DCACHE_ENABLE 1
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
#undef  CONFIG_DCACHE_LRAM
/*
 * MMU
 */
#undef  CONFIG_MMU_ENABLE
/*
 * Debug Support Unit        
 */
#define CONFIG_DSU_ENABLE 1
#undef  CONFIG_DSU_ITRACE
#undef  CONFIG_DSU_ATRACE
/*
 * AMBA configuration
 */
#define CONFIG_AHB_DEFMST (0)
#undef  CONFIG_AHB_RROBIN
#undef  CONFIG_AHB_SPLIT
#define CONFIG_AHB_IOADDR FFF
#define CONFIG_APB_HADDR 800
/*
 * Debug Link           
 */
#define CONFIG_DSU_UART 1
/*
 * Peripherals             
 */
/*
 * Memory controllers             
 */
#undef  CONFIG_MCTRL_NONE
#define CONFIG_MCTRL_SMALL 1
#undef  CONFIG_MCTRL_LEON2
#define CONFIG_MCTRL_PROMWS (3)
#define CONFIG_MCTRL_RAMWS (0)
#define CONFIG_MCTRL_SDRAM 1
#define CONFIG_MCTRL_SDRAM_BUS64 1
/*
 * On-chip RAM                     
 */
#undef  CONFIG_AHBRAM_ENABLE
/*
 * PCI              
 */
#define CONFIG_PCI_ENABLE 1
#define CONFIG_PCI_SIMPLE_TARGET 1
#undef  CONFIG_PCI_MASTER_TAGET
#undef  CONFIG_PCI_MASTER_TAGET_DMA
#define CONFIG_PCI_VENDORID 16E3
#define CONFIG_PCI_DEVICEID 0210
#undef  CONFIG_PCI_ARBITER
#undef  CONFIG_PCI_TRACE
/*
 * UARTs, timers and irq control         
 */
#define CONFIG_UART1_ENABLE 1
#define CONFIG_UA1_FIFO1 1
#undef  CONFIG_UA1_FIFO2
#undef  CONFIG_UA1_FIFO4
#undef  CONFIG_UA1_FIFO8
#undef  CONFIG_UA1_FIFO16
#undef  CONFIG_UA1_FIFO32
#define CONFIG_UART2_ENABLE 1
#define CONFIG_UA2_FIFO1 1
#undef  CONFIG_UA2_FIFO2
#undef  CONFIG_UA2_FIFO4
#undef  CONFIG_UA2_FIFO8
#undef  CONFIG_UA2_FIFO16
#undef  CONFIG_UA2_FIFO32
#define CONFIG_IRQ3_ENABLE 1
#define CONFIG_GPT_ENABLE 1
#define CONFIG_GPT_NTIM (2)
#define CONFIG_GPT_SW (8)
#define CONFIG_GPT_TW (32)
#define CONFIG_GPT_IRQ (8)
#define CONFIG_GPT_SEPIRQ 1
/*
 * VHDL Debugging        
 */
#undef  CONFIG_IU_DISAS
#define CONFIG_DEBUG_UART 1
#undef  CONFIG_DEBUG_PC32
