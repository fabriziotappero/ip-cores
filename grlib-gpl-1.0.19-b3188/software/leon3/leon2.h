
/* control structure */

#ifndef __ASSEMBLER__

struct l2regs {
	volatile unsigned int memcfg1;		/* 0x00 */
	volatile unsigned int memcfg2;
	volatile unsigned int ectrl;
	volatile unsigned int failaddr;
	volatile unsigned int memstatus;		/* 0x10 */
	volatile unsigned int cachectrl;
	volatile unsigned int powerdown;
	volatile unsigned int writeprot1;
	volatile unsigned int writeprot2;	/* 0x20 */
	volatile unsigned int leonconf;
	volatile unsigned int dummy2;
	volatile unsigned int dummy3;
	volatile unsigned int dummy4;		/* 0x30 */
	volatile unsigned int dummy5;
	volatile unsigned int dummy6;
	volatile unsigned int dummy7;
	volatile unsigned int timercnt1;		/* 0x40 */
	volatile unsigned int timerload1;
	volatile unsigned int timerctrl1;
	volatile unsigned int wdog;
	volatile unsigned int timercnt2;
	volatile unsigned int timerload2;
	volatile unsigned int timerctrl2;
	volatile unsigned int dummy8;
	volatile unsigned int scalercnt;
	volatile unsigned int scalerload;
	volatile unsigned int dummy9;
	volatile unsigned int dummy10;
	volatile unsigned int uartdata1;
	volatile unsigned int uartstatus1;
	volatile unsigned int uartctrl1;
	volatile unsigned int uartscaler1;
	volatile unsigned int uartdata2;
	volatile unsigned int uartstatus2;
	volatile unsigned int uartctrl2;
	volatile unsigned int uartscaler2;
	volatile unsigned int irqmask;
	volatile unsigned int irqpend;
	volatile unsigned int irqforce;
	volatile unsigned int irqclear;
	volatile unsigned int piodata;
	volatile unsigned int piodir;
	volatile unsigned int pioirq[2];
	volatile unsigned int imask2;
	volatile unsigned int ipend2;
	volatile unsigned int istat2;
	volatile unsigned int dummy12;
	volatile unsigned int dcomdata;
	volatile unsigned int dcomstatus;
	volatile unsigned int dcomctrl;
	volatile unsigned int dcomscaler;
	volatile unsigned int wprot1a;
	volatile unsigned int wprot1e;
	volatile unsigned int wprot2a;
	volatile unsigned int wprot2e;
};


#endif

/* control registers */

#define	PREGS	0x80000000
#define	MCFG1	0x00
#define	MCFG2	0x04
#define	MCFG3	0x08
#define	ECTRL	0x08
#define	FADDR	0x0c
#define	MSTAT	0x10
#define CCTRL	0x14
#define PWDOWN	0x18
#define WPROT1	0x1C
#define WPROT2	0x20
#define LCONF 	0x24
#define	TCNT0	0x40
#define	TRLD0	0x44
#define	TCTRL0	0x48
#define	TCNT1	0x50
#define	TRLD1	0x54
#define	TCTRL1	0x58
#define	SCNT  	0x60
#define	SRLD  	0x64
#define	UDATA0 	0x70
#define	USTAT0 	0x74
#define	UCTRL0 	0x78
#define	USCAL0 	0x7c
#define	UDATA1 	0x80
#define	USTAT1 	0x84
#define	UCTRL1 	0x88
#define	USCAL1 	0x8c
#define	IMASK	0x90
#define	IPEND	0x94
#define	IFORCE	0x98
#define	ICLEAR	0x9c
#define	IOREG	0xA0
#define	IODIR	0xA4
#define	IOICONF	0xA8
#define	IMASK2	0xB0
#define	IPEND2	0xB4
#define	ISTAT2  0xB8
#define	ICLEAR2	0xB8

/* ASI codes */

#define ASI_PCI 	0x4
#define ASI_ITAG	0xC
#define ASI_IDATA	0xD
#define ASI_DTAG	0xE
#define ASI_DDATA	0xF

/* memory areas */

#define CRAM	0x40000000
#define SDRAM	0x60000000
#define IOAREA	0x20000000

/* Some bit field masks */

#define CCTRL_FLUSHING_MASK 0x0c000

#define RFE_CONF_BIT	30
#define RFE_CONF_MASK	3
#define CPP_CONF_BIT	19
#define CPP_CONF_MASK	3
#define FPU_CONF_BIT	4
#define FPU_CONF_MASK	3
#define CPTE_MASK	(3 << 17)
#define MUL_CONF_BIT	8	
#define MAC_CONF_BIT	25	
#define DIV_CONF_BIT	9	
#define REDAC_CONF_BIT	9	
#define PEDAC_CONF_BIT	8	
#define MEDAC_CONF_BIT	27	
#define MMU_CONF_BIT	31
#define ITE_BIT		12
#define IDE_BIT		10
#define DTE_BIT		8
#define DDE_BIT		6
#define CE_CLEAR	0x3fc0;


