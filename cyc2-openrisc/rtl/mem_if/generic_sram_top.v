//////////////////////////////////////////////////////////////////////
////                                                              ////
////  XESS SRAM interface                                         ////
////                                                              ////
////  This file is part of the OR1K test application              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Connects the SoC to SRAM. It does RMW for byte accesses     ////
////  because XSV board has WEs on a 16-bit basis.                ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Srot, simons@opencores.org                      ////
////      - Igor Mohor, igorm@opencores.org                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Authors                                   ////
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
// Revision 1.2  2006/12/22 08:34:00  vak
// The design is successfully compiled using on-chip RAM.
//
// Revision 1.1  2006/12/21 16:46:58  vak
// Initial revision imported from
// http://www.opencores.org/cvsget.cgi/or1k/orp/orp_soc/rtl/verilog.
//
// Revision 1.7  2004/04/05 08:44:55  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.5  2002/09/16 02:51:23  lampret
// Delayed wb_err_o. Disabled wb_ack_o when wb_err_o is asserted.
//
// Revision 1.4  2002/08/18 19:55:30  lampret
// Added variable delay for SRAM.
//
// Revision 1.3  2002/08/14 06:24:43  lampret
// Fixed size of generic flash/sram to exactly 2MB
//
// Revision 1.2  2002/08/12 05:34:06  lampret
// Added SRAM_GENERIC
//
// Revision 1.1.1.1  2002/03/21 16:55:44  lampret
// First import of the "new" XESS XSV environment.
//
//
// Revision 1.3  2002/01/23 07:50:44  lampret
// Added wb_err_o to flash and sram i/f for testing the buserr exception.
//
// Revision 1.2  2002/01/14 06:18:22  lampret
// Fixed mem2reg bug in FAST implementation. Updated debug unit to work with new genpc/if.
//
// Revision 1.1.1.1  2001/11/04 19:00:09  lampret
// First import.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module generic_sram_top (
  wb_clk_i, wb_rst_i,

  wb_dat_i, wb_dat_o, wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i,
  wb_stb_i, wb_ack_o, wb_err_o

);

//
// Paraneters
//
parameter		aw = 19;
parameter      memfilename = "memory.hex";
// * memfilename is a parameter, and the corresponding file content
// * must follow the rules stated in Verilog standard for the
// * $readmemh() system task.
// * For instance if you don't change the default name you just
// * have to put a text file named "memory.hex" in your simulation
// * directory with the following content inside:
// *
// *   // We start from address zero by default:
// *   12
// *   34
// *   // Now we jump to doubleword number 10 (i.e. address 10):
// *   @ 10
// *   02

//
// I/O Ports
//
input			wb_clk_i;
input			wb_rst_i;

//
// WB slave i/f
//
input	[31:0]		wb_dat_i;
output	[31:0]		wb_dat_o;
input	[31:0]		wb_adr_i;
input	[3:0]		wb_sel_i;
input			wb_we_i;
input			wb_cyc_i;
input			wb_stb_i;
output			wb_ack_o;
output			wb_err_o;



//
// Internal wires and regs
//
reg     [7:0]           mem [2097151:0];
integer			i;
wire    [31:0]          adr;

`ifdef SRAM_GENERIC_REGISTERED
reg                     wb_err_o;
reg	[31:0]		prev_adr;
reg	[1:0]		delay;
`else
wire	[1:0]		delay;
`endif
wire                    wb_err;

//
// Aliases and simple assignments
//
assign wb_err = wb_cyc_i & wb_stb_i & (delay == 2'd0) & (|wb_adr_i[23:21]);     // If Access to > 2MB (8-bit leading prefix ignored)
assign adr = {8'h00, wb_adr_i[23:2], 2'b00};

//
// Reading from SRAM model
//
assign wb_dat_o[7:0] = mem[adr+3];
assign wb_dat_o[15:8] = mem[adr+2];
assign wb_dat_o[23:16] = mem[adr+1];
assign wb_dat_o[31:24] = mem[adr+0];

//
// Writing to SRAM model
//
always @(posedge wb_rst_i or posedge wb_clk_i)
        if (wb_cyc_i & wb_stb_i & wb_we_i) begin
                if (wb_sel_i[0])
                	mem[adr+3] <= #1 wb_dat_i[7:0];
                if (wb_sel_i[1])
                	mem[adr+2] <= #1 wb_dat_i[15:8];
                if (wb_sel_i[2])
                	mem[adr+1] <= #1 wb_dat_i[23:16];
                if (wb_sel_i[3])
                	mem[adr+0] <= #1 wb_dat_i[31:24];
        end

`ifdef SRAM_GENERIC_REGISTERED
//
// WB Acknowledge
//
always @(posedge wb_clk_i or posedge wb_rst_i)
        if (wb_rst_i) begin
                delay <= #1 2'd3;
                prev_adr <= #1 32'h0000_0000;
        end
        else if (delay && (wb_adr_i == prev_adr) && wb_cyc_i && wb_stb_i)
                delay <= #1 delay - 2'd1;
        else if (wb_ack_o || wb_err_o || (wb_adr_i != prev_adr) || ~wb_stb_i) begin
                delay <= #1 2'd2;       // delay ... can range from 3 to 0
                prev_adr <= #1 wb_adr_i;
        end
`else
assign delay = 2'd0;
`endif

assign wb_ack_o = wb_cyc_i & wb_stb_i & ~wb_err & (delay == 2'd0)
`ifdef SRAM_GENERIC_REGISTERED
        & (wb_adr_i == prev_adr)
`endif
        ;

`ifdef SRAM_GENERIC_REGISTERED
//
// WB Error
//
always @(posedge wb_clk_i or posedge wb_rst_i)
        if (wb_rst_i)
                wb_err_o <= #1 1'b0;
        else
                wb_err_o <= #1 wb_err & !wb_err_o;
`else
assign wb_err_o = wb_err;
`endif

//
// SRAM i/f monitor
//
// synopsys translate_off
integer fsram;
initial begin
	fsram = $fopen("sram.log");
	for (i = 0; i < 2097152; i = i + 1)
		mem[i] = 0;
   $readmemh(memfilename, mem);
   $display("INFO: MEMH %m: Memory initialization completed");
end
always @(posedge wb_clk_i)
        if (wb_cyc_i)
                if (wb_stb_i & wb_we_i) begin
                        if (wb_sel_i[3])
                                mem[{wb_adr_i[23:2], 2'b00}+0] = wb_dat_i[31:24];
                        if (wb_sel_i[2])
                                mem[{wb_adr_i[23:2], 2'b00}+1] = wb_dat_i[23:16];
                        if (wb_sel_i[1])
                                mem[{wb_adr_i[23:2], 2'b00}+2] = wb_dat_i[15:8];
                        if (wb_sel_i[0])
                                mem[{wb_adr_i[23:2], 2'b00}+3] = wb_dat_i[7:0];
                        $fdisplay(fsram, "%t [%h] <- write %h, byte sel %b", $time, wb_adr_i, wb_dat_i, wb_sel_i);
                end else if (wb_ack_o)
                        $fdisplay(fsram, "%t [%h] -> read %h", $time, wb_adr_i, wb_dat_o);
// synopsys translate_on

endmodule


