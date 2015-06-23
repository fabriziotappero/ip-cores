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
/** \file     usb_tmc.c
 *********************************************************************
 * \brief     The USB Test and Measurement Class (TMC) functions.
 *
 * \author    Christoph Zimmermann bfh.ch
 * \date      2009-02-04
 *
*/

#include <stdint.h>

#include "fx2regs.h"
#include "isr.h"
#include "usb_requests.h"
#include "usb_descriptors.h"
#include "usb_tmc.h"
#include "debugprint.h"

/* GECKO3COM specific includes */
#include "gecko3com_common.h"
#include "gecko3com_interfaces.h"
#include "gecko3com_gpif.h"
#include "fpga_load.h"


volatile static TMC_Status usb_tmc_status; 
volatile TMC_State usb_tmc_state;
volatile idata TMC_Transfer_Info usb_tmc_transfer; 

volatile idata IEEE488_status_registers ieee488_status;

/** This constant contains the device capabilities according to the TMC specification, Ref.: Table 37 */
volatile const USB_TMC_Capabilities USB_TMC_CAPABILITIES = {
  TMC_STATUS_SUCCESS,
      0,
      0x00,   /* BCD version number of TMC specification, 1.00 */
      0x01,
      HAS_INDICATOR_PULSE,
      0,
	{0,0,0,0,0,0},
    /* place here USB488 subclass capabilities */
    0x00,  /* BCD version number of USB488 specification, 1.00 */
      0x01,
      0,
      0,
	{0,0,0,0,0,0,0,0}
};

void init_usb_tmc(){
  usb_tmc_transfer.bTag = 0;
  usb_tmc_transfer.transfer_size = 0;
  usb_tmc_transfer.new_transfer = 0;
  usb_tmc_transfer.nbytes_rxd = 0;
  usb_tmc_transfer.nbytes_txd = 0;

  usb_tmc_status = TMC_STATUS_SUCCESS;
  usb_tmc_state = TMC_STATE_IDLE;

  ieee488_status.EventStatusRegister = bmPOWER_ON;
  ieee488_status.EventStatusEnable = 0;
  ieee488_status.StatusByteRegister = 0;
  ieee488_status.ServiceRequestEnable = 0;
}

uint8_t IEEE488_status_query(idata IEEE488_status_registers *status){

  uint8_t local_status, local_enable;

  local_status = status->EventStatusRegister;
  local_enable =  status->EventStatusEnable;

  if(local_status & local_enable)
    local_status |= 0x20; /* set the ESB bit */
  else
    local_status &= !0xDF;

  status->EventStatusRegister = local_status;

  local_status = status->StatusByteRegister;
  local_enable = status->ServiceRequestEnable;

  if((local_status &= 0xBF) & (local_enable & 0xBF)) {
    local_status |= 0x40; /* set the MSS bit */
    status->StatusByteRegister = local_status;
  }

  return local_status;
}

uint8_t usb_handle_tmc_packet (void){

  if ((bRequestType & bmRT_DIR_MASK) == bmRT_DIR_IN){
    /*********************************
     *    handle the TMC IN requests
     ********************************/

    switch (bRequest){
      
    case INITIATE_ABORT_BULK_OUT:
      /* --------------------------------------------------------------------*/
      /* abort GECKO3COM specific stuff */
      if( flLOCAL == GECKO3COM_REMOTE) {
	usb_tmc_status = TMC_STATUS_SUCCESS;
	usb_tmc_state = TMC_STATE_IDLE;
	abort_gpif();
      }
      
      /* check if the active transfer has the requested bTag value */
      else if(usb_tmc_transfer.bTag == wValueL) {
	usb_tmc_status = TMC_STATUS_SUCCESS;
	usb_tmc_state = TMC_STATE_IDLE;
	
	/* reset OUT FIFOs */
	FIFORESET = bmNAKALL;	                 SYNCDELAY;
	FIFORESET = bmNAKALL | USB_TMC_EP_OUT;   SYNCDELAY;

	/* because we use quad buffering we have to flush all for buffers */
	OUTPKTEND = bmSKIP | USB_TMC_EP_OUT;       SYNCDELAY; 
	OUTPKTEND = bmSKIP | USB_TMC_EP_OUT;       SYNCDELAY;
	OUTPKTEND = bmSKIP | USB_TMC_EP_OUT;       SYNCDELAY;
	OUTPKTEND = bmSKIP | USB_TMC_EP_OUT;       SYNCDELAY;

	FIFORESET = 0;		    SYNCDELAY;
      }
      
      else {
	usb_tmc_status = TMC_STATUS_TRANSFER_NOT_IN_PROGRESS;
      }

      EP0BUF[0] = usb_tmc_status;
      EP0BUF[1] = usb_tmc_transfer.bTag;
      EP0BCH = 0;
      EP0BCL = 2;     
      break;

    case CHECK_ABORT_BULK_OUT_STATUS:
      /* send number of transmitted bytes */ 
      usb_tmc_status = TMC_STATUS_SUCCESS;
      EP0BUF[0] = usb_tmc_status;
      EP0BUF[1] = 0;
      EP0BUF[2] = 0;
      EP0BUF[3] = 0;
      EP0BUF[4] = (usb_tmc_transfer.nbytes_rxd & 0x0000FF);
      EP0BUF[5] = (usb_tmc_transfer.nbytes_rxd & 0x00FF00)>>8;
      EP0BUF[6] = (usb_tmc_transfer.nbytes_rxd & 0xFF0000)>>16;
      EP0BUF[7] = usb_tmc_transfer.nbytes_rxd >>24;
      EP0BCH = 0;
      EP0BCL = 8;
      break;
      
    case INITIATE_ABORT_BULK_IN:
      /* --------------------------------------------------------------------*/
      /* abort GECKO3COM specific stuff */
      if( flLOCAL == GECKO3COM_REMOTE) {
	usb_tmc_status = TMC_STATUS_SUCCESS;
	usb_tmc_state = TMC_STATE_IDLE;
	
	abort_gpif();
	
	/* reset IN FIFOs */
	FIFORESET = bmNAKALL;	                SYNCDELAY;
	FIFORESET = bmNAKALL | USB_TMC_EP_IN;   SYNCDELAY;

	INPKTEND = bmSKIP | USB_TMC_EP_IN;      SYNCDELAY; 
	INPKTEND = bmSKIP | USB_TMC_EP_IN;      SYNCDELAY; 
	INPKTEND = bmSKIP | USB_TMC_EP_IN;      SYNCDELAY; 
	INPKTEND = bmSKIP | USB_TMC_EP_IN;      SYNCDELAY; 

	FIFORESET = 0;		    SYNCDELAY;

      }

      /* check if the active transfer has the requested bTag value */
      else if(usb_tmc_transfer.bTag == wValueL) {
	usb_tmc_status = TMC_STATUS_SUCCESS;
	usb_tmc_state = TMC_STATE_IDLE;
	IEEE488_clear_mav();
      }

      else {
	usb_tmc_status = TMC_STATUS_TRANSFER_NOT_IN_PROGRESS;
      }

      EP0BUF[0] = usb_tmc_status;
      EP0BUF[1] = wValueL;
      EP0BCH = 0;
      EP0BCL = 2;
      break;

    case CHECK_ABORT_BULK_IN_STATUS:
      /* send number of transmitted bytes */ 
      usb_tmc_status = TMC_STATUS_SUCCESS;
      EP0BUF[0] = usb_tmc_status;
      EP0BUF[1] = 0;
      EP0BUF[2] = 0;
      EP0BUF[3] = 0;
      EP0BUF[4] = (usb_tmc_transfer.nbytes_txd & 0x0000FF);
      EP0BUF[5] = (usb_tmc_transfer.nbytes_txd & 0x00FF00)>>8;
      EP0BUF[6] = (usb_tmc_transfer.nbytes_txd & 0xFF0000)>>16;
      EP0BUF[7] = usb_tmc_transfer.nbytes_txd >>24;
      EP0BCH = 0;
      EP0BCL = 8;
      break;
      
    case INITIATE_CLEAR:
      usb_tmc_status = TMC_STATUS_SUCCESS;
      usb_tmc_state = TMC_STATE_IDLE;
      IEEE488_clear_mav();

      /* --------------------------------------------------------------------*/
      /* abort GECKO3COM specific stuff */
      if( flLOCAL == GECKO3COM_REMOTE) {
	deactivate_gpif();
	flLOCAL = GECKO3COM_LOCAL;

	/* configure the fpga interface for configuration */
	init_fpga_interface();
      }
      
      /* --------------------------------------------------------------------*/


      /* reset FIFOs */
      FIFORESET = bmNAKALL;	               SYNCDELAY;
      FIFORESET = bmNAKALL | USB_TMC_EP_OUT;   SYNCDELAY;
      FIFORESET = bmNAKALL | USB_TMC_EP_IN;    SYNCDELAY;

      /* because we use quad buffering we have to flush all for buffers */
      OUTPKTEND = bmSKIP | USB_TMC_EP_OUT;       SYNCDELAY; 
      OUTPKTEND = bmSKIP | USB_TMC_EP_OUT;       SYNCDELAY;
      OUTPKTEND = bmSKIP | USB_TMC_EP_OUT;       SYNCDELAY;
      OUTPKTEND = bmSKIP | USB_TMC_EP_OUT;       SYNCDELAY;

      INPKTEND = bmSKIP | USB_TMC_EP_IN;      SYNCDELAY; 
      INPKTEND = bmSKIP | USB_TMC_EP_IN;      SYNCDELAY; 
      INPKTEND = bmSKIP | USB_TMC_EP_IN;      SYNCDELAY; 
      INPKTEND = bmSKIP | USB_TMC_EP_IN;      SYNCDELAY; 

      FIFORESET = 0;		    SYNCDELAY;

      EP2CS &= ~bmEPSTALL;
      EP6CS &= ~bmEPSTALL;
      
      EP0BUF[0] = usb_tmc_status;
      EP0BCH = 0;
      EP0BCL = 1;

      break;

    case CHECK_CLEAR_STATUS:
      usb_tmc_status = TMC_STATUS_SUCCESS;
      EP0BUF[0] = usb_tmc_status;
      EP0BUF[1] = 0; /* no queued data in bulk-in buffer */
      
      EP0BCH = 0;
      EP0BCL = 2;
      break;

    case GET_CAPABILITIES:
      usb_tmc_status = TMC_STATUS_SUCCESS;
      {
	uint8_t i = 0;
	//code char *local_capabilities = &((code char)USB_TMC_CAPABILITIES);
	for(i;i<0x18;i++){
	  //EP0BUF[i] = (&(code char)USB_TMC_CAPABILITIES)[i];
	  //EP0BUF[i] = local_capabilities[i];
	  EP0BUF[i] = (&(code unsigned char)USB_TMC_CAPABILITIES)[i];
	}
	EP0BCH = 0;
	EP0BCL = 0x18;
      }
      break;

    case INDICATOR_PULSE:
      /* GECKO3COM spcific command to set external LED */
      set_led_ext(ORANGE);
      usb_tmc_status = TMC_STATUS_SUCCESS;
      EP0BUF[0] = usb_tmc_status;
      EP0BCH = 0;
      EP0BCL = 1;
      break;

    /* USB488 subclass commands */  
    case READ_STATUS_BYTE:
      usb_tmc_status = TMC_STATUS_SUCCESS;
      EP0BUF[0] = usb_tmc_status;
      EP0BUF[1] = wValueL;
      EP0BUF[2] = IEEE488_status_query(&ieee488_status);
      EP0BCH = 0;
      EP0BCL = 3;
      break;

    case REN_CONTROL:
      /* optional command, not implemented */
      break;

    case GO_TO_LOCAL:
      /* optional command, not implemented */
      return 0;
      break;

    case LOCAL_LOCKOUT:
      /* optional command, not implemented */
      return 0;
      break;

    default:
      return 0;
    }
  }

  else if ((bRequestType & bmRT_DIR_MASK) == bmRT_DIR_OUT){

    /***********************************
     *    handle the TMC OUT requests
     **********************************/

    switch (bRequest){

    default:
      usb_tmc_status = TMC_STATUS_FAILED;
      return 0; 
    }
  }
  else
    return 0;    /* invalid bRequestType */

  return 1;
}
