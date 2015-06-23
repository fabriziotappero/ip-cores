//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's register file inside CPU                           ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Instantiation of register file memories                     ////
////                                                              ////
////  To Do:                                                      ////
////   - make it smaller and faster                               ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.2  2002/06/08 16:19:09  lampret
// Added generic flip-flop based memory macro instantiation.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.13  2001/11/20 18:46:15  simons
// Break point bug fixed
//
// Revision 1.12  2001/11/13 10:02:21  lampret
// Added 'setpc'. Renamed some signals (except_flushpipe into flushpipe etc)
//
// Revision 1.11  2001/11/12 01:45:40  lampret
// Moved flag bit into SR. Changed RF enable from constant enable to dynamic enable for read ports.
//
// Revision 1.10  2001/11/10 03:43:57  lampret
// Fixed exceptions.
//
// Revision 1.9  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.8  2001/10/14 13:12:10  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
//
// Revision 1.3  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.2  2001/07/22 03:31:54  lampret
// Fixed RAM's oen bug. Cache bypass under development.
//
// Revision 1.1  2001/07/20 00:46:21  lampret
// Development version of RTL. Libraries are missing.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_rf_cm2(
		clk_i_cml_1,
		cmls,
		
	// Clock and reset
	clk, rst,

	// Write i/f
	supv, wb_freeze, addrw, dataw, we, flushpipe,

	// Read i/f
	id_freeze, addra, addrb, dataa, datab, rda, rdb,

	// Debug
	spr_cs, spr_write, spr_addr, spr_dat_i, spr_dat_o
);


input clk_i_cml_1;
input cmls;
reg [ 5 - 1 : 0 ] addrw_cml_1;
reg  spr_cs_cml_1;
reg  spr_write_cml_1;
reg [ 31 : 0 ] spr_addr_cml_1;
reg [ 31 : 0 ] spr_dat_i_cml_1;
reg [ 32 : 0 ] dataa_saved_cml_1;
reg [ 32 : 0 ] datab_saved_cml_1;
reg  rf_we_allow_cml_1;
reg [ 32 - 1 : 0 ] from_rfa_int_cml_1;
reg [ 32 - 1 : 0 ] from_rfb_int_cml_1;
reg [ 4 : 0 ] rf_addra_reg_cml_1;
reg [ 4 : 0 ] rf_addrb_reg_cml_1;



parameter dw = `OR1200_OPERAND_WIDTH;
parameter aw = `OR1200_REGFILE_ADDR_WIDTH;

//
// I/O
//

//
// Clock and reset
//
input				clk;
input				rst;

//
// Write i/f
//
input				supv;
input				wb_freeze;
input	[aw-1:0]		addrw;
input	[dw-1:0]		dataw;
input				we;
input				flushpipe;

//
// Read i/f
//
input				id_freeze;
input	[aw-1:0]		addra;
input	[aw-1:0]		addrb;
output	[dw-1:0]		dataa;
output	[dw-1:0]		datab;
input				rda;
input				rdb;

//
// SPR access for debugging purposes
//
input				spr_cs;
input				spr_write;
input	[31:0]			spr_addr;
input	[31:0]			spr_dat_i;
output	[31:0]			spr_dat_o;

//
// Internal wires and regs
//
wire	[dw-1:0]		from_rfa;
wire	[dw-1:0]		from_rfb;
reg	[dw:0]			dataa_saved;
reg	[dw:0]			datab_saved;
wire	[aw-1:0]		rf_addra;
wire	[aw-1:0]		rf_addrw;
wire	[dw-1:0]		rf_dataw;
wire				rf_we;
wire				spr_valid;
wire				rf_ena;
wire				rf_enb;
reg				rf_we_allow;

//
// SPR access is valid when spr_cs is asserted and
// SPR address matches GPR addresses
//

// SynEDA CoreMultiplier
// assignment(s): spr_valid
// replace(s): spr_cs, spr_addr
assign spr_valid = spr_cs_cml_1 & (spr_addr_cml_1[10:5] == `OR1200_SPR_RF);

//
// SPR data output is always from RF A
//
assign spr_dat_o = from_rfa;

//
// Operand A comes from RF or from saved A register
//

// SynEDA CoreMultiplier
// assignment(s): dataa
// replace(s): dataa_saved
assign dataa = (dataa_saved_cml_1[32]) ? dataa_saved_cml_1[31:0] : from_rfa;

//
// Operand B comes from RF or from saved B register
//

// SynEDA CoreMultiplier
// assignment(s): datab
// replace(s): datab_saved
assign datab = (datab_saved_cml_1[32]) ? datab_saved_cml_1[31:0] : from_rfb;

//
// RF A read address is either from SPRS or normal from CPU control
//

// SynEDA CoreMultiplier
// assignment(s): rf_addra
// replace(s): spr_write, spr_addr
assign rf_addra = (spr_valid & !spr_write_cml_1) ? spr_addr_cml_1[4:0] : addra;

//
// RF write address is either from SPRS or normal from CPU control
//

// SynEDA CoreMultiplier
// assignment(s): rf_addrw
// replace(s): addrw, spr_write, spr_addr
assign rf_addrw = (spr_valid & spr_write_cml_1) ? spr_addr_cml_1[4:0] : addrw_cml_1;

//
// RF write data is either from SPRS or normal from CPU datapath
//

// SynEDA CoreMultiplier
// assignment(s): rf_dataw
// replace(s): spr_write, spr_dat_i
assign rf_dataw = (spr_valid & spr_write_cml_1) ? spr_dat_i_cml_1 : dataw;

//
// RF write enable is either from SPRS or normal from CPU control
//

// SynEDA CoreMultiplier
// assignment(s): rf_we_allow
// replace(s): rf_we_allow
always @(posedge rst or posedge clk)
	if (rst)
		rf_we_allow <= #1 1'b1;
	else begin  rf_we_allow <= rf_we_allow_cml_1; if (~wb_freeze)
		rf_we_allow <= #1 ~flushpipe; end


// SynEDA CoreMultiplier
// assignment(s): rf_we
// replace(s): spr_write, rf_we_allow
assign rf_we = ((spr_valid & spr_write_cml_1) | (we & ~wb_freeze)) & rf_we_allow_cml_1 & (supv | (|rf_addrw));

//
// CS RF A asserted when instruction reads operand A and ID stage
// is not stalled
//
assign rf_ena = rda & ~id_freeze | spr_valid;	// probably works with fixed binutils
// assign rf_ena = 1'b1;			// does not work with single-stepping
//assign rf_ena = ~id_freeze | spr_valid;	// works with broken binutils 

//
// CS RF B asserted when instruction reads operand B and ID stage
// is not stalled
//
assign rf_enb = rdb & ~id_freeze | spr_valid;
// assign rf_enb = 1'b1;
//assign rf_enb = ~id_freeze | spr_valid;	// works with broken binutils 

//
// Stores operand from RF_A into temp reg when pipeline is frozen
//

// SynEDA CoreMultiplier
// assignment(s): dataa_saved
// replace(s): dataa_saved
always @(posedge clk or posedge rst)
	if (rst) begin
		dataa_saved <= #1 33'b0;
	end
	else begin  dataa_saved <= dataa_saved_cml_1; if (id_freeze & !dataa_saved_cml_1[32]) begin
		dataa_saved <= #1 {1'b1, from_rfa};
	end
	else if (!id_freeze)
		dataa_saved <= #1 33'b0; end

//
// Stores operand from RF_B into temp reg when pipeline is frozen
//

// SynEDA CoreMultiplier
// assignment(s): datab_saved
// replace(s): datab_saved
always @(posedge clk or posedge rst)
	if (rst) begin
		datab_saved <= #1 33'b0;
	end
	else begin  datab_saved <= datab_saved_cml_1; if (id_freeze & !datab_saved_cml_1[32]) begin
		datab_saved <= #1 {1'b1, from_rfb};
	end
	else if (!id_freeze)
		datab_saved <= #1 33'b0; end

`ifdef OR1200_RFRAM_TWOPORT

//
// Instantiation of register file two-port RAM A
//
or1200_tpram_32x32 rf_a(
	// Port A
	.clk_a(clk),
	.rst_a(rst),
	.ce_a(rf_ena),
	.we_a(1'b0),
	.oe_a(1'b1),
	.addr_a(rf_addra),
	.di_a(32'h0000_0000),
	.do_a(from_rfa),

	// Port B
	.clk_b(clk),
	.rst_b(rst),
	.ce_b(rf_we),
	.we_b(rf_we),
	.oe_b(1'b0),
	.addr_b(rf_addrw),
	.di_b(rf_dataw),
	.do_b()
);

//
// Instantiation of register file two-port RAM B
//
or1200_tpram_32x32 rf_b(
	// Port A
	.clk_a(clk),
	.rst_a(rst),
	.ce_a(rf_enb),
	.we_a(1'b0),
	.oe_a(1'b1),
	.addr_a(addrb),
	.di_a(32'h0000_0000),
	.do_a(from_rfb),

	// Port B
	.clk_b(clk),
	.rst_b(rst),
	.ce_b(rf_we),
	.we_b(rf_we),
	.oe_b(1'b0),
	.addr_b(rf_addrw),
	.di_b(rf_dataw),
	.do_b()
);

`else

`ifdef OR1200_RFRAM_DUALPORT

//
// Instantiation of register file two-port RAM A
//
or1200_dpram_32x32 rf_a(
	// Port A
	.clk_a(clk),
	.rst_a(rst),
	.ce_a(rf_ena),
	.oe_a(1'b1),
	.addr_a(rf_addra),
	.do_a(from_rfa),

	// Port B
	.clk_b(clk),
	.rst_b(rst),
	.ce_b(rf_we),
	.we_b(rf_we),
	.addr_b(rf_addrw),
	.di_b(rf_dataw)
);

//
// Instantiation of register file two-port RAM B
//
or1200_dpram_32x32 rf_b(
	// Port A
	.clk_a(clk),
	.rst_a(rst),
	.ce_a(rf_enb),
	.oe_a(1'b1),
	.addr_a(addrb),
	.do_a(from_rfb),

	// Port B
	.clk_b(clk),
	.rst_b(rst),
	.ce_b(rf_we),
	.we_b(rf_we),
	.addr_b(rf_addrw),
	.di_b(rf_dataw)
);

`else

`ifdef OR1200_RFRAM_GENERIC

//
// Instantiation of generic (flip-flop based) register file
//
or1200_rfram_generic rf_a(
	// Clock and reset
	.clk(clk),
	.rst(rst),

	// Port A
	.ce_a(rf_ena),
	.addr_a(rf_addra),
	.do_a(from_rfa),

	// Port B
	.ce_b(rf_enb),
	.addr_b(addrb),
	.do_b(from_rfb),

	// Port W
	.ce_w(rf_we),
	.we_w(rf_we),
	.addr_w(rf_addrw),
	.di_w(rf_dataw)
);

`else


`ifdef OR1200_RAM_MODELS_VIRTEX

//
//	Non-generic FPGA model instantiations
//

//	write port: no add-reg
//	read port: add-reg

//	write port
//	a -> rf_addrw
//	d -> rf_dataw
//	we -> rf_we
//	spo -> open

//	read port
//	dpra -> rf_addra_reg registered
//	dpo -> from_rfa_int

wire	[dw-1:0]		from_rfa_int;
wire	[dw-1:0]		from_rfb_int;

reg	[4:0]	rf_addra_reg;		// RAM address a registered
reg	[4:0]	rf_addrb_reg;		// RAM address b registered


// SynEDA CoreMultiplier
// assignment(s): rf_addra_reg
// replace(s): rf_addra_reg
always @(posedge clk or posedge rst)
	if (rst)
		rf_addra_reg <= #1 {32{1'b0}};
	else begin  rf_addra_reg <= rf_addra_reg_cml_1; if (rf_ena)
		rf_addra_reg <= #1 rf_addra; end



// SynEDA CoreMultiplier
// assignment(s): rf_addrb_reg
// replace(s): rf_addrb_reg
always @(posedge clk or posedge rst)
	if (rst)
		rf_addrb_reg <= #1 {32{1'b0}};
	else begin  rf_addrb_reg <= rf_addrb_reg_cml_1; if (rf_enb)
		rf_addrb_reg <= #1 addrb; end

rf_sub_cm2 rf_sub_ia(
		.cmls(cmls),
	.a(rf_addrw),
	.d(rf_dataw),
	.dpra(rf_addra_reg),
	.clk(clk),
	.we(rf_we),
	.spo(),
	.dpo(from_rfa_int));

rf_sub_cm2 rf_sub_ib(
		.cmls(cmls),
	.a(rf_addrw),
	.d(rf_dataw),
	.dpra(rf_addrb_reg),
	.clk(clk),
	.we(rf_we),
	.spo(),
	.dpo(from_rfb_int));


// SynEDA CoreMultiplier
// assignment(s): from_rfa
// replace(s): from_rfa_int, rf_addra_reg
assign from_rfa = (rf_addra_reg_cml_1 == 5'h00) ? 32'h00000000 : from_rfa_int_cml_1;

// SynEDA CoreMultiplier
// assignment(s): from_rfb
// replace(s): from_rfb_int, rf_addrb_reg
assign from_rfb = (rf_addrb_reg_cml_1 == 5'h00) ? 32'h00000000 : from_rfb_int_cml_1;

`else

//
// RFRAM type not specified
//
initial begin
	$display("Define RFRAM type.");
	$finish;
end

`endif
`endif
`endif
`endif


always @ (posedge clk_i_cml_1) begin
addrw_cml_1 <= addrw;
spr_cs_cml_1 <= spr_cs;
spr_write_cml_1 <= spr_write;
spr_addr_cml_1 <= spr_addr;
spr_dat_i_cml_1 <= spr_dat_i;
dataa_saved_cml_1 <= dataa_saved;
datab_saved_cml_1 <= datab_saved;
rf_we_allow_cml_1 <= rf_we_allow;
from_rfa_int_cml_1 <= from_rfa_int;
from_rfb_int_cml_1 <= from_rfb_int;
rf_addra_reg_cml_1 <= rf_addra_reg;
rf_addrb_reg_cml_1 <= rf_addrb_reg;
end
endmodule

