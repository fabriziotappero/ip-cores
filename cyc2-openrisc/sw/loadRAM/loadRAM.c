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

#define DEBUG_PRINT
//#define SDRAM_READBACK_CHECK
//#define SDRAM_READBACK_PRINT

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
        
#ifdef DEBUG_PRINT        
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

// ------------------------ initMCregs -----------------------------
void initMCregs (void)
{
  //control status register
  //Refresh_prescaler = (wb_clk * 488.28nS) -1. For wb_clk = 30MHz, Refresh_prescaler = 14
  //REF_INT = 4. 2M32 DRAM requires 4096 refresh cycles per 64mS. That is refresh interval = 15.625uS
  REG32(MC_BASE_ADDR) = 0x0e000400;
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


// ------------------------ initSD -----------------------------
int initSD(void) {
  char *s;
  unsigned char transError;

  printStr("Starting SD Init\n");
  REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_INIT_SD;
  REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;
  printStr("Waiting transaction complete ...\n");
  while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY);
  transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
  if (transError != 0) {
    printStr("Transaction error. Trans error code: ");
    print32bit( (unsigned long int) transError);
    return (1);
  }
  return (0);
}


// ------------------------ copyFlashToRAM -----------------------------
int copyFlashToRAM(void) {
int i;
unsigned char dataWrite;
unsigned char dataRead;
char *s;
unsigned char transError;
unsigned long sdBuffer [128];
unsigned long dataReadWord; 
unsigned long address;
unsigned long data;
unsigned long fileSize;
unsigned char sigByte;
unsigned char checkSum;
unsigned char checkSumExpected;
unsigned long sdAddr;
unsigned long ramAddr;
int numBlocks;
int blockCnt;

  //printStr("Copying image from flash to RAM\n");

  //set SD address = SD_FLASH_FILE_START
  sdAddr = SD_FLASH_FILE_START;
  REG8(SD_BASE + SD_ADDR_7_0_REG) = (unsigned char) (sdAddr & 0xff);
  REG8(SD_BASE + SD_ADDR_15_8_REG) = (unsigned char) ((sdAddr >> 8) & 0xff);
  REG8(SD_BASE + SD_ADDR_23_16_REG) = (unsigned char) ((sdAddr >> 16) & 0xff);
  REG8(SD_BASE + SD_ADDR_31_24_REG) = (unsigned char) ((sdAddr >> 24) & 0xff);

  //set read trans type, and start
  REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_RW_READ_SD_BLOCK;
  REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;

  //wait for complete
  //printStr("Waiting transaction complete ...\n");
  while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY);

  //print read error code
  transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
  if (transError != 0) {
    printStr("Transaction error. Trans error code: ");
    print32bit( (unsigned long int) transError);
    return (1);
  }

  //read file control block
  fileSize = 0;
  checkSumExpected = 0;
  checkSum = 0;
  for (i=0; i<=511; i=i+1) {
    dataRead = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
    if (i==0)
      sigByte = dataRead;
    if (i >= 1 && i <= 4)
      fileSize = (fileSize << 8) + dataRead;
    if (i == 510 || i == 511)
      checkSumExpected = (checkSumExpected << 8) + dataRead;
    if (i >= 0 && i <= 509)
      checkSum = checkSum + dataRead;
  }

  if (sigByte != 0xa7) {
    return (1);
  }
  printStr("Detected boot file, size ");
  print32bit(fileSize);
  //print32bit(sigByte);
  //print32bit(checkSumExpected);
  //print32bit(checkSum);

  sdAddr += 512; //file data begins in block after file control block
  ramAddr = SDRAM_BASE_ADDR;
  numBlocks = fileSize/512;
  if (fileSize%512 != 0)
    numBlocks++;
  for (blockCnt = 0; blockCnt < numBlocks; blockCnt++) {
    //printStr("Block Num = ");
    //print32bit(blockCnt);

    REG8(SD_BASE + SD_ADDR_15_8_REG) = (unsigned char) ((sdAddr >> 8) & 0xff);
    REG8(SD_BASE + SD_ADDR_23_16_REG) = (unsigned char) ((sdAddr >> 16) & 0xff);
    REG8(SD_BASE + SD_ADDR_31_24_REG) = (unsigned char) ((sdAddr >> 24) & 0xff);
    //set read trans type, and start
    REG8(SD_BASE + SPI_TRANS_TYPE_REG) = SPI_RW_READ_SD_BLOCK;
    REG8(SD_BASE + SPI_TRANS_CTRL_REG) = SPI_TRANS_START;

    //wait for complete
    //printStr("Waiting transaction complete ...\n");
    while (REG8(SD_BASE + SPI_TRANS_STS_REG) == TRANS_BUSY);

    //print read error code
    if (transError != 0) {
      printStr("Transaction error. Trans error code: ");
      transError = REG8(SD_BASE + SPI_TRANS_ERROR_REG);  
      print32bit( (unsigned long int) transError);
      return (1);
    }
    //printStr("Transaction completed\n");
    //read RX fifo
    for (i=0; i<=127; i=i+1) {
      dataRead = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
      checkSum += dataRead;
      dataReadWord = dataRead << 24;
      dataRead = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
      checkSum += dataRead;
      dataReadWord = dataReadWord + (dataRead << 16);
      dataRead = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
      checkSum += dataRead;
      dataReadWord = dataReadWord + (dataRead << 8);
      dataRead = REG8(SD_BASE + SPI_RX_FIFO_DATA_REG);
      checkSum += dataRead;
      dataReadWord = dataReadWord + dataRead;
      sdBuffer[i] = dataReadWord;
    }

    //write data to SDRAM
    address = ramAddr;
    for (i=0; i<=127; i++) {
      *((volatile unsigned long *)(address)) = sdBuffer[i];
      address += 4;
    }
#ifdef SDRAM_READBACK_CHECK
    //read back from SDRAM and compare
    address = ramAddr;
    for (i=0; i<=127; i++) {
      data = *((volatile unsigned long *)(address));
      //print32bit(data);
      address += 4;
      if (data != sdBuffer[i]) {
        printStr("At address ");
        print32bit(address);
        printStr(" expected ");
        print32bit(i);
        printStr(" got ");
        print32bit(data);
        uart_putc ('\n');
      }
    }
#endif
    sdAddr += 512;
    ramAddr += 512; 
  }

#ifdef SDRAM_READBACK_PRINT
  //read back from SDRAM and print
  ramAddr = SDRAM_BASE_ADDR;
  for (blockCnt = 0; blockCnt < numBlocks; blockCnt++) {
    printStr("Block Num = ");
    print32bit(blockCnt);
    address = ramAddr;
    for (i=0; i<=127; i++) {
      data = *((volatile unsigned long *)(address));
      print32bit(data);
      address += 4;
    }
    ramAddr += 512; 
  }
#endif

  //print checksum
  if (checkSum == checkSumExpected)
    printStr("File load OK\n");
  else {
    printStr("Checksum test failed: ");
    printStr(" expected ");
    print32bit(checkSumExpected);
    printStr(" got ");
    print32bit(checkSum);
    return (1);
  }

  return (0);

}


// ------------------------ main -----------------------------
int main (void)
{
  char *s;
  int loadFail;
  int initFail;

  uart_init ();
  printStr("SD Boot loader V1.0\n");  
  initMCregs();
  initFail = initSD();
  if (initFail == 0) {
    loadFail = copyFlashToRAM();
    if (loadFail == 0)
      jumpToRAM();
  }
  while (1);

  return 0;
}

