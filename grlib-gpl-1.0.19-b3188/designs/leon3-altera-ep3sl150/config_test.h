/*
 * Processor
 */
/*
 * Integer unit
 */
#define CONFIG_IU_NWINDOWS (8)
#undef  CONFIG_IU_V8MULDIV
/*
 * Cache system
 */
#define CONFIG_ICACHE_ENABLE 1
#define CONFIG_ICACHE_SZ1 1
#undef  CONFIG_ICACHE_SZ2
#undef  CONFIG_ICACHE_SZ4
#undef  CONFIG_ICACHE_SZ8
#undef  CONFIG_ICACHE_SZ16
#undef  CONFIG_ICACHE_SZ32
#undef  CONFIG_ICACHE_SZ64
#undef  CONFIG_ICACHE_LRAM
#define CONFIG_DCACHE_ENABLE 1
#define CONFIG_DCACHE_SZ1 1
#undef  CONFIG_DCACHE_SZ2
#undef  CONFIG_DCACHE_SZ4
#undef  CONFIG_DCACHE_SZ8
#undef  CONFIG_DCACHE_SZ16
#undef  CONFIG_DCACHE_SZ32
#undef  CONFIG_DCACHE_SZ64
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
 * Debug Link
 */
#define CONFIG_DSU_UART 1
#define CONFIG_DSU_ETH 1
#undef  CONFIG_DSU_ETHSZ1
#define CONFIG_DSU_ETHSZ2 1
#undef  CONFIG_DSU_ETHSZ4
#undef  CONFIG_DSU_ETHSZ8
#undef  CONFIG_DSU_ETHSZ16
/*
 * Peripherals
 */
/*
 * Memory controllers
 */
#undef  CONFIG_MCTRL_NONE
#define CONFIG_MCTRL_LEON2 1
#define CONFIG_MCTRL_SDRAM 1
/*
 * Ethernet
 */
#undef  CONFIG_ETH_ENABLE
/*
 * PCI
 */
#undef  CONFIG_PCI_ENABLE
/*
 * CAN
 */
#undef  CONFIG_CAN_ENABLE
/*
 * UARTs, timers and irq control
 */
#define CONFIG_UART1_ENABLE 1
#define CONFIG_GPT_ENABLE 1
