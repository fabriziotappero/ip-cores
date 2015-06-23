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

