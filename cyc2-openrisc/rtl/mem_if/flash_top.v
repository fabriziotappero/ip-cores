//////////////////////////////////////////////////////////////////////
////                                                              ////
////  XESS Flash interface                                        ////
////                                                              ////
////  This file is part of the OR1K test application              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Connects the SoC to the Flash found on XSV board. It also   ////
////  implements a generic flash model for simulations.           ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////      - Lior Shtram, lior.shtram@flextronicssemi.com          ////
////      - Damjan Lampret, lampret@opencores.org                 ////
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
// Revision 1.1  2006/12/21 16:46:58  vak
// Initial revision imported from
// http://www.opencores.org/cvsget.cgi/or1k/orp/orp_soc/rtl/verilog.
//
// Revision 1.4  2002/09/16 02:51:23  lampret
// Delayed wb_err_o. Disabled wb_ack_o when wb_err_o is asserted.
//
// Revision 1.3  2002/08/14 06:24:43  lampret
// Fixed size of generic flash/sram to exactly 2MB
//
// Revision 1.2  2002/08/12 05:33:50  lampret
// Changed logic when FLASH_GENERIC_REGISTERED
//
// Revision 1.1.1.1  2002/03/21 16:55:44  lampret
// First import of the "new" XESS XSV environment.
//
//
// Revision 1.4  2002/02/11 04:41:01  lampret
// Allow flash writes. Ugly workaround for something else...
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
//`include "bench_define.v"

`ifdef FLASH_GENERIC

module flash_top (
  wb_clk_i, wb_rst_i,

  wb_dat_i, wb_dat_o, wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i,
  wb_stb_i, wb_ack_o, wb_err_o,

  flash_rstn, cen, oen, wen, rdy, d, a, a_oe
);

//
// I/O Ports
//

//
// Common WB signals
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
// Flash i/f
//
output			flash_rstn;
output			oen;
output			cen;
output			wen;
input			rdy;
inout	[7:0]		d;
output	[20:0]		a;
output			a_oe;

//
// Internal wires and regs
//
reg	[7:0]		mem [2097151:0];
wire	[31:0]		adr;
`ifdef FLASH_GENERIC_REGISTERED
reg			wb_err_o;
reg	[31:0]		prev_adr;
reg	[1:0]		delay;
`else
wire	[1:0]		delay;
`endif
wire			wb_err;

//
// Aliases and simple assignments
//
assign flash_rstn = 1'b1;
assign oen = 1'b1;
assign cen = 1'b1;
assign wen = 1'b1;
assign a = 21'b0;
assign a_oe = 1'b1;
assign wb_err = wb_cyc_i & wb_stb_i & (delay == 2'd0) & (|wb_adr_i[23:21]);     // If Access to > 2MB (8-bit leading prefix ignored)
assign adr = {8'h00, wb_adr_i[23:2], 2'b00};

//
// For simulation only
//
initial $readmemh("../src/flash.in", mem, 0);

//
// Reading from flash model
//
assign wb_dat_o[7:0] = wb_adr_i[23:0] < 65535 ? mem[adr+3] : 8'h00;
assign wb_dat_o[15:8] = wb_adr_i[23:0] < 65535 ? mem[adr+2] : 8'h00;
assign wb_dat_o[23:16] = wb_adr_i[23:0] < 65535 ? mem[adr+1] : 8'h00; 
assign wb_dat_o[31:24] = wb_adr_i[23:0] < 65535 ? mem[adr+0] : 8'h00; 


`ifdef FLASH_GENERIC_REGISTERED
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
		delay <= #1 2'd0;	// delay ... can range from 3 to 0
		prev_adr <= #1 wb_adr_i;
	end
`else
assign delay = 2'd0;
`endif

assign wb_ack_o = wb_cyc_i & wb_stb_i & ~wb_err & (delay == 2'd0)
`ifdef FLASH_GENERIC_REGISTERED
	& (wb_adr_i == prev_adr)
`endif
	;

`ifdef FLASH_GENERIC_REGISTERED
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
// Flash i/f monitor
//
// synopsys translate_off
integer fflash;
initial fflash = $fopen("flash.log");
always @(posedge wb_clk_i)
	if (wb_cyc_i)
		if (wb_stb_i & wb_we_i) begin
//			$fdisplay(fflash, "%t Trying to write into flash at %h (%b)", $time, wb_adr_i, wb_we_i);
//			#100 $finish;
			if (wb_sel_i[3])
				mem[{wb_adr_i[23:2], 2'b00}+0] = wb_dat_i[31:24];
			if (wb_sel_i[2])
				mem[{wb_adr_i[23:2], 2'b00}+1] = wb_dat_i[23:16];
			if (wb_sel_i[1])
				mem[{wb_adr_i[23:2], 2'b00}+2] = wb_dat_i[15:8];
			if (wb_sel_i[0])
				mem[{wb_adr_i[23:2], 2'b00}+3] = wb_dat_i[7:0];
			$fdisplay(fflash, "%t [%h] <- write %h, byte sel %b", $time, wb_adr_i, wb_dat_i, wb_sel_i);
		end else if (wb_ack_o)
			$fdisplay(fflash, "%t [%h] -> read %h", $time, wb_adr_i, wb_dat_o);
// synopsys translate_on

endmodule

`else

module flash_top (
  wb_clk_i, wb_rst_i,

  wb_dat_i, wb_dat_o, wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i,
  wb_stb_i, wb_ack_o, wb_err_o,

  flash_rstn, cen, oen, wen, rdy, d, a, a_oe
);

//
// I/O Ports
//

//
// Common WB signals
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
// Flash i/f
//
output			flash_rstn;
output			oen;
output			cen;
output			wen;
input			rdy;
inout	[7:0]		d;
output	[20:0]		a;
output			a_oe;

//
// Internal wires and regs
//
reg			ack;
reg	[3:0]		middle_tphqv;
reg	[31:0]		wb_dat_o;
reg	[4:0]		counter;

//
// Aliases and simple assignments
//
assign wb_ack_o = ~wb_err_o & ack;
assign wb_err_o = 1'b0;
assign flash_rstn = ~wb_rst_i;
assign a = { ~wb_adr_i[20], wb_adr_i[19:2], counter[3:2] };	// Lower 1MB is used by FPGA design conf.
assign a_oe = (wb_cyc_i &! (|middle_tphqv));
assign oen = |middle_tphqv;
assign wen = 1'b1;
assign cen = ~wb_cyc_i | ~wb_stb_i | (|middle_tphqv) | (counter[1:0] == 2'b00);

//
// Flash access time counter
//
always @(posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    counter <= #1 5'h0;
  else 
  if (!wb_cyc_i | (counter == 5'h10) | (|middle_tphqv))
    counter <= #1 5'h0;
  else
    counter <= #1 counter + 1;
end

//
// Acknowledge
//
always @(posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    ack <= #1 1'h0;
  else 
  if (counter == 5'h0f && !(|middle_tphqv))
    ack <= #1 1'h1;
  else
    ack <= #1 1'h0;
end

//
// Flash i/f monitor
//
// synopsys translate_off
integer fflash;
initial fflash = $fopen("flash.log");

always @(posedge wb_clk_i)
begin
  if (wb_cyc_i & !(|middle_tphqv)) begin
    if (wb_stb_i & wb_we_i) begin
      $fdisplay(fflash, "%t Trying to write into flash at %h", $time, wb_adr_i);
//    #100 $finish;
    end
    else if (ack)
      $fdisplay(fflash, "%t [%h] -> read %h", $time, wb_adr_i, wb_dat_o);
  end
end
// synopsys translate_on

always @(posedge wb_clk_i or posedge wb_rst_i)
  if (wb_rst_i)
    middle_tphqv <= #1 4'hf;
  else if (middle_tphqv)
    middle_tphqv <= #1 middle_tphqv - 1;

//
// Flash 8-bit data expand into 32-bit WB data
//
always @(posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    wb_dat_o <= #1 32'h0000_0000;
  else
  if (counter[1:0] == 2'h3)
    begin
      case (counter[3:2])
        2'h0 : wb_dat_o[31:24] <= #1 d;
        2'h1 : wb_dat_o[23:16] <= #1 d;
        2'h2 : wb_dat_o[15:8]  <= #1 d;
        2'h3 : wb_dat_o[7:0]   <= #1 d;
      endcase
    end
end
     
endmodule

`endif
