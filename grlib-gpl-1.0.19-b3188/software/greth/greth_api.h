
#define GRETH_FD 0x10
#define GRETH_RESET 0x40
#define GRETH_MII_BUSY 0x8
#define GRETH_MII_NVALID 0x10

/* MII registers */
#define GRETH_MII_EXTADV_1000FD 0x00000200
#define GRETH_MII_EXTADV_1000HD 0x00000100
#define GRETH_MII_EXTPRT_1000FD 0x00000800
#define GRETH_MII_EXTPRT_1000HD 0x00000400

#define GRETH_MII_100T4         0x00000200
#define GRETH_MII_100TXFD       0x00000100
#define GRETH_MII_100TXHD       0x00000080
#define GRETH_MII_10FD          0x00000040
#define GRETH_MII_10HD          0x00000020

#define GRETH_BD_EN 0x800
#define GRETH_BD_WR 0x1000
#define GRETH_BD_IE 0x2000
#define GRETH_BD_LEN 0x7FF

#define GRETH_TXEN 0x1
#define GRETH_INT_TX 0x8
#define GRETH_TXI 0x4
#define GRETH_TXBD_STATUS 0x0001C000
#define GRETH_TXBD_MORE 0x20000
#define GRETH_TXBD_IPCS 0x40000
#define GRETH_TXBD_TCPCS 0x80000
#define GRETH_TXBD_UDPCS 0x100000
#define GRETH_TXBD_ERR_LC 0x10000
#define GRETH_TXBD_ERR_UE 0x4000
#define GRETH_TXBD_ERR_AL 0x8000
#define GRETH_TXBD_NUM 128
#define GRETH_TXBD_NUM_MASK (GRETH_TXBD_NUM-1)
#define GRETH_TX_BUF_SIZE 2048

#define GRETH_INT_RX         0x4
#define GRETH_RXEN           0x2
#define GRETH_RXI            0x8
#define GRETH_RXBD_STATUS    0xFFFFC000
#define GRETH_RXBD_ERR_AE    0x4000
#define GRETH_RXBD_ERR_FT    0x8000
#define GRETH_RXBD_ERR_CRC   0x10000
#define GRETH_RXBD_ERR_OE    0x20000
#define GRETH_RXBD_ERR_LE    0x40000
#define GRETH_RXBD_IP_DEC    0x80000
#define GRETH_RXBD_IP_CSERR  0x100000
#define GRETH_RXBD_UDP_DEC   0x200000
#define GRETH_RXBD_UDP_CSERR 0x400000
#define GRETH_RXBD_TCP_DEC   0x800000
#define GRETH_RXBD_TCP_CSERR 0x1000000

#define GRETH_RXBD_NUM 128
#define GRETH_RXBD_NUM_MASK (GRETH_RXBD_NUM-1)
#define GRETH_RX_BUF_SIZE 2048

/* Ethernet configuration registers */
typedef struct _greth_regs {
    volatile int    control;        
    volatile int    status;        
    volatile int    esa_msb;        
    volatile int    esa_lsb;        
    volatile int    mdio;        
    volatile int    tx_desc_p;        
    volatile int    rx_desc_p;        
    volatile int    edclip;
} greth_regs;

/* Ethernet buffer descriptor */
typedef struct _greth_bd {
    int    stat;
    int    addr;           /* Buffer address */
} greth_bd;

struct descriptor 
{
    volatile int ctrl;
    volatile int addr;
};

struct rxstatus 
{
  
};

struct greth_info {
    greth_regs *regs;            /* Address of controller registers. */  
  
    unsigned char esa[6];
    unsigned int gbit;
    unsigned int phyaddr;
    unsigned int edcl;
    
    struct descriptor *txd;
    struct descriptor *rxd;  
    unsigned int txpnt;
    unsigned int rxpnt;  
    unsigned int txchkpnt;
    unsigned int rxchkpnt;

};

int read_mii(int phyaddr, int addr, volatile greth_regs *regs);

void write_mii(int phyaddr, int addr, int data, volatile greth_regs *regs);

int greth_set_mac_address(struct greth_info *greth, unsigned char *addr);

int greth_init(struct greth_info *greth);

inline int greth_tx(int size, char *buf, struct greth_info *greth);

inline int greth_rx(char *buf, struct greth_info *greth);

inline int greth_checkrx(int *size, struct rxstatus *rxs, struct greth_info *greth);

inline int greth_checktx(struct greth_info *greth);

