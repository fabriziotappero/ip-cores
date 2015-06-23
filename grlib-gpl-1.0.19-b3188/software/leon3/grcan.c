
grcan_test(int paddr)
   {

   // start of test
   report_device(0x0103D000);

   // can register structures
   struct grcan_ctrl {
      volatile unsigned long conf;           /* 0x000 */
      volatile unsigned long stat;           /* 0x004 */
      volatile unsigned long ctrl;           /* 0x008 */
      volatile unsigned long dummy0c;        /* 0x00C */
      volatile unsigned long dummy10;        /* 0x010 */
      volatile unsigned long dummy14;        /* 0x014 */
      volatile unsigned long smask;          /* 0x018 */
      volatile unsigned long scode;          /* 0x01C */
   };

   struct grcan_irq {
      volatile unsigned long pimsr;          /* 0x100 */
      volatile unsigned long pimr;           /* 0x104 */
      volatile unsigned long pisr;           /* 0x108 */
      volatile unsigned long pir;            /* 0x10C */
      volatile unsigned long imr;            /* 0x110 */
      volatile unsigned long picr;           /* 0x114 */
   };

   struct grcan_tx {
      volatile unsigned long ctrl;           /* 0x200 */
      volatile unsigned long addr;           /* 0x204 */
      volatile unsigned long size;           /* 0x208 */
      volatile unsigned long wr;             /* 0x20C */
      volatile unsigned long rd;             /* 0x210 */
      volatile unsigned long irq;            /* 0x214 */
   };

//   struct grcan_rx {
//      volatile unsigned long ctrl;           /* 0x300 */
//      volatile unsigned long addr;           /* 0x304 */
//      volatile unsigned long size;           /* 0x308 */
//      volatile unsigned long wr;             /* 0x30C */
//      volatile unsigned long rd;             /* 0x310 */
//      volatile unsigned long irq;            /* 0x314 */
//      volatile unsigned long mask;           /* 0x318 */
//      volatile unsigned long code;           /* 0x31C */
//   };

   // local registers
   struct grcan_ctrl *lctrl = (struct grcan_ctrl *) (paddr);
   struct grcan_irq  *lirq =  (struct grcan_irq *)  (paddr+0x100);
   struct grcan_tx   *ltx0 =  (struct grcan_tx *)   (paddr+0x200);
//   struct grcan_rx   *lrx0 =  (struct grcan_rx *)   (paddr+0x300);

   // transmit and receive memory, allocate 2k memory
   volatile long int memory[512];

   // search for start of allocated memory
   long int memorytxbase;
   memorytxbase = (long int)&memory[0];
   // search for 1k boundary within allocated memory, store as base
   memorytxbase = memorytxbase & 0xFFFFFC00;
   memorytxbase = memorytxbase + 0x400;

   // baud rate configuration
   int SCALER = 0;
   int PS1 = 2;
   int PS2 = 2;
   int RSJ = 1;
   int BPR = 0;
   int SELECTION = 0;
   int ENABLE = 0x1;

   // setup transmit memory
//   report_subtest(0x1);

   // set temporary pointer to base memory start
   volatile int *memorytx;
   memorytx = (int*)memorytxbase;
   *memorytx = 0x913579BD;
   memorytx++;
   *memorytx = 0x80000000;
   memorytx++;
   *memorytx = 0x01020304;
   memorytx++;
   *memorytx = 0x05060708;
   memorytx++;

   // reset controller, setup baud rate, clear int erupts, enable codec
//   report_subtest(0x2);

   lctrl->ctrl = 0x00000002;
   lctrl->conf = (SCALER<<24) | (PS1<<20) | (PS2<<16) | (RSJ<<12) | (BPR<<8) | (SELECTION<<3) | (ENABLE<<1);
   lirq->picr  = 0xFFFFFFFF;
//   lirq->imr   = 0x00000540;
   lctrl->ctrl = 0x00000001;

   // transmit messages test
//   report_subtest(0x3);

   ltx0->addr   = memorytxbase;
   ltx0->size   = 0x00000080;
//   ltx0->wr     = 0x00000000;
//   ltx0->rd     = 0x00000000;
   ltx0->irq    = 0x00000010; // number of packets
   ltx0->ctrl   = 0x00000001;

   // send message
   ltx0->wr     = 0x00000010; // number of packets

   // wait for four messages being sent
   while ((ltx0->rd & 0xFFFF) != 0x0010) ;

   // check status
//   report_subtest(0x4);
   if (lctrl->stat != 0x00000000) fail(1);
   if (lirq->pir != 0x00000540) fail(2);

   // clear interrupt
   lirq->picr  = 0xFFFFFFFF;

   // reset controller, setup baud rate, clear int erupts, enable codec
   SELECTION = 1;
   ENABLE = 2;

   lctrl->ctrl = 0x00000002;
   lctrl->conf = (SCALER<<24) | (PS1<<20) | (PS2<<16) | (RSJ<<12) | (BPR<<8) | (SELECTION<<3) | (ENABLE<<1);
   lirq->picr  = 0xFFFFFFFF;
//   lirq->imr   = 0x00000540;
   lctrl->ctrl = 0x00000001;

   // transmit messages test
//   report_subtest(0x5);

   ltx0->addr   = memorytxbase;
   ltx0->size   = 0x00000080;
//   ltx0->wr     = 0x00000000;
//   ltx0->rd     = 0x00000000;
   ltx0->irq    = 0x00000010; // number of packets
   ltx0->ctrl   = 0x00000001;

   // send message
   ltx0->wr     = 0x00000010; // number of packets

   // wait for four messages being sent
   while ((ltx0->rd & 0xFFFF) != 0x0010) ;

   // check status
//   report_subtest(0x6);
   if (lctrl->stat != 0x00000000) fail(3);
   if (lirq->pir != 0x00000540) fail(4);

   // clear interrupt
   lirq->picr  = 0xFFFFFFFF;

   // reset core
   lctrl->ctrl = 0x00000002;
}
