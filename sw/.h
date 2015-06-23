
#define ETH_MODER	        0x00
#define ETH_INT_SOURCE	    0x04
#define ETH_INT_MASK	    0x08
#define ETH_IPGT	        0x0C
#define ETH_IPGR1	        0x10
#define ETH_IPGR2	        0x14
#define ETH_PACKETLEN	    0x18
#define ETH_COLLCONF	    0x1C
#define ETH_TX_BD_NUM	    0x20
#define ETH_CTRLMODER	    0x24
#define ETH_MIIMODER	    0x28
#define ETH_MIICOMMAND  	0x2C
#define ETH_MIIADDRESS	    0x30
#define ETH_MIITX_DATA	    0x34
#define ETH_MIIRX_DATA	    0x38
#define ETH_MIISTATUS	    0x3C
#define ETH_MAC_ADDR0	    0x40
#define ETH_MAC_ADDR1	    0x44
#define ETH_HASH0_ADR	    0x48
#define ETH_HASH1_ADR	    0x4C
#define ETH_TXCTRL	        0x50

#define ETH_TXBD0H	        0x404
#define ETH_TXBD0L	        0x400

#define ETH_RXBD0H	        0x604	//this depends on TX_BD_NUM but this is the standard value
#define ETH_RXBD0L	        0x600	//this depends on TX_BD_NUM but this is the standard value

//MODER BITS
#define ETH_RECSMALL	    0x00010000
#define ETH_PAD		        0x00008000
#define ETH_HUGEN	        0x00004000
#define ETH_CRCEN	        0x00002000
#define ETH_DLYCRCEN	    0x00001000
#define ETH_FULLD	        0x00000400
#define ETH_EXDFREN	        0x00000200
#define ETH_NOBCKOF	        0x00000100
#define ETH_LOOPBCK	        0x00000080
#define ETH_IFG		        0x00000040
#define ETH_PRO		        0x00000020
#define ETH_IAM		        0x00000010
#define ETH_BRO		        0x00000008
#define ETH_NOPRE	        0x00000004
#define ETH_TXEN	        0x00000002
#define ETH_RXEN	        0x00000001

//INTERRUPTS BITS
#define ETH_RXC		        0x00000040
#define ETH_TXC		        0x00000020
#define ETH_BUSY	        0x00000010
#define ETH_RXE		        0x00000008
#define ETH_RXB		        0x00000004
#define ETH_TXE		        0x00000002
#define ETH_TXB		        0x00000001

//BUFFER DESCRIPTOR BITS
#define ETH_RXBD_EMPTY	    0x00008000
#define ETH_RXBD_IRQ	    0x00004000
#define ETH_RXBD_WRAP	    0x00002000
#define ETH_RXBD_CF	        0x00000100
#define ETH_RXBD_MISS	    0x00000080
#define ETH_RXBD_OR	        0x00000040
#define ETH_RXBD_IS	        0x00000020
#define ETH_RXBD_DN	        0x00000010
#define ETH_RXBD_TL	        0x00000008
#define ETH_RXBD_SF	        0x00000004
#define ETH_RXBD_CRC	    0x00000002
#define ETH_RXBD_LC	        0x00000001

#define ETH_TXBD_READY	    0x00008000
#define ETH_TXBD_IRQ	    0x00004000
#define ETH_TXBD_WRAP	    0x00002000
#define ETH_TXBD_PAD	    0x00001000
#define ETH_TXBD_CRC	    0x00000800
#define ETH_TXBD_UR	        0x00000100
#define ETH_TXBD_RL	        0x00000008
#define ETH_TXBD_LC	        0x00000004
#define ETH_TXBD_DF	        0x00000002
#define ETH_TXBD_CS	        0x00000001

//user defines
#define OWN_MAC_ADDRESS		0x554734228892
#define BROADCAST_ADDRESS	0xFFFFFFFFFFFF

#define HDR_LEN       14
#define CRC_LEN       4
#define BD_SND  ( ETH_TXBD_READY | ETH_TXBD_IRQ | ETH_TXBD_WRAP | ETH_TXBD_PAD | ETH_TXBD_CRC )
#define RX_READY    ( ETH_RXBD_EMPTY | ETH_RXBD_IRQ | ETH_RXBD_WRAP )
#define TX_READY ( ETH_TXBD_IRQ | ETH_TXBD_WRAP | ETH_TXBD_PAD | ETH_TXBD_CRC )

//~user defines


