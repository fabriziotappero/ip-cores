/*
 * Automatically generated C config: don't edit
 */
#define AUTOCONF_INCLUDED
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
#undef  CONFIG_SYN_INFER_MULT
#undef  CONFIG_SYN_RFTYPE
#undef  CONFIG_SYN_TRACE_DPRAM
/*
 * ------------------ Xilinx Clock generation ------------------
 */
/*
 * Clock generation
 */
#undef  CONFIG_CLK_VIRTEX
#undef  CONFIG_CLK_VIRTEX2
#undef  CONFIG_PCI_DLL
#undef  CONFIG_PCI_SYSCLK
/*
 * Target Architecture 
 */
#define CONFIG_TARGET_ARM 1
#undef  CONFIG_TARGET_SPARC
#undef  CONFIG_TARGET_M68K
/*
 * Target ARM            
 */
/*
 * Integer unit                                           
 */
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
#define CONFIG_ICACHE_SZ1 1
#undef  CONFIG_ICACHE_SZ2
#undef  CONFIG_ICACHE_SZ4
#undef  CONFIG_ICACHE_SZ8
#undef  CONFIG_ICACHE_SZ16
#undef  CONFIG_ICACHE_SZ32
#undef  CONFIG_ICACHE_SZ64
#define CONFIG_ICACHE_LZ4 1
#undef  CONFIG_ICACHE_LZ8
#undef  CONFIG_GENICACHE_LOCK
/*
 * Data cache
 */
#undef  CONFIG_DCACHE_WRITEBACK
#define CONFIG_DCACHE_WRITETHROUGH 1
#define CONFIG_DCACHE_ASSO1 1
#undef  CONFIG_DCACHE_ASSO2
#undef  CONFIG_DCACHE_ASSO3
#undef  CONFIG_DCACHE_ASSO4
#define CONFIG_DCACHE_SZ1 1
#undef  CONFIG_DCACHE_SZ2
#undef  CONFIG_DCACHE_SZ4
#undef  CONFIG_DCACHE_SZ8
#undef  CONFIG_DCACHE_SZ16
#undef  CONFIG_DCACHE_SZ32
#undef  CONFIG_DCACHE_SZ64
#define CONFIG_DCACHE_LZ4 1
#undef  CONFIG_DCACHE_LZ8
#undef  CONFIG_GENDCACHE_LOCK
#undef  CONFIG_DCACHE_WB_SZ1
#define CONFIG_DCACHE_WB_SZ2 1
#undef  CONFIG_DCACHE_WB_SZ4
#undef  CONFIG_DCACHE_WB_SZ8
#undef  CONFIG_DCACHE_WB_SZ16
/*
 * Amba bus           
 */
#define CONFIG_AHB_DEFMST (0)
#undef  CONFIG_AHB_SPLIT
#undef  CONFIG_PERI_AHBSTAT
/*
 * Peripherals        
 */
/*
 * Memory            
 */
/*
 *  Memory controller 
 */
#define CONFIG_MCTRL_8BIT 1
#define CONFIG_MCTRL_16BIT 1
#define CONFIG_PERI_WPROT 1
#define CONFIG_MCTRL_WFB 1
#define CONFIG_MCTRL_5CS 1
#define CONFIG_MCTRL_SDRAM 1
#define CONFIG_MCTRL_SDRAM_INVCLK 1
/*
 *  On chip ram 
 */
#undef  CONFIG_AHBRAM_ENABLE
/*
 * Serial            
 */
/*
 * VHDL Debugging        
 */
#undef  CONFIG_DEBUG_UART
/*
 * ARM debugging      
 */
