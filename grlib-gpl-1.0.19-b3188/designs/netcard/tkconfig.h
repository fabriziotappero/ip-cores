#if defined CONFIG_SYN_INFERRED
#define CONFIG_SYN_TECH inferred
#elif defined CONFIG_SYN_RHUMC
#define CONFIG_SYN_TECH rhumc
#elif defined CONFIG_SYN_ATC18
#define CONFIG_SYN_TECH atc18s
#elif defined CONFIG_SYN_AXCEL
#define CONFIG_SYN_TECH axcel
#elif defined CONFIG_SYN_PROASICPLUS
#define CONFIG_SYN_TECH proasic
#elif defined CONFIG_SYN_ALTERA
#define CONFIG_SYN_TECH altera
#elif defined CONFIG_SYN_IHP25
#define CONFIG_SYN_TECH ihp25
#elif defined CONFIG_SYN_IHP25RH
#define CONFIG_SYN_TECH ihp25rh
#elif defined CONFIG_SYN_LATTICE
#define CONFIG_SYN_TECH lattice
#elif defined CONFIG_SYN_PEREGRINE
#define CONFIG_SYN_TECH peregrine
#elif defined CONFIG_SYN_PROASIC
#define CONFIG_SYN_TECH proasic
#elif defined CONFIG_SYN_PROASIC3
#define CONFIG_SYN_TECH proasic3
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
#elif defined CONFIG_SYN_CUSTOM1
#define CONFIG_SYN_TECH custom1
#else
#error "unknown target technology"
#endif

#if defined CONFIG_SYN_INFER_RAM
#define CFG_RAM_TECH inferred
#elif defined CONFIG_MEM_RHUMC
#define CFG_RAM_TECH rhumc
#elif defined CONFIG_MEM_VIRAGE
#define CFG_RAM_TECH memvirage
#elif defined CONFIG_MEM_ARTISAN
#define CFG_RAM_TECH memartisan
#elif defined CONFIG_MEM_CUSTOM1
#define CFG_RAM_TECH custom1
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



#if defined CONFIG_CLK_ALTDLL
#define CFG_CLK_TECH stratix
#elif defined CONFIG_CLK_HCLKBUF
#define CFG_CLK_TECH axcel
#elif defined CONFIG_CLK_LATDLL
#define CFG_CLK_TECH lattice
#elif defined CONFIG_CLK_CLKDLL
#define CFG_CLK_TECH virtex
#elif defined CONFIG_CLK_DCM
#define CFG_CLK_TECH CONFIG_SYN_TECH
#elif defined CONFIG_CLK_LIB18T
#define CFG_CLK_TECH rhlib18t
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

#ifndef CONFIG_CLK_NOFB
#define CONFIG_CLK_NOFB 0
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

#ifndef CONFIG_DSU_UART
#define CONFIG_DSU_UART 0
#endif


#ifndef CONFIG_DSU_JTAG
#define CONFIG_DSU_JTAG 0
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

#if defined CONFIG_PCI_SIMPLE_TARGET
#define CFG_PCITYPE 1
#elif defined CONFIG_PCI_MASTER_TARGET_DMA
#define CFG_PCITYPE 3
#elif defined CONFIG_PCI_MASTER_TARGET
#define CFG_PCITYPE 2
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

#if defined CONFIG_PCI_FIFO0
#define CFG_PCIFIFO 8
#define CFG_PCI_ENFIFO 0
#elif defined CONFIG_PCI_FIFO16
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

#ifndef CFG_PCI_ENFIFO
#define CFG_PCI_ENFIFO 1
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


