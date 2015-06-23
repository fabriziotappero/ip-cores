//////////////////////////////////////////////////////////////////
////
////
//// 	CRCAHB CORE BLOCK
////
////
////
//// This file is part of the APB to I2C project
////
//// http://www.opencores.org/cores/apbi2c/
////
////
////
//// Description
////
//// Implementation of APB IP core according to
////
//// crcahb IP core specification document.
////
////
////
//// To Do: Things are right here but always all block can suffer changes
////
////
////
////
////
//// Author(s): -  Julio Cesar 
////
///////////////////////////////////////////////////////////////// 
////
////
//// Copyright (C) 2009 Authors and OPENCORES.ORG
////
////
////
//// This source file may be used and distributed without
////
//// restriction provided that this copyright statement is not
////
//// removed from the file and that any derivative work contains
//// the original copyright notice and the associated disclaimer.
////
////
//// This source file is free software; you can redistribute it
////
//// and/or modify it under the terms of the GNU Lesser General
////
//// Public License as published by the Free Software Foundation;
//// either version 2.1 of the License, or (at your option) any
////
//// later version.
////
////
////
//// This source is distributed in the hope that it will be
////
//// useful, but WITHOUT ANY WARRANTY; without even the implied
////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
////
//// PURPOSE. See the GNU Lesser General Public License for more
//// details.
////
////
////
//// You should have received a copy of the GNU Lesser General
////
//// Public License along with this source; if not, download it
////
//// from http://www.opencores.org/lgpl.shtml
////
////
///////////////////////////////////////////////////////////////////
module crc_datapath
(
 //OUTPUTS
 output [31:0] crc_out,
 output [ 1:0] size_out,
 output [ 7:0] crc_idr_out,
 output [31:0] crc_poly_out,
 output [31:0] crc_init_out,
 //INPUTS
 input [31:0] bus_wr, //Write data Bus
 input [ 1:0] rev_in_type, //select type of reversion of bus
 input rev_out_type,
 input buffer_en,
 input byte_en,
 input crc_init_en,
 input crc_out_en,
 input crc_idr_en,
 input crc_poly_en,
 input buffer_rst,
 input bypass_byte0,
 input bypass_size,
 input [1:0] byte_sel,
 input [1:0] size_in,
 input clear_crc_init_sel,
 input set_crc_init_sel,
 input [1:0] crc_poly_size,
 input clk,
 input rst_n
);

//Reset definitions
localparam RESET_BUFFER       = 32'hffffffff;
localparam RESET_BYTE         = 32'hffffffff;
localparam RESET_BF_SIZE      = 2'b10;
localparam RESET_SIZE         = 2'b10;
localparam RESET_CRC_INIT_SEL = 1'b0;
localparam RESET_CRC_INIT     = 32'hffffffff;
localparam RESET_CRC_OUT      = 32'h0;
localparam RESET_CRC_IDR      = 8'h0;
localparam RESET_CRC_POLY     = 32'h04c11db7;

//Parameters definitions
localparam BYTE_0 = 2'b00; 
localparam BYTE_1 = 2'b01; 
localparam BYTE_2 = 2'b10; 
localparam BYTE_3 = 2'b11; 

localparam POLY_SIZE_32 = 2'b00;
localparam POLY_SIZE_16 = 2'b01;
localparam POLY_SIZE_8  = 2'b10;
localparam POLY_SIZE_7  = 2'b11;

//Flops Definition
reg [31:0] buffer_ff;
reg [31:0] byte_ff;
reg [31:0] crc_init_ff;
reg [31:0] crc_out_ff;
reg [31:0] crc_poly_ff;
reg [ 7:0] crc_idr_ff;
reg [ 1:0] bf_size_ff;
reg [ 1:0] size_ff;
reg crc_init_sel_ff;

//internal signals definition
reg [7:0] crc_data_in;
reg crc_poly_size_7; 
reg crc_poly_size_8; 
reg crc_poly_size_16;
reg crc_poly_size_32;
wire [31:0] bus_reversed;
wire [31:0] crc_init_mux;
wire [31:0] crc_unit_out;
wire [31:0] crc_poly_size_in;
wire [31:0] crc_out_rev;
wire [ 7:0] byte0_in;
wire [ 7:0] byte1_in;
wire [ 7:0] byte2_in;
wire [ 7:0] byte3_in;
wire [ 7:0] byte0_mux_out;

//Instantiatin of bit_reversed module 
//to perform reversion fuctionality according with rev_type bits
bit_reversal 
#(
 .DATA_SIZE ( 32 )
)REV_IN
(
 .data_out ( bus_reversed    ),
 .data_in  ( bus_wr          ),
 .rev_type ( rev_in_type     )
);

//Definition of Registers buffer_ff and byte_ff
always @(posedge clk)
 begin
  if(!rst_n)
   begin
    buffer_ff  <= RESET_BUFFER; 
    byte_ff    <= RESET_BYTE; 
   end 
  else
   begin
    if(buffer_en)
     buffer_ff <= bus_reversed;
    //else
    // if(buffer_rst)
    //  buffer_ff <= RESET_BUFFER;

    if(byte_en)
     byte_ff <= buffer_ff;
   end
 end

//Definition of Registers bf_size_ff and size_ff
always @(posedge clk)
 begin
  if(!rst_n)
   begin
    bf_size_ff <= RESET_BF_SIZE;
    size_ff    <= RESET_SIZE;
   end 
  else
   begin
    if(buffer_en)
     bf_size_ff <= size_in;
    else
     if(buffer_rst)
      bf_size_ff <= RESET_BF_SIZE;

    if(byte_en)
     size_ff <= bf_size_ff;
   end
 end

//Mux to bypass size_ff
//This informatin is used by FSM to decide the size of the current operatin  
assign size_out = (bypass_size) ? bf_size_ff : size_ff;

assign byte0_in = byte_ff[ 7: 0];
assign byte1_in = byte_ff[15: 8];
assign byte2_in = byte_ff[23:16];
assign byte3_in = byte_ff[31:24];

//Mux to bypass byte0_ff
assign byte0_mux_out = (bypass_byte0) ? buffer_ff[7:0] : byte0_in;

//Mux to select input of CRC Unit
//TODO:AVALIAR A INFLUENCIA DA CODIFICACAO DA FSM NO SINAL BYTE_SEL 
always @(*)
 begin
  crc_data_in = 32'h0;
  case(byte_sel)
   BYTE_0: crc_data_in = byte0_mux_out;
   BYTE_1: crc_data_in = byte1_in;
   BYTE_2: crc_data_in = byte2_in;
   BYTE_3: crc_data_in = byte3_in;
   default:crc_data_in = 32'h0;
  endcase
 end

//Definition of Register crc_init_sel_ff
//This is a set/clear flop where the clear wins set
//This flop controls when the CRC operation is chained (crc_init_sel_ff = 1) or not
//In the chained operatin the current crc calculation depends of the previous crc calculated
//in the unchained operatin the current crc calculation depends of value of crc_init register
always @(posedge clk)
 begin
  if(!rst_n)
   crc_init_sel_ff <= RESET_CRC_INIT_SEL;
  else
   begin
    if(clear_crc_init_sel)
     crc_init_sel_ff <= 1'b0;
    else
     if(set_crc_init_sel)
      crc_init_sel_ff <= 1'b1;
   end
 end

//This register contains the init value used in non chained operatin of crc
assign crc_init_out = crc_init_ff;
always @(posedge clk)
 begin
  if(!rst_n)
   crc_init_ff <= RESET_CRC_INIT;
  else
   if(crc_init_en) 
    crc_init_ff <= bus_wr;
	 else
	   if(buffer_rst)
			 crc_init_ff <= RESET_CRC_INIT;
 end

//This register contains the final value of crc
always @(posedge clk)
 begin
  if(!rst_n)
   crc_out_ff <= RESET_CRC_OUT;
  else
   if(crc_out_en) 
    crc_out_ff <= crc_unit_out;
 end

//this is a general purpouse register
//see the spec for more details
assign crc_idr_out = crc_idr_ff;
always @(posedge clk)
 begin
  if(!rst_n)
   crc_idr_ff <= RESET_CRC_IDR;
  else
   if(crc_idr_en) 
    crc_idr_ff <= bus_wr[7:0];
 end

//This register contains the polynomial coefficients to crc calculation
assign crc_poly_out = crc_poly_ff;
always @(posedge clk)
 begin
  if(!rst_n)
   crc_poly_ff <= RESET_CRC_POLY;
  else
   if(crc_poly_en) 
    crc_poly_ff <= bus_wr;
 end

//Mux that define the type of operation (chained or not)    
assign crc_init_mux = (crc_init_sel_ff) ? crc_out_ff : crc_init_ff;

//Decoding of crc_poly_sizesignal
always @(*)
 begin
  crc_poly_size_7  = 1'b0;
  crc_poly_size_8  = 1'b0;
  crc_poly_size_16 = 1'b0;
  crc_poly_size_32 = 1'b0;
  case(crc_poly_size)
   POLY_SIZE_7 : crc_poly_size_7  = 1'b1;
   POLY_SIZE_8 : crc_poly_size_8  = 1'b1;
   POLY_SIZE_16: crc_poly_size_16 = 1'b1;
   POLY_SIZE_32: crc_poly_size_32 = 1'b1;
  endcase
 end

//This signal define the configurability of the CRC Unit
//In this case, the size of the polynomial can be: 7, 8, 16 or 32
assign crc_poly_size_in = {crc_poly_size_32, 15'h0, crc_poly_size_16, 7'h0, crc_poly_size_8, crc_poly_size_7, 6'h0};

//Instanciation of CRC Unit
//The module is configured to calculate CRC of 32 bits for 8 bits of data in parallel
crc_parallel
#(
 .CRC_SIZE   ( 32 ),
 .FRAME_SIZE ( 8  )
)CRC_UNIT
(
 .crc_out       ( crc_unit_out     ),
 .data_in       ( crc_data_in      ),
 .crc_init      ( crc_init_mux     ),
 .crc_poly      ( crc_poly_ff      ),
 .crc_poly_size ( crc_poly_size_in )
);

//crc_out_rev[31:0] = crc_out_ff[0:31]
generate
 genvar i;
 for(i = 0; i < 32; i = i + 1)
  assign crc_out_rev[i] = crc_out_ff[31 - i];
endgenerate

assign crc_out = (rev_out_type) ? crc_out_rev : crc_out_ff;

endmodule
