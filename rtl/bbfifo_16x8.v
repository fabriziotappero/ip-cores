////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2004 Xilinx, Inc.
// All Rights Reserved
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 1.01
//  \   \         Filename: bbfifo_16x8.v
//  /   /         Date Last Modified:  08/04/2004
// /___/   /\     Date Created: 10/14/2002
// \   \  /  \
//  \___\/\___\
//
//Device:  	Xilinx
//Purpose: 	
// 	'Bucket Brigade' FIFO
// 	16 deep
// 	8-bit data
//Reference:
// 	None
//Revision History:
//    Rev 1.00 - kc - Start of design entry in VHDL,  10/14/2002.
//    Rev 1.01 - sus - Converted to verilog,  08/04/2004.
//    Rev 1.02 - njs - Synplicity attributes added,  09/06/2004.
//    Rev 1.03 - njs - defparam values corrected,  12/01/2005.
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

module bbfifo_16x8
       (data_in,
   	data_out,
   	reset,
   	write,
   	read,
   	full,
		half_full,
	   data_present,
      clk);

input 	[7:0] 	data_in;
output 	[7:0] 	data_out;
input 		reset;
input 		write; 
input 		read;
output 		full;
output 		half_full;
output 		data_present;
input 		clk;

////////////////////////////////////////////////////////////////////////////////////
//
// Start of BBFIFO_16x8
//	 
//
////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////
//
// wires used in BBFIFO_16x8
//
////////////////////////////////////////////////////////////////////////////////////

wire [3:0] 	pointer;
wire [3:0] 	next_count;
wire [3:0] 	half_count;
wire [2:0] 	count_carry;

wire 		pointer_zero;
wire 		pointer_full;
wire 		decode_data_present;
wire 		data_present_int;
wire 		valid_write;

////////////////////////////////////////////////////////////////////////////////////
//
// Start of BBFIFO_16x8 circuit description
//
////////////////////////////////////////////////////////////////////////////////////
	
// SRL16E data storage
     SRL16E data_srl_0 
     (   	.D(data_in[0]),
            .CE(valid_write),
            .CLK(clk),
            .A0(pointer[0]),
            .A1(pointer[1]),
            .A2(pointer[2]),
            .A3(pointer[3]),
            .Q(data_out[0]) ); 
	
	defparam data_srl_0.INIT = 16'h0000; 
	

     SRL16E data_srl_1 
     (   	.D(data_in[1]),
            .CE(valid_write),
            .CLK(clk),
            .A0(pointer[0]),
            .A1(pointer[1]),
            .A2(pointer[2]),
            .A3(pointer[3]),
            .Q(data_out[1]) ); 
	
	defparam data_srl_1.INIT = 16'h0000; 
	

     SRL16E data_srl_2 
     (   	.D(data_in[2]),
            .CE(valid_write),
            .CLK(clk),
            .A0(pointer[0]),
            .A1(pointer[1]),
            .A2(pointer[2]),
            .A3(pointer[3]),
            .Q(data_out[2]) ); 
	
	defparam data_srl_2.INIT = 16'h0000; 
	

     SRL16E data_srl_3 
     (   	.D(data_in[3]),
            .CE(valid_write),
            .CLK(clk),
            .A0(pointer[0]),
            .A1(pointer[1]),
            .A2(pointer[2]),
            .A3(pointer[3]),
            .Q(data_out[3]) ); 
	
	defparam data_srl_3.INIT = 16'h0000; 
	

     SRL16E data_srl_4 
     (   	.D(data_in[4]),
            .CE(valid_write),
            .CLK(clk),
            .A0(pointer[0]),
            .A1(pointer[1]),
            .A2(pointer[2]),
            .A3(pointer[3]),
            .Q(data_out[4]) ); 
	
	defparam data_srl_4.INIT = 16'h0000; 
	

     SRL16E data_srl_5 
     (   	.D(data_in[5]),
            .CE(valid_write),
            .CLK(clk),
            .A0(pointer[0]),
            .A1(pointer[1]),
            .A2(pointer[2]),
            .A3(pointer[3]),
            .Q(data_out[5]) ); 
	
	defparam data_srl_5.INIT = 16'h0000; 
	

     SRL16E data_srl_6
     (   	.D(data_in[6]),
            .CE(valid_write),
            .CLK(clk),
            .A0(pointer[0]),
            .A1(pointer[1]),
            .A2(pointer[2]),
            .A3(pointer[3]),
            .Q(data_out[6]) ); 
	
	defparam data_srl_6.INIT = 16'h0000; 
	

     SRL16E data_srl_7 
     (   	.D(data_in[7]),
            .CE(valid_write),
            .CLK(clk),
            .A0(pointer[0]),
            .A1(pointer[1]),
            .A2(pointer[2]),
            .A3(pointer[3]),
            .Q(data_out[7]) ); 
	
	defparam data_srl_7.INIT = 16'h0000; 
	

  // 4-bit counter to act as data pointer
  // Counter is clock enabled by 'data_present'
  // Counter will be reset when 'reset' is active
  // Counter will increment when 'valid_write' is active

     FDRE register_bit_0
     ( 	.D(next_count[0]),
            .Q(pointer[0]),
            .CE(data_present_int),
            .R(reset),
            .C(clk) );

     LUT4 count_lut_0
     ( 	.I0(pointer[0]),
            .I1(read),
            .I2(pointer_zero),
            .I3(write),
            .O(half_count[0]) );
	
	defparam count_lut_0.INIT = 16'h6606; 
	

     FDRE register_bit_1
     ( 	.D(next_count[1]),
            .Q(pointer[1]),
            .CE(data_present_int),
            .R(reset),
            .C(clk) );

     LUT4 count_lut_1
     ( 	.I0(pointer[1]),
            .I1(read),
            .I2(pointer_zero),
            .I3(write),
            .O(half_count[1]) );
	
	defparam count_lut_1.INIT = 16'h6606; 
	

     FDRE register_bit_2
     ( 	.D(next_count[2]),
            .Q(pointer[2]),
            .CE(data_present_int),
            .R(reset),
            .C(clk) );

     LUT4 count_lut_2
     ( 	.I0(pointer[2]),
            .I1(read),
            .I2(pointer_zero),
            .I3(write),
            .O(half_count[2]) );
	
	defparam count_lut_2.INIT = 16'h6606; 
	

     FDRE register_bit_3
     ( 	.D(next_count[3]),
            .Q(pointer[3]),
            .CE(data_present_int),
            .R(reset),
            .C(clk) );

     LUT4 count_lut_3
     ( 	.I0(pointer[3]),
            .I1(read),
            .I2(pointer_zero),
            .I3(write),
            .O(half_count[3]) );
	
	defparam count_lut_3.INIT = 16'h6606; 
	

     	MUXCY count_muxcy_0
      ( 	.DI(pointer[0]),
            .CI(valid_write),
            .S(half_count[0]),
            .O(count_carry[0]) );
       
     	XORCY count_xor_0
      ( 	.LI(half_count[0]),
            .CI(valid_write),
            .O(next_count[0]) );

      MUXCY count_muxcy_1 
      ( 	.DI(pointer[1]),
            .CI(count_carry[0]),
            .S(half_count[1]),
            .O(count_carry[1]) );
       
      XORCY count_xor_1
      ( 	.LI(half_count[1]),
            .CI(count_carry[0]),
            .O(next_count[1]) );

	MUXCY count_muxcy_2 
      ( 	.DI(pointer[2]),
            .CI(count_carry[1]),
            .S(half_count[2]),
            .O(count_carry[2]) );
       
      XORCY count_xor_2
      ( 	.LI(half_count[2]),
            .CI(count_carry[1]),
            .O(next_count[2]) );

      XORCY count_xor
      ( 	.LI(half_count[3]),
            .CI(count_carry[2]),
            .O(next_count[3]) );

  // Detect when pointer is zero and maximum

  	LUT4 zero_lut
	( 	.I0(pointer[0]),
            .I1(pointer[1]),
            .I2(pointer[2]),
            .I3(pointer[3]),
            .O(pointer_zero ) );
	
	defparam zero_lut.INIT = 16'h0001; 
	

  	LUT4 full_lut
	( 	.I0(pointer[0]),
            .I1(pointer[1]),
            .I2(pointer[2]),
            .I3(pointer[3]),
            .O(pointer_full ) );
	
	defparam full_lut.INIT = 16'h8000; 
	

  // Data Present status

  	LUT4 dp_lut
  	( 	.I0(write),
            .I1(read),
            .I2(pointer_zero),
            .I3(data_present_int),
            .O(decode_data_present ) );
	
	defparam dp_lut.INIT = 16'hBFA0; 
	

	FDR dp_flop
	( 	.D(decode_data_present),
            .Q(data_present_int),
            .R(reset),
            .C(clk) );

  // Valid write wire

  	LUT3 valid_lut
  	( 	.I0(pointer_full),
            .I1(write),
            .I2(read),
            .O(valid_write ) );
	
	defparam valid_lut.INIT = 8'hC4; 
	

  // assign internal wires to outputs

  	assign full = pointer_full;  
	assign half_full = pointer[3];  
  	assign data_present = data_present_int;	 

endmodule



////////////////////////////////////////////////////////////////////////////////////
//
// END OF FILE BBFIFO_16x8.V
//
////////////////////////////////////////////////////////////////////////////////////


