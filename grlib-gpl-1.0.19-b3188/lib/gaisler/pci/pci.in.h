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

