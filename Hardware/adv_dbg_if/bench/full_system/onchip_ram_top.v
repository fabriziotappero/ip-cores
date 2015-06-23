//////////////////////////////////////////////////////////////////////
////                                                              ////
////  onchip_ram_top.v                                            ////
////                                                              ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       De Nayer Instituut (emsys.denayer.wenk.be)             ////
////       Nathan Yawn (nathan.yawn@epfl.ch)                      ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2003-2008 Authors                              ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//                                                                  //
// This file is a simple wrapper for on-chip (FPGA) RAM blocks,     //
// coupled with a simple WISHBONE bus interface.  It supports 2-    //
// cycle writes, and 1-cycle reads.  Bursts using bus tags (for     //
// registered-feedback busses) are not supported at present.        //
// Altera ALTSYNCRAM blocks are instantiated directly.  Xilinx      //
// BRAM blocks are not as easy to declare for a wide range of       //
// devices, they are implied instead of declared directly.          //
//                                                                  //
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: onchip_ram_top.v,v $
// Revision 1.1  2010-03-29 19:34:52  Nathan
// The onchip_ram memory unit is not distributed on the OpenCores website as of this checkin; this version of the core may be used with the advanced debug system testbench until it is.
//
// Revision 1.1  2008/07/18 20:13:48  Nathan
// Changed directory structure to match existing projects.
//
// Revision 1.2  2008/05/22 19:56:36  Nathan
// Added implied BRAM for Xilinx FPGAs.  Also added copyright, CVS log, and brief description.
//


`define ALTERA


module onchip_ram_top (
wb_clk_i, wb_rst_i,
wb_dat_i, wb_dat_o, wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i,
wb_stb_i, wb_ack_o, wb_err_o
);

// Function to calculate width of address signal.
function integer log2;
input [31:0] value;
for (log2=0; value>0; log2=log2+1)
value = value>>1;
endfunction

//
// Parameters
//
parameter dwidth = 32;
parameter size_bytes = 4096;
parameter initfile = "NONE";
parameter words = (size_bytes / (dwidth/8));  // Don't override this.  Really.
parameter awidth = log2(size_bytes)-1;  // Don't override this either.
parameter bewidth = (dwidth/8);  // Or this.

//
// I/O Ports
//
input wb_clk_i;
input wb_rst_i;
//
// WB slave i/f
//
input [dwidth-1:0] wb_dat_i;
output [dwidth-1:0] wb_dat_o;
input [awidth-1:0] wb_adr_i;
input [bewidth-1:0] wb_sel_i;
input wb_we_i;
input wb_cyc_i;
input wb_stb_i;
output wb_ack_o;
output wb_err_o;
//
// Internal regs and wires
//
wire we;
wire [bewidth-1:0] be_i;
wire [dwidth-1:0] wb_dat_o;
wire ack_we;
reg ack_we1;
reg ack_we2;
reg ack_re;

//
// Aliases and simple assignments
//
assign wb_ack_o = ack_re | ack_we;
assign wb_err_o = 1'b0;  //wb_cyc_i & wb_stb_i & ???; 
assign we = wb_cyc_i & wb_stb_i & wb_we_i & (|wb_sel_i[bewidth-1:0]);
assign be_i = (wb_cyc_i & wb_stb_i) * wb_sel_i;

//
// Write acknowledge
// Little trick to keep the writes single-cycle:
// set the write ack signal on the falling clk edge, so it will be set halfway through the
// cycle and be registered at the end of the first clock cycle.  To prevent contention for
// the next half-cycle, latch the ack_we1 signal on the next rising edge, and force the
// bus output low when that latched signal is high.
always @ (negedge wb_clk_i or posedge wb_rst_i)
begin
	if (wb_rst_i)
		ack_we1 <= 1'b0;
	else
		if (wb_cyc_i & wb_stb_i & wb_we_i & ~ack_we)
			ack_we1 <= #1 1'b1;
		else
			ack_we1 <= #1 1'b0;
end

always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
	if (wb_rst_i)
		ack_we2 <= 1'b0;
	else
		ack_we2 <= ack_we1;
end

assign ack_we = ack_we1 & ~ack_we2;


//
// read acknowledge
//
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
	if (wb_rst_i)
		ack_re <= 1'b0;
	else
		if (wb_cyc_i & wb_stb_i & ~wb_err_o & ~wb_we_i & ~ack_re)
			ack_re <= 1'b1;
		else
			ack_re <= 1'b0;
end


`ifdef ALTERA
//
// change intended_device_family according to the FPGA device (Stratix or Cyclone)
//
altsyncram altsyncram_component (
.wren_a (we),
.clock0 (wb_clk_i),
.byteena_a (be_i),
.address_a (wb_adr_i[awidth-1:2]),
.data_a (wb_dat_i),
.q_a (wb_dat_o));
defparam
altsyncram_component.intended_device_family = "CycloneII",
altsyncram_component.width_a = dwidth,
altsyncram_component.widthad_a = (awidth-2),
altsyncram_component.numwords_a = (words),
altsyncram_component.operation_mode = "SINGLE_PORT",
altsyncram_component.outdata_reg_a = "UNREGISTERED",
altsyncram_component.indata_aclr_a = "NONE",
altsyncram_component.wrcontrol_aclr_a = "NONE",
altsyncram_component.address_aclr_a = "NONE",
altsyncram_component.outdata_aclr_a = "NONE",
altsyncram_component.width_byteena_a = bewidth,
altsyncram_component.byte_size = 8,
altsyncram_component.byteena_aclr_a = "NONE",
altsyncram_component.ram_block_type = "AUTO",
altsyncram_component.lpm_type = "altsyncram",
altsyncram_component.init_file = initfile;


`else
// Xilinx does not have anything so neat as a resizable memory array.
// We use generic code, which will imply a BRAM array.
// This will also work for non-Xilinx architectures, but be warned that
// it will not be recognized as an implied RAM block by the current Altera
// tools.

// The actual memory array...4 banks, for 4 separate byte lanes
reg [7:0] mem_bank0 [0:(words-1)];
reg [7:0] mem_bank1 [0:(words-1)];
reg [7:0] mem_bank2 [0:(words-1)];
reg [7:0] mem_bank3 [0:(words-1)];

// Write enables, qualified with byte lane enables
wire we_0, we_1, we_2, we_3;

// Enable, indicates any read or write operation
wire en;

// Yes, separate address registers, which will hold identical data.  This
// is necessary to correctly imply a Xilinx BRAM.  Because that's just
// how they roll.
reg [(awidth-3):0] addr_reg0;
reg [(awidth-3):0] addr_reg1;
reg [(awidth-3):0] addr_reg2;
reg [(awidth-3):0] addr_reg3;

assign we_0 = be_i[0] & wb_we_i;
assign we_1 = be_i[1] & wb_we_i;
assign we_2 = be_i[2] & wb_we_i;
assign we_3 = be_i[3] & wb_we_i;

assign en = (|be_i);

// Sequential bits.  Setting of the address registers, and memory array writes.
always @ (posedge wb_clk_i)
begin
	if (en) 
		begin
		addr_reg0 <= wb_adr_i[(awidth-1):2];
		if (we_0)
		begin
			mem_bank0[wb_adr_i[(awidth-1):2]] <= wb_dat_i[7:0];
		end
	end

	if (en) 
		begin
		addr_reg1 <= wb_adr_i[(awidth-1):2];
		if (we_1)
		begin
			mem_bank1[wb_adr_i[(awidth-1):2]] <= wb_dat_i[15:8];
		end
	end

	if (en) 
		begin
		addr_reg2 <= wb_adr_i[(awidth-1):2];
		if (we_2)
		begin
			mem_bank2[wb_adr_i[(awidth-1):2]] <= wb_dat_i[23:16];
		end
	end

	if (en) 
		begin
		addr_reg3 <= wb_adr_i[(awidth-1):2];
		if (we_3)
		begin
			mem_bank3[wb_adr_i[(awidth-1):2]] <= wb_dat_i[31:24];
		end
	end

end


// Data output.  Combinatorial, no output register.
assign wb_dat_o = {mem_bank3[addr_reg2], mem_bank2[addr_reg2], mem_bank1[addr_reg1], mem_bank0[addr_reg0]};

`endif

endmodule
