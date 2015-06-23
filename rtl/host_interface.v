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
module host_interface
(
	//OUTPUTS
	output [31:0] HRDATA,
	output HREADYOUT,
	output HRESP,
	output [31:0] bus_wr,
	output [ 1:0] crc_poly_size,
	output [ 1:0] bus_size,
	output [ 1:0] rev_in_type,
	output rev_out_type,
	output crc_init_en,
	output crc_idr_en,
	output crc_poly_en,
	output buffer_write_en,
	output reset_chain,
	//INPUTS
	input [31:0] HWDATA,
	input [31:0] HADDR,
	input [ 2:0] HSIZE,
	input [ 1:0] HTRANS,
	input HWRITE,
	input HSElx,
	input HREADY,
	input HRESETn,
	input HCLK,
	input [31:0] crc_poly_out,
	input [31:0] crc_out,
	input [31:0] crc_init_out,
	input [ 7:0] crc_idr_out,
	input buffer_full,
	input reset_pending,
	input read_wait
);

//Reset Values
localparam RESET_CRC_CR = 6'h00;

//CRC Register Map
localparam CRC_DR   = 3'h0;
localparam CRC_IDR  = 3'h1;
localparam CRC_CR   = 3'h2;
localparam CRC_INIT = 3'h4;
localparam CRC_POL  = 3'h5;

//Transfer Type Encoding
localparam IDLE    = 2'b00;
localparam BUSY    = 2'b01;
localparam NON_SEQ = 2'b10;
localparam SEQ     = 2'b11;

//HRESP Encoding
localparam OK    = 1'b0;
localparam ERROR = 1'b1;

//Pipeline flops
reg [2:0] haddr_pp;
reg [2:0] hsize_pp;
reg [1:0] htrans_pp;
reg hwrite_pp;
reg hselx_pp;

//Flops
reg [4:0] crc_cr_ff;

//Internal Signals
wire [31:0] crc_cr_rd;
wire crc_dr_sel;
wire crc_init_sel;
wire crc_idr_sel;
wire crc_poly_sel;
wire crc_cr_sel;
wire ahb_enable;
wire write_en;
wire read_en;
wire crc_cr_en;
wire sample_bus;
wire buffer_read_en;

//Pipeline Registers for Address Phase of AHB Protocol
always @(posedge HCLK)
	begin
		if(!HRESETn)
			begin
				hselx_pp <= 1'b0;
			end
		else
			if(sample_bus)
				begin
					haddr_pp  <= HADDR[4:2];
					hsize_pp  <= HSIZE;
					htrans_pp <= HTRANS;
					hwrite_pp <= HWRITE;
					hselx_pp  <= HSElx;
				end
	end

//Enable Signals
assign ahb_enable = (htrans_pp == NON_SEQ);
assign write_en = hselx_pp &&  hwrite_pp && ahb_enable;
assign read_en  = hselx_pp && !hwrite_pp && ahb_enable;

//Registers decoding
assign crc_dr_sel   = (haddr_pp == CRC_DR  );
assign crc_init_sel = (haddr_pp == CRC_INIT);
assign crc_idr_sel  = (haddr_pp == CRC_IDR );
assign crc_poly_sel = (haddr_pp == CRC_POL );
assign crc_cr_sel   = (haddr_pp == CRC_CR  );

//Write Esnables Signals for Registers
assign buffer_write_en = crc_dr_sel   && write_en;
assign crc_init_en     = crc_init_sel && write_en;
assign crc_idr_en      = crc_idr_sel  && write_en;
assign crc_poly_en     = crc_poly_sel && write_en;
assign crc_cr_en       = crc_cr_sel   && write_en;

//Indicates reading operation request to crc_dr register
assign buffer_read_en = crc_dr_sel && read_en;

//Bus Size is the output of HSIZE pipeline register
assign bus_size = hsize_pp;

//The Write Bus is not pipelined
assign bus_wr = HWDATA;

//HREADY Signal outputed to Master
assign HREADYOUT = !((buffer_write_en && buffer_full   ) ||
                     (buffer_read_en  && read_wait     ) ||
                     (crc_init_en     && reset_pending ) );

//Signal to control sampling of bus
assign sample_bus = HREADYOUT && HREADY;

//HRESP Signal outputed to Master
//This implementation never signalize bus error to master
assign HRESP = OK;

//CRC_CR Data Read
assign crc_cr_rd = {24'h0, crc_cr_ff[4:0], 3'h0};

//Mux to HRDATA
assign HRDATA = ({32{crc_dr_sel  }} & crc_out             ) |
                ({32{crc_init_sel}} & crc_init_out        ) |
                ({32{crc_idr_sel }} & {24'h0, crc_idr_out}) |
                ({32{crc_poly_sel}} & crc_poly_out        ) |
                ({32{crc_cr_sel  }} & crc_cr_rd           ) ;

//Control Register
always @(posedge HCLK)
	begin
		if(!HRESETn)
			crc_cr_ff <= RESET_CRC_CR;
		else
			if(crc_cr_en)
				crc_cr_ff <= {HWDATA[7], HWDATA[6:5], HWDATA[4:3]};
	end

//Configuration Signals
assign reset_chain   = (crc_cr_en && HWDATA[0]);
assign crc_poly_size = crc_cr_ff[1:0];
assign rev_in_type   = crc_cr_ff[3:2];
assign rev_out_type  = crc_cr_ff[4];

endmodule
