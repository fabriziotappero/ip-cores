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


//#define SIM_COMPILE

// ------------------------ uart_putc -----------------------------
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

// ------------------------ initSD -----------------------------
void initSD(void) {
  char *s;
  unsigned char transError;

  printStr("Starting SD Init\n");
  REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_INIT_SD;
  REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;
  printStr("Waiting transaction complete ...\n");
  while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY);
  printStr("Transaction completed. Trans error code: ");
  transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
  print32bit( (unsigned long int) transError);
}


// ------------------------ SDBlockReadWriteTest -----------------------------
int SDBlockReadWriteTest(unsigned long sdAddr) {
int i;
unsigned char dataWrite;
unsigned char dataRead;
char *s;
unsigned char transError;

  printStr("Writing SD memory at address = ");
  print32bit(sdAddr);
  //write to TX fifo
  dataWrite = 0;
  for (i=0; i<=511; i=i+1) {
    REG8(SD_BASE + SPI_TX_FIFO_DATA_REG) = dataWrite;
    dataWrite = dataWrite + 1;
  }

  //set SD address = SD_FLASH_FILE_START
  REG8(SD_BASE + SD_ADDR_7_0_REG) = (unsigned char) (sdAddr & 0xff);
  REG8(SD_BASE + SD_ADDR_15_8_REG) = (unsigned char) ((sdAddr >> 8) & 0xff);
  REG8(SD_BASE + SD_ADDR_23_16_REG) = (unsigned char) ((sdAddr >> 16) & 0xff);
  REG8(SD_BASE + SD_ADDR_31_24_REG) = (unsigned char) ((sdAddr >> 24) & 0xff);

  //set write trans type, and start
  REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_RW_WRITE_SD_BLOCK;
  REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;

  //wait for complete
  printStr("Waiting transaction complete ...\n");
  while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY);

  //check write error code
  transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
  if (transError != 0) {
    printStr("Transaction error. Trans error code: ");
    print32bit( (unsigned long int) transError);
    return (1);
  }

  printStr("Starting SD block read\n");

  //set read trans type, and start
  REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_RW_READ_SD_BLOCK;
  REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;

  //wait for complete
  printStr("Waiting transaction complete ...\n");
  while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY);

  //check read error code
  transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
  if (transError != 0) {
    printStr("Transaction error. Trans error code: ");
    print32bit( (unsigned long int) transError);
    return (1);
  }

  //read RX fifo
  dataWrite = 0;
  for (i=0; i<=511; i=i+1) {
    dataRead = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
    if (dataRead != dataWrite) {
      printStr("Data read error, expected ");
      print32bit( (unsigned long int) dataWrite);
      printStr(" got ");
      print32bit( (unsigned long int) dataRead);
      return (1);
    }
    dataWrite = dataWrite + 1;
  }
  return (0);
}


// ------------------------ SDMultiBlockWrite -----------------------------
int SDMultiBlockWrite(unsigned long sdAddr, unsigned long numBlocks) {
int i;
unsigned long blockCnt;
unsigned int waitCnt;
unsigned long dataWrite;
unsigned char dataRead;
char *s;
unsigned char transError;


  printStr("--- Starting SD memory write\n");
  dataWrite = 0;
  for (blockCnt = 0; blockCnt <= numBlocks; blockCnt++) {
    if ((blockCnt & 0xff) == 0) {
      printStr("Writing SD memory at address = 0x");
      print32bit(sdAddr);
    }
    //write to TX fifo
    for (i=0; i<=127; i=i+1) {
      REG8(SD_BASE + SPI_TX_FIFO_DATA_REG) = (unsigned char) (dataWrite & 0xff);
      REG8(SD_BASE + SPI_TX_FIFO_DATA_REG) = (unsigned char) ((dataWrite >> 8) & 0xff);
      REG8(SD_BASE + SPI_TX_FIFO_DATA_REG) = (unsigned char) ((dataWrite >> 16) & 0xff);
      REG8(SD_BASE + SPI_TX_FIFO_DATA_REG) = (unsigned char) ((dataWrite >> 24) & 0xff);
      dataWrite = dataWrite + 1;
    }

    //set SD address
    REG8(SD_BASE + SD_ADDR_7_0_REG) = (unsigned char) (sdAddr & 0xff);
    REG8(SD_BASE + SD_ADDR_15_8_REG) = (unsigned char) ((sdAddr >> 8) & 0xff);
    REG8(SD_BASE + SD_ADDR_23_16_REG) = (unsigned char) ((sdAddr >> 16) & 0xff);
    REG8(SD_BASE + SD_ADDR_31_24_REG) = (unsigned char) ((sdAddr >> 24) & 0xff);

    //set write trans type, and start
    REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_RW_WRITE_SD_BLOCK;
    REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;

    //wait for complete
    //printStr("Waiting transaction complete ...\n");
    waitCnt = 0;
    while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY) {
      waitCnt++;
      if ((waitCnt & 0x3ff) == 0)
        printStr("Waiting transaction complete ...\n");
    }
    //check write error code
    transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
    if (transError != 0) {
      printStr("Transaction error. Trans error code: ");
      print32bit( (unsigned long int) transError);
      printStr("At SD memory address = 0x");
      print32bit(sdAddr);
      return (1);
    }
    sdAddr += 512;
  }
  return (0);
}

// ------------------------ SDMultiBlockRead -----------------------------
int SDMultiBlockRead(unsigned long sdAddr, unsigned long numBlocks) {
int i;
unsigned long blockCnt;
unsigned int waitCnt;
unsigned long dataWrite;
unsigned long dataRead;
unsigned char dataRead1;
unsigned char dataRead2;
unsigned char dataRead3;
unsigned char dataRead4;
char *s;
unsigned char transError;


  printStr("--- Starting SD memory read\n");
  dataWrite = 0;
  for (blockCnt = 0; blockCnt <= numBlocks; blockCnt++) {
    if ((blockCnt & 0xff) == 0) {
      printStr("Reading SD memory at address = 0x");
      print32bit(sdAddr);
    }

    //set SD address
    REG8(SD_BASE + SD_ADDR_7_0_REG) = (unsigned char) (sdAddr & 0xff);
    REG8(SD_BASE + SD_ADDR_15_8_REG) = (unsigned char) ((sdAddr >> 8) & 0xff);
    REG8(SD_BASE + SD_ADDR_23_16_REG) = (unsigned char) ((sdAddr >> 16) & 0xff);
    REG8(SD_BASE + SD_ADDR_31_24_REG) = (unsigned char) ((sdAddr >> 24) & 0xff);
  
    //set read trans type, and start
    REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_RW_READ_SD_BLOCK;
    REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;

    //wait for complete
    //printStr("Waiting transaction complete ...\n");
    waitCnt = 0;
    while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY) {
      waitCnt++;
      if ((waitCnt & 0x3ff) == 0)
        printStr("Waiting transaction complete ...\n");
    }

    //check read error code
    transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
    if (transError != 0) {
      printStr("Transaction error. Trans error code: ");
      print32bit( (unsigned long int) transError);
      return (1);
    }

    //read RX fifo
    for (i=0; i<=127; i=i+1) {
      dataRead1 = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
      dataRead2 = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
      dataRead3 = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
      dataRead4 = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
      dataRead = dataRead1 + (dataRead2 << 8) + (dataRead3 << 16) + (dataRead4 << 24); 
      if (dataRead != dataWrite) {
        printStr("Data read error, expected ");
        print32bit(dataWrite);
        printStr(" got ");
        print32bit(dataRead);
        printStr("At SD memory address = 0x");
        print32bit(sdAddr);
        return (1);
      }
      dataWrite = dataWrite + 1;
    }
    sdAddr += 512;
  }
  return (0);
}

// ------------------------ main -----------------------------
int main (void)
{
  char *s;
  unsigned long sdAddr;
  int testFail;
  int readFail;
  int writeFail;

  uart_init ();
  REG8(SD_BASE + SPI_CLK_DEL_REG) = 0x00; 
  initSD();

  //testFail = 0;
  //sdAddr = 0xf0000;
  //while ((sdAddr <= 0xf00000) && (testFail == 0)) {
  //  testFail = SDBlockReadWriteTest(sdAddr);
  //  sdAddr += 512;
  //}

  readFail = 0;
  writeFail = 0;
  sdAddr = 0xf0000;
  while (readFail == 0 && writeFail == 0) {
    writeFail = SDMultiBlockWrite(sdAddr, 10000);
    if (readFail == 0)
      readFail = SDMultiBlockRead(sdAddr, 10000);
  }

  while (1);
}

