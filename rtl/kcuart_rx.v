////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2004 Xilinx, Inc.
// All Rights Reserved
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 1.01
//  \   \         Filename: kcuart_rx.v
//  /   /         Date Last Modified:  08/04/2004
// /___/   /\     Date Created: 10/16/2002
// \   \  /  \
//  \___\/\___\
//
//Device:  	Xilinx
//Purpose: 	
// 	Constant (K) Compact UART Receiver
//Reference:
// 	None
//Revision History:
//    Rev 1.00 - kc - Start of design entry in VHDL,  10/16/2002.
//    Rev 1.01 - sus - Converted to verilog,  08/04/2004.
//    Rev 1.02 - njs - Synplicity attributes added,  09/06/2004.
//    Rev 1.03 - njs - defparam values corrected,  12/01/2005.
//////////////////////////////////////////////////////////////////////////////////
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

module kcuart_rx
     (serial_in,
      data_out,
      data_strobe,
      en_16_x_baud,
      clk);

input 		serial_in;
output [7:0] 	data_out;
output 		data_strobe;
input 		en_16_x_baud;
input 		clk;

////////////////////////////////////////////////////////////////////////////////////
//
// Start of KCUART_RX
//	 
//
////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////
//
// wires used in KCUART_RX
//
////////////////////////////////////////////////////////////////////////////////////
//
wire 		sync_serial        ;
wire 		stop_bit           ;
wire 	[7:0] 	data_int     ;
wire 	[7:0] 	data_delay   ;
wire 		start_delay        ;
wire 		start_bit          ;
wire 		edge_delay         ;
wire 		start_edge         ;
wire 		decode_valid_char  ;
wire 		valid_char         ;
wire 		decode_purge       ;
wire 		purge              ;
wire 	[8:0] 	valid_srl_delay   ;
wire 	[8:0] 	valid_reg_delay   ;
wire 		decode_data_strobe ;

////////////////////////////////////////////////////////////////////////////////////
//
// Start of KCUART_RX circuit description
//
////////////////////////////////////////////////////////////////////////////////////
//	

  // Synchronise input serial data to system clock

FD sync_reg
( 	.D(serial_in),
      .Q(sync_serial),
      .C(clk) );

FD stop_reg
( 	.D(sync_serial),
      .Q(stop_bit),
      .C(clk) );


// Data delays to capture data at 16 time baud rate
// Each SRL16E is followed by a flip-flop for best timing

	SRL16E delay15_srl_0
	(  	.D(data_int[1]),
	      .CE(en_16_x_baud),
      	.CLK(clk),
	      .A0(1'b0),
	      .A1(1'b1),
	      .A2(1'b1),
	      .A3(1'b1),
	      .Q(data_delay[0] ));
	
	defparam delay15_srl_0.INIT = 16'h0000;
	

       SRL16E delay15_srl_1
       (   	.D(data_int[2]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b0),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(data_delay[1] ));
	
	defparam delay15_srl_1.INIT = 16'h0000;
	

      SRL16E delay15_srl_2
      (   	.D(data_int[3]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b0),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(data_delay[2] ));
	
	defparam delay15_srl_2.INIT = 16'h0000;
	

      SRL16E delay15_srl_3
      (   	.D(data_int[4]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b0),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(data_delay[3] ));
	
	defparam delay15_srl_3.INIT = 16'h0000;
	

      SRL16E delay15_srl_4
      (   	.D(data_int[5]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b0),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(data_delay[4] ));
	
	defparam delay15_srl_4.INIT = 16'h0000;
	

      SRL16E delay15_srl_5
      (   	.D(data_int[6]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b0),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(data_delay[5] ));
	
	defparam delay15_srl_5.INIT = 16'h0000;
	

      SRL16E delay15_srl_6
      (   	.D(data_int[7]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b0),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(data_delay[6] ));
	
	defparam delay15_srl_6.INIT = 16'h0000;
	
      
	SRL16E  delay15_srl_7
      (   	.D(stop_bit),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b0),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(data_delay[7]) );
	
	defparam delay15_srl_7.INIT = 16'h0000;
	

	FDE data_reg_0
      ( 	.D(data_delay[0]),
            .Q(data_int[0]),
            .CE(en_16_x_baud),
            .C(clk) );

	FDE data_reg_1
      ( 	.D(data_delay[1]),
		.Q(data_int[1]),
            .CE(en_16_x_baud),
            .C(clk) );

	FDE data_reg_2
      ( 	.D(data_delay[2]),
            .Q(data_int[2]),
            .CE(en_16_x_baud),
            .C(clk) );

	FDE data_reg_3
      ( 	.D(data_delay[3]),
            .Q(data_int[3]),
            .CE(en_16_x_baud),
            .C(clk) );

	FDE data_reg_4
      ( 	.D(data_delay[4]),
            .Q(data_int[4]),
            .CE(en_16_x_baud),
            .C(clk) );

	FDE data_reg_5
      ( 	.D(data_delay[5]),
            .Q(data_int[5]),
            .CE(en_16_x_baud),
            .C(clk) );

	FDE data_reg_6
      ( 	.D(data_delay[6]),
            .Q(data_int[6]),
            .CE(en_16_x_baud),
            .C(clk) );

	FDE data_reg_7
      ( 	.D(data_delay[7]),
            .Q(data_int[7]),
            .CE(en_16_x_baud),
            .C(clk) );

  // Assign internal wires to outputs
  assign data_out = data_int;
 
  // Data delays to capture start bit at 16 time baud rate

  	SRL16E start_srl
  	(   	.D(data_int[0]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b0),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(start_delay ) );
	
	defparam start_srl.INIT = 16'h0000;
	

	FDE start_reg
   	( 	.D(start_delay),
            .Q(start_bit),
            .CE(en_16_x_baud),
            .C(clk) );

  // Data delays to capture start bit leading edge at 16 time baud rate
  // Delay ensures data is captured at mid-bit position

  	SRL16E edge_srl
  	(   	.D(start_bit),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b1),
            .A1(1'b0),
            .A2(1'b1),
            .A3(1'b0),
            .Q(edge_delay ) );
	
	defparam edge_srl.INIT = 16'h0000;
	

  	FDE edge_reg
   	( 	.D(edge_delay),
            .Q(start_edge),
            .CE(en_16_x_baud),
            .C(clk) );

  // Detect a valid character 

  	LUT4 valid_lut
	( 	.I0(purge),
            .I1(stop_bit),
            .I2(start_edge),
            .I3(edge_delay),
            .O(decode_valid_char ) );  
	
	defparam valid_lut.INIT = 16'h0040;
	

  	FDE valid_reg
   	( 	.D(decode_valid_char),
            .Q(valid_char),
            .CE(en_16_x_baud),
            .C(clk) );

  // Purge of data status 

  	LUT3 purge_lut
  	( 	.I0(valid_reg_delay[8]),
            .I1(valid_char),
            .I2(purge),
            .O(decode_purge ) );
	
	defparam purge_lut.INIT = 8'h54;
	
				   

  	FDE purge_reg
   	( 	.D(decode_purge),
            .Q(purge),
            .CE(en_16_x_baud),
            .C(clk) );

  // Delay of valid_char pulse of length equivalent to the time taken 
  // to purge data shift register of all data which has been used.
  // Requires 9x16 + 8 delays which is achieved by packing of SRL16E with 
  // 16 delays and utilising the dedicated flip flop in each of 8 stages.

	SRL16E valid_delay15_srl_0
      (   	.D(valid_char),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b0),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(valid_srl_delay[0] ) );
	
	defparam valid_delay15_srl_0.INIT = 16'h0000;
	

	SRL16E valid_delay16_srl_1
      (   	.D(valid_reg_delay[0]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b1),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(valid_srl_delay[1] ) );
	
	defparam valid_delay16_srl_1.INIT = 16'h0000;
	

	SRL16E valid_delay16_srl_2
      (   	.D(valid_reg_delay[1]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b1),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(valid_srl_delay[2] ) );
	
	defparam valid_delay16_srl_2.INIT = 16'h0000;
	

	SRL16E valid_delay16_srl_3
      (   	.D(valid_reg_delay[2]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b1),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(valid_srl_delay[3] ) );
	
	defparam valid_delay16_srl_3.INIT = 16'h0000;
	

	SRL16E valid_delay16_srl_4
      (   	.D(valid_reg_delay[3]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b1),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(valid_srl_delay[4] ) );
	
	defparam valid_delay16_srl_4.INIT = 16'h0000;
	

	SRL16E valid_delay16_srl_5
      (   	.D(valid_reg_delay[4]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b1),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(valid_srl_delay[5] ) );
	
	defparam valid_delay16_srl_5.INIT = 16'h0000;
	

	SRL16E valid_delay16_srl_6
      (   	.D(valid_reg_delay[5]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b1),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(valid_srl_delay[6] ) );
	
	defparam valid_delay16_srl_6.INIT = 16'h0000;
	

	SRL16E valid_delay16_srl_7
      (   	.D(valid_reg_delay[6]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b1),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(valid_srl_delay[7] ) );
	
	defparam valid_delay16_srl_7.INIT = 16'h0000;
	

	SRL16E valid_delay16_srl_8
      (   	.D(valid_reg_delay[7]),
            .CE(en_16_x_baud),
            .CLK(clk),
            .A0(1'b1),
            .A1(1'b1),
            .A2(1'b1),
            .A3(1'b1),
            .Q(valid_srl_delay[8] ) );
	
	defparam valid_delay16_srl_8.INIT = 16'h0000;
	

     	FDE valid_data_reg_0
      ( 	.D(valid_srl_delay[0]),
            .Q(valid_reg_delay[0]),
            .CE(en_16_x_baud),
            .C(clk) );

	FDE valid_data_reg_1
      ( 	.D(valid_srl_delay[1]),
            .Q(valid_reg_delay[1]),
            .CE(en_16_x_baud),
            .C(clk) );
     
	FDE valid_data_reg_2
      ( 	.D(valid_srl_delay[2]),
            .Q(valid_reg_delay[2]),
            .CE(en_16_x_baud),
            .C(clk) );

     	FDE valid_data_reg_3
     	( 	.D(valid_srl_delay[3]),
            .Q(valid_reg_delay[3]),
            .CE(en_16_x_baud),
            .C(clk) );

     	FDE valid_data_reg_4
     	( 	.D(valid_srl_delay[4]),
            .Q(valid_reg_delay[4]),
            .CE(en_16_x_baud),
            .C(clk) );

     	FDE valid_data_reg_5
     	( 	.D(valid_srl_delay[5]),
            .Q(valid_reg_delay[5]),
            .CE(en_16_x_baud),
            .C(clk) );

	FDE valid_data_reg_6
      ( 	.D(valid_srl_delay[6]),
            .Q(valid_reg_delay[6]),
            .CE(en_16_x_baud),
            .C(clk) );

     FDE valid_data_reg_7
     ( 	.D(valid_srl_delay[7]),
            .Q(valid_reg_delay[7]),
            .CE(en_16_x_baud),
            .C(clk) );

     FDE valid_data_reg_8
     ( 	.D(valid_srl_delay[8]),
            .Q(valid_reg_delay[8]),
            .CE(en_16_x_baud),
            .C(clk) );

  // Form data strobe

		LUT2 strobe_lut
  		( 		.I0(valid_char),
         	.I1(en_16_x_baud),
            .O(decode_data_strobe ) );
		
		defparam strobe_lut.INIT = 4'h8;
		

  		FD strobe_reg
   	( 		.D(decode_data_strobe),
            .Q(data_strobe),
            .C(clk) );

endmodule

////////////////////////////////////////////////////////////////////////////////////
//
// END OF FILE KCUART_RX.V
//
////////////////////////////////////////////////////////////////////////////////////


