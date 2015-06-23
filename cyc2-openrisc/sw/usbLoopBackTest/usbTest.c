#include "board.h"
#include "uart.h"
#include "usbHostSlave.h"

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
  //uart_putc ('\n');
}




// ------------------------ printStr -----------------------------
void printStr(char *str)
{
  char *s;

  for (s = str; *s; s++)
    uart_putc (*s);
}

// ------------------------ print2 -----------------------------
void print2(char *str1, unsigned long data1)
{
  printStr(str1);
  print32bit(data1);
}

// ------------------------ print3 -----------------------------
void print3(char *str1, unsigned long data1, char *str2)
{
  printStr(str1);
  print32bit(data1);
  printStr(str2);
}

// ------------------------ print4 -----------------------------
void print4(char *str1, unsigned long data1, char *str2, unsigned long data2)
{
  printStr(str1);
  print32bit(data1);
  printStr(str2);
  print32bit(data2);
}

/* ------------------------------- quit ---------------------------------- */
void quit(int errorLevel)
{
  if (errorLevel != 0)
    printStr("Verification ERROR. Simulation stopped\n");
  while (1);
}

/* ------------------------------- readXCReg ---------------------------------- */
unsigned char readXCReg(int hostSlaveSel, int regOffset, unsigned char expectedData, unsigned char rxDataMask)
{
unsigned char rxedData;
unsigned long memBase;

  if (hostSlaveSel == HOST)
    memBase = USB_HOST_BASE + HCREG_BASE;
  else
    memBase = USB_SLAVE_BASE + SCREG_BASE;

  rxedData = REG8(memBase + regOffset);
  if ( (rxedData & rxDataMask) != expectedData) {
    if (hostSlaveSel == HOST)
      printStr("\nHC");
    else
      printStr("\nSC");
    print4("Reg[0x", regOffset, "] & mask = (0x", rxedData);
    print4(" & 0x", rxDataMask, ") = 0x", (rxedData & rxDataMask) );
    print3(" , expecting 0x", expectedData, "\n");
    quit(1);
  }
  return rxedData;
}

/* ------------------------------- readXCRegNoQuit ---------------------------------- */
unsigned char readXCRegNoQuit(int hostSlaveSel, int regOffset, unsigned char expectedData, unsigned char rxDataMask, int *errorDetected)
{
unsigned char rxedData;
unsigned long memBase;

  if (hostSlaveSel == HOST)
    memBase = USB_HOST_BASE + HCREG_BASE;
  else
    memBase = USB_SLAVE_BASE + SCREG_BASE;

  rxedData = REG8(memBase + regOffset);
  if ( (rxedData & rxDataMask) != expectedData) {
    if (hostSlaveSel == HOST)
      printStr("\nHC");
    else
      printStr("\nSC");
    print4("Reg[0x", regOffset, "] & mask = (0x", rxedData);
    print4(" & 0x", rxDataMask, ") = 0x", (rxedData & rxDataMask) );
    print3(" , expecting 0x", expectedData, "\n");
    *errorDetected = 1;
  }
  return rxedData;
}

/* ------------------------------- writeXCReg ---------------------------------- */
void writeXCReg(int hostSlaveSel, unsigned char data, int regOffset)
{
  if (hostSlaveSel == HOST)
    REG8(USB_HOST_BASE + HCREG_BASE + regOffset) = data;
  else
    REG8(USB_SLAVE_BASE + SCREG_BASE + regOffset) = data;
}

/* ------------------------------- wait ---------------------------------- */
void wait(unsigned int waitTicks)
{
  unsigned int i;
 
  i=0;
  while (i<waitTicks) {
    i++;
  }
  
}


/* ------------------------------- cancelInterrupt ---------------------------------- */
void cancelInterrupt(int hostSlaveSel, unsigned char interruptBit)
{
unsigned char tempDataFromHost;

  if (hostSlaveSel == HOST) {
    writeXCReg(HOST, (unsigned char) (1 << interruptBit), INTERRUPT_STATUS_REG);
    tempDataFromHost = readXCReg(HOST, INTERRUPT_STATUS_REG, 0x0, (unsigned char) (1 << interruptBit) );
  }
  else {
    writeXCReg(SLAVE, (unsigned char) (1 << interruptBit), SC_INTERRUPT_STATUS_REG);
    tempDataFromHost = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, 0x0, (unsigned char) (1 << interruptBit) );
  }

}

/* ------------------------------- connection ---------------------------------- */
void connection(int lineState, unsigned int waitTime, int hostInterruptExpected, int slaveInterruptExpected, int checkInterruptStatus)
{
  unsigned char tempDataFromHost;
  unsigned char tempDataFromHost2;
  int expectedData;
  int expectedConnectState;



  if (lineState == ZERO_ONE) {
    expectedConnectState = LOW_SPEED_CONNECT;
    writeXCReg(HOST, 0x00, TX_LINE_CONTROL_REG);  //low speed polarity and bit rate, direct control off, line state don't care
    writeXCReg(SLAVE, 0x40, SC_CONTROL_REG);  //connect to host, low speed polarity and bit rate, direct control off, line state don't care, global enable off
  }
  else if (lineState == ONE_ZERO) {
    expectedConnectState = FULL_SPEED_CONNECT;
    writeXCReg(HOST, 0x18, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care
    writeXCReg(SLAVE, 0x70, SC_CONTROL_REG);  //connect to host, full speed polarity and bit rate, direct control off, line state don't care, global enable off
  }
  else {
    expectedConnectState = DISCONNECT;
    writeXCReg(HOST, 0x18, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care
    writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //disconnect from host, full speed polarity and bit rate, direct control off, line state don't care, global enable off
  }
  wait(waitTime);              //allow 'waitTime' samples to be clocked through
  if (hostInterruptExpected)
    expectedData = (1 << CONNECTION_EVENT_BIT);
  else
    expectedData = 0x0;
  if (checkInterruptStatus == 1)
    tempDataFromHost = readXCReg(HOST, INTERRUPT_STATUS_REG, expectedData, (1 << CONNECTION_EVENT_BIT) );
  else
    tempDataFromHost = readXCReg(HOST, INTERRUPT_STATUS_REG, expectedData, 0x0 );
  tempDataFromHost2 = readXCReg(HOST, RX_CONNECT_STATE_REG, expectedConnectState, 0xff);
  print4("\nHost interrupt status reg (HISR) = 0x", tempDataFromHost, " , host line state = 0x", tempDataFromHost2);
  if (slaveInterruptExpected)
    expectedData = (1 << SC_RESET_EVENT_BIT);
  else
    expectedData = 0x0;
  if (checkInterruptStatus == 1)
    tempDataFromHost = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, expectedData , (1 << SC_RESET_EVENT_BIT) );
  else
    tempDataFromHost = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, expectedData , 0x0 );

  tempDataFromHost2 = readXCReg(SLAVE, SC_LINE_STATUS_REG, expectedConnectState + (1 << SC_VBUS_DETECT_BIT), 0xff );
  print4("\nSlave interrupt status reg (SISR) = 0x", tempDataFromHost, " ,slave line state = 0x", tempDataFromHost2);
  printStr("\nCancel interrupts\n");
  cancelInterrupt(HOST, CONNECTION_EVENT_BIT);
  cancelInterrupt(SLAVE, SC_RESET_EVENT_BIT);

  wait(0xff); 
}


/* ------------------------------- sendTransaction ---------------------------------- */
void sendTransaction(int USBAddress, int USBEndPoint, int transType, int dataSize, int dataGenType, int waitTime, int endPControlReg, int fullSpeedRate)
{
  int i;
  int endPointStatusRegAddress;
  int endPointControlRegAddress;
  int endPointTransTypeRegAddress;
  int endPointNAKTransTypeRegAddress;
  int tempDataFromHost;
  int tempDataFromHost2;
  int fifoBaseAddress;
  int expectedTransTypeAtSlave;
  int numOfElementsInRXFifo;
  int data [LARGEST_FIFO_SIZE];
  int dataSeqeunceBit;
  int expectedDataCnt;
  int errorDetected;
  unsigned int randVal;
  
  errorDetected = 0;
  randVal = 1804;

  switch (dataGenType)
  {
    case SEQ_GEN:
      for (i=0;i<dataSize;i++)
        data[i] = i;
      break;
    case RAND_GEN:
      for (i=0;i<dataSize;i++) {
        data[i] = randVal & 0xff;
        randVal = (randVal * 123) + 765;
      }
      break;
    default:
      print3("(sendTransaction) dataGenType = 0x", dataGenType,"  not a valid type\n");
      quit(1);
      break;
  }

  dataSeqeunceBit = 0;
  switch (transType)
  {
    case SETUP_TRANS:
      printStr("SETUP");
      expectedTransTypeAtSlave = SC_SETUP_TRANS;
      break;
    case OUTDATA1_TRANS:
      dataSeqeunceBit = 1 << SC_DATA_SEQUENCE_BIT;
      printStr("OUTDATA1");
      expectedTransTypeAtSlave = SC_OUTDATA_TRANS;
      break;
    case OUTDATA0_TRANS:
      printStr("OUTDATA0");
      expectedTransTypeAtSlave = SC_OUTDATA_TRANS;
      break;
    default:
      print3("sendTransaction - Invalid transactionType 0x",transType," aborting\n");
      quit(1);

      break;
  }

  print3(" transaction, with a ", dataSize, " byte data packet\n");

  switch (USBEndPoint)
  {
    case 0:
      fifoBaseAddress = EP0_RX_FIFO_BASE;
      break;
    case 1:
      fifoBaseAddress = EP1_RX_FIFO_BASE;
      break;
    case 2:
      fifoBaseAddress = EP2_RX_FIFO_BASE;
      break;
    case 3:
      fifoBaseAddress = EP3_RX_FIFO_BASE;
      break;
    default:
      print3("Invalid endpoint ",USBEndPoint,"\n");
      quit(1);
      break;
  }

  endPointControlRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_CONTROL_REG;
  endPointStatusRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_STATUS_REG;
  endPointTransTypeRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_TRANSTYPE_STATUS_REG;
  endPointNAKTransTypeRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + NAK_TRANSTYPE_STATUS_REG;
 
  writeXCReg(SLAVE, endPControlReg, endPointControlRegAddress);
  writeXCReg(HOST, USBAddress, TX_ADDR_REG);
  writeXCReg(HOST, USBEndPoint, TX_ENDP_REG);
  writeXCReg(HOST, transType, TX_TRANS_TYPE_REG);
  for (i=0; i<dataSize; i++)
    REG8(USB_HOST_BASE + HOST_TX_FIFO_BASE + FIFO_DATA_REG) = data[i];
  if ((endPControlReg & (1 << ENDPOINT_ISO_ENABLE_BIT)) == 0)    //if not iso mode
    writeXCReg(HOST, (1 << TRANS_REQ_BIT), TX_CONTROL_REG); //then
  else
    //writeXCReg(HOST, (1 << TRANS_REQ_BIT) & (1 << ISO_ENABLE_BIT), TX_CONTROL_REG);
    writeXCReg(HOST, 0x9, TX_CONTROL_REG);
  if (fullSpeedRate == 1)
    //wait(500+dataSize*100);    //suspend test bench so that DUT can process the packet
    wait(0xff);    //suspend test bench so that DUT can process the packet
  else
    wait(20000+dataSize*4000);  //suspend test bench so that DUT can process the packet
  tempDataFromHost = readXCReg(HOST, INTERRUPT_STATUS_REG, (1 << TRANS_DONE_BIT), 0xf7); //ignore SOF sent interrupt
  expectedDataCnt = 0;
  if ( (endPControlReg & (1 << ENDPOINT_ENABLE_BIT) ) != 0) {
    if ( (endPControlReg & (1 << ENDPOINT_READY_BIT) ) != 0) {
      expectedDataCnt = dataSize;
      tempDataFromHost = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, (1 << SC_TRANS_DONE_BIT), 0xf7); //ignore SOF rxed interrupt
      tempDataFromHost = readXCReg(SLAVE, endPointTransTypeRegAddress, expectedTransTypeAtSlave, 0xff);  //expecting 'expectedTransTypeAtSlave' transaction
    }
    else {
      tempDataFromHost = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, (1 << SC_NAK_SENT_INT_BIT), 0xf7); //ignore SOF rxed interrupt
      tempDataFromHost = readXCReg(SLAVE, endPointNAKTransTypeRegAddress, expectedTransTypeAtSlave, 0xff);  //expecting 'expectedTransTypeAtSlave' transaction
    }
  }
  tempDataFromHost = REG8(USB_SLAVE_BASE + fifoBaseAddress + FIFO_DATA_COUNT_MSB);
  tempDataFromHost2 = REG8(USB_SLAVE_BASE + fifoBaseAddress + FIFO_DATA_COUNT_LSB);
  numOfElementsInRXFifo = (tempDataFromHost * 256) +  tempDataFromHost2;
  print4("Slave EndPoint ", USBEndPoint, " RX FIFO has  0x", numOfElementsInRXFifo);
  printStr(" elements\n");
  if (expectedDataCnt != numOfElementsInRXFifo) {
    print4("Data packet incorrect size. Expected 0x", expectedDataCnt, " bytes, received 0x", numOfElementsInRXFifo);
    printStr(" bytes\n");
    errorDetected = 1;
  }
  for (i=0;i<numOfElementsInRXFifo;i++) {
    tempDataFromHost = REG8(USB_SLAVE_BASE + fifoBaseAddress + FIFO_DATA_REG);
    if (tempDataFromHost != data[i]) {
      print4("Data mismatch.  TX data [0x", i, "] = 0x", data[i]);
      print4(" RX data[0x", i, "] = 0x", tempDataFromHost);
      printStr(". Aborting\n");
      errorDetected = 1;
    }
  }
  if (numOfElementsInRXFifo > 0 && errorDetected == 0)
    printStr("RX packet matches TX packet\n");

  cancelInterrupt(SLAVE, SC_TRANS_DONE_BIT);
  cancelInterrupt(SLAVE, SC_NAK_SENT_INT_BIT);
  cancelInterrupt(HOST, TRANS_DONE_BIT);
  tempDataFromHost = readXCReg(HOST, INTERRUPT_STATUS_REG, 0x00, 0xf7);

  switch (endPControlReg & 0xf)
  {
  case 0x0:  //endpoint disabled
  case 0x2:  //endpoint ready, but disabled. Not a valid control state, but disable should pre-dominate
    tempDataFromHost = readXCReg(HOST, RX_STATUS_REG, (1 << RX_TIME_OUT_BIT), 0xff);  //expecting host to receive time out
    //expecting no response from host
    break;
  case 0x1:  //endpoint enabled, but not ready
    tempDataFromHost = readXCReg(SLAVE, endPointStatusRegAddress, (1 << SC_NAK_SENT_BIT), (1 << SC_NAK_SENT_BIT));  //expecting slave to send NAK
    tempDataFromHost = readXCReg(HOST, RX_STATUS_REG, (1 << NAK_RXED_BIT), 0xff);  //expecting NAK at host

    break;
  case 0x3: //endpoint enabled, and ready
    tempDataFromHost = readXCReg(SLAVE, endPointStatusRegAddress, dataSeqeunceBit , 0xff);  //expecting no errors at the slave
    if ((endPControlReg & (1 << ENDPOINT_ISO_ENABLE_BIT)) == 0)    //if not iso mode
      tempDataFromHost = readXCReg(HOST, RX_STATUS_REG, (1 << ACK_RXED_BIT), 0xff);  //expecting host to receive ACK
    //if ENDPOINT_ISO_ENABLE_BIT == 1 then no response form slave, no need to check RX_STATUS_REG
    break;
  case 0xb: //endpoint enabled, ready, send stall.
    tempDataFromHost = readXCReg(SLAVE, endPointStatusRegAddress, (1 << SC_STALL_SENT_BIT) | dataSeqeunceBit, 0xff);  //expecting slave to send stall
    tempDataFromHost = readXCReg(HOST, RX_STATUS_REG, (1 << STALL_RXED_BIT), 0xff);  //expecting host to receive STALL
    break;
  default:
    print3("sendTransaction: Umimplemented endPControlReg 0x", USBEndPoint, "\n");
    quit(1);
    break;
  }
  if (errorDetected == 1) 
    quit(1);
}

/* ------------------------------- rxTransaction ---------------------------------- */

void rxTransaction(int USBAddress, int USBEndPoint, int transType, int dataSize, int dataGenType, int waitTime, int endPControlReg)
{
  int i;
  int endPointStatusRegAddress;
  int endPointTransTypeRegAddress;
  int endPointControlRegAddress;
  int endPointNAKTransTypeRegAddress;
  int tempDataFromHost;
  int tempDataFromHost2;
  int fifoBaseAddress;
  int expectedTransTypeAtSlave;
  int numOfElementsInRXFifo;
  int data [64];
  int dataSequenceBitAtHost;
  int expectedDataCnt;
  int errorDetected;
  unsigned int randVal;
  
  
  errorDetected = 0;
  switch (dataGenType)
  {
    case NO_GEN:
      //data payload provided by caller. Do nothing
      break;
    case SEQ_GEN:
      for (i=0;i<dataSize;i++)

        data[i] = i;
      break;
    case RAND_GEN:
      for (i=0;i<dataSize;i++) {
        data[i] = randVal & 0xff;
        randVal = (randVal * 123) + 765;
      }
      break;
    default:
      print3("(sendTransaction) dataGenType = 0x", dataGenType, " not a valid type\n");
      quit(1);
      break;
  }
  expectedTransTypeAtSlave = SC_IN_TRANS;
  print3("INDATA transaction, with a ", dataSize, " byte data packet\n");
  endPointStatusRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_STATUS_REG;
  endPointTransTypeRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_TRANSTYPE_STATUS_REG;
  endPointControlRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_CONTROL_REG;
  endPointNAKTransTypeRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + NAK_TRANSTYPE_STATUS_REG;

  writeXCReg(SLAVE, endPControlReg, endPointControlRegAddress);
  writeXCReg(HOST, USBAddress, TX_ADDR_REG);
  writeXCReg(HOST, USBEndPoint, TX_ENDP_REG);
  writeXCReg(HOST, transType, TX_TRANS_TYPE_REG);
  switch (USBEndPoint)
  {
    case 0:
      fifoBaseAddress = EP0_TX_FIFO_BASE;
      break;
    case 1:
      fifoBaseAddress = EP1_TX_FIFO_BASE;
      break;
    case 2:
      fifoBaseAddress = EP2_TX_FIFO_BASE;
      break;
    case 3:
      fifoBaseAddress = EP3_TX_FIFO_BASE;
      break;
    default:
      print3("Invalid endpoint 0x", USBEndPoint, "\n");
      quit(1);
      break;
  }

  for (i=0; i<dataSize; i++)
    REG8(USB_SLAVE_BASE + fifoBaseAddress + FIFO_DATA_REG) = data[i];
  writeXCReg(HOST, (1 << TRANS_REQ_BIT), TX_CONTROL_REG);
  wait(500+dataSize*100);   //suspend test bench so that DUT can process the packet


  expectedDataCnt = 0;
  if ( (endPControlReg & (1 << ENDPOINT_ENABLE_BIT) ) != 0) {
    if ( (endPControlReg & (1 << ENDPOINT_READY_BIT) ) != 0) {
      expectedDataCnt = dataSize;
      tempDataFromHost = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, (1 << SC_TRANS_DONE_BIT), 0xf7); //ignore SOF sent interrupt
      tempDataFromHost = readXCReg(SLAVE, endPointTransTypeRegAddress, expectedTransTypeAtSlave, 0xff);  //expecting 'expectedTransTypeAtSlave' transaction
      print3("\nGot slave trans type = ", tempDataFromHost, "\n");
    }
    else {
      tempDataFromHost = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, (1 << SC_NAK_SENT_INT_BIT), 0xf7); //ignore SOF sent interrupt
      tempDataFromHost = readXCReg(SLAVE, endPointNAKTransTypeRegAddress, expectedTransTypeAtSlave, 0xff);  //expecting 'expectedTransTypeAtSlave' transaction
    }
  }
  tempDataFromHost = readXCReg(HOST, INTERRUPT_STATUS_REG, (1 << TRANS_DONE_BIT), 0xf7); //ignore SOF sent interrup

  tempDataFromHost = REG8(USB_HOST_BASE + HOST_RX_FIFO_BASE + FIFO_DATA_COUNT_MSB);
  tempDataFromHost2 = REG8(USB_HOST_BASE + HOST_RX_FIFO_BASE + FIFO_DATA_COUNT_LSB);
  numOfElementsInRXFifo = (tempDataFromHost * 256) +  tempDataFromHost2;
  print3("Host RX FIFO has ", numOfElementsInRXFifo, " elements\n");
  if (expectedDataCnt != numOfElementsInRXFifo) {
    print4("Data packet incorrect size. Expected", expectedDataCnt, " bytes, received", numOfElementsInRXFifo);
    printStr(" bytes\n");
    errorDetected = 1;
  }
  for (i=0;i<numOfElementsInRXFifo;i++) {
    tempDataFromHost = REG8(USB_HOST_BASE + HOST_RX_FIFO_BASE + FIFO_DATA_REG);
    if (tempDataFromHost != data[i]) {
      print4("Data mismatch.  TX data [0x", i, "] = 0x", data[i]);
      print4(" RX data[0x", i, "] = 0x", tempDataFromHost);
      printStr(". Aborting\n");
      errorDetected = 1;
    }
  }

  if (numOfElementsInRXFifo > 0 && errorDetected == 0)
    printStr("RX packet matches TX packet\n");
  cancelInterrupt(SLAVE, SC_TRANS_DONE_BIT);

  cancelInterrupt(SLAVE, SC_NAK_SENT_INT_BIT);
  cancelInterrupt(HOST, TRANS_DONE_BIT);
  tempDataFromHost = readXCReg(HOST, TX_CONTROL_REG, 0, (1 << TRANS_REQ_BIT)); //check that the bit was set
  print3("TX_CONTROL_REG = 0x", tempDataFromHost, "\n");


  if (endPControlReg & (1 << ENDPOINT_OUTDATA_SEQUENCE_BIT) )
    dataSequenceBitAtHost = 1 << DATA_SEQUENCE_BIT;
  else
    dataSequenceBitAtHost = 0;
  switch (endPControlReg & 0xb)
  {
  case 0x0:  //endpoint disabled
  case 0x2:  //endpoint ready, but disabled. Not a valid control state, but disable should pre-dominate
    tempDataFromHost = readXCRegNoQuit(HOST, RX_STATUS_REG, (1 << RX_TIME_OUT_BIT), 0xff, (int *) &errorDetected);  //expecting host to receive time out
    REG8(USB_SLAVE_BASE + fifoBaseAddress + FIFO_CONTROL_REG) = 0x1;     //force the slave tx fifo empty
    break;
  case 0x1:  //endpoint enabled, but not ready
    tempDataFromHost = readXCRegNoQuit(SLAVE, endPointStatusRegAddress, (1 << SC_NAK_SENT_BIT), (1 << SC_NAK_SENT_BIT), (int *) &errorDetected);  //expecting slave to send NAK
    tempDataFromHost = readXCRegNoQuit(HOST, RX_STATUS_REG, (1 << NAK_RXED_BIT), 0xff, (int *) &errorDetected);  //expecting NAK at host
    REG8(USB_SLAVE_BASE + fifoBaseAddress + FIFO_CONTROL_REG) = 0x1;     //force the slave tx fifo empty
    break;
  case 0x3: //endpoint enabled, and ready
    tempDataFromHost = readXCRegNoQuit(SLAVE, endPointStatusRegAddress, (1 << SC_ACK_RXED_BIT) , 0xff, (int *) &errorDetected);  //expecting slave to receive ACK
    tempDataFromHost = readXCRegNoQuit(HOST, RX_STATUS_REG, dataSequenceBitAtHost, 0xff, (int *) &errorDetected);  //expecting no errors at the host
    break;
  case 0xb: //endpoint enabled, ready, send stall.
    print3("rxTransaction: Unexpected endPControlReg = 0x", endPControlReg, "\n");
    errorDetected = 1;
    break;
  default:
    print3("rxTransaction: Unimplemented endPControlReg 0x", USBEndPoint, "\n");
    errorDetected = 1;
    break;
  }
  if (errorDetected == 1)
    quit(1);
}

// ------------------------ main -----------------------------
int main (void)
{
unsigned char hostVer;
unsigned char slaveVer;
unsigned char data;
unsigned char tempDataFromHost;
unsigned char tempDataFromHost2;
unsigned int i;
unsigned int firstFrameNumMSB;
unsigned int firstFrameNumLSB;
unsigned int expectedFrameNum;
unsigned int USBAddress;
unsigned int dataPacketSize;
int fullSpeedRate;
int USBEndPoint;

  uart_init ();

  printStr("-------- usbHostSlave TestBench ---------\n");
  hostVer = REG8(USB_HOST_BASE + RA_HOST_SLAVE_VERSION);
  print4("Host Ver num = ", ((hostVer >> 4) & 0xf), ".", (hostVer & 0xf));
  slaveVer = REG8(USB_SLAVE_BASE + RA_HOST_SLAVE_VERSION);
  print4("\nSlave Ver num = ", ((slaveVer >> 4) & 0xf), ".", (slaveVer & 0xf));
  printStr("\n");

  printStr("Register write/read test...\n");
  writeXCReg(HOST, 0x18, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care
  writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //disconnect from host, full speed polarity and bit rate, direct control off, line state don't care, global enable off
  wait(2);
  tempDataFromHost = readXCReg(HOST, TX_LINE_CONTROL_REG, 0x18, 0xff);
  tempDataFromHost = readXCReg(SLAVE, SC_CONTROL_REG, 0x30, 0xff);

  printStr("Reset register test...\n");
  REG8(USB_HOST_BASE + RA_HOST_SLAVE_MODE) = 0x2; //reset host instance
  REG8(USB_SLAVE_BASE + RA_HOST_SLAVE_MODE) = 0x2; //reset slave instance
  wait(30);  //allow time for logic to reset
  tempDataFromHost = readXCReg(HOST, TX_LINE_CONTROL_REG, 0x0, 0xff);
  tempDataFromHost = readXCReg(SLAVE, SC_CONTROL_REG, 0x00, 0xff);

  //Configure usbhostslave instances as host and slave 
  writeXCReg(HOST, 0x1, HOST_SLAVE_CONTROL_BASE);  //set host mode. Not required for host only instance
  writeXCReg(HOST, 0x18, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care
  writeXCReg(SLAVE, 0x0, HOST_SLAVE_CONTROL_BASE);  //set slave mode. Not required for slave only instance
  writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //disconnect from host, full speed polarity and bit rate, direct control off, line state don't care, global enable off

  printStr("Check for VBus detect interrupt\n");
  tempDataFromHost = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, (1 << SC_VBUS_DET_INT_BIT) , (1 << SC_VBUS_DET_INT_BIT) );
  printStr("Cancel VBus detect interrupt\n");
  cancelInterrupt(SLAVE, SC_VBUS_DET_INT_BIT);

  //disconnect
  printStr("\nDisconnecting...\n");
  connection(SE0, 0xff, 0, 0, 1);     //set default line state to single ended zero, ie disconnect

#ifdef LOW_SPEED_TEST
  //connect low speed
  printStr("\nConnecting low speed...\n");
  connection(ZERO_ONE, 0xff, 1, 1, 1);     //set default line state to ZERO_ONE, ie connect low speed

  //disconnect
  printStr("\nDisconnecting...\n");
  connection(SE0, 0xff, 1, 1, 1);     //set default line state to single ended zero, ie disconnect
#endif

  //connect full speed
  printStr("\nConnecting full speed...\n");
  connection(ONE_ZERO, 0xff, 1, 1, 1);     //set default line state to ONE_ZERO, ie connect full speed

  //disconnect
  printStr("\nDisconnecting...\n");
  connection(SE0, 0xff, 1, 1, 1);     //set default line state to single ended zero, ie disconnect

  //connect full speed
  printStr("\nConnecting full speed...\n");
  connection(ONE_ZERO, 0xff, 1, 1, 1);     //set default line state to ONE_ZERO, ie connect full speed

  //host forces a reset
  printStr("\nHost forcing reset...\n");
  writeXCReg(HOST, 0x1c, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control on, line state SE0
  wait(0xff);
  tempDataFromHost = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, (1 << SC_RESET_EVENT_BIT), 0xff);
  tempDataFromHost2 = readXCReg(SLAVE, SC_LINE_STATUS_REG, (1 << SC_VBUS_DETECT_BIT) + DISCONNECT, 0xff);
  print4("\nSISR = 0x", tempDataFromHost, ", slave line state = 0x", tempDataFromHost2);

  printStr("\nCancel reset event interrupt\n");
  cancelInterrupt(SLAVE, SC_RESET_EVENT_BIT);



  //re-connect at full speed
  //writeXCReg(HOST, 0x18, TX_LINE_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care
  printStr("\nReconnecting at full speed...\n");
  connection(ONE_ZERO, 0xff, 0, 1, 1);     //set default line state to ONE_ZERO, ie connect full speed

  //slave forces a disconnect
  printStr("\nSlave forcing disconnect...\n");
  writeXCReg(SLAVE, 0x38, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control on, line state SE0, global enable off
  wait(DISCONNECT_WAIT_TIME*4+100);
  tempDataFromHost = readXCReg(HOST, INTERRUPT_STATUS_REG, (1 << CONNECTION_EVENT_BIT), 0xff);
  tempDataFromHost2 = readXCReg(HOST, RX_CONNECT_STATE_REG, DISCONNECT, 0xff);
  print4("\nHISR =  0x", tempDataFromHost, ", host line state = 0x", tempDataFromHost2);
  printStr("\nCancel host interrupt\n");
  cancelInterrupt(HOST, CONNECTION_EVENT_BIT);

  //re-connect at full speed
  writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care, global enable off
  printStr("\nReconnecting at full speed...\n");
  connection(ONE_ZERO, 0xff, 1, 1, 1);     //set default line state to ONE_ZERO, ie connect full speed


  //Enable host SOF transmission (forces a resume)
  printStr("\nEnabling host SOF transmission\n");
  writeXCReg(HOST, 0x1, TX_SOF_ENABLE_REG); //enable SOF transmission
  wait(0xfff);
  printStr("Checking for resume interrupt...\n");
  tempDataFromHost2 = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, (1 << SC_RESUME_INT_BIT), (1 << SC_RESUME_INT_BIT));  //check for resume interrupt
  print4("\nHISR =  0x", tempDataFromHost, ", SISR = 0x", tempDataFromHost2);
  cancelInterrupt(SLAVE, SC_RESUME_INT_BIT);
  printStr("\nChecking for SOF packets...\n");
  cancelInterrupt(SLAVE, SC_SOF_RECEIVED_BIT);
  for (i=0;i<=10;i++) {
    tempDataFromHost = REG8(USB_SLAVE_BASE + SCREG_BASE + SC_INTERRUPT_STATUS_REG);
    while ( tempDataFromHost == 0) {
      tempDataFromHost = REG8(USB_SLAVE_BASE + SCREG_BASE + SC_INTERRUPT_STATUS_REG);
    }
    cancelInterrupt(SLAVE, SC_SOF_RECEIVED_BIT);
    if (i == 0) {
      tempDataFromHost = readXCReg(SLAVE, SC_FRAME_NUM_MSP, ((i % 2048) / 256) , 0x00);
      tempDataFromHost2 = readXCReg(SLAVE, SC_FRAME_NUM_LSP, (i % 256), 0x00);
      firstFrameNumMSB = tempDataFromHost;
      firstFrameNumLSB = tempDataFromHost2;
    }
    else {
      expectedFrameNum = i + (firstFrameNumMSB * 256) + firstFrameNumLSB; 
      tempDataFromHost = readXCReg(SLAVE, SC_FRAME_NUM_MSP, ((expectedFrameNum % 2048) / 256) , 0xff);
      tempDataFromHost2 = readXCReg(SLAVE, SC_FRAME_NUM_LSP, (expectedFrameNum % 256), 0xff);
    } 
    //print4("\nSOF Frame count", i, " = 0x",  (tempDataFromHost * 256) + tempDataFromHost2) ;
    //tempDataFromHost = readXCReg(HOST, SOF_TIMER_MSB_REG, 0x0, 0x0);
    //printStr("\nHost SOF Timer MSB = 0x");
    //print32bit(tempDataFromHost);
  }
  printStr("Detected 10 SOFs\n");
  printStr("Passed SOF test.\n");

  printStr("\nDisabling SOF transmission\n");
  writeXCReg(HOST, 0x0, TX_SOF_ENABLE_REG); //disable SOF transmission
  wait(RESUME_LEN*4+100); //wait for last SOF to be flushed out
  printStr("\nFor slave, cancel resume interrupt, and SOF received interrupt\n");
  printStr("For host, cancel SOF sent interrupt\n");
  tempDataFromHost = readXCReg(HOST, INTERRUPT_STATUS_REG, (1 << SOF_SENT_BIT) , 0xff);
  cancelInterrupt(HOST, SOF_SENT_BIT);
  cancelInterrupt(SLAVE, SC_RESUME_INT_BIT);
  cancelInterrupt(SLAVE, SC_SOF_RECEIVED_BIT);

  //Slave forces resume
  printStr("\nSlave forcing resume...\n");
  writeXCReg(SLAVE, 0x3a, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control on, line state ZERO_ONE (full speed resume), global enable off
  wait(RESUME_WAIT_TIME*32+100);

  tempDataFromHost = readXCReg(HOST, INTERRUPT_STATUS_REG, (1 << RESUME_INT_BIT), 0xff);
  tempDataFromHost2 = readXCReg(HOST, RX_CONNECT_STATE_REG, FULL_SPEED_CONNECT, 0xff);
  print4("\nHISR = 0x", tempDataFromHost , ", host line state = 0x", tempDataFromHost2);
  printStr("\nCancel resume interrupt");
  cancelInterrupt(HOST, RESUME_INT_BIT);
  writeXCReg(SLAVE, 0x70, SC_CONTROL_REG);  //USB connect, full speed polarity and bit rate, direct control off, line state don't care, global enable off
  wait(0xff); //wait for some idle bits to be sent
  tempDataFromHost = readXCReg(HOST, RX_CONNECT_STATE_REG, FULL_SPEED_CONNECT, 0xff);
  printStr("\nResume recovery check , host line state = 0x");
  print32bit(tempDataFromHost);

  printStr("\nTransaction tests...\n");
  printStr("\nEnabling host SOF transmission\n");
  writeXCReg(HOST, 0x1, TX_SOF_ENABLE_REG); //enable SOF transmission
  wait(0xfff);
  printStr("Checking for resume interrupt...\n");
  tempDataFromHost2 = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, (1 << SC_RESUME_INT_BIT), (1 << SC_RESUME_INT_BIT));  //check for resume interrupt
  print4("\nHISR =  0x", tempDataFromHost, ", SISR = 0x", tempDataFromHost2);
  cancelInterrupt(SLAVE, SC_RESUME_INT_BIT);
  //set up some variables and pointers used for send transaction tests
  writeXCReg(SLAVE, 0x71, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care, global enable on
  fullSpeedRate = 1;
    
  for (USBAddress = 0; USBAddress <=127; USBAddress = USBAddress + 1) {
    writeXCReg(SLAVE, USBAddress, SC_ADDRESS);       //set slave usb address
    for (dataPacketSize = 1; dataPacketSize <= SMALLEST_FIFO_SIZE; dataPacketSize = dataPacketSize+1) {
      for (USBEndPoint = 0; USBEndPoint <=3; USBEndPoint++) {
        printStr("\n------------------------------------\n");
        print4("USBAddress = ", USBAddress, " USBEndPoint = ", USBEndPoint);
        printStr("\n------------------------------------\n");

        //SETUP - NAK'd
        printStr("\nNAK'd SETUP\n");
        sendTransaction(USBAddress, USBEndPoint, SETUP_TRANS, dataPacketSize, RAND_GEN, 1, (1 << ENDPOINT_ENABLE_BIT), fullSpeedRate);

        //SETUP - ACK'd
        printStr("\nACK'd SETUP\n");
        sendTransaction(USBAddress, USBEndPoint, SETUP_TRANS, dataPacketSize, RAND_GEN, 1, 0x3, fullSpeedRate);

        //SETUP - STALL'd
        printStr("\nSTALL'd SETUP\n");
        sendTransaction(USBAddress, USBEndPoint, SETUP_TRANS, dataPacketSize, SEQ_GEN, 1, 0xb, fullSpeedRate);

        //SETUP - timed out
        printStr("\nTimed out SETUP\n");
        sendTransaction(USBAddress, USBEndPoint, SETUP_TRANS, dataPacketSize, RAND_GEN, 1, 0x0, fullSpeedRate);

        //OUTDATA0 - ACK'd
        printStr("\nACK'd OUTDATA0\n");
        sendTransaction(USBAddress, USBEndPoint, OUTDATA0_TRANS, dataPacketSize, RAND_GEN, 1, 0x3, fullSpeedRate);

        //OUTDATA1 - ACK'd
        printStr("\nACK'd OUTDATA1\n");
        sendTransaction(USBAddress, USBEndPoint, OUTDATA1_TRANS, dataPacketSize, RAND_GEN, 1, 0x3, fullSpeedRate);

        //OUTDATA1 - NAK'd
        printStr("\nNAK'd OUTDATA1\n");
        sendTransaction(USBAddress, USBEndPoint, OUTDATA1_TRANS, dataPacketSize, RAND_GEN, 1, (1 << ENDPOINT_ENABLE_BIT), fullSpeedRate);

        //INDATA (DATA0) - ACK'd
        printStr("\nACK'd INDATA (DATA0)\n");
        rxTransaction(USBAddress, USBEndPoint, IN_TRANS, dataPacketSize, RAND_GEN, 1, 0x3);

        //INDATA (DATA1) - ACK'd
        printStr("\nACK'd INDATA (DATA1)\n");
        rxTransaction(USBAddress, USBEndPoint, IN_TRANS, dataPacketSize, RAND_GEN, 1, 0x7);

        //INDATA (DATA0) - NAK'd
        printStr("\nNAK'd INDATA (DATA0)\n");
        rxTransaction(USBAddress, USBEndPoint, IN_TRANS, dataPacketSize, RAND_GEN, 1, (1 << ENDPOINT_ENABLE_BIT));

        //INDATA (DATA0) - Timed out
        printStr("\nTimed out INDATA (DATA0)\n");
        rxTransaction(USBAddress, USBEndPoint, IN_TRANS, dataPacketSize, RAND_GEN, 1, 0x0);
      }
    }
  }
  while (1) {
    printStr("\n-----------------------------------------------\n");
    printStr("USBHostSlave verification completed successfully\n");
  }  
} 

