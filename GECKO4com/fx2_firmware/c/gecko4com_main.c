/******************************************************************************/
/*            _   _            __   ____                                      */
/*           / / | |          / _| |  __|                                     */
/*           | |_| |  _   _  / /   | |_                                       */
/*           |  _  | | | | | | |   |  _|                                      */
/*           | | | | | |_| | \ \_  | |__                                      */
/*           |_| |_| \_____|  \__| |____| microLab                            */
/*                                                                            */
/*           Bern University of Applied Sciences (BFH)                        */
/*           Quellgasse 21                                                    */
/*           Room HG 4.33                                                     */
/*           2501 Biel/Bienne                                                 */
/*           Switzerland                                                      */
/*                                                                            */
/*           http://www.microlab.ch                                           */
/******************************************************************************/
/* GECKO4COM
  
  
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
  
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details. 
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
   Parts of this code are based on the USRP2 firmware (GNU Radio Project),
   version 3.0.2, Copyright 2003 Free Software Foundation, Inc
  ********************************************************************
*/

#include "fx2regs.h"
#include "isr.h"
#include "fx2utils.h"
#include "usb_common.h"
#include "usb_requests.h"
#include "syncdelay.h"

sbit at 0x80+0 PA0;
sbit at 0x80+1 PA1;
sbit at 0x80+2 PA2;
sbit at 0x80+3 PA3;
sbit at 0x80+4 PA4;
sbit at 0x80+5 PA5;
sbit at 0x80+6 PA6;
sbit at 0x80+7 PA7;

#define USB_TMC_STATUS_SUCCESS 1
#define USB_TMC_INDICATOR_PULSE_MASK 1<<2
#define USB_TMC_INITIATE_ABORT_BULK_OUT 1
#define USB_TMC_CHECK_ABORT_BULK_OUT_STATUS 2
#define USB_TMC_INITIATE_ABORT_BULK_IN 3
#define USB_TMC_CHECK_ABORT_BULK_IN_STATUS 4
#define USB_TMC_INITIATE_CLEAR 5
#define USB_TMC_CHECK_CLEAR_STATUS 6
#define USB_TMC_GET_CAPABILITIES 7
#define USB_TMC_INDICATOR_PULSE 64
#define USB_TMC_READ_STATUS_BYTE 128

#define IFCONFIG_INTERNAL_CLOCK 1<<7
#define IFCONFIG_INTERNAL_48MHZ_Clock 1<<6
#define IFCONFIG_DRIVE_IFCLK_PIN 1<<5
#define IFCONFIG_INVERT_IFCLK 1<<4
#define IFCONFIG_ASYNC_MODE 1<<3
#define IFCONFIG_USE_GSTATE 1<<2
#define IFCONFIG_USE_GPIF 2
#define IFCONFIG_USE_FIFOS 3

#define FIXED_EP2_PROG_FLAG 4
#define FIXED_EP4_PROG_FLAG 5
#define FIXED_EP6_PROG_FLAG 6
#define FIXED_EP8_PROG_FLAG 7
#define FIXED_EP2_EMPTY_FLAG 8
#define FIXED_EP4_EMPTY_FLAG 9
#define FIXED_EP6_EMPTY_FLAG 10
#define FIXED_EP8_EMPTY_FLAG 11
#define FIXED_EP2_FULL_FLAG 12
#define FIXED_EP4_FULL_FLAG 13
#define FIXED_EP6_FULL_FLAG 14
#define FIXED_EP8_FULL_FLAG 15
#define PORT_A_USE_FLAGD 1 << 7
#define PORT_A_USE_SLCS  1 << 6
#define PORT_A_USE_INT1  2
#define PORT_A_USE_INT0  1
#define PKTEND_ACTIVE_HIGH 1<<5
#define SLOE_ACTIVE_HIGH 1<<4
#define SLRD_ACTIVE_HIGH 1<<3
#define SLWR_ACTIVE_HIGH 1<<2
#define EMPTY_FLAG_ACTIVE_HIGH 2
#define FULL_FLAG_ACTIVE_HIGH 1
#define DISABLE_AUTO_ARMING 2
#define ENABLE_ENHANCED_PACKET_HANDLING 1
#define ACTIVE_ENDPOINT 1 << 7
#define IN_ENDPOINT 1<<6
#define ISOCHRONOUS_MODE 1 << 4
#define BULK_MODE 2 << 4
#define INTERRUPT_MODE 3 << 4
#define SIZE_1KB  1<<3
#define QUAD_BUFFERING 0
#define DOUBLE_BUFFERING 2
#define TRIPLE_BUFFERING 3
#define FIFO_IN_EARLY 1 << 6
#define FIFO_OUT_EARLY 1 << 5
#define FIFO_AUTO_OUT 1 << 4
#define FIFO_AUTO_IN 1 << 3
#define FIFO_ZEROLEN 1 << 2
#define FIFO_WORDWIDE 1

extern xdata char device_bus_attributes_hs[];
extern xdata char device_bus_attributes_fs[];

unsigned char app_class_cmd(void) {
   switch (bRequestType) {
      case 0xA1 : switch (bRequest) {
                     case USB_TMC_GET_CAPABILITIES :
                        EP0BUF[0] = USB_TMC_STATUS_SUCCESS;
                        EP0BUF[1] = 0;
                        EP0BUF[2] = 0;
                        EP0BUF[3] = 1;
                        EP0BUF[4] = USB_TMC_INDICATOR_PULSE_MASK;
                        EP0BUF[5] = 0;
                        EP0BUF[6] = 0;
                        EP0BUF[7] = 0;
                        EP0BUF[8] = 0;
                        EP0BUF[9] = 0;
                        EP0BUF[10] = 0;
                        EP0BUF[11] = 0;
                        EP0BUF[12] = 0;
                        EP0BUF[13] = 1;
                        EP0BUF[14] = 0;
                        EP0BUF[15] = 0;
                        EP0BUF[16] = 0;
                        EP0BUF[17] = 0;
                        EP0BUF[18] = 0;
                        EP0BUF[19] = 0;
                        EP0BUF[20] = 0;
                        EP0BUF[21] = 0;
                        EP0BUF[22] = 0;
                        EP0BUF[23] = 0;
                        EP0BCH = 0;
                        EP0BCL = 0x18;
                        return 1;
                     case USB_TMC_INDICATOR_PULSE :
                        IOD = 0xEF; /* indicator pulse */
                        EP0BUF[0] = USB_TMC_STATUS_SUCCESS;
                        IOD = 0xFF;
                        EP0BCH = 0;
                        EP0BCL = 1;
                        return 1;
                     case USB_TMC_INITIATE_CLEAR :
                        /* reset the stuff in the FPGA */
                        PA1 = 1;
                        NOP;
                        PA1 = 0;
                        EP0BUF[0] = USB_TMC_STATUS_SUCCESS;
                        EP0BCH = 0;
                        EP0BCL = 1;
                        return 1;
                     case USB_TMC_CHECK_CLEAR_STATUS :
                        EP0BUF[0] = USB_TMC_STATUS_SUCCESS;
                        EP0BUF[1] = 0;
                        EP0BCH = 0;
                        EP0BCL = 2;
                        return 1;
                     case USB_TMC_READ_STATUS_BYTE :
                        IOD = 0xFF; /* select the USB488 status word */
                        EP0BUF[0] = USB_TMC_STATUS_SUCCESS;
                        EP0BUF[1] = wValueL;
                        EP0BUF[2] = (IOD&0xF)<<2;/*status byte*/
                        EP0BCH = 0;
                        EP0BCL = 3;
                        return 1;
                     default : break;
                 }
      /* TODO: finish the abort handling! */
      case 0xA2 : switch (bRequest) {
                     case USB_TMC_INITIATE_ABORT_BULK_OUT :
                        IOD = 0xCF; /* read btag lo nibble */
                        EP0BUF[0] = USB_TMC_STATUS_SUCCESS;
                        EP0BUF[1] = IOD&0xF;
                        IOD= 0xDF; /* read btag hi nibble */
                        EP0BCH = 0;
                        EP0BUF[1] |= (IOD&0xF)<<4;
                        EP0BCL = 2;
                        return 1;
                     case USB_TMC_CHECK_ABORT_BULK_OUT_STATUS :
                        EP0BUF[0] = USB_TMC_STATUS_SUCCESS;
                        EP0BUF[1] = 0;
                        EP0BUF[2] = 0;
                        EP0BUF[3] = 0;
                        EP0BUF[4] = 0;
                        EP0BUF[5] = 0;
                        EP0BUF[6] = 0;
                        EP0BUF[7] = 0;
                        EP0BCH = 0;
                        EP0BCL = 8;
                        return 1;
                     case USB_TMC_INITIATE_ABORT_BULK_IN :
                        IOD = 0xCF; /* read btag lo nibble */
                        EP0BUF[0] = USB_TMC_STATUS_SUCCESS;
                        EP0BUF[1] = IOD&0xF;
                        IOD= 0xDF; /* read btag hi nibble */
                        EP0BCH = 0;
                        EP0BUF[1] |= (IOD&0xF)<<4;
                        EP0BCL = 2;
                        return 1;
                     case USB_TMC_CHECK_ABORT_BULK_IN_STATUS :
                        EP0BUF[0] = USB_TMC_STATUS_SUCCESS;
                        EP0BUF[1] = 0;
                        EP0BUF[2] = 0;
                        EP0BUF[3] = 0;
                        EP0BUF[4] = 0;
                        EP0BUF[5] = 0;
                        EP0BUF[6] = 0;
                        EP0BUF[7] = 0;
                        EP0BCH = 0;
                        EP0BCL = 8;
                        return 1;
                     default : break;
                  }
      default : break;
   }
   return 0;
}

unsigned char app_vendor_cmd(void) {
   return 0;
}

void setup_endpoint_fifos() {
   /* IMPORTANT: Endpoint configurations:
                 EP6 => USBTMC IN endpoint (to PC) double buffered 512 bytes
                 EP8 => USBTMC OUT endpoint (from PC) double buffered 512 bytes
                 both endpoints are 8 bytes fifo 
   */
   IFCONFIG = IFCONFIG_USE_FIFOS;
   SYNCDELAY;
   SYNCDELAY;
   PORTACFG = PORT_A_USE_FLAGD | PORT_A_USE_INT0;
   SYNCDELAY;
   
   PINFLAGSAB = (FIXED_EP6_FULL_FLAG << 4)|
                 FIXED_EP8_EMPTY_FLAG; /* Flag B is EP6 Full Flag; Flag A is EP8 Empty Flag */
   SYNCDELAY;
   PINFLAGSCD = (FIXED_EP4_FULL_FLAG << 4)|
                 FIXED_EP2_EMPTY_FLAG;
   SYNCDELAY;
   FIFOPINPOLAR = 0; /* All FIFO signals active low */
   SYNCDELAY;
   REVCTL = 0; /* Auto Arming and no enhanced packet handling */
   SYNCDELAY;
   
   EP2CFG=0;   /* Disabled endpoint */
   SYNCDELAY;
   EP4CFG=0;   /* Disabled endpoint */
   SYNCDELAY;
   EP6CFG=ACTIVE_ENDPOINT|IN_ENDPOINT|BULK_MODE|DOUBLE_BUFFERING;
   SYNCDELAY;
   EP8CFG=ACTIVE_ENDPOINT|BULK_MODE; /* fixed to double buffering ! */
   SYNCDELAY;
   
   EP2FIFOCFG = 0;
   SYNCDELAY;
   EP4FIFOCFG = 0;
   SYNCDELAY;
   EP6FIFOCFG = 0;
   SYNCDELAY;
   EP8FIFOCFG = 0;
   SYNCDELAY;     /* Set all FIFOs to passive byte wide */
   

   FIFORESET=0x80;
   SYNCDELAY;
   FIFORESET=0x02;
   SYNCDELAY;
   FIFORESET=0x04;
   SYNCDELAY;
   FIFORESET=0x06;
   SYNCDELAY;
   FIFORESET=0x08;
   SYNCDELAY;
   FIFORESET=0x00;
   SYNCDELAY;     /* Reset all FIFOs */
   
   EP8FIFOCFG=FIFO_AUTO_OUT|FIFO_OUT_EARLY; /* Autoout and OUTEARLY */
   SYNCDELAY;
   EP6FIFOCFG=FIFO_IN_EARLY;
   SYNCDELAY;

   
}



void main(void) {
   EA = 0; /* disable all interrupts */

   PA1 = 1; /* indicate to the FPGA that the FX2 is still setting up things */
   PA3 = 0; /* Indicate to the FPGA that the FX2 uses full speed */
   OEA = 1<<3|1<<1; /* PA1 and PA3 are set to output, the rest of the pins as input */
   
   setup_autovectors();
   usb_install_handlers();
   setup_endpoint_fifos();
   OED = 0xF0; /* The high 4 pins of the d-port are outputs the low 4 are inputs */
   IOD = 0xFF; /* select the USB488 status word */
   
   EA = 1; /* enable all interrupts */
   
   fx2_renumerate();
   
   /* now everything should be fine */
   PA1 = 0; /* indicate to the FPGA that the FX2 is ready */

   while (1) {
      if(usb_setup_packet_avail()) usb_handle_setup_packet();
   }
}
