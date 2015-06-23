/*	MODULE: openfire simulator
	DESCRIPTION: Contains top-level simulator of the Openfire SOC

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
SOFTWARE.*/

`timescale 1ns / 1ps
`include "openfire_define.v"

module sp3dk_simulator();

reg				clk;
reg				rst;

`ifdef SP3SK_USERIO
reg	[7:0]		switches;
reg	[3:0]		pushbuttons;
wire	[7:0]		leds;
wire	[3:0]		drivers_n;
wire	[7:0]		segments_n;	
`endif
`ifdef UART1_ENABLE
wire				tx1;
reg				rx1;
`endif
`ifdef UART2_ENABLE
wire				tx2;
reg				rx2;
`endif
`ifdef SP3SK_PROM_DATA
reg				prom_din;
wire				prom_cclk;
wire				prom_reset_n;
`endif
`ifdef SP3SK_SRAM
wire 	[17:0]	ram_addr;		// SRAM ADDR (256K @)
wire				ram_oe_n;		// OE_N shared by 2 IC
wire				ram_we_n;		//	WE_N shared by 2 IC
wire	[15:0]	ram1_io;			//	I/O data port SRAM1
wire				ram1_ce_n;		// SRAM1 CE_N	chip enable
wire				ram1_ub_n;		// UB_N	upper byte select
wire				ram1_lb_n;		// LB_N  lower byte select
wire	[15:0]	ram2_io;			//	I/O data port SRAM2
wire				ram2_ce_n;		// SRAM2 CE_N	chip enable
wire				ram2_ub_n;		// UB_N	upper byte select
wire				ram2_lb_n;		// LB_N  lower byte select`endif
`endif
`ifdef SP3SK_VGA
wire				r, g, b;			// VGA components (1 bit per component)
wire				hsync_n;			// VGA hsync_n
wire				vsync_n;			// VGA vsync_n
`endif
		
// --- simulation statments ---
// Toggle clock every time unit
always #20 clk = ~clk;

`define TIMEOUT 	1000000
initial begin
`ifdef SP3SK_USERIO
	pushbuttons <= 0;
	switches	   <= 0;
`endif
	clk   = 1;
	rst   = 1;	// reset the processor (active high)

`ifdef UART1_ENABLE
	rx1	= 1;
`endif
`ifdef UART2_ENABLE
	rx2   = 1;
`endif
`ifdef SP3SK_PROM_DATA
	prom_din = 1;
`endif

	#70 rst = 0;
	#`TIMEOUT;
	//$finish;	// finish after TIMEOUT
end

// ---------- device under test ----------
openfire_soc DUT( 
`ifndef SP3SK_USERIO
   .rst( rst ),
`endif
`ifdef SP3SK_USERIO
	.leds( leds ),
	.drivers_n( drivers_n ), 
	.segments_n( segments_n ), 
	.pushbuttons( {rst, pushbuttons[2:0]} ), 		// 3rd push button is the RESET
	.switches( switches ),
`endif
`ifdef SP3SK_SRAM
	.ram_addr(ram_addr), .ram_oe_n(ram_oe_n),   .ram_we_n(ram_we_n),
	.ram1_io(ram1_io),   .ram1_ce_n(ram1_ce_n), .ram1_ub_n(ram1_ub_n), .ram1_lb_n(ram1_lb_n),
	.ram2_io(ram2_io),   .ram2_ce_n(ram2_ce_n), .ram2_ub_n(ram2_ub_n), .ram2_lb_n(ram2_lb_n),
`endif
`ifdef UART1_ENABLE
	.tx1(tx1), .rx1(rx1),
`endif
`ifdef UART2_ENABLE
	.tx2(tx2), .rx2(rx2),
`endif
`ifdef SP3SK_PROM_DATA
	.prom_din(prom_din), .prom_cclk(prom_cclk), .prom_reset_n(prom_reset_n),
`endif
`ifdef SP3SK_VGA
	.r(r), .g(g), .b(b),
	.hsync_n(hsync_n), .vsync_n(vsync_n),
`endif
	.clk_50mhz( clk )
);

`ifdef SP3SK_SRAM			// used as a whole 256Kx32
SRAM256KX16 sram1(		// 256K x 16 #1
	.ce_n(ram1_ce_n), .we_n(ram_we_n), .oe_n(ram_oe_n), 
	.ub_n(ram1_ub_n), .lb_n(ram1_lb_n), .addr(ram_addr), 
	.io(ram1_io)
);
SRAM256KX16 sram2(		// 256K x 16 #2
	.ce_n(ram2_ce_n), .we_n(ram_we_n), .oe_n(ram_oe_n), 
	.ub_n(ram2_ub_n), .lb_n(ram2_lb_n), .addr(ram_addr), 
	.io(ram2_io)
);

// ---- load program/data in external SRAM -----------
`ifdef DEBUG_FILE_SRAM
reg	[31:0] addr;
reg 	[31:0] memory[`MAX_SIMULATION_SRAM];	// temporary load here
reg	[31:0] word;

initial begin
  #1			// wait SRAM initialization
  $display("Loading ROM file...");	// file should be rows of 32 bit hex dump (in ascii)
  $readmemh(`DEBUG_FILE_SRAM, memory);
  $display("File loaded");

  $display("Populating SRAM...");
  addr = 0;
  word = memory[0];
  while( addr < `MAX_SIMULATION_SRAM && word !== 32'bX )	// populate only until
  begin										// the end of valid data
   word = memory[addr];
	sram1.memh[addr] = word[31:24];
	sram1.meml[addr] = word[23:16];
	sram2.memh[addr] = word[15:8];
	sram2.meml[addr] = word[7:0];
	// $display(" SRAM[%x]=%x", addr, word);
	addr = addr + 1;
  end
  $display("SRAM Populated with %d bytes", addr * 4);
end
`endif

`endif	 

endmodule
