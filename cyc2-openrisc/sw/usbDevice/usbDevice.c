// ------------------------------------------------------------------
// -------------------- usbDevice.c ---------------------------------
// ------------------------------------------------------------------
#include "board.h"
#include "uart.h"
#include "usbHostSlave.h"
#include "usb.h"

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


// ====================================
// =====    DEVICE Descriptor     =====
// ====================================
unsigned char deviceDescriptor[] = {
	0x12,					//BYTE bLength
	0x01,					//BYTE bDescriptorType
	0x10,					//WORD (Lo) bcdUSB version supported
	0x01,					//WORD (Hi) bcdUSB version supported
	0x00,					//BYTE bDeviceClass
	0x00,					//BYTE bDeviceSubClass
	0x00,					//BYTE bDeviceProtocol
	MAX_RESP_SIZE,   	//BYTE bMaxPacketSize 
	0xC7,					//WORD (Lo) idVendor
	0x05,					//WORD (Hi) idVendor
	0x13,					//WORD (Lo) idProduct, For Philips Hub mouse
	0x01,					//WORD (Hi) idProduct, For Philips Hub mouse
	0x01,					//WORD (Lo) bcdDevice
	0x00,					//WORD (Hi) bcdDevice
	0x01,					//BYTE iManufacturer
	0x02,					//BYTE iProduct
	0x03,					//BYTE iSerialNumber
//	0x00,					//BYTE iManufacturer
//	0x00,					//BYTE iProduct
//	0x00,					//BYTE iSerialNumber
	0x01 					//BYTE bNumConfigurations
};
 
// ====================================
// ===== Configuration Descriptor =====
// ====================================
unsigned char configDescriptor[] = {
	// Configuration
	0x09,					//BYTE bLength (Configuration descriptor)
	0x02,					//BYTE bDescriptorType //Assigned by USB
	34,					//WORD (Lo) wTotalLength
	0x00,					//WORD (Hi) wTotalLength
	0x01,					//BYTE bNumInterfaces
	0x01,					//BYTE bConfigurationValue
	0x00,					//BYTE iConfiguration
	0xa0,					//BYTE bmAttributes, Bus powered and remote wakeup
	0x32					//BYTE MaxPower, 100mA
};
 
// ====================================
// =====   Interface Descriptor   =====
// ====================================
unsigned char interfaceDescriptor[] = {
	// Interface
	0x09,					//BYTE bLength (Interface descriptor)
	0x04,					//BYTE bDescriptionType, assigned by USB
	0x00,					//BYTE bInterfaceNumber
	0x00,					//BYTE bAlternateSetting
	0x01,					//BYTE bNumEndpoints, uses 1 endpoints
	0x03,					//BYTE bInterfaceClass, HID Class - 0x03
	0x00,					//BYTE bInterfaceSubClass, no subclass
	0x00,					//BYTE bInterfaceProtocol, none
	0x00 					//BYTE iInterface
};
 
// ====================================
// =====   HID Descriptor   =====
// ====================================
unsigned char HIDDescriptor[] = {
	// HID
	0x09,					//BYTE bLength (HID Descriptor)
	0x21,					//BYTE bDescriptorType, HID
	0x10,					//WORD (Lo) bcdHID
	0x01,					//WORD (Hi) bcdHID
	0x00,					//BYTE bCountryCode
	0x01,					//BYTE bNumDescriptors
	0x22,					//BYTE bReportDescriptorType
	0x32,					//WORD (Lo) wItemLength
	0x00					//WORD (Hi) wItemLength
};

// ====================================
// =====   Endpoint 1 Descriptor  =====
// ====================================
unsigned char ep1Descriptor[] = {
	// Endpoint
	0x07,					//BYTE bLength (Endpoint Descriptor)
	0x05,					//BYTE bDescriptorType, assigned by USB
	0x81,					//BYTE bEndpointAddress, IN endpoint, endpoint 1
	0x03,					//BYTE bmAttributes, Interrupt endpoint
	0x10,					//WORD (Lo) wMaxPacketSize
	0x00,					//WORD (Hi) wMaxPacketSize
	0xFF					//BYTE bInterval
};

// ====================================
// =====   Language ID Descriptor  =====
// ====================================
unsigned char langIDDescriptor[] = {
// Lang_ID (String0)
	0x04,					// bLength
	0x03,					// bDescriptorType = String Desc
	0x09,					// wLangID (Lo) (Lang ID for English = 0x0409)
	0x04					// wLangID (Hi) (Lang ID for English = 0x0409)
};

// ====================================
// =====   string 1 Descriptor  =====
// ====================================
unsigned char string1Descriptor[] = {
// String1
	30,						// bLength
	0x03,					// bDescriptorType = String Desc
	// Noting that text is always unicode, hence the 'padding'
	'B', 00, 'a', 00, 's', 00, 'e', 00, '2', 00,
	'D', 00, 'e', 00, 's', 00, 'i', 00, 'g', 00,
	'n', 00, 's', 00, ' ', 00, ' ', 00
};

// ====================================
// =====   string 2 Descriptor  =====
// ====================================
unsigned char string2Descriptor[] = {
// String2
	30, 					// bLength
	0x03, 					// bDescriptorType = String Desc
	// Noting that text is always unicode, hence the 'padding'
	'B', 00, '2', 00, 'D', 00, ' ', 00, 'H', 00,
	'I', 00, 'D', 00, ' ', 00, 'D', 00, 'e', 00,
   'v', 00, 'i', 00, 'c', 00, 'e', 00
};

// ====================================
// =====   string 3 Descriptor  =====
// ====================================
unsigned char string3Descriptor[] = {
// String3
	30, 					// bLength
	0x03, 					// bDescriptorType = String Desc
	// Noting that text is always unicode, hence the 'padding'
	'L', 00, 'i', 00, 'm', 00, 'i', 00, 't', 00,
	'e', 00, 'd', 00, 'E', 00, 'd', 00, 'i', 00,
	't', 00, 'i', 00, 'o', 00, 'n', 00
}; 

 
// ====================================
// =====   Report Descriptor  =====
// ====================================
unsigned char reportDescriptor[] = {
    0x05, 0x01,                    // USAGE_PAGE (Generic Desktop)
    0x09, 0x00,                    // USAGE (undefined)
    0xa1, 0x01,                    // COLLECTION (Application)
    0x09, 0x00,                    //   USAGE (Undefined)
    0xa1, 0x00,                    //   COLLECTION (Physical)
    0x05, 0x09,                    //     USAGE_PAGE (Button)
    0x19, 0x01,                    //     USAGE_MINIMUM (Button 1)
    0x29, 0x03,                    //     USAGE_MAXIMUM (Button 3)
    0x15, 0x00,                    //     LOGICAL_MINIMUM (0)
    0x25, 0x01,                    //     LOGICAL_MAXIMUM (1)
    0x95, 0x03,                    //     REPORT_COUNT (3)
    0x75, 0x01,                    //     REPORT_SIZE (1)
    0x81, 0x02,                    //     INPUT (Data,Var,Abs)
    0x95, 0x01,                    //     REPORT_COUNT (1)
    0x75, 0x05,                    //     REPORT_SIZE (5)
    0x81, 0x01,                    //     INPUT (Cnst,Var,Rel)
    0x05, 0x01,                    //     USAGE_PAGE (Generic Desktop)
    0x09, 0x30,                    //     USAGE (X)
    0x09, 0x31,                    //     USAGE (Y)
    0x15, 0x81,                    //     LOGICAL_MINIMUM (-127)
    0x25, 0x7f,                    //     LOGICAL_MAXIMUM (127)
    0x75, 0x08,                    //     REPORT_SIZE (8)
    0x95, 0x02,                    //     REPORT_COUNT (2)
    0x81, 0x06,                    //     INPUT (Data,Var,Rel)
    0xc0,                          //   END_COLLECTION
    0xc0                           // END_COLLECTION
};
 
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
void connection(int lineState, unsigned int waitTime, int hostInterruptExpected, int slaveInterruptExpected)
{
  unsigned char tempDataFromHost;
  unsigned char tempDataFromHost2;
  int expectedData;
  int expectedConnectState;



  if (lineState == ZERO_ONE) {
    expectedConnectState = LOW_SPEED_CONNECT;
    writeXCReg(SLAVE, 0x40, SC_CONTROL_REG);  //connect to host, low speed polarity and bit rate, direct control off, line state don't care, global enable off
  }
  else if (lineState == ONE_ZERO) {
    expectedConnectState = FULL_SPEED_CONNECT;
    writeXCReg(SLAVE, 0x70, SC_CONTROL_REG);  //connect to host, full speed polarity and bit rate, direct control off, line state don't care, global enable off
  }
  else {
    expectedConnectState = DISCONNECT;
    writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //disconnect from host, full speed polarity and bit rate, direct control off, line state don't care, global enable off
  }
  wait(waitTime);              //allow 'waitTime' samples to be clocked through
  if (hostInterruptExpected)
    expectedData = (1 << CONNECTION_EVENT_BIT);
  else
    expectedData = 0x0;
  if (slaveInterruptExpected)
    expectedData = (1 << SC_RESET_EVENT_BIT);
  else
    expectedData = 0x0;
  tempDataFromHost = readXCReg(SLAVE, SC_INTERRUPT_STATUS_REG, expectedData , (1 << SC_RESET_EVENT_BIT) );
  tempDataFromHost2 = readXCReg(SLAVE, SC_LINE_STATUS_REG, expectedConnectState + (1 << SC_VBUS_DETECT_BIT), 0xff );
  print4("\nSlave interrupt status reg (SISR) = 0x", tempDataFromHost, " ,slave line state = 0x", tempDataFromHost2);
  printStr("\nCancel interrupts\n");
  cancelInterrupt(SLAVE, SC_RESET_EVENT_BIT);
  wait(0xff); 
}


/* ------------------------------- startTransaction ---------------------------------- */
// For the selected endpoint:
// Load the transmit fifo, and make the endpoint ready 
void startTransaction(
  int USBEndPoint, 
  unsigned char dataSeq, //tx data seq for IN trans
  unsigned int txDataSize, 
  unsigned char txData[]  
)
{
  int i;
  int endPointControlRegAddress;
  int txFifoBaseAddress;
  unsigned char endPointControlReg;

  endPointControlRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_CONTROL_REG;
  endPointControlReg = REG8(USB_SLAVE_BASE + SCREG_BASE + endPointControlRegAddress);
  // Check to see if the last transaction has finished
  if ( (endPointControlReg & (1 << ENDPOINT_READY_BIT) ) == 0x0) { //if endpoint not ready, then start a new transaction

    switch (USBEndPoint)
    {
      case 0:
        txFifoBaseAddress = EP0_TX_FIFO_BASE;
        break;
      case 1:
        txFifoBaseAddress = EP1_TX_FIFO_BASE;
        break;
      case 2:
        txFifoBaseAddress = EP2_TX_FIFO_BASE;
        break;
      case 3:
        txFifoBaseAddress = EP3_TX_FIFO_BASE;
        break;
      default:
        print3("Invalid endpoint ",USBEndPoint,"\n");
        quit(1);
        break;
    }

    REG8(USB_SLAVE_BASE + txFifoBaseAddress + FIFO_CONTROL_REG) = 0x1; //force txFifo empty 
    //load tx data. Only used if there is a INDATA transaction expected
    for (i = 0; i < txDataSize; i++) {
      REG8(USB_SLAVE_BASE + txFifoBaseAddress + FIFO_DATA_REG) = txData[i];
    }

    //make EP ready for transaction
    if (dataSeq == 1)
      REG8(USB_SLAVE_BASE + SCREG_BASE + endPointControlRegAddress) = 0x7;
    else
      REG8(USB_SLAVE_BASE + SCREG_BASE + endPointControlRegAddress) = 0x3;
  } 
}

/* ------------------------------- endTransaction ---------------------------------- */
// For the selected endpoint: 
// Check for errors, get the transaction type, and read the RX fifo
unsigned int endTransaction(
  int USBEndPoint, 
  unsigned char *transType,
  unsigned char dataSeq, //tx data seq for IN trans, expected data seq for OUT trans
  unsigned int *rxDataSize, 
  unsigned char rxData[],
  int *transactionDone
)
{
  int i;
  int endPointStatusRegAddress;
  int endPointTransTypeRegAddress;
  unsigned char tempData1;
  unsigned char tempData2;
  int rxFifoBaseAddress;
  int numOfElementsInRXFifo;
  int errorDetected;
  unsigned char localTransType;
  int endPointControlRegAddress;
  unsigned char endPointControlReg;
  unsigned char endPointStatusReg; 

  errorDetected = 0;
  *transactionDone = 0;

  endPointStatusRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_STATUS_REG;
  endPointTransTypeRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_TRANSTYPE_STATUS_REG;
  endPointControlRegAddress = (NUM_OF_REGISTERS_PER_ENDPOINT * USBEndPoint) + ENDPOINT_CONTROL_REG;
  endPointControlReg = REG8(USB_SLAVE_BASE + SCREG_BASE + endPointControlRegAddress);
  if ( (endPointControlReg & (1 << ENDPOINT_READY_BIT) ) == 0x0) { //if endpoint not ready, then process the transaction
    *transactionDone = 1;
    switch (USBEndPoint)
    {
      case 0:
        rxFifoBaseAddress = EP0_RX_FIFO_BASE;
      break;
      case 1:
        rxFifoBaseAddress = EP1_RX_FIFO_BASE;
      break;
      case 2:
        rxFifoBaseAddress = EP2_RX_FIFO_BASE;
      break;
      case 3:
        rxFifoBaseAddress = EP3_RX_FIFO_BASE;
      break;
      default:
        print3("Invalid endpoint ",USBEndPoint,"\n");
        quit(1);
      break;
    }

    endPointStatusReg = REG8(USB_SLAVE_BASE + SCREG_BASE + endPointStatusRegAddress);
    //print3("\nEndpoint statReg = ", endPointStatusReg, "\n");
    if ( (endPointStatusReg & (1 << SC_CRC_ERROR_BIT) ) != 0x0) {
      errorDetected = 1;
      printStr("\nCRC error detected\n");
    }
    if ( (endPointStatusReg & (1 << SC_BIT_STUFF_ERROR_BIT) ) != 0x0) {
      errorDetected = 1;
      printStr("\nbit stuff error detected\n");
    }
    if ( (endPointStatusReg & (1 << SC_RX_OVERFLOW_BIT) ) != 0x0) {
      errorDetected = 1;
      printStr("\nRX overflow error detected\n");
    }
    if ( (endPointStatusReg & (1 << SC_RX_TIME_OUT_BIT) ) != 0x0) {
      errorDetected = 1;
      printStr("\nRX timeout error detected\n");
    }

    tempData1 = REG8(USB_SLAVE_BASE + rxFifoBaseAddress + FIFO_DATA_COUNT_MSB);
    tempData2 = REG8(USB_SLAVE_BASE + rxFifoBaseAddress + FIFO_DATA_COUNT_LSB);
    numOfElementsInRXFifo = (tempData1 * 256) +  tempData2;
    //print4("EP ", USBEndPoint, " RX has 0x", numOfElementsInRXFifo);
    //printStr(" bytes\n");

    //check trans type
    localTransType = REG8(USB_SLAVE_BASE + SCREG_BASE + endPointTransTypeRegAddress);
    *transType = localTransType;
    //print3("EP transTypeReg = ", localTransType, "\n");
    switch (localTransType)
    {
      case SC_SETUP_TRANS:
        //printStr("\nSETUP");
        if (numOfElementsInRXFifo != 8) {
          errorDetected = 1;
          printStr("\nError: Expecting 8 data elements\n");
        }
        else {
          for (i=0;i<numOfElementsInRXFifo;i++) {
            rxData[i] = REG8(USB_SLAVE_BASE + rxFifoBaseAddress + FIFO_DATA_REG);
            //print4("\nRX[0x", i, "]=0x", rxData[i]);
          }
        }
        break;
      case SC_OUTDATA_TRANS:
        tempData1 = REG8(USB_SLAVE_BASE + SCREG_BASE + endPointStatusRegAddress);
        //if (tempData1 & (1 << SC_DATA_SEQUENCE_BIT) != 0)  
        //  printStr("\nOUTDATA1");
        //else
        //  printStr("\nOUTDATA0");
        if ( (tempData1 & (1 << SC_DATA_SEQUENCE_BIT)) !=  (dataSeq << SC_DATA_SEQUENCE_BIT) ) {
          errorDetected = 1;
          printStr("\nERROR: data sequence error\n");
        }
        break;
      case SC_IN_TRANS:
        //printStr("\nINDATA");
        if ( (endPointStatusReg & (1 << SC_ACK_RXED_BIT) ) != (1 << SC_ACK_RXED_BIT)) {
          errorDetected = 1;
          printStr("\nERROR: no ack from host\n");
        }
        break;
      default:
        print3("sendTransaction - Invalid transactionType 0x",localTransType," aborting\n");
        quit(1);

        break;
    }
    REG8(USB_SLAVE_BASE + rxFifoBaseAddress + FIFO_CONTROL_REG) = 0x1; //force rxFifo empty 
  }
  return errorDetected;
}




// ------------------------ processEP0Transaction -----------------------------
// Process the completed transaction according to the transaction type
// Load the TX fifo for the next transaction.
void processEP0Transaction (
  unsigned char transType,
  unsigned int *txDataPacketSize,
  unsigned char txData[],
  unsigned int rxDataPacketSize,
  unsigned char rxData[],
  unsigned char *dataSeq
)
{
static unsigned int txDataCompPSize = 0;
static unsigned int txPacketRemSize = 0;
static unsigned int txPacketRemIndex = 0;
static unsigned char USBAddress = 0;
static int updateUSBAddress = 0;
static unsigned char txDataComplete[256];
static unsigned char bm_req_dir = 0;
static unsigned char bm_req_type = 0;
static unsigned char bm_req_recp = 0;
static unsigned char bRequest = 0;
static unsigned int wValue = 0;
static unsigned int wIndex = 0;
static unsigned int wLength = 0;
unsigned char wValueMSB;
unsigned char wValueLSB;
int i;
int j;

  //printStr("Processing EP0 transaction\n");


  // ---- SETUP transaction
  if (transType == SC_SETUP_TRANS) {
    *txDataPacketSize = 0; //default tx packet size
    txDataCompPSize = 0;
    txPacketRemSize = 0;
    updateUSBAddress = 0;
    bm_req_dir = (rxData[0] >> 7) & 0x1;   // 0-Host to device; 1-device to host 
    bm_req_type = (rxData[0] >> 5) & 0x3;  // 0-standard; 1-class; 2-vendor; 3-RESERVED
    bm_req_recp = rxData[0] & 0x1f;        // 0-device; 1-interface; 2-endpoint; 3-other
                                           // 4..31-reserved
    //print2("\nbm_req_dir = ", bm_req_dir);   
    //print2("\nbm_req_type = ", bm_req_type); 
    //print2("\nbm_req_recp = ", bm_req_recp); 

    bRequest =  rxData[1]; //0 - Get_Status
    //print2("\nbRequest = ", bRequest); 

    wValue = (rxData[3] << 8) |  rxData[2];
    //print2("\nwValue = ", wValue); 

    wIndex = (rxData[5] << 8) | rxData[4];
    //print2("\nwIndex = ", wIndex);

    wLength = (rxData[7] << 8) | rxData[6];
    //print2("\nwLength = ", wLength);
 
    //printStr("\n");
    *dataSeq = 1; //sending DATA1
    switch (bRequest) {
      case GET_STATUS:
        if (bm_req_type == 0x0) {
          txDataComplete[1] = 0x00;
          txDataCompPSize = 2;
          if (bm_req_recp == 0x0)
            txDataComplete[0] = 0x01;
          else
            txDataComplete[0] = 0x00;
        }
        else if (bm_req_type == 0x2) {
          txDataComplete[0] = VENDOR_DATA_LSB;
          txDataComplete[1] = VENDOR_DATA_MSB;
          txDataCompPSize = 2;
        }
      break;
      case GET_DESCRIPTOR:
        wValueMSB = (wValue >> 8) & 0xff;
        wValueLSB = wValue & 0xff;
        switch (wValueMSB) {
          case 0x0:
          break;
          case 0x1: //device descriptor
            for (i=0; i < deviceDescriptor[0]; i++)
              txDataComplete[i] = deviceDescriptor[i];
            txDataCompPSize = deviceDescriptor[0];
           break;
          case 0x2: //config descriptor
            j = 0;
            for (i=0; i < configDescriptor[0]; i++)
              txDataComplete[j++] = configDescriptor[i];
            for (i=0; i < interfaceDescriptor[0]; i++)
              txDataComplete[j++] = interfaceDescriptor[i];
            for (i=0; i < HIDDescriptor[0]; i++)
              txDataComplete[j++] = HIDDescriptor[i];
            for (i=0; i < ep1Descriptor[0]; i++)
              txDataComplete[j++] = ep1Descriptor[i];
            txDataCompPSize = j;
          break;
          case 0x3: //strng descriptor
            switch (wValueLSB & 0xf) {
              case 0x0:
                for (i=0; i < langIDDescriptor[0]; i++)
                  txDataComplete[i] = langIDDescriptor[i];
                txDataCompPSize = langIDDescriptor[0];
              break;         
              case 0x1:
                for (i=0; i < string1Descriptor[0]; i++)
                  txDataComplete[i] = string1Descriptor[i];
                txDataCompPSize = string1Descriptor[0];
              break;         
              case 0x2:
                for (i=0; i < string2Descriptor[0]; i++)
                  txDataComplete[i] = string2Descriptor[i];
                txDataCompPSize = string2Descriptor[0];
              break;         
              case 0x3:
                for (i=0; i < string3Descriptor[0]; i++)
                  txDataComplete[i] = string3Descriptor[i];
                txDataCompPSize = string3Descriptor[0];
              break; 
              default:
              break; 
            }
          break;       
          case 0x22: //report descriptor
            j = 0;
            for (i=0; i < 50; i++)
              txDataComplete[j++] = reportDescriptor[i];
            txDataCompPSize = j;
          break;
          default:
          break;
        }
      break;
      case SET_ADDRESS:
        // SET_ADRESS is different than other requests because the requested action is not 
        // completed until after the status stage. So we request the address the update here
        // then perform the address update on the next pass
        if (wValue <= 127 && wIndex == 0 && wLength == 0) {
          USBAddress = wValue;
          updateUSBAddress = 1; 
        }
      break;
      default:
      break;
    }
    if (txDataCompPSize > wLength) {
      txDataCompPSize = wLength; //limit response size to wLength
    }
    if (txDataCompPSize > MAX_RESP_SIZE) {
      for (i=0;i<MAX_RESP_SIZE;i++) {
        txData[i] = txDataComplete[i];
      }
      txPacketRemIndex = i;
      txPacketRemSize = txDataCompPSize - MAX_RESP_SIZE;
      *txDataPacketSize = MAX_RESP_SIZE;
    }
    else {
      for (i=0;i<txDataCompPSize;i++) {
        txData[i] = txDataComplete[i];
      }
      txPacketRemSize = 0;
      *txDataPacketSize = txDataCompPSize;
    }
  }



  // ---- IN transaction
  //either IN data, or IN status
  else if (transType == SC_IN_TRANS) {
    *dataSeq = 1;
    if (updateUSBAddress == 1) {
      //print3("\nReceived status ACK. New device address = \n", USBAddress, "\n");
      // Status stage has completed, so update the address now
      writeXCReg(SLAVE, USBAddress, SC_ADDRESS);
      updateUSBAddress = 0;
    }
    if (txPacketRemSize != 0) {
      if (txPacketRemSize > wLength) {
        for (i=0;i<wLength;i++) {
          txData[i] = txDataComplete[txPacketRemIndex++];
        }
        *txDataPacketSize = wLength;
        txPacketRemSize = txPacketRemSize - wLength;
      }
      else {
        for (i=0;i < txPacketRemSize;i++) {
          txData[i] = txDataComplete[txPacketRemIndex++];
        }
        *txDataPacketSize = txPacketRemSize;
        txPacketRemSize = 0;
      }          
    }         
  }



  // ---- OUT transaction
  //either OUT data, or OUT status
  else if (transType == SC_OUTDATA_TRANS) {
    *dataSeq = 1;
  }
}

// ------------------------ processHidInTransaction -----------------------------
void processHidInTransaction (
  unsigned char transType,
  unsigned int *txDataPacketSize,
  unsigned char txData[],
  unsigned char *dataSeq

)
{

  txData[0] = 0;
  txData[1] = 1; // relative X position
  txData[2] = 1; // relative Y position
  *txDataPacketSize = 0x3;
  if (*dataSeq == 0)
    *dataSeq = 1;
  else
    *dataSeq = 0;

}

// ------------------------ checkForReset -----------------------------
void checkForReset (void)
{
unsigned char tempData1;

  // check for reset
  tempData1 =  REG8(USB_SLAVE_BASE + RA_SC_INTERRUPT_STATUS_REG);
  if ( (tempData1 & (1 << SC_RESET_EVENT_BIT) ) != 0) { //detect reset event
    cancelInterrupt(SLAVE, SC_RESET_EVENT_BIT);         //cancel interrupt
    tempData1 = readXCReg(SLAVE, SC_LINE_STATUS_REG, 0x00, 0x00 );  //check for reset state
    if ((tempData1 && 0x3) == DISCONNECT) {             //if reset state
      REG8(USB_SLAVE_BASE + RA_HOST_SLAVE_MODE) = 0x2;  //then reset slave instance
      wait(30);                                         //allow time for logic to reset
      printStr("\nRe-connecting full speed...\n");         //re-connect
      connection(ONE_ZERO, 0xff, 1, 1);     //set default line state to ONE_ZERO, ie connect full speed
      writeXCReg(SLAVE, 0x71, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care, global enable on
    }
  }   
}

// ------------------------ usbInit -----------------------------
void usbInit (void)
{
unsigned char tempData1;
unsigned char slaveVer;

  printStr("-------- usbDevice ---------\n");
  slaveVer = REG8(USB_SLAVE_BASE + RA_HOST_SLAVE_VERSION);
  print4("\nSlave Ver num = ", ((slaveVer >> 4) & 0xf), ".", (slaveVer & 0xf));
  printStr("\n");

  printStr("Register write/read test...\n");
  writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //disconnect from host, full speed polarity and bit rate, direct control off, line state don't care, global enable off
  wait(2);
  tempData1 = readXCReg(SLAVE, SC_CONTROL_REG, 0x30, 0xff);

  printStr("Reset register test...\n");
  REG8(USB_SLAVE_BASE + RA_HOST_SLAVE_MODE) = 0x2; //reset slave instance
  wait(30);  //allow time for logic to reset
  tempData1 = readXCReg(SLAVE, SC_CONTROL_REG, 0x00, 0xff);

  //Configure usbhostslave instances as host and slave 
  writeXCReg(SLAVE, 0x0, HOST_SLAVE_CONTROL_BASE);  //set slave mode. Not required for slave only instance
  writeXCReg(SLAVE, 0x30, SC_CONTROL_REG);  //disconnect from host, full speed polarity and bit rate, direct control off, line state don't care, global enable off

  //Wait for VBus. Cannot activate pull up (ie connect) until VBus is detected
  tempData1 = readXCReg(SLAVE, SC_LINE_STATUS_REG, 0x00, 0x00 ); //check for vbus
  if ( (tempData1 & (1 << SC_VBUS_DETECT_BIT)) == 0) { //if vbus not present, then wait
    printStr("Wait for VBus detect interrupt\n");
    do {
      tempData1 =  REG8(USB_SLAVE_BASE + RA_SC_INTERRUPT_STATUS_REG);
    } while ( (tempData1 & (1 << SC_VBUS_DET_INT_BIT) ) == 0);
    printStr("Cancel VBus detect interrupt\n");
    cancelInterrupt(SLAVE, SC_VBUS_DET_INT_BIT);
  }

  //connect full speed
  printStr("\nConnecting full speed...\n");
  connection(ONE_ZERO, 0xff, 1, 1);     //set default line state to ONE_ZERO, ie connect full speed


  printStr("\nEnumerate...\n");
  cancelInterrupt(SLAVE, SC_RESUME_INT_BIT);
  //set up some variables and pointers used for send transaction tests
  writeXCReg(SLAVE, 0x71, SC_CONTROL_REG);  //full speed polarity and bit rate, direct control off, line state don't care, global enable on

}

// ------------------------ main -----------------------------
int main (void)
{
unsigned int rxDataPacketSizeEP0;
unsigned int rxDataPacketSizeEP1;
unsigned int txDataPacketSizeEP0;
unsigned int txDataPacketSizeEP1;
unsigned char txDataEP0[64];
unsigned char txDataEP1[64];
unsigned char rxDataEP0[64];
unsigned char rxDataEP1[64];
unsigned char transTypeEP0;
unsigned char transTypeEP1;
unsigned int transErrorEP0;
unsigned int transErrorEP1;
unsigned char dataSeqEP0;
unsigned char dataSeqEP1;
int transactionDoneEP0;
int transactionDoneEP1;
int firstPass;

  uart_init ();
  usbInit();

  txDataPacketSizeEP0 = 0; 
  dataSeqEP0 = 1;
  transactionDoneEP0 = 0;
  dataSeqEP1 = 1;
  transactionDoneEP1 = 0;
  firstPass = 1;
  processHidInTransaction (
    transTypeEP1,
    &txDataPacketSizeEP1,
    &txDataEP1[0],
    &dataSeqEP1
  );

  while (1) {
    checkForReset();
    // --- Endpoint 0
    if (transactionDoneEP0 == 1 || firstPass == 1)
      startTransaction(
        0,
        dataSeqEP0, 
        txDataPacketSizeEP0,
        &txDataEP0[0]
      );

    transErrorEP0 = endTransaction(
      0,
      &transTypeEP0,
      dataSeqEP0, 
      &rxDataPacketSizeEP0,
      &rxDataEP0[0],
      &transactionDoneEP0
    );


    if (transErrorEP0 == 0 && transactionDoneEP0 == 1)
      processEP0Transaction (
        transTypeEP0,
        &txDataPacketSizeEP0,
        &txDataEP0[0],
        rxDataPacketSizeEP0,
        &rxDataEP0[0],
        &dataSeqEP0
      );

    // --- Endpoint 1
    if (transactionDoneEP1 == 1 || firstPass == 1)
      startTransaction(
        1,
        dataSeqEP1, 
        txDataPacketSizeEP1,
        &txDataEP1[0]
      );

    transErrorEP1 = endTransaction(
      1,
      &transTypeEP1,
      dataSeqEP1, 
      &rxDataPacketSizeEP1,
      &rxDataEP1[0],
      &transactionDoneEP1
    );

    if (transErrorEP1 == 0 && transactionDoneEP1 == 1)
      processHidInTransaction (
        transTypeEP1,
        &txDataPacketSizeEP1,
        &txDataEP1[0],
        &dataSeqEP1
      );

    firstPass = 0;

  }
} 

