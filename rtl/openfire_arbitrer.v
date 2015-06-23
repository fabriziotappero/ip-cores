/*	MODULE: openfire arbitrer
	DESCRIPTION: Contains data/instruction memory decoder and arbitrer for 
		several peripherals

AUTHOR: 
Antonio J. Anton
Anro Ingenieros (www.anro-ingenieros.com)
aj@anro-ingenieros.com

REVISION HISTORY:
Revision 1.0, 26/03/2007
Initial release

COPYRIGHT:
Copyright (c) 2007 Antonio J. Anton

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.*/`timescale 1ns / 1ps
`include "openfire_define.v"

module openfire_arbitrer(
`ifdef SP3SK_SRAM
	sram_data2mem, sram_data2cpu, 
	sram_dmem_re, sram_dmem_we, sram_dmem_done,
	sram_ins2cpu, sram_imem_re, sram_imem_done,
`endif
`ifdef IO_MULTICYCLE
	dmem_done_io,
`endif
`ifdef ENABLE_ALIGNMENT_EXCEPTION
	dmem_alignment_exception,
`endif
`ifdef SP3SK_IODEVICES
	dmem_data_fromio, dmem_data_toio, dmem_we_io, dmem_re_io,
`endif
	clock, reset, imem_done, dmem_done,
	dmem_address, dmem_data_out, dmem_data_in, dmem_re, dmem_we, 
	dmem_input_sel, data_selector,
	imem_address, imem_data, imem_re,		
	dmem_data_frombram, dmem_data_tobram, dmem_we_bram, 
	imem_data_frombram
);

input 		  clock;					// clock signal
input			  reset;					// reset signal
output		  imem_done;			// imem operation done
output		  dmem_done;			// dmem operation done

input	 [31:0] dmem_address;		// dmem address from cpu
output [31:0] dmem_data_out;		// data-out to cpu (from arbitrer multiplexer)
input	 [31:0] dmem_data_in;		// data-in from cpu to selected device
input			  dmem_re;				// cpu read enable signal
input			  dmem_we;				// cpu write enable signal
input	 [1:0]  dmem_input_sel;		// 0=byte, 1=hw, 2=word
output [3:0]  data_selector;		// each byte of the word (msb..lsb)
`ifdef ENABLE_ALIGNMENT_EXCEPTION
output		  dmem_alignment_exception;	// exception on hw/word alignment
`endif

input	 [31:0] imem_address;		// imem address from cpu
output [31:0] imem_data;			// instruction to cpu
input			  imem_re;				// instruction read enable

input	 [31:0] dmem_data_frombram;	// data from bram
output [31:0] dmem_data_tobram;		// data to bram
output 		  dmem_we_bram;			// write enable bram
input	 [31:0] imem_data_frombram;	// instruction from bram

`ifdef SP3SK_IODEVICES
input	 [31:0] dmem_data_fromio;		// data from iospace
output [31:0] dmem_data_toio;			// data to iospace
output		  dmem_we_io;				// write enable iospace
output		  dmem_re_io;				// read from iospace
`endif

`ifdef SP3SK_SRAM							// interface to external memory controller
output [31:0] sram_data2mem;
input  [31:0] sram_data2cpu;
output 		  sram_dmem_re;
output		  sram_dmem_we;
input			  sram_dmem_done;
input	 [31:0] sram_ins2cpu;
output		  sram_imem_re;
input			  sram_imem_done;
`endif
`ifdef IO_MULTICYCLE
input			  dmem_done_io;
`endif

// ---- read/write enable byte decoder and data selector -----
// this code generates de byte enable for a 32 bit word (4 bytes)
// based on dmem_address and dmem_input_sel (byte, hw or word)
// *** also generates unalignment exception
// *** also generates the memory to cpu data depending on the width
// of the request and the address
// *** also aligns the data from the cpu to the correct byte in the
// 32 bit word to be stored on memory

wire		 data_operation = dmem_re | dmem_we;
reg [3:0] data_selector;
`ifdef ENABLE_ALIGNMENT_EXCEPTION
reg		 dmem_alignment;
assign 	 dmem_alignment_exception = dmem_alignment & data_operation;
`endif

wire [31:0] dmem_data2cpu;		// bytes readed from device
reg  [31:0] dmem_data_out;
reg  [31:0] dmem_data2mem;		// data 2 memory

always @(dmem_input_sel or dmem_address[1:0] or dmem_data2cpu or dmem_data_in)
begin
`ifdef ENABLE_ALIGNMENT_EXCEPTION
   dmem_alignment <= 0;			// default value
`endif
   data_selector  <= 4'b0000;	// default no data selected
	dmem_data_out  <= 32'b0;
	dmem_data2mem  <= 32'bX;
	case(dmem_address[1:0])
	  2'b00: case(dmem_input_sel)
				  `DM_byte 	  	 : begin
				  							data_selector <= 4'b1000;
											dmem_data_out <= { dmem_data2cpu[31:24], 24'b0 };
											dmem_data2mem <= { dmem_data_in[7:0], 24'bX };
									   end
				  `DM_halfword  : begin
				  							data_selector <= 4'b1100;
											dmem_data_out <= { dmem_data2cpu[31:16], 16'b0 };
											dmem_data2mem <= { dmem_data_in[15:0],   16'bX };
									   end
  				  `DM_wholeword : begin
				  							data_selector <= 4'b1111;
											dmem_data_out <= dmem_data2cpu;
											dmem_data2mem <= dmem_data_in;
									   end
`ifdef ENABLE_ALIGNMENT_EXCEPTION
				  default:		   dmem_alignment <= 1;
`endif
			   endcase
     2'b01: case(dmem_input_sel)
	  			  `DM_byte		 : begin
				  							data_selector <= 4'b0100;
											dmem_data_out <= { dmem_data2cpu[23:16], 24'b0 };
											dmem_data2mem <= { 8'bX, dmem_data_in[7:0], 16'bX };
										end
`ifdef ENABLE_ALIGNMENT_EXCEPTION
				  default:		   dmem_alignment <= 1;
`endif
			   endcase
     2'b10: case(dmem_input_sel)
	  			  `DM_byte		 : begin
				  							data_selector <= 4'b0010;
											dmem_data_out <= {dmem_data2cpu[15:8], 24'b0 };
											dmem_data2mem <= { 16'bX, dmem_data_in[7:0], 8'bX };
										end
				  `DM_halfword  : begin
				  							data_selector <= 4'b0011;
											dmem_data_out <= {dmem_data2cpu[15:0], 16'b0 };
											dmem_data2mem <= { 16'bX, dmem_data_in[15:0] };
										end
`ifdef ENABLE_ALIGNMENT_EXCEPTION
				  default:	      dmem_alignment <= 1;
`endif
			   endcase
	  2'b11: case(dmem_input_sel)
	  			  `DM_byte		 : begin
				  							data_selector <= 4'b0001;
											dmem_data_out <= { dmem_data2cpu[7:0], 24'b0 };
											dmem_data2mem <= { 24'b0, dmem_data_in[7:0] };
										end
`ifdef ENABLE_ALIGNMENT_EXCEPTION
				  default:	      dmem_alignment <= 1;
`endif
			   endcase
   endcase
`ifdef ENABLE_ALIGNMENT_EXCEPTION
//synthesis translate_off
   if(dmem_alignment_exception) $display("ERROR!! Alignment exception");
//synthesis translate_on
`endif
end

// ---- data memory port chip select ----
// this logic generates the chip select based on the data address present

wire select_data_bram   = (dmem_address[`DM_SIZE-1:`DM_SIZE-2] == `LOCATION_BRAM || 
								   dmem_address[`DM_SIZE-1:`DM_SIZE-2] == `LOCATION_BRAM_WRAP);	// temporal!!!
`ifdef SP3SK_IODEVICES
wire select_data_io     =  dmem_address[`DM_SIZE-1:`DM_SIZE-2] == `LOCATION_IOSPACE;
`endif
`ifdef SP3SK_SRAM
wire  select_data_sram	=  dmem_address[`DM_SIZE-1:`DM_SIZE-2] == `LOCATION_SRAM;
`endif

// ---- instruction memory port chip select ----

wire select_ins_bram	   = imem_address[`DM_SIZE-1:`DM_SIZE-2] == `LOCATION_BRAM;
`ifdef SP3SK_SRAM
wire  select_ins_sram	= imem_address[`DM_SIZE-1:`DM_SIZE-2] == `LOCATION_SRAM;
`endif

// ---- operation completed on data port ----
`ifndef IO_MULTICYCLE
wire	 dmem_done_io = 1;			// no multicycle i/o
`endif

assign dmem_done = data_operation & ( select_data_bram	// data BRAM
`ifdef SP3SK_SRAM	 
						 | (select_data_sram & sram_dmem_done)	// data SRAM
`endif
`ifdef SP3SK_IODEVICES
						 | (select_data_io   & dmem_done_io)	// data IO
`endif
						);

// ---- operation completed on instruction port ----
assign imem_done = /*imem_re &*/ (select_ins_bram				// instruction BRAM
`ifdef SP3SK_SRAM
						 | (select_ins_sram & sram_imem_done)	// instruction SRAM
`endif
						);

// ---- data port operation enable ----
// data read BRAM always enabled
assign dmem_we_bram  	= dmem_we & select_data_bram;		// write enable to bram
`ifdef SP3SK_IODEVICES
assign dmem_we_io	      = dmem_we & select_data_io;
assign dmem_re_io			= dmem_re & select_data_io;
`endif
`ifdef SP3SK_SRAM
assign sram_dmem_re		= dmem_re & select_data_sram;		// read/write enable to sram
assign sram_dmem_we		= dmem_we & select_data_sram;
`endif

// ---- instruction port operation enable ----
// instruction read BRAM always 
`ifdef SP3SK_SRAM
wire   sram_imem_re		= select_ins_sram & imem_re;
`endif

// ----- instruction from memory to cpu multiplexer ----
`ifndef SP3SK_SRAM
assign imem_data			= imem_data_frombram;		// only BRAM
`else			
assign imem_data			= select_ins_bram ? imem_data_frombram : sram_ins2cpu;		// ins2cpu mux
`endif

// ----- data from memory to cpu multiplexer ----
`ifndef SP3SK_SRAM
`ifndef SP3SK_IODEVICES
assign dmem_data2cpu    = dmem_data_frombram;	// only BRAM
`else
assign dmem_data2cpu	   = select_data_io ? dmem_data_fromio : dmem_data_frombram;	// BRAM + IO
`endif
`else
`ifndef SP3SK_IODEVICES
assign dmem_data2cpu	   = select_data_sram ? sram_data2cpu : dmem_data_frombram;	// BRAM + SRAM
`else
assign dmem_data2cpu    = select_data_sram ? sram_data2cpu : 
								  select_data_io	 ? dmem_data_fromio :
								   						dmem_data_frombram;
`endif
`endif

// ---- data from cpu to all devices ----
assign dmem_data_tobram = dmem_data2mem;		// data from cpu to all devices
`ifdef SP3SK_IODEVICES
assign dmem_data_toio	= dmem_data2mem;
`endif
`ifdef SP3SK_SRAM
assign sram_data2mem	   = dmem_data2mem;
`endif

endmodule
