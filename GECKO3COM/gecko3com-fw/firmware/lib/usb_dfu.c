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

//#define USB_DFU_SUPPORT

#include <stdint.h>
#include "fx2regs.h"
#include "isr.h"
#include "usb_requests.h"
#include "usb_common.h"
#include "usb_dfu.h"
#include "debugprint.h"

volatile uint8_t  usb_dfu_status = DFU_STATUS_OK;
volatile enum dfu_state usb_dfu_state = DFU_STATE_appIDLE;
volatile uint8_t usb_dfu_timeout = DFU_TIMEOUT;

uint8_t usb_handle_dfu_packet (void)
{
  if ((bRequestType & bmRT_DIR_MASK) == bmRT_DIR_IN){
    /*********************************
     *    handle the DFU IN requests
     ********************************/

    switch (bRequest){
      
    case DFU_UPLOAD:
      usb_dfu_status == DFU_STATUS_errSTALLEDPKT;
      return 0;
      break;

    case DFU_GETSTATUS:
      EP0BUF[0] = usb_dfu_status;
      EP0BUF[1] = 0;
      EP0BUF[2] = 0;
      EP0BUF[3] = 0xff;
      EP0BUF[4] = usb_dfu_state;
      EP0BUF[5] = 0;
      EP0BCH = 0;
      EP0BCL = 6;
      break;
      
    case DFU_GETSTATE:
      EP0BUF[0] = usb_dfu_state;
      EP0BCH = 0;
      EP0BCL = 1;
      break;
      
    default:
      return 0;
    }
  }

  else if ((bRequestType & bmRT_DIR_MASK) == bmRT_DIR_OUT){

    /***********************************
     *    handle the DFU OUT requests
     **********************************/

    switch (bRequest){
    case DFU_DETACH:
      if(usb_dfu_state == DFU_STATE_appIDLE){
	usb_toggle_dfu_handlers();
	usb_dfu_state = DFU_STATE_appDETACH;
	usb_dfu_timeout = DFU_TIMEOUT;

	/* FIXME start watchdog for usb reset */
      }
      else {
	usb_dfu_status = DFU_STATUS_errSTALLEDPKT;
	return 0;
      }
      break;
      
    case DFU_DNLOAD:
      if((usb_dfu_state == DFU_STATE_dfuIDLE ||
	  usb_dfu_state == DFU_STATE_dfuDNLOAD_IDLE) &&
	 wLengthL > 0){
	if(!app_firmware_write()){
	  usb_dfu_status = DFU_STATUS_errWRITE;
	  usb_dfu_state = DFU_STATE_dfuERROR;
	  return 0;
	}
	usb_dfu_state = DFU_STATE_dfuDNLOAD_IDLE;
      }
      else if(usb_dfu_state == DFU_STATE_dfuDNLOAD_IDLE &&
	      wLengthL == 0){
	usb_toggle_dfu_handlers();
	usb_dfu_state = DFU_STATE_dfuMANIFEST_WAIT_RST;
      }
      else {
	usb_dfu_status = DFU_STATUS_errSTALLEDPKT;
	return 0;
      }
      break;

    case DFU_CLRSTATUS:
      if(usb_dfu_state == DFU_STATE_dfuERROR){ 
	usb_dfu_status = DFU_STATUS_OK;
	usb_dfu_state = DFU_STATE_dfuIDLE;
      }
      else {
	usb_dfu_status = DFU_STATUS_errSTALLEDPKT;
	return 0;
      }
      break;

    case DFU_ABORT:
      if(usb_dfu_state != DFU_STATE_appIDLE && \
	 usb_dfu_state != DFU_STATE_appDETACH){
	/*FIXME stop all pending operations */
	usb_dfu_status = DFU_STATUS_OK;
	usb_dfu_state = DFU_STATE_dfuIDLE;
      }
      else {
	usb_dfu_status = DFU_STATUS_errSTALLEDPKT;
	return 0;
      }
      break;

    default:
      usb_dfu_status = DFU_STATUS_errSTALLEDPKT;
      return 0; 
    }
  }
  else
    return 0;    /* invalid bRequestType */
  
  return 1;
}
