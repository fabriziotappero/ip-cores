////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2004 Xilinx, Inc.
// All Rights Reserved
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 1.01
//  \   \         Filename: uart_tx.v
//  /   /         Date Last Modified:  08/04/2004
// /___/   /\     Date Created: 10/14/2002
// \   \  /  \
//  \___\/\___\
//
//Device:  	Xilinx
//Purpose: 	
//	UART Transmitter with integral 16 byte FIFO buffer
//	8 bit, no parity, 1 stop bit
//Reference:
// 	None
//Revision History:
//    Rev 1.00 - kc - Start of design entry in VHDL,  10/14/2002.
//    Rev 1.01 - sus - Converted to verilog,  08/04/2004.
////////////////////////////////////////////////////////////////////////////////
// Contact: e-mail  picoblaze@xilinx.com
//////////////////////////////////////////////////////////////////////////////////
//
// Disclaimer: 
// LIMITED WARRANTY AND DISCLAIMER. These designs are
// provided to you "as is". Xilinx and its licensors make and you
// receive no warranties or conditions, express, implied,
// statutory or otherwise, and Xilinx specifically disclaims any
// implied warranties of merchantability, non-infringement, or
// fitness for a particular purpose. Xilinx does not warrant that
// the functions contained in these designs will meet your
// requirements, or that the operation of these designs will be
// uninterrupted or error free, or that defects in the Designs
// will be corrected. Furthermore, Xilinx does not warrant or
// make any representations regarding use or the results of the
// use of the designs in terms of correctness, accuracy,
// reliability, or otherwise.
//
// LIMITATION OF LIABILITY. In no event will Xilinx or its
// licensors be liable for any loss of data, lost profits, cost
// or procurement of substitute goods or services, or for any
// special, incidental, consequential, or indirect damages
// arising from the use or operation of the designs or
// accompanying documentation, however caused and on any theory
// of liability. This limitation will apply even if Xilinx
// has been advised of the possibility of such damage. This
// limitation shall apply not-withstanding the failure of the 
// essential purpose of any limited remedies herein. 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1ps

module uart_tx
(	data_in,
	write_buffer,
	reset_buffer,
	en_16_x_baud,
	serial_out,
	buffer_full,
	buffer_half_full,
	clk);

input[7:0] 	data_in;
input 	write_buffer;
input 	reset_buffer;
input 	en_16_x_baud;
output 	serial_out;
output 	buffer_full;
output 	buffer_half_full;
input 	clk;

wire  [7:0] data_in;
wire   	write_buffer;
wire   	reset_buffer;
wire   	en_16_x_baud;
wire   	serial_out;
wire   	buffer_full;
wire   	buffer_half_full;
wire   	clk;

//----------------------------------------------------------------------------------
//
// Start of UART_TX
//	 
//
//----------------------------------------------------------------------------------
//
// Signals used in UART_TX
//
//----------------------------------------------------------------------------------
//
wire [7:0] 	fifo_data_out;
wire  	fifo_data_present;
wire  	fifo_read;
//
//----------------------------------------------------------------------------------
//
// Start of UART_TX circuit description
//
//----------------------------------------------------------------------------------
//	

  // 8 to 1 multiplexer to convert parallel data to serial
kcuart_tx kcuart
(	.data_in(fifo_data_out),
    	.send_character(fifo_data_present),
    	.en_16_x_baud(en_16_x_baud),
    	.serial_out(serial_out),
    	.Tx_complete(fifo_read),
    	.clk(clk));

bbfifo_16x8 buf_0
(	.data_in(data_in),
    	.data_out(fifo_data_out),
    	.reset(reset_buffer),
    	.write(write_buffer),
    	.read(fifo_read),
    	.full(buffer_full),
    	.half_full(buffer_half_full),
    	.data_present(fifo_data_present),
    	.clk(clk));

endmodule

//----------------------------------------------------------------------------------
//
// END OF FILE UART_TX.V
//
//----------------------------------------------------------------------------------


