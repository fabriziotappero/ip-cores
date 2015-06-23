//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: ddr_186.v
// Description: Part of the Next186 SoC PC project, main system, ddr interface
// Version 1.0
// Creation date: Apr2012
//
// Author: Nicolae Dumitrache 
// e-mail: ndumitrache@opencores.org
//
/////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2012 Nicolae Dumitrache
// 
// This source file may be used and distributed without 
// restriction provided that this copyright statement is not 
// removed from the file and that any derivative work contains 
// the original copyright notice and the associated disclaimer.
// 
// This source file is free software; you can redistribute it 
// and/or modify it under the terms of the GNU Lesser General 
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any 
// later version. 
// 
// This source is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied 
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
// PURPOSE. See the GNU Lesser General Public License for more 
// details. 
// 
// You should have received a copy of the GNU Lesser General 
// Public License along with this source; if not, download it 
// from http://www.opencores.org/lgpl.shtml 
// 
///////////////////////////////////////////////////////////////////////////////////
// Additional Comments: 
//
// 25Apr2012 - added SD card SPI support
// 15May2012 - added PIT 8253 (sound + timer INT8)
// 24May2012 - added PIC 8259  
// 28May2012 - RS232 boot loader does not depend on CPU speed anymore (uses timer0)
//	01Feb2013 - ADD 8042 PS2 Keyboard & Mouse controller
// 27Feb2013 - ADD RTC
// 04Apr2013 - ADD NMI, port 3bc for 8 leds
//
//Route:455 - CLK Net:u_ddr/top_00/dqs_int_delay_in<0> may have excessive skew because 
//   22 CLK pins and 0 NON_CLK pins failed to route using a CLK template.
//////////////////////////////////////////////////////////////////////////////////

/* ----------------- implemented ports -------------------
0001 - write RS232 (bit0)

0021, 00a1 - interrupt controller data ports. R/W interrupt mask, 1disabled/0enabled (bit0=timer, bit1=keyboard, bit3=RTC, bit4=mouse) 

0040-0043 - PIT 8253 ports

0x60, 0x64 - 8042 keyboard/mouse data and cfg

0061 - bits1:0 speaker on/off (write only)

0070 - RTC (16bit write only counter value). RTC is incremented with 1Mhz and at set value sends INT70h, then restart from 0
		 When set, it restarts from 0. If the set value is 0, it will send INT70h only once, if it was not already 0
			
080h-08fh - memory map: bit9:0=64 Kbytes DDRAM segment index (up to 1024 segs = 64MB), mapped over 
								PORT[3:0] 80186 addressable segment

03BC - parallel port (out only) LED[7:0]

03C0 - VGA mode (index 10h only)
			bit0 = graphic(1)/text(0)
			bit3 = text mode flash enabled(1)
			bit6 = 320x200(1)/640x480(0)

03C6 - DAC mask (rw)
03C7 - DAC read index (rw)
03C8 - DAC write index (rw)
03C9 - DAC color (rw)
03CB - font: write WORD = set index (8 bit), r/w BYTE = r/w font data

03DA - read VGA status, bit0=1 on vblank or hblank, bit1=RS232in, bit3=1 on vblank, bit7=1 always, bit15:8=SD SPI byte read
		 write bit7=SD SPI MOSI bit, SPI CLK 0->1 (BYTE write only), bit8 = SD card chip select (WORD write only)
		 also reset the 3C0 port index flag

03B4, 03D4 - VGA CRT write index:  
										0A(bit 5 only): hide cursor
										0C: HI screen offset
										0D: LO screen offset
										0E: HI cursor pos
										0F: LO cursor pos
03B5, 03D5 - VGA CRT read/write data
*/


`timescale 1ns / 1ps

module system
	(
		 inout	[15:0]cntrl0_ddr2_dq,        
		 output	[12:0]cntrl0_ddr2_a,         
		 output	[1:0]	cntrl0_ddr2_ba,        
		 output			cntrl0_ddr2_cke,       
		 output			cntrl0_ddr2_cs_n,      
		 output			cntrl0_ddr2_ras_n,     
		 output			cntrl0_ddr2_cas_n,     
		 output			cntrl0_ddr2_we_n,      
		 output			cntrl0_ddr2_odt,       
		 output	[1:0]	cntrl0_ddr2_dm,        
		 inout	[1:0]	cntrl0_ddr2_dqs,       
		 inout	[1:0]	cntrl0_ddr2_dqs_n,     
		 output			cntrl0_ddr2_ck,        
		 output			cntrl0_ddr2_ck_n,
		 input			cntrl0_rst_dqs_div_in, 
		 output			cntrl0_rst_dqs_div_out,

		 input			sys_clk_in,     // 133Mhz
		 input 			CLK_50MHZ,

		 output wire[3:0]	VGA_R,
		 output wire[3:0]	VGA_G,
		 output wire[3:0]	VGA_B,
		 output wire VGA_HSYNC,
		 output wire VGA_VSYNC,
		 
		 input BTN_SOUTH,		// Reset
		 input BTN_WEST,		// NMI
//		 output reg [7:0]LED,
		 output FPGA_AWAKE,	// HALT
		 input RS232_DCE_RXD,
		 output reg RS232_DCE_TXD,
		 
		 output reg SD_CS = 1,
		 output wire SD_DI,
		 output reg SD_CK = 0,
		 input SD_DO,
		 
		 output AUD_L,
		 output AUD_R,
	 	 inout PS2_CLK1,
		 inout PS2_CLK2,
		 inout PS2_DATA1,
		 inout PS2_DATA2
    );

	wire [31:0]cntrl0_user_output_data;//o    
	wire [31:0]cntrl0_user_input_data;//i    
	wire [11:0]waddr;
	wire [31:0] DOUT;
	wire [15:0]CPU_DOUT;
	wire [15:0]PORT_ADDR;
	wire [31:0] DRAM_dout;
	wire [31:0] SRAM_dout;
	wire [19:0] ADDR;
	wire IORQ;
	wire WR;
	wire INTA;
	wire WORD;
	wire [3:0] RAM_WMASK;
	wire cntrl0_ar_done;
	wire cntrl0_auto_ref_req;
	wire cntrl0_user_cmd_ack;
	wire cntrl0_user_data_valid;
	wire cntrl0_sys_rst180_tb;
	wire cntrl0_init_done;
	wire hblnk;
	wire vblnk;
	wire [9:0]hcount;
	wire [9:0]vcount;
	wire displ_on = !(hblnk | vblnk);
	wire [15:0]fifo_dout;
	wire [11:0]DAC_COLOR;
	wire fifo_empty;	// fifo empty
	wire full;
	wire prog_full;
	wire prog_empty;
	wire clk_25;
	wire clk_cpu;
	wire CPU_CE;	// CPU clock enable
	wire CE;
	wire ddr_rd; 
	wire ddr_wr;
	wire TIMER_OE;
	wire VGA_DAC_OE;
	wire LED_PORT = PORT_ADDR[15:0] == 16'h03bc;
	wire SPEAKER_PORT = PORT_ADDR[15:0] == 16'h0061;
	wire MEMORY_MAP = PORT_ADDR[15:4] == 12'h008;
	wire VGA_FONT_OE = PORT_ADDR[15:0] == 16'h03cb;
	wire RS232_OE = PORT_ADDR[15:0] == 16'h0001;
	wire INPUT_STATUS_OE = PORT_ADDR[15:0] == 16'h03da;
	wire VGA_CRT_OE = (PORT_ADDR[15:1] == 15'b000000111011010) || (PORT_ADDR[15:1] == 15'b000000111101010); // 3b4, 3b5, 3d4, 3d5
	wire RTC_SELECT = PORT_ADDR[15:0] == 16'h0070;
	wire [7:0]VGA_DAC_DATA;
	wire [7:0]VGA_CRT_DATA;
	wire [15:0]PORT_IN;
	wire [7:0]TIMER_DOUT;
	wire [7:0]KB_DOUT;
	wire [7:0]PIC_DOUT;
	wire PIC_OE; 
	wire KB_OE;
		
	reg [3:0]STATE = 0;
	reg [1:0]cntrl0_user_command_register = 0;
	reg cntrl0_burst_done = 0;
	reg [15:0]vga_ddr_row_col = 0;// = 16'h4000; // video buffer at 0xa0000
	reg [4:0]cache_counter = 0;
	reg [5:0]lowaddr = 0; //cache mem address
	reg s_prog_full;
	reg s_prog_empty;
	reg s_ddr_rd;
	reg s_ddr_wr;
	reg cache_op = 0;
	reg [1:0]cww = 0; // cache write window
	reg [3:0]crw = 0;	// cache read window
	reg crw_start = 0;
	reg rfsh = 0;
	wire ccd = cache_counter == 5'b11111;
	reg s_RS232_DCE_RXD;
	reg [4:0]rstcount = 0;
	reg [1:0]s_displ_on = 0;	// clk_25 delayed displ_on
	reg [2:0]vga400 = 0; 	// 1 for 400 lines, 0 for 480 lines
	reg [2:0]vgatext = 0;  // 1 for text mode
	wire vgaflash;
	reg flashbit = 0;
	reg [5:0]flashcount = 0;
	reg s_ddr_endburst = 0;
	wire [11:0]charcount = {vcount[8:4], 4'b0000} + {vcount[8:4], 6'b000000} + hcount[9:3];

	reg [8:0]vga_ddr_row_count = 0; 
	reg [3:0]vga_repln_count = 0; // repeat line counter
	reg [6:0]vga_lnbytecount = 0; // line byte count (multiple of 8)
	reg [11:0]vga_font_counter = 0;
	reg [7:0]vga_attr;
	reg [4:0]RTCDIV25 = 0;
	reg [1:0]RTCSYNC = 0;
	reg [15:0]RTC = 0;
	reg [15:0]RTCSET = 0;
	wire RTCEND = RTC == RTCSET;
	wire RTCDIVEND = RTCDIV25 == 24;
	wire [11:0]cache_hi_addr = |cww ? waddr : ADDR[19:8];
	wire [9:0]memmap;
	wire [9:0]memmap_mux;
	wire [3:0]vga_repln = vgatext[0] ? 15 : vga400[0] ? 1 : 0;
	wire [6:0]vga_lnend = vgatext[0] ? 19 : vga400[0] ? 39 : 79; // multiple of 8(DDRAM resolution = 8)
	wire vga_end_line = vga_lnbytecount == vga_lnend;
	wire vga_repeat_line = vga_repln_count != vga_repln;
	wire vga_end_frame = vga_ddr_row_count == (vgatext[0] | vga400[0] ? 399 : 479);
	wire [7:0]font_dout;
	wire [7:0]VGA_FONT_DATA;
	wire [2:0]pxindex = -hcount[2:0];
	wire vgatextreq;
	wire vga400req;
	wire oncursor;
	wire [11:0]cursorpos;
	wire [15:0]scraddr;
	reg flash_on;
	reg speaker_on = 0;
	reg [9:0]rNMI = 0;
	wire [3:0]VGA_MUX = (font_dout[pxindex] ^ flash_on) ? vga_attr[3:0] : {vga_attr[7] & ~vgaflash, vga_attr[6:4]};

	wire [3:0]sdon = {4{s_displ_on[vgatext[1]]}};
	assign VGA_R[3:0] = DAC_COLOR[3:0] & sdon;
	assign VGA_G[3:0] = DAC_COLOR[7:4] & sdon;
	assign VGA_B[3:0] = DAC_COLOR[11:8] & sdon;
	
// SD interface
	reg [7:0]SDI;
	assign SD_DI = CPU_DOUT[7];

	assign PORT_IN[15:8] = { ({8{MEMORY_MAP}} & {6'b000000, memmap[9:8]}) |
									 ({8{INPUT_STATUS_OE}} & SDI)
								  };

	assign PORT_IN[7:0] = {  ({8{VGA_DAC_OE}} & VGA_DAC_DATA) |
									 ({8{VGA_FONT_OE}}& VGA_FONT_DATA) |
									 ({8{KB_OE}} & KB_DOUT) |
									 ({8{INPUT_STATUS_OE}} & {4'b1xxx, vblnk, 1'bx, s_RS232_DCE_RXD, hblnk | vblnk}) | 
									 ({8{VGA_CRT_OE}} & VGA_CRT_DATA) | 
									 ({8{MEMORY_MAP}} & {memmap[7:0]}) |
									 ({8{TIMER_OE}} & TIMER_DOUT) |
									 ({8{PIC_OE}} & PIC_DOUT)
								 };

	dcm_vga dcm133_25 
	(
    .CLKIN_IN(sys_clk_in), 
    .CLKFX_OUT(clk_25), 
    .CLKIN_IBUFG_OUT(CLKIN_IBUFG_OUT), 
    .CLK0_OUT(CLK0_OUT), 
    .CLK90_OUT(CLK90_OUT), 
    .LOCKED_OUT(LOCKED_OUT)
//	 .CLKDV_OUT(clk_cpu)
    );
	 
	 dcm_cpu dcm50_cpu 
	 (
	  .CLKIN_IN(CLK_50MHZ), 
     .CLKFX_OUT(clk_cpu)
//	  .CLKDV_OUT(clk_25)
 //   .CLKIN_IBUFG_OUT(CLKIN_IBUFG_OUT), 
 //   .CLK0_OUT(CLK0_OUT)
    );

// ddr_cal_ctl.v, line 194, I made <tapfordqs> always fixed <default_tap> instead of variable <tapfordqs1> 
// ddr_s3_dqs_iob.v, line 115, added delay property .IBUF_DELAY_VALUE("4") to IBUFDS (works ok for values < 8)
	ddr u_ddr 
	( 
      .cntrl0_ddr2_dq            (cntrl0_ddr2_dq),
      .cntrl0_ddr2_a             (cntrl0_ddr2_a),
      .cntrl0_ddr2_ba            (cntrl0_ddr2_ba),
      .cntrl0_ddr2_cke           (cntrl0_ddr2_cke),
      .cntrl0_ddr2_cs_n          (cntrl0_ddr2_cs_n),
      .cntrl0_ddr2_ras_n         (cntrl0_ddr2_ras_n),
      .cntrl0_ddr2_cas_n         (cntrl0_ddr2_cas_n),
      .cntrl0_ddr2_we_n          (cntrl0_ddr2_we_n),
      .cntrl0_ddr2_odt           (cntrl0_ddr2_odt),
      .cntrl0_ddr2_dm            (cntrl0_ddr2_dm),
      .cntrl0_ddr2_dqs           (cntrl0_ddr2_dqs),
      .cntrl0_ddr2_dqs_n         (cntrl0_ddr2_dqs_n),
      .cntrl0_ddr2_ck            (cntrl0_ddr2_ck),
      .cntrl0_ddr2_ck_n          (cntrl0_ddr2_ck_n),
      .cntrl0_rst_dqs_div_in     (cntrl0_rst_dqs_div_in),
      .cntrl0_rst_dqs_div_out    (cntrl0_rst_dqs_div_out),

      .clk_int                   (CLK0_OUT),
      .clk90_int                 (CLK90_OUT),
      .dcm_lock                  (LOCKED_OUT),
		
      .reset_in_n                (1'b1),
      .cntrl0_burst_done         (cntrl0_burst_done),
      .cntrl0_init_done          (cntrl0_init_done),
      .cntrl0_ar_done            (cntrl0_ar_done),
      .cntrl0_user_data_valid    (cntrl0_user_data_valid),
      .cntrl0_auto_ref_req       (cntrl0_auto_ref_req),
      .cntrl0_user_cmd_ack       (cntrl0_user_cmd_ack),
      .cntrl0_user_command_register  ({cntrl0_user_command_register, 1'b0}),
      .cntrl0_clk_tb             (cntrl0_clk_tb),
      .cntrl0_clk90_tb           (cntrl0_clk90_tb),
  //    .cntrl0_sys_rst_tb         (cntrl0_sys_rst_tb),
  //    .cntrl0_sys_rst90_tb       (cntrl0_sys_rst90_tb),
      .cntrl0_sys_rst180_tb      (cntrl0_sys_rst180_tb),
      .cntrl0_user_output_data   (cntrl0_user_output_data),
      .cntrl0_user_input_data    (cntrl0_user_input_data),
      .cntrl0_user_data_mask     (4'b0000),
      .cntrl0_user_input_address  (cache_op ? {memmap_mux[9:6], memmap_mux[3:0], cache_hi_addr[7:0], cache_counter, 2'b00, memmap_mux[5:4]}: {5'b00001, vga_ddr_row_col, 2'b00, 2'b00})
	);

	fifo ddr_vga_fifo 
	(
	  .rst(cntrl0_sys_rst180_tb), // input rst
	  .wr_clk(cntrl0_clk90_tb), // input wr_clk
	  .rd_clk(clk_25), // input rd_clk
	  .din({cntrl0_user_output_data[7:0], cntrl0_user_output_data[15:8], cntrl0_user_output_data[23:16], cntrl0_user_output_data[31:24]}), // input [31 : 0] din
	  .wr_en(~crw[3] && cntrl0_user_data_valid),
	  .rd_en(!fifo_empty && displ_on && (vgatext[1] ? &hcount[2:0] : vga400[1] ? &hcount[1:0] : hcount[0])), // input rd_en
	  .dout(fifo_dout), // output [15 : 0] dout
	  .full(full), // output full
	  .empty(fifo_empty), // output empty
	  .prog_full(prog_full), // output prog_full
	  .prog_empty(prog_empty) // output prog_empty
	);

	VGA_SG VGA 
	(
		.tc_hsblnk(10'd639), 
		.tc_hssync(10'd655), 
		.tc_hesync(10'd751), 
		.tc_heblnk(10'd799), 
		.hcount(hcount), 
		.hsync(VGA_HSYNC), 
		.hblnk(hblnk), 
		.tc_vsblnk(vga400[2] | vgatext[2] ? 10'd399 : 10'd479), 
		.tc_vssync(vga400[2] | vgatext[2] ? 10'd411 : 10'd489), 
		.tc_vesync(vga400[2] | vgatext[2] ? 10'd413 : 10'd491), 
		.tc_veblnk(vga400[2] | vgatext[2] ? 10'd446 : 10'd520), 
		.vcount(vcount), 
		.vsync(VGA_VSYNC), 
		.vblnk(vblnk), 
		.clk(clk_25),
		.ce(!fifo_empty)
	);
	
	VGA_DAC dac 
	(
		 .CE(IORQ && CPU_CE && (PORT_ADDR[15:4] == 12'h03c)), 
		 .WR(WR), 
		 .addr(PORT_ADDR[3:0]), 
		 .din(CPU_DOUT[7:0]), 
		 .OE(VGA_DAC_OE), 
		 .dout(VGA_DAC_DATA), 
		 .CLK(clk_cpu), 
		 .VGA_CLK(clk_25), 
		 .vga_addr(vgatext[1] ? {4'b0000, VGA_MUX} : (vga400[1] ? hcount[1] : hcount[0]) ? fifo_dout[7:0] : fifo_dout[15:8]), 
		 .color(DAC_COLOR),
		 .vgatext(vgatextreq),
		 .vga400(vga400req),
		 .vgaflash(vgaflash),
		 .setindex(INPUT_STATUS_OE && IORQ && CPU_CE)
    );
	 
	 VGA_CRT crt
	 (
		.CE(IORQ && CPU_CE && VGA_CRT_OE),
		.WR(WR),
		.din(CPU_DOUT[7:0]),
		.addr(PORT_ADDR[0]),
		.dout(VGA_CRT_DATA),
		.CLK(clk_cpu),
		.oncursor(oncursor),
		.cursorpos(cursorpos),
		.scraddr(scraddr)
	);

	sr_font VGA_FONT 
	(
	  .clka(clk_25), // input clka
	  .wea(1'b0), // input [0 : 0] wea
	  .addra({fifo_dout[15:8], vcount[3:0]}), // input [11 : 0] addra
	  .dina(8'hxx), // input [7 : 0] dina
	  .douta(font_dout), // output [7 : 0] douta
	  .clkb(clk_cpu), // input clkb
	  .web(CPU_CE & WR & IORQ & VGA_FONT_OE & ~WORD), // input [0 : 0] web
	  .addrb(vga_font_counter), // input [11 : 0] addrb
	  .dinb(CPU_DOUT[7:0]), // input [7 : 0] dinb
	  .doutb(VGA_FONT_DATA) // output [7 : 0] doutb
	);
	
	cache_controller cache_ctl 
	(
		 .addr(ADDR), 
		 .dout(DRAM_dout), 
		 .din(DOUT), 
		 .clk(clk_cpu), 
		 .mreq(MREQ), 
		 .wr(WR),
		 .wmask(RAM_WMASK),	 
		 .ce(CE), 
		 .ddr_din(cntrl0_user_output_data), 
		 .ddr_dout(cntrl0_user_input_data), 
		 .ddr_clk(cntrl0_clk90_tb), 
		 .ddr_rd(ddr_rd), 
		 .ddr_wr(ddr_wr),
		 .lowaddr(lowaddr),
		 .waddr(waddr),
		 .cache_write_data(crw[3] && cntrl0_user_data_valid) // read DDR, write to cache
	);

	wire I_KB;
	wire I_MOUSE;
	wire KB_RST;
	KB_Mouse_8042 KB_Mouse 
	(
		 .CS(IORQ && CPU_CE && PORT_ADDR[15:4] == 12'h006 && {PORT_ADDR[3], PORT_ADDR[1:0]} == 3'b000), // 60h, 64h
		 .WR(WR), 
		 .cmd(PORT_ADDR[2]), // 64h
		 .din(CPU_DOUT[7:0]), 
		 .OE(KB_OE), 
		 .dout(KB_DOUT), 
		 .clk(clk_cpu), 
		 .I_KB(I_KB), 
		 .I_MOUSE(I_MOUSE), 
		 .CPU_RST(KB_RST), 
		 .PS2_CLK1(PS2_CLK1), 
		 .PS2_CLK2(PS2_CLK2), 
		 .PS2_DATA1(PS2_DATA1), 
		 .PS2_DATA2(PS2_DATA2)
	);
	
	wire [7:0]PIC_IVECT;
	wire INT;
	wire timer_int;
	PIC_8259 PIC 
	(
		 .CS((PORT_ADDR[15:8] == 8'h00) && (PORT_ADDR[6:0] == 7'b0100001) && IORQ && CPU_CE), // 21h, a1h
		 .WR(WR), 
		 .din(CPU_DOUT[7:0]), 
		 .OE(PIC_OE), 
		 .dout(PIC_DOUT), 
		 .ivect(PIC_IVECT), 
		 .clk(clk_cpu), 
		 .INT(INT), 
		 .IACK(INTA & CPU_CE), 
		 .I({I_MOUSE, RTCEND, I_KB, timer_int})
//		 .I({hblnk, 1'b0, vblnk, timer_int})
    );

	unit186 CPUUnit
	(
		 .INPORT(INTA ? PIC_IVECT : PORT_IN), 
		 .DIN(DRAM_dout), 
		 .CPU_DOUT(CPU_DOUT),
		 .PORT_ADDR(PORT_ADDR),
		 .DOUT(DOUT), 
		 .ADDR(ADDR), 
		 .WMASK(RAM_WMASK), 
		 .CLK(clk_cpu), 
		 .CE(CE), 
		 .CPU_CE(CPU_CE),
		 .INTR(INT), 
		 .NMI(rNMI[9]), 
		 .RST(BTN_SOUTH || !rstcount[4]), 
		 .INTA(INTA), 
//		 .LOCK(LOCK), 
		 .HALT(FPGA_AWAKE), 
		 .MREQ(MREQ),
		 .IORQ(IORQ),
		 .WR(WR),
		 .WORD(WORD)
	);
	
	seg_map seg_mapper 
	(
		 .CLK(clk_cpu), 
		 .addr(PORT_ADDR[3:0]), 
		 .rdata(memmap), 
		 .wdata(CPU_DOUT[9:0]), 
		 .addr1(cache_hi_addr[11:8]), 
		 .data1(memmap_mux), 
		 .WE(MEMORY_MAP & WR & WORD & IORQ & CPU_CE)
    );
	 
	 wire timer_spk;
	 timer_8253 timer 
	 (
		 .CS(PORT_ADDR[15:2] == 14'b00000000010000 && IORQ && CPU_CE), 
		 .WR(WR), 
		 .addr(PORT_ADDR[1:0]), 
		 .din(CPU_DOUT[7:0]), 
		 .OE(TIMER_OE), 
		 .dout(TIMER_DOUT), 
		 .CLK_25(clk_25), 
		 .clk(clk_cpu), 
		 .out0(timer_int), 
		 .out2(timer_spk)
    );
	 assign AUD_L = speaker_on & timer_spk;
	 assign AUD_R = speaker_on & timer_spk; 
	 
	always @ (negedge cntrl0_clk_tb) begin
		cntrl0_user_command_register <= 2'b00;
		cntrl0_burst_done <= 1'b0;
		s_prog_full <= prog_full; // sychronized because prog_full is asserted on a different clock
		s_prog_empty <= prog_empty;
		s_ddr_rd <= ddr_rd;
		s_ddr_wr <= ddr_wr;
		s_ddr_endburst <= s_prog_full || cntrl0_auto_ref_req || (~s_prog_empty && (s_ddr_rd || s_ddr_wr));
		crw_start <= 1'b0;
		cww[1] <= cww[0];
		if(cntrl0_auto_ref_req) rfsh <= 1'b1;
		else if(cntrl0_ar_done) rfsh <= 1'b0;
		
		if(cntrl0_sys_rst180_tb) begin
			STATE <= 4'b0000;
			vga_ddr_row_col <= 0;
			vga_ddr_row_count <= 0;
			cache_counter <= 0;
			vga_repln_count <= 0;
			vga_lnbytecount <= 0;
		end else case(STATE)
			4'b0000: begin
				cntrl0_user_command_register <= 2'b01;	// initialize DDR
				STATE <= 4'b0001;	// reset
			end
			
// wait for completion
			4'b0001: begin
				if(~cntrl0_user_cmd_ack && cntrl0_init_done && ~rfsh && ~cntrl0_auto_ref_req) begin
					if(s_prog_empty) begin
						cntrl0_user_command_register <= 2'b11;
						STATE <= 4'b0010;
					end else if(s_ddr_wr) begin
						cntrl0_user_command_register <= 2'b10;
						cache_op <= 1'b1;
						cww[0] <= 1'b1;
						STATE <= 4'b0110;
					end else if(s_ddr_rd) begin
						cntrl0_user_command_register <= 2'b11;
						cache_op <= 1'b1;
						STATE <= 4'b1010;
					end else if(~s_prog_full) begin
						cntrl0_user_command_register <= 2'b11;
						STATE <= 4'b0010;
					end
				end
			end
			
// VGA read
			4'b0010: begin	// assert READ command, wait for ACK
				cntrl0_user_command_register <= 2'b11; // read
				if(cntrl0_user_cmd_ack) STATE <= 4'b0011;
			end
			4'b0011: begin // keep READ for 2nd T after ACK
				cntrl0_user_command_register <= 2'b11; // read
				STATE <= 4'b0100;
			end
			4'b0100: begin	// keep READ for 3rd T after ACK
				cntrl0_user_command_register <= 2'b11; // read
				
				if(vga_end_line) begin
					vga_lnbytecount <= 0;
					vga_ddr_row_count <= vga_ddr_row_count + 1;
					if(vga_repeat_line) begin
						vga_repln_count <= vga_repln_count + 1;
						vga_ddr_row_col <= vga_ddr_row_col - vga_lnend;
					end else begin
						vga_repln_count <= 0;
						if(vga_end_frame) begin
							vga400[0] <= vga400req;
							vgatext[0] <= vgatextreq;
							vga_ddr_row_col <= scraddr + {vgatext[0] ? 4'b0111 : 4'b0100, 12'h000};
							vga_ddr_row_count <= 0;
						end else vga_ddr_row_col <= vga_ddr_row_col + 1;
					end
				end else begin
					vga_lnbytecount <= vga_lnbytecount + 1;
					vga_ddr_row_col <= vga_ddr_row_col + 1;
				end
				
//				vga_ddr_row_col <= vga_ddr_row_col == vga_ddr_row_col_end ? vga_ddr_row_col_start : vga_ddr_row_col + 1; 
				if(s_ddr_endburst || &vga_ddr_row_col[7:0] || ((vga_end_frame || vga_repeat_line) && vga_end_line)) begin // end burst if (FIFO full or DDR refresh or end column address)
					cntrl0_burst_done <= 1'b1;
					STATE <= 4'b0101;	// end burst
				end else STATE <= 4'b0011;	// continue read burst
			end
			4'b0101: begin	// keep burst_done
				cntrl0_burst_done <= 1'b1;
				cache_op <= 1'b0;
				STATE <= 4'b0001;
			end
			
// cache write to DDR
			4'b0110: begin // assert WRITE command, wait for ACK
				cntrl0_user_command_register <= 2'b10; // write
				if(cntrl0_user_cmd_ack) STATE <= 4'b0111;
			end
			4'b0111: begin // keep WRITE for 2nd T after ACK
				cntrl0_user_command_register <= 2'b10; // write
				if(cntrl0_auto_ref_req || ccd) cww[0] <= 1'b0;
				STATE <= 4'b1000;
			end
			4'b1000: begin // keep WRITE for 3rd T after ACK
				cntrl0_user_command_register <= 2'b10; // write
				cache_counter <= cache_counter + 1;
				if(~cww[0]) begin
					cntrl0_burst_done <= 1'b1;
					STATE <= ccd ? 4'b0101 : 4'b1001;
				end else STATE <= 4'b0111;
			end
			4'b1001: begin
				cntrl0_burst_done <= 1'b1;
				STATE <= 4'b1110;
			end
			4'b1110: begin
				if(~cntrl0_user_cmd_ack) begin
					cntrl0_user_command_register <= 2'b10; // write
					cww[0] <= 1'b1;
					STATE <= 4'b0110;
				end
			end
			
// cache read from DDR
			4'b1010: begin // assert READ command, wait for ACK
				cntrl0_user_command_register <= 2'b11; // read
				if(cntrl0_user_cmd_ack) STATE <= 4'b1011;
			end
			4'b1011: begin // keep READ for 2nd T after ACK
				crw_start <= 1'b1;
				cntrl0_user_command_register <= 2'b11; // read
				STATE <= 4'b1100;
			end
			4'b1100: begin	// keep READ for 3rd T after ACK
				cntrl0_user_command_register <= 2'b11; // read
				cache_counter <= cache_counter + 1;
				if(cntrl0_auto_ref_req || ccd) begin
					cntrl0_burst_done <= 1'b1;
					STATE <= ccd ? 4'b0101 : 4'b1101;
				end else STATE <= 4'b1011;
			end
			4'b1101: begin	// keep burst_done
				cntrl0_burst_done <= 1'b1;
				STATE <= 4'b1111;
			end
			4'b1111: begin
				if(~cntrl0_user_cmd_ack) begin
					cntrl0_user_command_register <= 2'b11; // read
					STATE <= 4'b1010;
				end
			end
			
		endcase
	end
	
	
	always @ (posedge cntrl0_clk90_tb) begin
		if(cntrl0_sys_rst180_tb) begin
			crw <= 0;
			lowaddr <= 0;
		end else begin
			if((crw[3] && cntrl0_user_data_valid) || (cww[0] && cntrl0_user_cmd_ack)) lowaddr <= lowaddr + 1;
			if(~crw[3]) begin
				if(crw_start || |crw[2:0]) crw <= crw + 1;
			end else if(&lowaddr) crw <= 0;
		end
	end
	
	always @ (posedge clk_cpu) begin
		s_RS232_DCE_RXD <= RS232_DCE_RXD;
		if(IORQ & CPU_CE) begin
			if(WR & RS232_OE) RS232_DCE_TXD <= CPU_DOUT[0];
			if(VGA_FONT_OE) vga_font_counter <= WR && WORD ? {CPU_DOUT[7:0], 4'b0000} : vga_font_counter + 1; 
			if(WR & SPEAKER_PORT) speaker_on <= &CPU_DOUT[1:0];
//			if(WR & LED_PORT) LED <= CPU_DOUT[7:0];
		end
// SD
		if(CPU_CE) begin
			SD_CK <= IORQ & INPUT_STATUS_OE & WR & ~WORD;
			if(IORQ & INPUT_STATUS_OE & WR) begin
				if(WORD) SD_CS <= ~CPU_DOUT[8]; // SD chip select
				else SDI <= {SDI[6:0], SD_DO};
			end
		end

		if(KB_RST) rstcount <= 0;
		else if(CPU_CE && ~rstcount[4]) rstcount <= rstcount + 1;
		
// RTC		
		RTCSYNC <= {RTCSYNC[0], RTCDIVEND};
		if(IORQ && CPU_CE && WR && WORD && RTC_SELECT) begin
			RTC <= 0;
			RTCSET <= CPU_DOUT;
		end else if(RTCSYNC == 2'b01) begin
			if(RTCEND) RTC <= 0;
			else RTC <= RTC + 1;
		end
		
	end
	
	always @ (posedge clk_25) begin
		s_displ_on[1:0] <= {s_displ_on[0], displ_on};
		vga_attr <= fifo_dout[7:0];
		
		flash_on <= (vgaflash & fifo_dout[7] & flashcount[5]) | (~oncursor && flashcount[4] && (charcount == cursorpos) && ((vcount[3:0] == 13) || vcount[3:0] == 14));		
		
		if(!vblnk) begin
			flashbit <= 1;
			vga400[2] <= vga400[1];
			vgatext[2] <= vgatext[1];
		end else if(flashbit) begin
			flashcount <= flashcount + 1;
			flashbit <= 0;
			vga400[1] <= vga400[0];
			vgatext[1] <= vgatext[0];
		end
		
		if(RTCDIVEND) RTCDIV25 <= 0;	// real time clock
		else RTCDIV25 <= RTCDIV25 + 1;
		
		if(!BTN_WEST) rNMI <= 0;		// NMI
		else if(!rNMI[9] && RTCDIVEND) rNMI <= rNMI + 1;	// 1Mhz increment

	end
	
endmodule

