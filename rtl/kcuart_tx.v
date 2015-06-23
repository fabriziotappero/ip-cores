////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2004 Xilinx, Inc.
// All Rights Reserved
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 1.03
//  \   \         Filename: kcuart_tx.v
//  /   /         Date Last Modified:  November 2, 2004
// /___/   /\     Date Created: October 14, 2002
// \   \  /  \
//  \___\/\___\
//
//Device:  	Xilinx
//Purpose: 	
// 	Constant (K) Compact UART Transmitter
//Reference:
// 	None
//Revision History:
//    Rev 1.00 - kc - Start of design entry in VHDL,  October 14, 2002
//    Rev 1.01 - sus - Converted to verilog,  August 4, 2004
//    Rev 1.02 - njs - Synplicity attributes added,  September 6, 2004
//    Rev 1.03 - njs - Fixed simulation attributes from string to hex, 
//				November 2, 2004
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

module kcuart_tx
     (data_in,
      send_character,
      en_16_x_baud,
      serial_out,
      Tx_complete,
      clk);

input 	[7:0]	data_in;
input       	send_character;
input       	en_16_x_baud;
output		serial_out;
output		Tx_complete;
input 		clk;

//
////////////////////////////////////////////////////////////////////////////////////
//
// Start of KCUART_TX
//	 
//
////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////
//
// wires used in KCUART_TX
//
////////////////////////////////////////////////////////////////////////////////////
//
wire 		data_01;
wire 		data_23;
wire 		data_45;
wire 		data_67;
wire 		data_0123;
wire 		data_4567;
wire 		data_01234567;
wire 	[2:0] 	bit_select;
wire 	[2:0] 	next_count;
wire 	[2:0] 	mask_count;
wire 	[2:0] 	mask_count_carry;
wire 	[2:0] 	count_carry;
wire 		ready_to_start;
wire 		decode_Tx_start;
wire 		Tx_start;
wire 		decode_Tx_run;
wire 		Tx_run;
wire 		decode_hot_state;
wire 		hot_state;
wire 		hot_delay;
wire 		Tx_bit;
wire 		decode_Tx_stop;
wire 		Tx_stop;
wire 		decode_Tx_complete;

////////////////////////////////////////////////////////////////////////////////////
//
// Start of KCUART_TX circuit description
//
////////////////////////////////////////////////////////////////////////////////////
//	

  // 8 to 1 multiplexer to convert parallel data to serial

  	LUT4 mux1_lut
  	  ( .I0(bit_select[0]),
   	    .I1(data_in[0]),
            .I2(data_in[1]),
            .I3(Tx_run),
            .O(data_01) );
	
	defparam mux1_lut.INIT = 16'hE4FF; 
	

  	LUT4 mux2_lut 
  	(   .I0(bit_select[0]),
            .I1(data_in[2]),
            .I2(data_in[3]),
            .I3(Tx_run),
            .O(data_23) );
	
	defparam mux2_lut.INIT = 16'hE4FF; 
	

  	LUT4 mux3_lut
  	   (.I0(bit_select[0]),
            .I1(data_in[4]),
            .I2(data_in[5]),
            .I3(Tx_run),
            .O(data_45) );
	
	defparam mux3_lut.INIT = 16'hE4FF; 
	

  	LUT4 mux4_lut
  	   (.I0(bit_select[0]),
            .I1(data_in[6]),
            .I2(data_in[7]),
            .I3(Tx_run),
            .O(data_67) );
	
	defparam mux4_lut.INIT = 16'hE4FF; 
	

  	MUXF5 mux5_muxf5
  		(		.I1(data_23),
            .I0(data_01),
            .S(bit_select[1]),
            .O(data_0123) );

  	MUXF5 mux6_muxf5
  		( 		.I1(data_67),
            .I0(data_45),
            .S(bit_select[1]),
            .O(data_4567) );

  	MUXF6 mux7_muxf6
  		(		.I1(data_4567),
            .I0(data_0123),
            .S(bit_select[2]),
            .O(data_01234567) );

  // Register serial output and force start and stop bits

  	FDRS pipeline_serial
   	(   .D(data_01234567),
            .Q(serial_out),
            .R(Tx_start),
            .S(Tx_stop),
            .C(clk) ) ;

  // 3-bit counter
  // Counter is clock enabled by en_16_x_baud
  // Counter will be reset when 'Tx_start' is active
  // Counter will increment when Tx_bit is active
  // Tx_run must be active to count
  // count_carry[2] indicates when terminal count [7] is reached and Tx_bit=1 (ie overflow)

	FDRE register_bit_0
   	(.D(next_count[0]),
         .Q(bit_select[0]),
         .CE(en_16_x_baud),
         .R(Tx_start),
         .C(clk) );

	LUT2 count_lut_0
     	(.I0(bit_select[0]),
         .I1(Tx_run),
         .O(mask_count[0]) );
	
	defparam count_lut_0.INIT = 4'h8; 					 
	

   MULT_AND mask_and_0
   	(.I0(bit_select[0]),
       	 .I1(Tx_run),
         .LO(mask_count_carry[0]) );

	MUXCY count_muxcy_0
   	( .DI(mask_count_carry[0]),
         .CI(Tx_bit),
         .S(mask_count[0]),
         .O(count_carry[0]) );
       
	XORCY count_xor_0
   	(.LI(mask_count[0]),
         .CI(Tx_bit),
         .O(next_count[0]) );
 
	FDRE register_bit_1
     	(.D(next_count[1]),
         .Q(bit_select[1]),
         .CE(en_16_x_baud),
         .R(Tx_start),
         .C(clk) );

	LUT2 count_lut_1
     	(.I0(bit_select[1]),
         .I1(Tx_run),
         .O(mask_count[1]) );
	
	defparam count_lut_1.INIT = 4'h8; 					 
	

   MULT_AND mask_and_1
     	( 	.I0(bit_select[1]),
         .I1(Tx_run),
         .LO(mask_count_carry[1]) );

	MUXCY count_muxcy_1
   	( 	.DI(mask_count_carry[1]),
         .CI(count_carry[0]),
         .S(mask_count[1]),
         .O(count_carry[1]) );
       
	XORCY count_xor_1
     	( 	.LI(mask_count[1]),
         .CI(count_carry[0]),
         .O(next_count[1]) );

	FDRE register_bit_2
     	( 	.D(next_count[2]),
         .Q(bit_select[2]),
         .CE(en_16_x_baud),
         .R(Tx_start),
         .C(clk) );

  	LUT2 count_lut_2
   	( 	.I0(bit_select[2]),
         .I1(Tx_run),
         .O(mask_count[2]) );
	
	defparam count_lut_2.INIT = 4'h8; 					 
	
	
	MULT_AND mask_and_2
     	( 	.I0(bit_select[2]),
         .I1(Tx_run),
         .LO(mask_count_carry[2]) );


	MUXCY count_muxcy_2
   	( 	.DI(mask_count_carry[2]),
         .CI(count_carry[1]),
         .S(mask_count[2]) ,
         .O(count_carry[2]) );
       
	XORCY count_xor_2
		( 	.LI(mask_count[2]),
         .CI(count_carry[1]),
         .O(next_count[2]) );

  // Ready to start decode

  	LUT3 ready_lut
  		( 	.I0(Tx_run),
         .I1(Tx_start),
         .I2(send_character),
         .O(ready_to_start ) );
	
	defparam ready_lut.INIT = 8'h10; 
	

  // Start bit enable

  	LUT4 start_lut
  		( 	.I0(Tx_bit),
         .I1(Tx_stop),
         .I2(ready_to_start),
         .I3(Tx_start),
         .O(decode_Tx_start ) );
	
	defparam start_lut.INIT = 16'h0190; 
	

  	FDE Tx_start_reg
  	(	.D(decode_Tx_start),
      .Q(Tx_start),
      .CE(en_16_x_baud),
      .C(clk) );


  // Run bit enable
  	LUT4 run_lut
  	( 	.I0(count_carry[2]),
      .I1(Tx_bit),
      .I2(Tx_start),
      .I3(Tx_run),
		.O(decode_Tx_run ) );
	
	defparam run_lut.INIT = 16'h1540; 
	

  	FDE Tx_run_reg
  	(	.D(decode_Tx_run),
      .Q(Tx_run),
      .CE(en_16_x_baud),
      .C(clk) );

  // Bit rate enable

  	LUT3 hot_state_lut
  	(	.I0(Tx_stop),
      .I1(ready_to_start),
      .I2(Tx_bit),
      .O(decode_hot_state) );
	
	defparam hot_state_lut.INIT = 8'h94; 
	

  	FDE hot_state_reg
  	(	.D(decode_hot_state),
      .Q(hot_state),
      .CE(en_16_x_baud),
      .C(clk) );

  	SRL16E delay14_srl
  	(	.D(hot_state),
      .CE(en_16_x_baud),
      .CLK(clk),
      .A0(1'b1),
      .A1(1'b0),
      .A2(1'b1),
      .A3(1'b1),
      .Q(hot_delay) );
	
	defparam delay14_srl.INIT = 16'h0000; 
	

  	FDE Tx_bit_reg
  	(	.D(hot_delay),
     	.Q(Tx_bit),
      .CE(en_16_x_baud),
      .C(clk) );

  // Stop bit enable
  	LUT4 stop_lut
  	(	.I0(Tx_bit),
      .I1(Tx_run),
      .I2(count_carry[2]),
      .I3(Tx_stop),	  
      .O(decode_Tx_stop) );
	
	defparam stop_lut.INIT = 16'h0180; 
	

  FDE Tx_stop_reg
  ( 	    .D(decode_Tx_stop),
            .Q(Tx_stop),
            .CE(en_16_x_baud),
            .C(clk) );

  // Tx_complete strobe

  LUT2 complete_lut
  ( 	    .I0(count_carry[2]),
            .I1(en_16_x_baud),
            .O(decode_Tx_complete) );
	
	defparam complete_lut.INIT = 4'h8; 
	

  FD Tx_complete_reg
  ( 	     .D(decode_Tx_complete),
             .Q(Tx_complete),
             .C(clk) );


endmodule

////////////////////////////////////////////////////////////////////////////////////
//
// END OF FILE KCUART_TX.V
//
////////////////////////////////////////////////////////////////////////////////////


