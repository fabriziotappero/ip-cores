/* GECKO3COM
 *
 * Copyright (C) 2008 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Berne University of Applied Sciences
 *  |  _ <'|  _) |  _  |   School of Engineering and
 *  | (_) )| |   | | | |   Information Technology
 *  (____/'(_)   (_) (_)
 *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details. 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*********************************************************************/
/** \file     usb_tmc.h
 *********************************************************************
 * \brief     header file for the USB Test and Measurement Class (TMC)
 *            functions.
 *
 *            According to USBTMC Specification Revision 1.0 and
 *            USBTMC-USB488 Subclass Specification Revision 1.0.
 *
 * \author    Christoph Zimmermann bfh.ch, Eldo José dos Santos
 * \date      2009-02-04
 *
*/

#ifndef _USBTMC_H_
#define _USBTMC_H_

/** length of the buffer to hold the response messages to be sent to the host */
#define TMC_RESPONSE_QUEUE_LENGTH 256  

/*****************************************************************************/
/* definitions, data structures and related stuff 
 * according to USBTMC standard */

#define USB_TMC_HEADER_SIZE 12  /**< length of a USBTMC header */


/* USBTMC MsgID. Values, Ref.: Table 2 */
#define DEV_DEP_MSG_OUT             1   /**< device dependent command message */
#define REQUEST_DEV_DEP_MSG_IN      2   /**< command message that requests the 
					   device to send a USBTMC response */
#define DEV_DEP_MSG_IN              2   /**< response message to the 
					   REQUEST_DEV_DEP_MSG_IN */
#define VENDOR_SPECIFIC_OUT         126 /**< vendor specific command message */
#define REQUEST_VENDOR_SPECIFIC_IN  127 /**< command message that requests the
					   device to send a vendor specific 
					   USBTMC response */
#define VENDOR_SPECIFIC_IN          127 /**< response message to the 
					   REQUEST_VENDOR_SPECIFIC_IN */


/* format of bmRequestType byte */
#define	bmRT_TMC_OUT   0x21		
#define	bmRT_TMC_IN    0xA1
 

/* USBTMC commands (bRequest values, Ref.: Table 15) */
#define INITIATE_ABORT_BULK_OUT      1
#define CHECK_ABORT_BULK_OUT_STATUS  2
#define INITIATE_ABORT_BULK_IN       3
#define CHECK_ABORT_BULK_IN_STATUS   4
#define INITIATE_CLEAR               5
#define CHECK_CLEAR_STATUS           6
#define GET_CAPABILITIES             7
#define INDICATOR_PULSE              64

/* USBTMC USB488 Subclass commands (bRequest values, Ref.: Table 9) */
#define READ_STATUS_BYTE             128
#define REN_CONTROL                  160
#define GO_TO_LOCAL                  161
#define LOCAL_LOCKOUT                162

/* bmTransfer attributes */
#define bmTA_EOM       0x01  /**< bmTransfer Attribute: End of Message */
#define bmTA_TERMCHAR  0x02  /**< bmTransfer Attribute: Terminate transfer with Terminate Character */

/** \brief status values according to USBTMC specificaton, Ref.: Table 16 */
typedef enum {
        TMC_STATUS_SUCCESS                   = 0x01,
	TMC_STATUS_PENDING                   = 0x02,

	/* USB488 defined USBTMC status values */
	TMC_STATUS_INTERRUPT_IN_BUSY         = 0x20,

	TMC_STATUS_FAILED                    = 0x80,
	TMC_STATUS_TRANSFER_NOT_IN_PROGRESS  = 0x81,
	TMC_STATUS_SPLIT_NOT_IN_PROGRESS     = 0x82,
	TMC_STATUS_SPLIT_IN_PROGRESS         = 0x83,
} TMC_Status;

/* defines for the device capablilities, Ref.: Table 37 and Table 8 USB488 */
#define HAS_INDICATOR_PULSE 0x04
#define TALK_ONLY       0x02
#define LISTEN_ONLY     0x01
#define TERMCHAR_BULKIN 0x01
#define IS_488_2        0x04
#define ACCEPTS_LOCAL_LOCKOUT 0x02
#define TRIGGER         0x01
#define SCPI_COMPILIANT 0x08
#define SR1_CAPABLE     0x04
#define RL1_CAPABLE     0x02
#define DT1_CAPABLE     0x01

/** \brief Structure to handle get_capabilities command. 
 * 
 *  contains all required parameters for a correct device specification */
typedef struct {
  uint8_t USBTMC_status;
  uint8_t reserved0;
  uint8_t bcdUSBTMC_lsb;
  uint8_t bcdUSBTMC_msb;
  uint8_t TMCInterface;
  uint8_t TMCDevice;
  uint8_t reserved1[6];
  /* place here USB488 subclass capabilities */
  uint8_t bcdUSB488_lsb;
  uint8_t bcdUSB488_msb;
  uint8_t USB488Interface;
  uint8_t USB488Device;
  uint8_t reserved2[8];
} USB_TMC_Capabilities;

/* Structure to handle Bulk-OUT Header for a DEV_DEP_MSG
 *
 * Ref.: Table 3 or Bulk-IN Header for a DEV_DEP_MSG, Ref.: Table 9 */
typedef struct
{
	uint32_t TransferSize;
	int8_t   bmTransferAttributes;
	int8_t   Reserved[3];
} DEV_DEP_MSG_OUT_Header, /**< Bulk-OUT Header for a DEV_DEP_MSG, 
			    Ref.: Table 3 */ 
  DEV_DEP_MSG_IN_Header;  /**< Bulk-IN Header for a DEV_DEP_MSG, 
			     Ref.: Table 9 */

/** \brief Structure to handle USBTMC device dependent message IN requests. 
 *
 *  Ref.: Table 4 */
typedef struct
{
	uint32_t TransferSize;
	int8_t   bmTransferAttributes;
	int8_t   TermChar;
	int8_t   Reserved[2];
} REQUEST_DEV_DEP_MSG_IN_Header; /* Ref.: Table 4 */

/* \brief structure to handle vendor specific IN/OUT or REQUESTS according 
 *  to USBTMC */
typedef struct
{                
	uint32_t TransferSize;
	int8_t   Reserved[4];
} VENDOR_SPECIFIC_OUT_Header, /**< structure to handle vendor specific 
			       *IN/OUT or REQUESTS according to Ref.: Table 5 */
  REQUEST_VENDOR_SPECIFIC_IN_Header, /**< structure to handle vendor 
				      * specific IN/OUT or REQUESTS according 
				      * Ref.: Table 6 */
  VENDOR_SPECIFIC_IN_Header; /**< structure to handle vendor specific 
			      * IN/OUT or REQUESTS according Ref.: Table 10 */

/** \brief general Header structure for USBTMC bulk messages. The MsgID value 
 *  determines the type of the msg_specific part of these structure */
typedef struct _tHeader
{
	int8_t MsgID; /**< The MsgID value determines the type of the 
		       * msg_specific part of these structure */
	int8_t bTag;
	int8_t bTagInverse;
	int8_t Reserved;
	int8_t msg_specific[8];

} BulkOUT_Header, /**< \brief According to USBTMC Ref.: Table 1 */
  BulkIN_Header,  /**< \brief According to USBTMC Ref.: Table 8 */
  tHeader; /**< \brief general Header structure for USBTMC bulk messages. */


/*****************************************************************************/
/* IEEE488 related stuff */

#define bmPOWER_ON                0x80
#define bmUSER_REQUEST            0x40
#define bmCOMMAND_ERROR           0x20
#define bmEXECUTION_ERROR         0x10
#define bmDEVICEDEPENDENT_ERROR   0x08
#define bmQUERY_ERROR             0x04
#define bmREQUEST_CONTROL         0x02
#define bmOPERATION_COMPLETE      0x01

/** \brief struct that contains all registers needed for the IEEE488.2 
 *  compiliant status reporting */
typedef struct {
        uint8_t EventStatusRegister;
        uint8_t EventStatusEnable;
        uint8_t StatusByteRegister;
        uint8_t ServiceRequestEnable;
        uint8_t OPC_Received;
} IEEE488_status_registers;


/*****************************************************************************/
/* internal definitions and typedef's needed for this implementation */

#define NEWTRANSFER 1

/** \brief Internal state of tmc system.
 *
 *  used by this implementation, no reference in standard */
typedef enum {
        TMC_STATE_IDLE = 0x01,
	TMC_STATE_OUT_TRANSFER = 0x02,
	TMC_STATE_IN_TRANSFER = 0x03,
	TMC_STATE_ABORTING_OUT = 0x04,
	TMC_STATE_ABORTING_IN = 0x05,
	TMC_STATE_HALT = 0x06,
} TMC_State;

/** \brief struct to hold all usb tmc transfer relevant information */
typedef struct {
  uint8_t bTag; /**< contains the bTag value of the currently active transfer */
  uint32_t transfer_size;
  uint8_t new_transfer; /**< flag to signal the start of a new transfer, 
			   else 0 */
  uint32_t nbytes_rxd; /**< contains the number of bytes received in active 
			  tmc OUT transfer */
  uint32_t nbytes_txd; /**< contains the number of bytes transmitted in active 
			  tmc IN transfer */

} TMC_Transfer_Info;


/** \brief response queue to hold the data for requests */
typedef struct {
  unsigned char buf[TMC_RESPONSE_QUEUE_LENGTH]; /**< message buffer */
  uint16_t length;  /**< length of message. is 0 when no message is available */
} TMC_Response_Queue;


/* Global variables */
extern volatile static TMC_Status usb_tmc_status;       /**< Global variable 
contains the status of the last tmc operation. normally USB_TMC_SUCCESS */
extern volatile TMC_State usb_tmc_state;         /**< Global variable contains 
the state of the tmc system. Example USB_TMC_IDLE or USB_TMC_IN_TRANSFER */
extern volatile idata TMC_Transfer_Info usb_tmc_transfer; /**< Global struct 
to hold all usb tmc transfer relevant information */    
extern volatile idata IEEE488_status_registers ieee488_status;   /**< Struct 
that contains all status and enable registers for the IEEE488 status reporting 
capabilities */


/** Makro to check if this setup package is a USBTMC request */
#define usb_tmc_request() ((wIndexL == USB_TMC_INTERFACE && \
			    (bRequestType & bmRT_RECIP_INTERFACE) == bmRT_RECIP_INTERFACE) \
			   ||						\
			   (wIndexL == USB_TMC_EP_OUT && \
			    (bRequestType & bmRT_RECIP_ENDPOINT) == bmRT_RECIP_ENDPOINT) \
			   ||						\
			   (wIndexL == (bmRT_DIR_IN | USB_TMC_EP_IN) && \
			    (bRequestType & bmRT_RECIP_ENDPOINT) == bmRT_RECIP_ENDPOINT) \
			  )

/** \brief general function to handle the TMC requests. 
 *
 *  Parses the TMC header to provide needed information to the 
 *  following message parser.
 *  \return returns non-zero if it handled the command successfully.
 */
uint8_t usb_handle_tmc_packet (void);


/** \brief clears all global variables to known states. sets the POWER_ON bit */
void init_usb_tmc();

/** set the mav bit (Message available or "Queue not empty") in the IEEE488 
    status structure */
#define IEEE488_set_mav() (ieee488_status.StatusByteRegister |= 0x10)

/** clear the mav bit (Message available or "Queue not empty") in the IEEE488 
    status structure */
#define IEEE488_clear_mav() (ieee488_status.StatusByteRegister &= 0xEF)

/** \brief evalutates the status IEEE488 status byte. represents the current 
 *         device state
 * 
 * executes the process to evaluate the current state of the status byte 
 * according to the IEEE488.2 standard status reporting capabilities. 
 * Reference: IEC60488-2:2004 figure 4-1
 *
 * \param[in] *status pointer to a IEEE488_status_registers struct. 
 *            Status byte in the struct is updated
 * \return return value is the current value of the status byte
 */
uint8_t IEEE488_status_query(idata IEEE488_status_registers *status);

#endif /* _USBTMC_H_ */
