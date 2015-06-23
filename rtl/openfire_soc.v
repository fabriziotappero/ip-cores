/*	MODULE: openfire soc
	DESCRIPTION: Contains top-level SOC 

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

module openfire_soc(
`ifndef SP3SK_USERIO
	rst, 					// if no SP3SK IOs, then we need a reset signal
`endif
`ifdef SP3SK_USERIO
	leds,	drivers_n, segments_n, pushbuttons, switches,
`endif	 
`ifdef UART1_ENABLE
	tx1, rx1,
`endif		 
`ifdef UART2_ENABLE
	tx2, rx2,
`endif
`ifdef SP3SK_SRAM
	ram_addr, ram_oe_n, ram_we_n,
	ram1_io, ram1_ce_n, ram1_ub_n, ram1_lb_n,
	ram2_io, ram2_ce_n, ram2_ub_n, ram2_lb_n,
`endif
`ifdef SP3SK_VGA
	r, g, b, hsync_n, vsync_n,
`endif
`ifdef SP3SK_PROM_DATA
	prom_din, prom_cclk, prom_reset_n,
`endif
//	tx_ultrasonidos_p, tx_ultrasonidos_n, rx_ultrasonidos,
//	spi_clk, spi_datain, spi_dataout, 
//	spi_cs_1, spi_cs_2, spi_cs_3, spi_cs_4,
//	i2c_clk, i2c_data,
	clk_50mhz
);

`ifndef SP3SK_USERIO
input 				rst;				// external RST (active HIGH)
`endif
input					clk_50mhz;		// board clock 50 MHZ
`ifdef SP3SK_USERIO
output	[7:0] 	leds;				// onboard LEDS
output	[3:0]		drivers_n;		// 7segments element's driver (negated)
output	[7:0]		segments_n;		// display segment
input		[3:0]		pushbuttons;	// 4 push-buttons
input		[7:0]		switches;		// 8 switches
`endif
`ifdef UART1_ENABLE
input					rx1;				// RS232 rx
output				tx1;				// RS232 tx
`endif
`ifdef UART2_ENABLE
input					rx2;				// RS232 rx #2
output				tx2;				// RS232 tx #2
`endif
`ifdef SP3SK_SRAM
output 	[17:0]	ram_addr;		// SRAM ADDR (256K @)
output				ram_oe_n;		// OE_N shared by 2 IC
output				ram_we_n;		//	WE_N shared by 2 IC
inout		[15:0]	ram1_io;			//	I/O data port SRAM1
output				ram1_ce_n;		// SRAM1 CE_N	chip enable
output				ram1_ub_n;		// UB_N	upper byte select
output				ram1_lb_n;		// LB_N  lower byte select
inout		[15:0]	ram2_io;			//	I/O data port SRAM2
output				ram2_ce_n;		// SRAM2 CE_N	chip enable
output				ram2_ub_n;		// UB_N	upper byte select
output				ram2_lb_n;		// LB_N  lower byte select
`endif
`ifdef SP3SK_VGA
output				r, g, b;			// VGA components (1 bit per component)
output				hsync_n;			// VGA hsync_n
output				vsync_n;			// VGA vsync_n
`endif
`ifdef SP3SK_PROM_DATA
input					prom_din;
output				prom_cclk;
output				prom_reset_n;
`endif
//output				tx_ultrasonidos_p;		// application specific ports
//output				tx_ultrasonidos_n;
//input				rx_ultrasonidos;
//output				spi_clk;
//input				spi_datain;
//output				spi_dataout;
//output				spi_cs_1;
//output				spi_cs_2;
//output				spi_cs_3;
//output				spi_cs_4;
//inout				i2c_clk;
//inout				i2c_data;

// -------- connections ------------
`ifdef SP3SK_USERIO
wire 				rst = pushbuttons[3];		// reset generated from a push button
`endif
wire	[31:0]	imem_data;				// ports to/from CPU
wire	[31:0]	imem_addr;
wire	[31:0]	dmem_data2mem;
wire	[31:0]	dmem_data2cpu;
wire	[31:0]	dmem_addr;
wire	[1:0]		dmem_input_sel;		// 0=byte, 1=hw, 2=word
wire  [3:0]		data_selector;			// maps each byte in a word (msb..lsb)
wire				dmem_we;					// request data write
wire				dmem_re;					// request data read
wire				imem_re;					// request instruction read
wire  [31:0]	dmem_data_frombram;	// arbitrer to/from BRAM
wire  [31:0]	dmem_data_tobram;
wire				dmem_we_bram;
wire  [31:0]	imem_data_frombram;
`ifdef SP3SK_IODEVICES
wire 	[31:0]	dmem_data_fromio;		// arbitrer to/from IO-SPACE
wire  [31:0]	dmem_data_toio;
wire			   dmem_we_io;
wire				dmem_re_io;
`endif
`ifdef IO_MULTICYCLE
wire				io_done;					// handle multicycle i/o operations
`endif
wire			   imem_done;				// operation on imem completed
wire			   dmem_done;				// operation on dmem completed
`ifdef SP3SK_SRAM
wire	[31:0]	sram_data2mem1;
wire	[31:0]	sram_data2cpu1;
wire				sram_re1, sram_we1, sram_done1;
wire	[31:0]	sram_data2cpu2;
wire				sram_re2, sram_done2;
wire	[17:0]	sram_addr3;				// port #3 other uses
wire	[31:0]	sram_data2cpu3;
wire				sram_re3, sram_done3;
`endif					  

`ifdef CLK_25MHZ							// cpu clock generation
reg clk;
//synthesis translate_off
initial clk = 0;
//synthesis translate_on
always @(posedge clk_50mhz) clk <= ~clk;		// 25mhz clock
`else
wire				clk = clk_50mhz;					// 50mhz clock
`endif

`ifdef ENABLE_INTERRUPTS
wire				interrupt;	 						// interrupt line
`endif

`ifdef ENABLE_ALIGNMENT_EXCEPTION
wire	dmem_alignment_exception;
`endif

// --------- instantiation of the SoC ----------------
openfire_cpu CPU(							// openfire CPU
	.clock(clk), 
	.reset(rst), 
`ifdef ENABLE_INTERRUPTS
	.interrupt(interrupt),
`endif
`ifdef ENABLE_ALIGNMENT_EXCEPTION
	.dmem_alignment_exception(dmem_alignment_exception),
`endif
	.dmem_addr(dmem_addr), 
	.dmem_data_in(dmem_data2cpu), 
	.dmem_data_out(dmem_data2mem), 
	.dmem_we(dmem_we),	  
	.dmem_re(dmem_re),
	.dmem_input_sel(dmem_input_sel),
	.dmem_done(dmem_done),
	.imem_addr(imem_addr), 
	.imem_data_in(imem_data), 
	.imem_re(imem_re),
	.imem_done(imem_done)
);

openfire_arbitrer ARBITRER(			// bus arbitrer 
`ifdef SP3SK_SRAM
	.sram_data2mem(sram_data2mem1), 
	.sram_data2cpu(sram_data2cpu1), 
	.sram_dmem_re(sram_re1), 
	.sram_dmem_we(sram_we1), 
	.sram_dmem_done(sram_done1),
	.sram_ins2cpu(sram_data2cpu2),
	.sram_imem_re(sram_re2), 
	.sram_imem_done(sram_done2),
`endif
`ifdef IO_MULTICYCLE
	.dmem_done_io(io_done),
`endif
`ifdef SP3SK_IODEVICES
	.dmem_we_io(dmem_we_io),
	.dmem_re_io(dmem_re_io),
	.dmem_data_fromio(dmem_data_fromio), 
	.dmem_data_toio(dmem_data_toio),
`endif
`ifdef ENABLE_ALIGNMENT_EXCEPTION
	.dmem_alignment_exception(dmem_alignment_exception),
`endif
	.clock(clk), 
	.reset(rst), 
	.imem_done(imem_done),
	.dmem_done(dmem_done),
	.dmem_address(dmem_addr), 
	.dmem_data_out(dmem_data2cpu), 
	.dmem_data_in(dmem_data2mem), 
	.dmem_re(dmem_re),
	.dmem_we(dmem_we),
	.dmem_input_sel(dmem_input_sel),
	.data_selector(data_selector),
	.imem_address(imem_addr), 
	.imem_data(imem_data), 
	.imem_re(imem_re),
	.dmem_data_frombram(dmem_data_frombram),
	.dmem_data_tobram(dmem_data_tobram), 
	.dmem_we_bram(dmem_we_bram),
	.imem_data_frombram(imem_data_frombram)
);

`ifdef SP3SK_IODEVICES
openfire_iospace IOSPACE(				// i/o space manager
`ifdef SP3SK_USERIO
	.leds(leds), 
	.drivers_n(drivers_n), 
	.segments_n(segments_n), 
	.pushbuttons(pushbuttons), 
	.switches(switches),
`endif
`ifdef UART1_ENABLE
	.tx1(tx1), 
	.rx1(rx1),
`endif
`ifdef UART2_ENABLE
	.tx2(tx2), 
	.rx2(rx2),
`endif
`ifdef SP3SK_PROM_DATA
	 .prom_din(prom_din), 
	 .prom_cclk(prom_cclk), 
	 .prom_reset_n(prom_reset_n),
`endif
`ifdef ENABLE_INTERRUPTS
	 .interrupt(interrupt),
`endif
`ifdef IO_MULTICYCLE
	.done(io_done),
`endif
	.clk(~clk), 
	.rst(rst), 
	.addr(dmem_addr[`IO_SIZE+1:2]), 
	.data_in(dmem_data_toio), 
	.data_out(dmem_data_fromio), 
	.read(dmem_re_io),
	.write(dmem_we_io)
);
`endif

openfire_bootram BOOTRAM(				// boot ram (block ram)
	.rst(rst), 
	.clk(~clk),
	.ins_addr( imem_addr[12:2] ),
	.ins_output(imem_data_frombram),
	.data_sel(data_selector), 
	.data_we(dmem_we_bram), 
	.data_addr( dmem_addr[12:2] ),
	.data_input(dmem_data_tobram), 
	.data_output(dmem_data_frombram)
); 

`ifdef SP3SK_SRAM							// sram controller
sram_controller sram_256kx32(
	.rst(rst), .clk(~clk),				// controller at full speed

	.ram_addr(ram_addr), .ram_oe_n(ram_oe_n),   .ram_we_n(ram_we_n),	// sp3sk sram interface
	.ram1_io(ram1_io),   .ram1_ce_n(ram1_ce_n), .ram1_ub_n(ram1_ub_n), .ram1_lb_n(ram1_lb_n),
	.ram2_io(ram2_io),   .ram2_ce_n(ram2_ce_n), .ram2_ub_n(ram2_ub_n), .ram2_lb_n(ram2_lb_n),

	.addr1( dmem_addr[19:2] ), 		// dmem port (read/write) byte capable
	.data2mem1(sram_data2mem1), 
	.data2cpu1(sram_data2cpu1), 
	.re1(sram_re1), 
	.we1(sram_we1), 
	.select1(data_selector),	
	.done1(sram_done1),

	.addr2( imem_addr[19:2] ), 		// imem port (read only) word only
	.data2cpu2(sram_data2cpu2), 
	.re2(sram_re2), 
	.done2(sram_done2),

	.addr3(sram_addr3),					 // aux port (read only) word only
	.data2cpu3(sram_data2cpu3),
	.re3(sram_re3), 
	.done3(sram_done3)
);
`endif

`ifdef SP3SK_VGA							// vga module
vga_controller VGA(
	.reset(rst),
	.cpu_clk(clk),							// for the sram fetch module
	.pixel_clk(clk), 						// should be 25MHz for 640x480 video mode
	.hsync_n(hsync_n), 
	.vsync_n(vsync_n),
	.red(r),
	.green(g),
	.blue(b),
	.ram_pointer(sram_addr3),
	.ram_data(sram_data2cpu3),
	.req(sram_re3),
	.rdy(sram_done3)
);
`endif

`include "openfire_debug.v"
endmodule

