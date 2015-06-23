#include "board.h"
#include "uart.h"

#define BOTH_EMPTY (UART_LSR_TEMT | UART_LSR_THRE)

#define WAIT_FOR_XMITR \
        do { \
                lsr = REG8(UART_BASE + UART_LSR); \
        } while ((lsr & BOTH_EMPTY) != BOTH_EMPTY)

#define WAIT_FOR_THRE \
        do { \
                lsr = REG8(UART_BASE + UART_LSR); \
        } while ((lsr & UART_LSR_THRE) != UART_LSR_THRE)

#define CHECK_FOR_CHAR (REG8(UART_BASE + UART_LSR) & UART_LSR_DR)

#define WAIT_FOR_CHAR \
         do { \
                lsr = REG8(UART_BASE + UART_LSR); \
         } while ((lsr & UART_LSR_DR) != UART_LSR_DR)


// ------------------------ uart_init -----------------------------
void uart_init(void)
{
  int divisor;

  /* Reset receiver and transmiter */
  REG8(UART_BASE + UART_FCR) = UART_FCR_ENABLE_FIFO | UART_FCR_CLEAR_RCVR | UART_FCR_CLEAR_XMIT | UART_FCR_TRIGGER_14;

  /* Disable all interrupts */
  REG8(UART_BASE + UART_IER) = 0x00;

  /* Set 8 bit char, 1 stop bit, no parity */
  REG8(UART_BASE + UART_LCR) = UART_LCR_WLEN8 & ~(UART_LCR_STOP | UART_LCR_PARITY);

  /* Set baud rate */
  divisor = IN_CLK/(16 * UART_BAUD_RATE);
  REG8(UART_BASE + UART_LCR) |= UART_LCR_DLAB;
  REG8(UART_BASE + UART_DLL) = divisor & 0x000000ff;
  REG8(UART_BASE + UART_DLM) = (divisor >> 8) & 0x000000ff;
  REG8(UART_BASE + UART_LCR) &= ~(UART_LCR_DLAB);
}


// ------------------------ uart_putc -----------------------------
void uart_putc(char c)
{
  unsigned char lsr;
        
  WAIT_FOR_THRE;
  REG8(UART_BASE + UART_TX) = c;
  if(c == '\n') {
    WAIT_FOR_THRE;
    REG8(UART_BASE + UART_TX) = '\r';
  }
  WAIT_FOR_XMITR;
}

// ------------------------ uart_getc -----------------------------
char uart_getc(void)
{
  unsigned char lsr;
  char c;

  WAIT_FOR_CHAR;
  c = REG8(UART_BASE + UART_RX);
  return c;
}

// ------------------------ print32bit -----------------------------
void print32bit (long unsigned int val)
{
  int i;
  unsigned long int myNibble;
  char myChar;

  for (i=0;i<8;i++) {
    myNibble =  (val >> 28) & 0xfUL;
    if (myNibble <= 0x9)
      myChar = (char) myNibble + 0x30;
    else 
      myChar = (char) myNibble + 0x37;
    uart_putc (myChar);
    val = val << 4;
  }
  uart_putc ('\n');
}

// ------------------------ printStr -----------------------------
void printStr(char *str)
{
  char *s;

  for (s = str; *s; s++)
    uart_putc (*s);
}

// ------------------------ dumpMCregs -----------------------------
void dumpMCregs (void)
{
  unsigned long mcReg;
  int i;

    mcReg = REG32(MC_BASE_ADDR);
    print32bit(mcReg);
    mcReg = REG32(0x60000008);
    print32bit(mcReg);
    mcReg = REG32(0x60000014);
    print32bit(mcReg);
    mcReg = REG32(0x60000010);
    print32bit(mcReg);

    //print32bit(mcReg);
    //uart_putc ('\n');

  //for (i=0;i<20;i++) {
    //mcReg = REG32(MC_BASE_ADDR + i);
    //mcReg = (unsigned long) i;
    //print32bit(mcReg);
    //uart_putc ('\n');
  //}
}

// ------------------------ initMCregs -----------------------------
void initMCregs (void)
{

  //control status register
  //Refresh_prescaler = 13. wb_clk / 14.55 ~= 1 / 488.28nS, where wb_clk ~= 31MHz
  //REF_INT = 4. 2M32 DRAM requires 4096 refresh cycles per 64mS. That is refresh interval = 15.625uS
  REG32(MC_BASE_ADDR) = 0x0d000400;
  //Base address mask register
  REG32(0x60000008) = 0x00000000;
  //TMS0
  //Includes mode register setting
  //Burst Length = 1, burst type = sequential, CAS latency = 2
  //operation mode = standard, write burst mode = single loaction
  //Twr = 2, Tcrd = 2, Trp = 2, Trfc = 7
  REG32(0x60000014) = 0x07250220;
  //CSC0 Chip Select Config Register 0
  //base address 0, PEN = 0, Keep row open = 0, bank address follows column address,
  //writes enabled, memory size = 128Mb, Bus Width = 32-bit, Mem Type = SDRAM, EN = 1
  //SDRAM init begins after this register write
  REG32(0x60000010) = 0x00000061;

  //For some reason loading mode register twice is required. Need to investigate reason
  //TMS0
  REG32(0x60000014) = 0x07250220;

  
}

// ------------------------ testDRAMShort -----------------------------
unsigned int testDRAMShort (void) {
unsigned long temp;
unsigned long address;
unsigned long data;
int i;
unsigned int testFail;

  //The first access will be stalled until the SDRAM has finished initialization
  //REG32(0x40000000) = 0x12345678;
  //temp = REG32(0x40000000);

  testFail = 0;
  address = 0x40004000;
  for (i=0; i<100; i++) {
    *((volatile unsigned long *)(address)) = i;
    address += 4;
  }
  address = 0x40004000;
  for (i=0; i<100; i++) {
    data = *((volatile unsigned long *)(address));
    if (data != i) {
      testFail = 1;
      //printStr("At address 0x");
      //print32bit(address);
      //printStr(" expected 0x");
      //print32bit(i);
      //printStr(" got 0x");
      //print32bit(data);
      //uart_putc ('\n');
    }   
    address += 4;
  }
  return testFail;
}


// ------------------------ testAllDRAM -----------------------------
unsigned int testAllDRAM (void) {
unsigned long temp;
unsigned long address;
unsigned long memBase;
unsigned long memOffSet;
unsigned long bitIndexBase;
unsigned long data;
unsigned long i;
char *s;
unsigned int keyPress;
unsigned int testFail;

  //The first access will be stalled until the SDRAM has finished initialization
  //REG32(0x40000000) = 0x12345678;
  //temp = REG32(0x40000000);

  testFail = 0;
  keyPress = 0;
  memBase = 0x40000000;
  // Start at DRAM location beyond where this code is located
  // If the code is located in FPGA block RAM, then you can start at 0x0
  memOffSet = 0x40000;
  bitIndexBase = 0;  
  printStr("Press any key to stop\n");
  while (memOffSet < 0x1000000 && keyPress == 0) {
    address = memBase + memOffSet;
    printStr("Testing DRAM at address 0x");
    print32bit(address);
    for (i=0; i<0x10000; i++) {
      *((volatile unsigned long *)(address)) = i << bitIndexBase;
      address += 4;
    }
    address = memBase + memOffSet;
    for (i=0; i<0x10000; i++) {
      data = *((volatile unsigned long *)(address));
      if (data != i << bitIndexBase) {
        testFail = 1;
        printStr("At address 0x");
        print32bit(address);
        printStr(" expected 0x");
        print32bit(i << bitIndexBase);
        printStr(" got 0x");
        print32bit(data);
        uart_putc ('\n');
      }   
      address += 4;
    }
    memOffSet += 0x40000;
    if (bitIndexBase == 0)
      bitIndexBase = 16;
    else
      bitIndexBase = 0;
    if ( ( REG8(UART_BASE + UART_LSR) & UART_LSR_DR) == UART_LSR_DR)
      keyPress = 1;
  }
  return testFail;
}

// ------------------------ main -----------------------------
int main (void)
{
  char *s;


  uart_init ();
  initMCregs();
  //dumpMCregs();
  printStr("\nDRAM test\n");
  //dumpMCregs();
  //initMCregs();
  //dumpMCregs();
#ifdef SIM_COMPILE
  if (testDRAMShort() == 0)
    printStr("Pass\n");
  else
    printStr("Fail\n");
#else
  if (testAllDRAM() == 0)
    printStr("Passed DRAM memory test  \n");
  else
    printStr("Failed DRAM memory test  \n");
  printStr("Press a key and see the key+1 echoed\n");
  while (1)
    uart_putc (uart_getc () + 1);
#endif

  return 0;
}

