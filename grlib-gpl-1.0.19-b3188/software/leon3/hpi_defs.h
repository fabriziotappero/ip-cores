#ifndef HPI_DEFS_H
#define HPI_DEFS_H

#define USHORT unsigned short
#define PUSHORT unsigned short*
#define VOID void
#define UBYTE unsigned char
#define PUBYTE unsigned char*

#define HPI_BASE 0xfff24000
#define HPI_CTRL 0xfff34000

/** local definitions **/
#define HPI_DATA_PORT                                        0x0000 /* HPI Data Port */
#define HPI_MBX_PORT                                         0x0001 /* HPI Mailbox Port */
#define HPI_ADDR_PORT                                        0x0002 /* HPI Address Port */
#define HPI_STAT_PORT                                        0x0003 /* HPI Status Port */

#define HPI_STAT_ADDR    (HPI_STAT_PORT << 1)
#define HPI_MBX_ADDR     (HPI_MBX_PORT << 1)
#define HPI_DATA_ADDR    (HPI_DATA_PORT << 1)
#define HPI_ADDR_ADDR    (HPI_ADDR_PORT << 1)

#define HPI_INT_MASK     (1 << 12)

#define CY_INTMEM_BASE 0x4A4

typedef union {
  struct {
    USHORT RESERVED : 3;
    USHORT INT : 1;
    USHORT AtoCSlow : 2;
    USHORT CStoCTRLlow : 2;
    USHORT CTRLlowDvalid : 2;
    USHORT CTRLlow : 2;
    USHORT CTRLhighCShigh : 2;
    USHORT CShighREC : 2;
  };
  USHORT reg;

} CTRL_REG;


#endif
