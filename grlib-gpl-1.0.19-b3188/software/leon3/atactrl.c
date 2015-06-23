typedef struct {
  volatile unsigned int ctrl;	// 0x00
  volatile unsigned int stat;
  volatile unsigned int pctr;
  volatile unsigned int pftr0;	
  volatile unsigned int pftr1;	// 0x10
  volatile unsigned int drt0;
  volatile unsigned int drt1;
  volatile unsigned int bmcmd;	
  volatile unsigned int bmvd0;	// 0x20
  volatile unsigned int bmsta;	
  volatile unsigned int bmvd1;	
  volatile unsigned int prdtb;	
  volatile unsigned int dummy[4];    // 0x30 - 0x3c	
  volatile unsigned int data;	
  volatile unsigned int features;	
  volatile unsigned int secnum;	
  volatile unsigned int seccnt;	
  volatile unsigned int cyllow;		// 0x50
  volatile unsigned int cylhigh;	
  volatile unsigned int devhead;	
  volatile unsigned int status;	
  volatile unsigned int dummy2[6];    // 0x60 - 0x74	
  volatile unsigned int altstat;	
} ataregs;

ata_test(int addr) {
    ataregs *ata = (ataregs *) addr;
    unsigned int tmp, i;
    volatile int vtmp;
    unsigned short buf[256]; 

    // init
    ata->ctrl = 0x800000e0;
    vtmp = ata->status;
    ata->ctrl = 0x800000ee;

    ata->devhead = 0;
    ata->status = 0xEC;

    tmp = ata->status;
    while (tmp & 0x80) tmp = ata->status;

    if((tmp & 0x1) == 1 || (tmp & 0x40) != 0x40){
//	fail(1);
    }
    for (i=0; i<256; i++) {
	tmp = ata->data;
	buf[i] = tmp;
    }

    
}

