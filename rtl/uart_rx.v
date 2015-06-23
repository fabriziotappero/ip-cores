////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2004 Xilinx, Inc.
// All Rights Reserved
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 1.01
//  \   \         Filename: uart_rx.v
//  /   /         Date Last Modified:  08/04/2004
// /___/   /\     Date Created: 10/16/2002
// \   \  /  \
//  \___\/\___\
//
//Device:  	Xilinx
//Purpose: 	
//	UART Receiver with integral 16 byte FIFO buffer
//	8 bit, no parity, 1 stop bit
//Reference:
// 	None
//Revision History:
//    Rev 1.00 - kc - Start of design entry in VHDL,  10/16/2002.
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
 
module uart_rx
(	serial_in,
	data_out,
	read_buffer,
	reset_buffer,
	en_16_x_baud,
	buffer_data_present,
	buffer_full,
	buffer_half_full,
	clk);

input 	serial_in;
output[7:0] data_out;
input 	read_buffer;
input 	reset_buffer;
input 	en_16_x_baud;
output 	buffer_data_present;
output 	buffer_full;
output 	buffer_half_full;
input 	clk;

wire   	serial_in;
wire  [7:0] data_out;
wire   	read_buffer;
wire   	reset_buffer;
wire   	en_16_x_baud;
wire   	buffer_data_present;
wire   	buffer_full;
wire   	buffer_half_full;
wire   	clk;


//----------------------------------------------------------------------------------
//
// Start of Main UART_RX
//	 
//
//----------------------------------------------------------------------------------
//
// Signals used in UART_RX
//
//----------------------------------------------------------------------------------
//
wire [7:0] uart_data_out;
wire  fifo_write;
//
//----------------------------------------------------------------------------------
//
// Start of UART_RX circuit description
//
//----------------------------------------------------------------------------------
//	

// 8 to 1 multiplexer to convert parallel data to serial
kcuart_rx kcuart
(	.serial_in(serial_in),
    	.data_out(uart_data_out),
    	.data_strobe(fifo_write),
    	.en_16_x_baud(en_16_x_baud),
    	.clk(clk));

bbfifo_16x8 buf_0
(	.data_in(uart_data_out),
    	.data_out(data_out),
    	.reset(reset_buffer),
    	.write(fifo_write),
    	.read(read_buffer),
    	.full(buffer_full),
    	.half_full(buffer_half_full),
    	.data_present(buffer_data_present),
    	.clk(clk));

endmodule

//----------------------------------------------------------------------------------
//
// END OF FILE uart_rx.v
//
//----------------------------------------------------------------------------------

