
/* Address map */
/* System has 128MB which is 0x04000000 */
/* First 16KB is embedded block RAMs. The rest is ddr3 memory */

/* boot program in block RAM gets copied here to execute */
#define ADR_EXEC_BASE       0x01000000  /* 16KB  program size   */
#define ADR_STACK           0x0100f000  /* 44KB     stack space */
#define ADR_IRQ_STACK       0x01010000  /*  4KB IRQ stack space */

#define ADR_MALLOC_POINTER  0x01020000
#define ADR_MALLOC_COUNT    0x01020004
#define ADR_MALLOC_BASE     0x01020100  /* ~95MB malloc space   */

/* Packet buffers. These need to be in non-cached space
   The cache is configured in startup in start.S  */
#define ETHMAC_RX_BUFFER    0x03010000
#define ETHMAC_TX_BUFFER    0x03040002
