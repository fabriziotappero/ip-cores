#include "board.h"
#include "uart.h"
#include "spiMaster.h"

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


//#define SIM_COMPILE

void uart_putc(char c)
{
  unsigned char lsr;

#ifndef SIM_COMPILE        
  WAIT_FOR_THRE;
  REG8(UART_BASE + UART_TX) = c;
  if(c == '\n') {
    WAIT_FOR_THRE;
    REG8(UART_BASE + UART_TX) = '\r';
  }
  WAIT_FOR_XMITR;
#endif
}


char uart_getc(void)
{
  unsigned char lsr;
  char c;

  WAIT_FOR_CHAR;
  c = REG8(UART_BASE + UART_RX);
  return c;
}

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

void initMCregs (void)
{
  //control status register
  //Refresh_prescaler = 13. wb_clk / 14.55 ~= 1 / 488.28nS, where wb_clk ~= 31MHz
  //REF_INT = 4. 2M32 DRAM requires 4096 refresh cycles per 64mS. That is refresh interval = 15.625uS
  REG32(MC_BASE_ADDR) = 0x0d000400;
  //Base address mask register
  REG32(0x60000008) = 0x00000000;
  //TMS0
  REG32(0x60000014) = 0x00044a24;
  //CSC0 Chip Select Config Register 0
  //base address 0, PEN = 0, Keep row open = 0, bank address follows column address,
  //writes enabled, memory size = 128Mb, Bus Width = 32-bit, Mem Type = SDRAM, EN = 1
  //SDRAM init begins after this register write
  REG32(0x60000010) = 0x00000061;
  
}

void testDRAM (void) {
unsigned long temp;
unsigned long address;
unsigned long data;
int i;

  //The first access will be stalled until the SDRAM has finished initialization
  //REG32(0x40000000) = 0x12345678;
  //temp = REG32(0x40000000);

  address = 0x40000000;
  for (i=0; i<100; i++) {
    *((volatile unsigned long *)(address)) = i;
    address += 4;
  }
  address = 0x40000000;
  for (i=0; i<100; i++) {
    data = *((volatile unsigned long *)(address));
    address += 4;
    print32bit(data);
  }
}

char *str = "Hello world!!!\n";
char *addrStr = "At address ";
char *expectedStr = " expected ";
char *gotStr = " got ";
char *passedStr = "Passed all memory tests  \n";
char *startSDInit = "Starting SD Init\n";
char *startSDBlockRead = "Starting SD block read\n";
char *startSDBlockWrite = "Starting SD block write\n";
char *startSDRegReadWriteTest = "SD reg read/write. Read ";
char *waitTransComp = "Waiting transaction complete ...\n";
char *transErrorStr = "Transaction completed. Trans error code: ";

void testAllDRAM (void) {
unsigned long temp;
unsigned long address;
unsigned long data;
unsigned long i;
char *s;

  //The first access will be stalled until the SDRAM has finished initialization
  //REG32(0x40000000) = 0x12345678;
  //temp = REG32(0x40000000);

  address = 0x40000000;
  for (i=0; i<100; i++) {
    *((volatile unsigned long *)(address)) = i;
    address += 4;
  }
  address = 0x40000000;
  for (i=0; i<100; i++) {
    data = *((volatile unsigned long *)(address));
    address += 4;
    if (data != i) {
      for (s = addrStr; *s; s++)
        uart_putc (*s);
      print32bit(address);
      for (s = expectedStr; *s; s++)
        uart_putc (*s);
      print32bit(i);
      for (s = gotStr; *s; s++)
        uart_putc (*s);
      print32bit(data);
      uart_putc ('\n');
    }   
  }
}

// ------------------------ initSD -----------------------------
void initSD(void) {
  char *s;
  unsigned char transError;

  for (s = startSDInit; *s; s++)
    uart_putc (*s);
  REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_INIT_SD;
  REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;
  for (s = waitTransComp; *s; s++)
    uart_putc (*s);
  while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY);
  for (s = transErrorStr; *s; s++)
    uart_putc (*s);
  transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
  print32bit( (unsigned long int) transError);
}


// ------------------------ SDBlockReadWriteTest -----------------------------
void SDBlockReadWriteTest(void) {
int i;
unsigned char dataWrite;
unsigned char dataRead;
char *s;
unsigned char transError;

  for (s = startSDBlockWrite; *s; s++)
    uart_putc (*s);

  //write to TX fifo
  dataWrite = 0;
  for (i=0; i<=511; i=i+1) {
    REG8(SD_BASE + SPI_TX_FIFO_DATA_REG) = dataWrite;
    dataWrite = dataWrite + 1;
  }

  //set SD address = 0x90000
  REG8(SD_BASE + SD_ADDR_7_0_REG) = 0x00;
  REG8(SD_BASE + SD_ADDR_15_8_REG) = 0x00;
  REG8(SD_BASE + SD_ADDR_23_16_REG) = 0x09;
  REG8(SD_BASE + SD_ADDR_31_24_REG) = 0x00;

  //set write trans type, and start
  REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_RW_WRITE_SD_BLOCK;
  REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;

  //wait for complete
  for (s = waitTransComp; *s; s++)
    uart_putc (*s);
  while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY);

  //print write error code
  for (s = transErrorStr; *s; s++)
    uart_putc (*s);
  transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
  print32bit( (unsigned long int) transError);

  for (s = startSDBlockRead; *s; s++)
    uart_putc (*s);

  //set read trans type, and start
  REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_RW_READ_SD_BLOCK;
  REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;

  //wait for complete
  for (s = waitTransComp; *s; s++)
    uart_putc (*s);
  while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY);

  //print read error code
  for (s = transErrorStr; *s; s++)
    uart_putc (*s);
  transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
  print32bit( (unsigned long int) transError);

  //read RX fifo
  for (i=0; i<=511; i=i+1) {
    dataRead = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
    print32bit( (unsigned long int) dataRead);
  }
  
}


// ------------------------ SDRegReadWriteTest -----------------------------
void SDRegReadWriteTest(void) {
  unsigned char version;
  unsigned char temp;
  char *s;
  unsigned long int SDaddr;

  for (s = startSDRegReadWriteTest; *s; s++)
    uart_putc (*s);
  version = REG8(SD_BASE + SPI_MASTER_VERSION_REG);
  REG8(SD_BASE + SD_ADDR_7_0_REG) = 0x78;
  REG8(SD_BASE + SD_ADDR_15_8_REG) = 0x56;
  REG8(SD_BASE + SD_ADDR_23_16_REG) = 0x34;
  REG8(SD_BASE + SD_ADDR_31_24_REG) = 0x12;
  temp = REG8(SD_BASE + SD_ADDR_7_0_REG);
  SDaddr = temp;
  temp = REG8(SD_BASE + SD_ADDR_15_8_REG);
  SDaddr = SDaddr + (temp << 8);
  temp = REG8(SD_BASE + SD_ADDR_23_16_REG);
  SDaddr = SDaddr + (temp << 16);
  temp = REG8(SD_BASE + SD_ADDR_31_24_REG);
  SDaddr = SDaddr + (temp << 24);
  print32bit(SDaddr);
}

// ------------------------ spiDirectWrite -----------------------------
void spiDirectWrite(unsigned char txByte) {

  REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_DIRECT_ACCESS;
  REG8(SD_BASE + SPI_DIRECT_ACCESS_DATA_REG) = txByte;
  REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;
  while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY);
}

int main (void)
{
  char *s;

  uart_init ();
  REG8(SD_BASE + SPI_CLK_DEL_REG) = 0x10; //911KHz @ 31MHz sysClk
  initSD();
  SDRegReadWriteTest();
  SDBlockReadWriteTest();
  spiDirectWrite(0x96);
  while (1)
    uart_putc (uart_getc () + 1);


  //initMCregs();
  ////dumpMCregs();
  //testAllDRAM();
  //for (s = passedStr; *s; s++)
    //uart_putc (*s);
  //while (1);

  //for (s = str; *s; s++)
    //uart_putc (*s);

  //print32bit(0x12345678UL);

  //while (1)
    //uart_putc (uart_getc () + 1);

  //return 0;


}

