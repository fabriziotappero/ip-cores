#define DSU3SIZE	0x1000000

#define DSU3_TIMETAG	0x000008
#define DSU3_BREAK	0x000020
#define DSU3_MASK 	0x000024
#define DSU3_AHBCTRL	0x000040
#define DSU3_AHBINDEX	0x000044
#define DSU3_AHBBPT1	0x000050
#define DSU3_AHBMSK1	0x000054
#define DSU3_AHBBPT2	0x000058
#define DSU3_AHBMSK2	0x00005C
#define DSU3_TBUF 	0x100000
#define DSU3_TBCTRL 	0x110000
#define DSU3_AHBBUF	0x200000
#define DSU3_RFILE	0x300000
#define DSU3_RFILEPAR   0x300800
#define DSU3_FPRFILE	0x301000
#define DSU3_FPRFILEPAR	0x301800
#define DSU3_SPREG	0x400000
#define DSU3_RFFTCTRL   0x400040
#define DSU3_LCFG	0x400044
#define DSU3_PC    	0x400010
#define DSU3_TRAP  	0x400020
#define DSU3_ASI  	0x400024
#define DSU3_ASR  	0x400040
#define DSU3_WPOINT 	0x400060
#define DSU3_ITAGS  	0x800000
#define DSU3_IDATA  	0xA00000
#define DSU3_DTAGS  	0xC00000
#define DSU3_DDATA  	0xE00000

#define DSU3_ERRMODE 	0x200
#define DSU3_DBGMODE 	0x040

#define DSU3_ASIMASK  	0x0FFFFF
#define DSU3_ASIADDR  	0x700000
#define DSU3_CCTRL      0x0
#define DSU3_ICFG  	0x8
#define DSU3_DCFG  	0xc
#define ASI_UINST       0x8
#define ASI_ILRAM       0x9
#define ASI_UDATA       0xa
#define ASI_DLRAM       0xb
#define ASI_ITAG  	0xc
#define ASI_IDATA 	0xd
#define ASI_DTAG  	0xe
#define ASI_DDATA 	0xf

#define ASI_MMUSNOOP_DTAG  0x1e 

#define DSU3_CPAR       0x10000000


#ifndef __ASSEMBLER__

struct dsu3regs {
	volatile unsigned int dsuctrl;		/* 0x00 */
	volatile unsigned int dummy04;
	volatile unsigned int timetag;		/* 0x08 */
	volatile unsigned int dummy0C;


};


#endif

