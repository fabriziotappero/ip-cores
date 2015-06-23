/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 function defines file                              ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb1_funct/////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: usb1_defines.v,v 1.3 2002-09-25 06:06:49 rudi Exp $
//
//  $Date: 2002-09-25 06:06:49 $
//  $Revision: 1.3 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.2  2002/09/20 11:46:54  rudi
//               fixed a type 'define' was missing ...
//
//               Revision 1.1.1.1  2002/09/19 12:07:40  rudi
//               Initial Checkin
//
//
//
//
//
//
//
//

`include "timescale.v"

//`define USBF_DEBUG
//`define USBF_VERBOSE_DEBUG

// Enable or disable Block Frames
//`define USB1_BF_ENABLE

/////////////////////////////////////////////////////////////////////
//
// Items below this point should NOT be modified by the end user
// UNLESS you know exactly what you are doing !
// Modify at you own risk !!!
//
/////////////////////////////////////////////////////////////////////

`define	ROM_SIZE0	7'd018	// Device Descriptor Length
`define	ROM_SIZE1	7'd053	// Configuration Descriptor Length
`define	ROM_SIZE2A	7'd004	// Language ID Descriptor Start Length
`define	ROM_SIZE2B	7'd010	// String Descriptor Length
`define	ROM_SIZE2C	7'd010	// for future use
`define	ROM_SIZE2D	7'd010	// for future use

`define	ROM_START0	7'h00	// Device Descriptor Start Address
`define	ROM_START1	7'h12	// Configuration Descriptor Start Address
`define	ROM_START2A	7'h47	// Language ID Descriptor Start Address
`define	ROM_START2B	7'h50	// String Descriptor Start Address
`define	ROM_START2C	7'h60	// for future use
`define	ROM_START2D	7'h70	// for future use

// Endpoint Configuration Constants
`define IN	14'b00_001_000000000
`define OUT	14'b00_010_000000000
`define CTRL	14'b10_100_000000000
`define ISO	14'b01_000_000000000
`define BULK	14'b10_000_000000000
`define INT	14'b00_000_000000000

// PID Encodings
`define USBF_T_PID_OUT		4'b0001
`define USBF_T_PID_IN		4'b1001
`define USBF_T_PID_SOF		4'b0101
`define USBF_T_PID_SETUP	4'b1101
`define USBF_T_PID_DATA0	4'b0011
`define USBF_T_PID_DATA1	4'b1011
`define USBF_T_PID_DATA2	4'b0111
`define USBF_T_PID_MDATA	4'b1111
`define USBF_T_PID_ACK		4'b0010
`define USBF_T_PID_NACK		4'b1010
`define USBF_T_PID_STALL	4'b1110
`define USBF_T_PID_NYET		4'b0110
`define USBF_T_PID_PRE		4'b1100
`define USBF_T_PID_ERR		4'b1100
`define USBF_T_PID_SPLIT	4'b1000
`define USBF_T_PID_PING		4'b0100
`define USBF_T_PID_RES		4'b0000

// The HMS_DEL is a constant for the "Half Micro Second"
// Clock pulse generator. This constant specifies how many
// Phy clocks there are between two hms_clock pulses. This
// constant plus 2 represents the actual delay.
// Example: For a 60 Mhz (16.667 nS period) Phy Clock, the
// delay must be 30 phy clock: 500ns / 16.667nS = 30 clocks
`define USBF_HMS_DEL		5'h16

// After sending Data in response to an IN token from host, the
// host must reply with an ack. The host has 622nS in Full Speed
// mode and 400nS in High Speed mode to reply. RX_ACK_TO_VAL_FS
// and RX_ACK_TO_VAL_HS are the numbers of UTMI clock cycles
// minus 2 for Full and High Speed modes.
//`define USBF_RX_ACK_TO_VAL_FS	8'd36
`define USBF_RX_ACK_TO_VAL_FS	8'd200

// After sending a OUT token the host must send a data packet.
// The host has 622nS in Full Speed mode and 400nS in High Speed
// mode to send the data packet.
// TX_DATA_TO_VAL_FS and TX_DATA_TO_VAL_HS are is the numbers of
// UTMI clock cycles minus 2.
//`define USBF_TX_DATA_TO_VAL_FS	8'd36
`define USBF_TX_DATA_TO_VAL_FS	8'd200
