//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: ddr_186.v
// Description: Part of the Next186 SoC PC project, main system, RAM interface
// Version 2.0
// Creation date: Apr2014
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
// Feb2014 - ported for SDRAM, added USB host serial communication
// 		   - added video modes 0dh, 12h
//		   - support for ModeX
//////////////////////////////////////////////////////////////////////////////////

/* ----------------- implemented ports -------------------
0001 - bit0=write RS232, bit1=write USB host out, bit2=USB host reset
	  - bit0=auto cache flush, on WORD write only
	  
0002 - 32 bit CPU data port R/W, lo first
0003 - 32 bit CPU command port W
		16'b00000cvvvvvvvvvv = set r/w pointer - 256 32bit integers, 1024 instructions. c=1 for code write, 0 for data read/write
		16'b100wwwvvvvvvvvvv = run ip - 1024 instructions, 3 bit data window offs

0021, 00a1 - interrupt controller data ports. R/W interrupt mask, 1disabled/0enabled (bit0=timer, bit1=keyboard, bit3=RTC, bit4=mouse) 

0040-0043 - PIT 8253 ports

0x60, 0x64 - 8042 keyboard/mouse data and cfg

0061 - bits1:0 speaker on/off (write only)

0070 - RTC (16bit write only counter value). RTC is incremented with 1Mhz and at set value sends INT70h, then restart from 0
		 When set, it restarts from 0. If the set value is 0, it will send INT70h only once, if it was not already 0
			
080h-08fh - memory map: bit9:0=64 Kbytes DDRAM segment index (up to 1024 segs = 64MB), mapped over 
								PORT[3:0] 80186 addressable segment
								
0200h-020fh - joystick port - returns 0ffh

0378 - sound port: 8bit=Covox & DSS compatible, 16bit = stereo L+R - fifo sampled at 44100Hz
		 bit4 of port 03DA is 1 when the sound queue is full. If it is 0, the queue may accept up to 1152 stereo samples (L + R), so 2304 16bit writes.

0379 - parallel port control: bit6 = 1 when DSS queue is full

03C0 - VGA mode 
		index 10h:
			bit0 = graphic(1)/text(0)
			bit3 = text mode flash enabled(1)
			bit4 = half mode (EGA)
			bit6 = 320x200(1)/640x480(0)
		index 13h: bit[3:0] = hrz pan

03C4, 03C5 (Sequencer registers) - idx2[3:0] = write plane, idx4[3]=0 for planar (rw)

03C6 - DAC mask (rw)
03C7 - DAC read index (rw)
03C8 - DAC write index (rw)
03C9 - DAC color (rw)
03CB - font: write WORD = set index (8 bit), r/w BYTE = r/w font data

03CE, 03CF (Graphics registers) (rw)
	0: setres <= din[3:0];
	1: enable_setres <= din[3:0];
	2: color_compare <= din[3:0];
	3: logop <= din[4:3];
	4: rplane <= din[1:0];
	5: rwmode <= {din[3], din[1:0]};
	7: color_dont_care <= din[3:0];
	8: bitmask <= din[7:0]; (1=CPU, 0=latch)

03DA - read VGA status, bit0=1 on vblank or hblank, bit1=RS232in, bit2=USB host serial in, bit3=1 on vblank, bit4=sound queue full, bit5=DSP32 halt, bit7=1 always, bit15:8=SD SPI byte read
		 write bit7=SD SPI MOSI bit, SPI CLK 0->1 (BYTE write only), bit8 = SD card chip select (WORD write only)
		 also reset the 3C0 port index flag

03B4, 03D4 - VGA CRT write index:  
										06h: bit 7=1 for 200lines, 0 for 240 lines
										0Ah(bit 5 only): hide cursor
										0Ch: HI screen offset
										0Dh: LO screen offset
										0Eh: HI cursor pos
										0Fh: LO cursor pos
										13h: scan line offset
03B5, 03D5 - VGA CRT read/write data
*/


`timescale 1ns / 1ps

module system
	(
		 output sdr_CLK_out,
		 output [3:0]sdr_n_CS_WE_RAS_CAS,
		 output [1:0]sdr_BA,
		 output [12:0]sdr_ADDR,
		 inout [15:0]sdr_DATA,
		 output [1:0]sdr_DQM,
		 input 	CLK_32MHZ,
		 output reg [5:0]VGA_R,
		 output reg [5:0]VGA_G,
		 output reg [5:0]VGA_B,
		 output wire VGA_HSYNC,
		 output wire VGA_VSYNC,
		 input BTN_RESET,	// Reset
		 input BTN_NMI,		// NMI
		 output [7:0]LED,	// HALT
		 input RS232_DCE_RXD,
		 output reg RS232_DCE_TXD,
		 input RS232_HOST_RXD,
		 output reg RS232_HOST_TXD,
		 output reg RS232_HOST_RST,

		 output reg SD_n_CS = 1,
		 output wire SD_DI,
		 output reg SD_CK = 0,
		 input SD_DO,
		 
		 output reg AUD_L,
		 output reg AUD_R,
	 	 inout PS2_CLK1,
		 inout PS2_CLK2,
		 inout PS2_DATA1,
		 inout PS2_DATA2
    );

	wire [15:0]cntrl0_user_input_data;//i
	wire [1:0]sys_cmd_ack;
	wire sys_rd_data_valid;
	wire sys_wr_data_valid;   
	wire [15:0]sys_DOUT;	// sdr data out
	wire [12:0]waddr;
	wire [31:0] DOUT;
	wire [15:0]CPU_DOUT;
	wire [15:0]PORT_ADDR;
	wire [31:0] DRAM_dout;
	wire [20:0] ADDR;
	wire IORQ;
	wire WR;
	wire INTA;
	wire WORD;
	wire [3:0] RAM_WMASK;
	wire Empty;	// fifo empty
	wire hblnk;
	wire vblnk;
	wire [9:0]hcount;
	wire [9:0]vcount;
	reg [3:0]vga_hrzpan = 0;
	wire [3:0]vga_hrzpan_req;
	wire [9:0]hcount_pan = hcount + vga_hrzpan - 17;
	wire displ_on = !(hblnk | vblnk | Empty);
	wire [17:0]DAC_COLOR;
	wire Full;
	wire AlmostFull;
	wire AlmostEmpty;
	wire clk_25;
	wire clk_cpu;
	wire clk_sdr;
	wire CPU_CE;	// CPU clock enable
	wire CE;
	wire CE_186;
	wire ddr_rd; 
	wire ddr_wr;
	wire TIMER_OE = PORT_ADDR[15:2] == 14'b00000000010000;	//   40h..43h
	wire VGA_DAC_OE = PORT_ADDR[15:4] == 12'h03c && PORT_ADDR[3:0] <= 4'h9; // 3c0h..3c9h	
	wire LED_PORT = PORT_ADDR[15:0] == 16'h03bc;
	wire SPEAKER_PORT = PORT_ADDR[15:0] == 16'h0061;
	wire MEMORY_MAP = PORT_ADDR[15:4] == 12'h008;
	wire VGA_FONT_OE = PORT_ADDR[15:0] == 16'h03cb;
	wire RS232_OE = PORT_ADDR[15:0] == 16'h0001;
	wire INPUT_STATUS_OE = PORT_ADDR[15:0] == 16'h03da;
	wire VGA_CRT_OE = (PORT_ADDR[15:1] == 15'b000000111011010) || (PORT_ADDR[15:1] == 15'b000000111101010); // 3b4h, 3b5h, 3d4h, 3d5h
	wire RTC_SELECT = PORT_ADDR[15:0] == 16'h0070;
	wire VGA_SC = PORT_ADDR[15:1] == (16'h03c4 >> 1); // 3c4h, 3c5h
	wire VGA_GC = PORT_ADDR[15:1] == (16'h03ce >> 1); // 3ceh, 3cfh
	wire PIC_OE = PORT_ADDR[15:8] == 8'h00 && PORT_ADDR[6:0] == 7'b0100001;	// 21h, a1h
	wire KB_OE = PORT_ADDR[15:4] == 12'h006 && {PORT_ADDR[3], PORT_ADDR[1:0]} == 3'b000; // 60h, 64h
	wire JOYSTICK = PORT_ADDR[15:4] == 12'h020; // 0x200-0x20f
	wire PARALLEL_PORT = PORT_ADDR[15:0] == 16'h0378;
	wire PARALLEL_PORT_CTL = PORT_ADDR[15:0] == 16'h0379;
	wire CPU32_PORT = PORT_ADDR[15:1] == (16'h0002 >> 1); // port 1 for data and 3 for instructions
	wire [7:0]VGA_DAC_DATA;
	wire [7:0]VGA_CRT_DATA;
	wire [7:0]VGA_SC_DATA;
	wire [7:0]VGA_GC_DATA;
	wire [15:0]PORT_IN;
	wire [7:0]TIMER_DOUT;
	wire [7:0]KB_DOUT;
	wire [7:0]PIC_DOUT;
	wire HALT;
	wire CLK44100x256;
	wire sq_full; // sound queue full
	wire dss_full;
	wire AUDIO_L;
	wire AUDIO_R;
	wire [15:0]cpu32_data;
	wire cpu32_halt;
		
	reg [1:0]cntrl0_user_command_register = 0;
	reg [16:0]vga_ddr_row_col = 0; // video buffer offset (multiple of 4)
	reg s_prog_full;
	reg s_prog_empty;
	reg [1:0]s_ddr_rd = 0;
	reg [1:0]s_ddr_wr = 0;
	reg crw = 0;	// 1=cache read window
	reg s_RS232_DCE_RXD;
	reg s_RS232_HOST_RXD;
	reg [4:0]rstcount = 0;
	reg [18:0]s_displ_on = 0;	// clk_25 delayed displ_on
	reg [2:0]vga400 = 0; 		// 1 for 400 lines, 0 for 480 lines
	reg [2:0]vgatext = 0;  		// 1 for text mode
	reg [2:0]v240 = 0;
	reg [2:0]planar = 0;
	reg [2:0]half = 0;
	wire vgaflash;
	reg flashbit = 0;
	reg [5:0]flashcount = 0;
	wire [11:0]charcount = {vcount[8:4], 4'b0000} + {vcount[8:4], 6'b000000} + hcount_pan[9:3];
	wire [31:0]fifo_dout32;
	wire [15:0]fifo_dout = (vgatext[1] ? hcount_pan[3] : vga400[1] ? hcount_pan[2] : hcount_pan[1]) ? fifo_dout32[31:16] : fifo_dout32[15:0];

	reg [8:0]vga_ddr_row_count = 0;
	reg [2:0]max_read;
	reg [4:0]col_counter;
	wire vga_end_frame = vga_ddr_row_count == (v240[0] ? 479 : 399);
	reg [3:0]vga_repln_count = 0; // repeat line counter
	wire [3:0]vga_repln = vgatext[0] ? 15 : (vga400[0] | half[0]) ? 1 : 0;
	reg [7:0]vga_lnbytecount = 0; // line byte count (multiple of 4)
	wire [4:0]vga_lnend = (vgatext[0] | half[0]) ? 5 : (vga400[0] | planar[0]) ? 10 : 20; // multiple of 32 (SDRAM resolution = 32)
	reg [11:0]vga_font_counter = 0;
	reg [7:0]vga_attr;
	reg [4:0]RTCDIV25 = 0;
	reg [1:0]RTCSYNC = 0;
	reg [15:0]RTC = 0;
	reg [15:0]RTCSET = 0;
	wire RTCEND = RTC == RTCSET;
	wire RTCDIVEND = RTCDIV25 == 24;
	reg [12:0]cache_hi_addr;
	wire [8:0]memmap;
	wire [8:0]memmap_mux;
	wire [7:0]font_dout;
	wire [7:0]VGA_FONT_DATA;
	wire vgatextreq;
	wire vga400req;
	wire planarreq;
	wire v240req;
	wire halfreq;
	wire oncursor;
	wire [11:0]cursorpos;
	wire [15:0]scraddr;
	reg flash_on;
	reg speaker_on = 0;
	reg [9:0]rNMI = 0;
	wire [2:0]shift = half[1] ? ~hcount_pan[3:1] : ~hcount_pan[2:0];
	wire [2:0]pxindex = -hcount_pan[2:0];
	wire [3:0]VGA_MUX = vgatext[1] ? (font_dout[pxindex] ^ flash_on) ? vga_attr[3:0] : {vga_attr[7] & ~vgaflash, vga_attr[6:4]} :
									 {fifo_dout32[{2'b11, shift}], fifo_dout32[{2'b10, shift}], fifo_dout32[{2'b01, shift}], fifo_dout32[{2'b00, shift}]};
	reg s_vga_endline;
	reg s_vga_endscanline = 0;
	reg s_vga_endframe;
	reg [20:0]sdraddr;
	wire [3:0]vga_wplane;
	wire [1:0]vga_rplane;
	wire [7:0]vga_bitmask;	// write 1=CPU, 0=VGA latch
	wire [2:0]vga_rwmode;
	wire [3:0]vga_setres;
	wire [3:0]vga_enable_setres;
	wire [1:0]vga_logop;
	wire [3:0]vga_color_compare;
	wire [3:0]vga_color_dont_care;
	wire [7:0]vga_offset;
	reg [2:0]auto_flush = 3'b000;
//	wire slowport = !(INPUT_STATUS_OE || CPU32_PORT);
//	wire WAITIO_ADDR = IORQ && !WR && CE_186 && slowport;
//	reg rWAITIO_ADDR = 1'b0;
//	wire WAITIO = WAITIO_ADDR && !rWAITIO_ADDR;
//	reg [7:0]slowportdata;

	assign LED = {1'b0, !cpu32_halt, AUDIO_L, AUDIO_R, planarreq, |sys_cmd_ack, ~SD_n_CS, HALT};
	
// SD interface
	reg [7:0]SDI;
	assign SD_DI = CPU_DOUT[7];

	assign PORT_IN[15:8] = 
		({8{MEMORY_MAP}} & {7'b0000000, memmap[8]}) |
		({8{INPUT_STATUS_OE}} & SDI) |
		({8{CPU32_PORT}} & cpu32_data[15:8]);

	assign PORT_IN[7:0] = //INPUT_STATUS_OE ? {2'b1x, cpu32_halt, sq_full, vblnk, s_RS232_HOST_RXD, s_RS232_DCE_RXD, hblnk | vblnk} : CPU32_PORT ? cpu32_data[7:0] : slowportdata;
							 ({8{VGA_DAC_OE}} & VGA_DAC_DATA) |
							 ({8{VGA_FONT_OE}}& VGA_FONT_DATA) |
							 ({8{KB_OE}} & KB_DOUT) |
							 ({8{INPUT_STATUS_OE}} & {2'b1x, cpu32_halt, sq_full, vblnk, s_RS232_HOST_RXD, s_RS232_DCE_RXD, hblnk | vblnk}) | 
							 ({8{VGA_CRT_OE}} & VGA_CRT_DATA) | 
							 ({8{MEMORY_MAP}} & {memmap[7:0]}) |
							 ({8{TIMER_OE}} & TIMER_DOUT) |
							 ({8{PIC_OE}} & PIC_DOUT) |
							 ({8{VGA_SC}} & VGA_SC_DATA) |
							 ({8{VGA_GC}} & VGA_GC_DATA) |
							 ({8{JOYSTICK}})|
							 ({8{PARALLEL_PORT_CTL}} & {1'bx, dss_full, 6'bxxxxxx}) |
							 ({8{CPU32_PORT}} & cpu32_data[7:0]);

	dcm dcm_system 
	(
		.CLK_IN1(CLK_32MHZ), 
		.CLK_OUT1(clk_25), 
		.CLK_OUT2(clk_sdr),
		.CLK_OUT3(sdr_CLK_out),
		.CLK_OUT4(clk_cpu),
		.CLK_OUT5(CLK44100x256)
    );


	SDRAM_16bit SDR
	(
		.sys_CLK(clk_sdr),				// clock
		.sys_CMD(cntrl0_user_command_register),					// 00=nop, 01 = write 256 bytes, 10=read 32 bytes, 11=read 256 bytes
		.sys_ADDR(sdraddr),	// word address
		.sys_DIN(cntrl0_user_input_data),		// data input
		.sys_DOUT(sys_DOUT),					// data output
		.sys_rd_data_valid(sys_rd_data_valid),	// data valid read
		.sys_wr_data_valid(sys_wr_data_valid),	// data valid write
		.sys_cmd_ack(sys_cmd_ack),			// command acknowledged
		
		.sdr_n_CS_WE_RAS_CAS(sdr_n_CS_WE_RAS_CAS),			// SDRAM #CS, #WE, #RAS, #CAS
		.sdr_BA(sdr_BA),					// SDRAM bank address
		.sdr_ADDR(sdr_ADDR),				// SDRAM address
		.sdr_DATA(sdr_DATA),				// SDRAM data
		.sdr_DQM(sdr_DQM)					// SDRAM DQM
	);

	fifo vga_fifo 
	(
	  .wr_clk(clk_sdr), // input wr_clk
	  .rd_clk(clk_25), // input rd_clk
	  .din(sys_DOUT), // input [15 : 0] din
	  .wr_en(!crw && sys_rd_data_valid && !col_counter[4]), // input wr_en
	  .rd_en(s_displ_on[~vga_hrzpan] && ((vgatext[1] | half[1]) ? &hcount_pan[3:0] : (vga400[1] | planar[1]) ? &hcount_pan[2:0] : &hcount_pan[1:0])), // input rd_en
	  .dout({fifo_dout32[15:0], fifo_dout32[31:16]}), // output [31 : 0] dout
	  .full(Full), // output full
	  .empty(Empty), // output empty
	  .prog_full(AlmostFull), // output prog_full
	  .prog_empty(AlmostEmpty) // output prog_empty
	);

	VGA_SG VGA 
	(
		.tc_hsblnk(10'd639), 
		.tc_hssync(10'd655 + 10'd17), 	// +17 for hrz panning
		.tc_hesync(10'd751 + 10'd17), 	// +17 for hrz panning
		.tc_heblnk(10'd799), 
		.hcount(hcount), 
		.hsync(VGA_HSYNC), 
		.hblnk(hblnk), 
		.tc_vsblnk(v240[2] ? 10'd479 : 10'd399), 
		.tc_vssync(v240[2] ? 10'd489 : 10'd411), 
		.tc_vesync(v240[2] ? 10'd491 : 10'd413), 
		.tc_veblnk(v240[2] ? 10'd520 : 10'd446), 
		.vcount(vcount), 
		.vsync(VGA_VSYNC), 
		.vblnk(vblnk), 
		.clk(clk_25),
		.ce(!Empty)
	);
	
	VGA_DAC dac 
	(
		 .CE(VGA_DAC_OE && IORQ && CPU_CE), 
		 .WR(WR), 
		 .addr(PORT_ADDR[3:0]), 
		 .din(CPU_DOUT[7:0]), 
		 .dout(VGA_DAC_DATA), 
		 .CLK(clk_cpu), 
		 .VGA_CLK(clk_25), 
		 .vga_addr((vgatext[1] | (~vga400[1] & planar[1])) ? {4'b0000, VGA_MUX} : (vga400[1] ? hcount_pan[1] : hcount_pan[0]) ? fifo_dout[15:8] : fifo_dout[7:0]), 
		 .color(DAC_COLOR),
		 .vgatext(vgatextreq),
		 .vga400(vga400req),
		 .half(halfreq),
		 .vgaflash(vgaflash),
		 .setindex(INPUT_STATUS_OE && IORQ && CPU_CE),
		 .hrzpan(vga_hrzpan_req)
    );
	 
	 VGA_CRT crt
	 (
		.CE(IORQ && CPU_CE && VGA_CRT_OE),
		.WR(WR),
		.WORD(WORD),
		.din(CPU_DOUT),
		.addr(PORT_ADDR[0]),
		.dout(VGA_CRT_DATA),
		.CLK(clk_cpu),
		.oncursor(oncursor),
		.cursorpos(cursorpos),
		.scraddr(scraddr),
		.v240(v240req),
		.offset(vga_offset)
	);
	
	VGA_SC sc
	(
		.CE(IORQ && CPU_CE && VGA_SC),	// 3c4, 3c5
		.WR(WR),
		.WORD(WORD),
		.din(CPU_DOUT),
		.dout(VGA_SC_DATA),
		.addr(PORT_ADDR[0]),
		.CLK(clk_cpu),
		.planarreq(planarreq),
		.wplane(vga_wplane)
    );

	VGA_GC gc
	(
		.CE(IORQ && CPU_CE && VGA_GC),
		.WR(WR),
		.WORD(WORD),
		.din(CPU_DOUT),
		.addr(PORT_ADDR[0]),
		.CLK(clk_cpu),
		.rplane(vga_rplane),
		.bitmask(vga_bitmask),
		.rwmode(vga_rwmode),
		.setres(vga_setres),
		.enable_setres(vga_enable_setres),
		.logop(vga_logop),
		.color_compare(vga_color_compare),
		.color_dont_care(vga_color_dont_care),
		.dout(VGA_GC_DATA)
	);

	sr_font VGA_FONT 
	(
		.clka(clk_25), // input clka
		.wea(1'b0), // input [0 : 0] wea
		.addra({fifo_dout[7:0], vcount[3:0]}), // input [11 : 0] addra
		.dina(8'h00), // input [7 : 0] dina
		.douta(font_dout), // output [7 : 0] douta
		.clkb(clk_cpu), // input clkb
		.web(WR & IORQ & VGA_FONT_OE & ~WORD & CPU_CE), // input [0 : 0] web
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
		 .wmask(RAM_WMASK),
		 .ce(CE), 
		 .ddr_din(sys_DOUT), 
		 .ddr_dout(cntrl0_user_input_data), 
		 .ddr_clk(clk_sdr), 
		 .ddr_rd(ddr_rd), 
		 .ddr_wr(ddr_wr),
		 .waddr(waddr),
		 .cache_write_data(crw && sys_rd_data_valid), // read DDR, write to cache
		 .cache_read_data(crw && sys_wr_data_valid),
		 .flush(auto_flush == 3'b101)
	);

	wire I_KB;
	wire I_MOUSE;
	wire KB_RST;
	KB_Mouse_8042 KB_Mouse 
	(
		 .CS(IORQ && CPU_CE && KB_OE), // 60h, 64h
		 .WR(WR), 
		 .cmd(PORT_ADDR[2]), // 64h
		 .din(CPU_DOUT[7:0]), 
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
		 .CS(PIC_OE && IORQ && CPU_CE), // 21h, a1h
		 .WR(WR), 
		 .din(CPU_DOUT[7:0]), 
		 .dout(PIC_DOUT), 
		 .ivect(PIC_IVECT), 
		 .clk(clk_cpu), 
		 .INT(INT), 
		 .IACK(INTA & CPU_CE), 
		 .I({I_MOUSE, RTCEND, I_KB, timer_int})
    );

	unit186 CPUUnit
	(
		 .INPORT(INTA ? {8'h00, PIC_IVECT} : PORT_IN), 
		 .DIN(DRAM_dout), 
		 .CPU_DOUT(CPU_DOUT),
		 .PORT_ADDR(PORT_ADDR),
		 .DOUT(DOUT), 
		 .ADDR(ADDR), 
		 .WMASK(RAM_WMASK), 
		 .CLK(clk_cpu), 
		 .CE(CE/* & !WAITIO*/), 
		 .CPU_CE(CPU_CE),
		 .CE_186(CE_186),
		 .INTR(INT), 
		 .NMI(rNMI[9]), 
		 .RST(BTN_RESET || !rstcount[4]), 
		 .INTA(INTA), 
		 .LOCK(LOCK), 
		 .HALT(HALT), 
		 .MREQ(MREQ),
		 .IORQ(IORQ),
		 .WR(WR),
		 .WORD(WORD),
		 
		 .PLANAR(planarreq),
		 .VGA_WPLANE(vga_wplane),
		 .VGA_RPLANE(vga_rplane),
		 .VGA_BITMASK(vga_bitmask),
		 .VGA_RWMODE(vga_rwmode),
		 .VGA_SETRES(vga_setres),
		 .VGA_ENABLE_SETRES(vga_enable_setres),
		 .VGA_LOGOP(vga_logop),
		 .VGA_COLOR_COMPARE(vga_color_compare),
		 .VGA_COLOR_DONT_CARE(vga_color_dont_care)
	);
	
	seg_map seg_mapper 
	(
		 .CLK(clk_cpu), 
		 .cpuaddr(PORT_ADDR[3:0]), 
		 .cpurdata(memmap), 
		 .cpuwdata(CPU_DOUT[8:0]), 
		 .memaddr(cache_hi_addr[12:8]), 
		 .memdata(memmap_mux), 
		 .WE(MEMORY_MAP & WR & WORD & IORQ & CPU_CE)
    );

	 wire timer_spk;
	 timer_8253 timer 
	 (
		 .CS(TIMER_OE && IORQ && CPU_CE), 
		 .WR(WR), 
		 .addr(PORT_ADDR[1:0]), 
		 .din(CPU_DOUT[7:0]), 
		 .dout(TIMER_DOUT), 
		 .CLK_25(clk_25), 
		 .clk(clk_cpu), 
		 .out0(timer_int), 
		 .out2(timer_spk)
    );
	 
	 soundwave sound_gen
	 (
		.CLK(clk_cpu),
		.CLK44100x256(CLK44100x256),
		.data(CPU_DOUT),
		.we(IORQ & CPU_CE & WR & PARALLEL_PORT),
		.word(WORD),
		.full(sq_full),	// when not full, write max 2x1152 16bit samples
		.dss_full(dss_full),
		.AUDIO_L(AUDIO_L),
		.AUDIO_R(AUDIO_R)
	);
	 
	DSP32 DSP32_inst
	(
		.clk(clk_cpu),
		.cmd(PORT_ADDR[0]), // port 2=data, port 3=cmd (word only)
		.ce(IORQ & CPU_CE & CPU32_PORT & WORD),
		.wr(WR),
		.din(CPU_DOUT),
		.dout(cpu32_data),
		.halt(cpu32_halt)
	);
	
	reg nop;
	always @ (posedge clk_sdr) begin
		s_prog_full <= AlmostFull;
		s_prog_empty <= AlmostEmpty;
		s_ddr_rd <= {s_ddr_rd[0], ddr_rd};
		s_ddr_wr <= {s_ddr_wr[0], ddr_wr};
		s_vga_endline <= vga_repln_count == vga_repln;
		s_vga_endframe <= vga_end_frame;
		cache_hi_addr <= s_ddr_wr[0] ? waddr : ADDR[20:8];
		nop <= sys_cmd_ack == 2'b00;
		sdraddr <= s_prog_empty || !(s_ddr_wr[1] || s_ddr_rd[1]) ? {4'b0001, vga_ddr_row_col + vga_lnbytecount} : {memmap_mux[6:0], cache_hi_addr[7:0], 6'b000000};
		max_read <= &sdraddr[6:3] ? ~sdraddr[2:0] : 3'b111;	// SDRAM row size = 256 words
		
		if(s_prog_empty) cntrl0_user_command_register <= 2'b10;			// read 32 bytes VGA
		else if(s_ddr_wr[1]) cntrl0_user_command_register <= 2'b01;		// write 256 bytes cache
		else if(s_ddr_rd[1]) cntrl0_user_command_register <= 2'b11;		// read 256 bytes cache
		else if(~s_prog_full) cntrl0_user_command_register <= 2'b10;	// read 32 bytes VGA
		else cntrl0_user_command_register <= 2'b00;
									
		if(!crw && sys_rd_data_valid) col_counter <= col_counter - 1;
		if(nop) case(sys_cmd_ack)
			2'b10: begin
				crw <= 1'b0;	// VGA read
				col_counter <= {1'b0, max_read, 1'b1};
				vga_lnbytecount <= vga_lnbytecount + max_read + 1;
			end					
			2'b01, 2'b11: crw <= 1'b1;	// cache read/write			
		endcase
				
		if(s_vga_endscanline) begin
			col_counter[3:1] <= col_counter[3:1] - vga_lnbytecount[2:0];
			vga_lnbytecount <= 0;
			s_vga_endscanline <= 1'b0;

			if(s_vga_endframe) vga_ddr_row_col <= {{1'b0, scraddr[15:13]} + (vgatext[0] ? 4'b0111 : 4'b0100), scraddr[12:0]};
			else if(s_vga_endline) vga_ddr_row_col <= vga_ddr_row_col + (vgatext[0] ? 40 : {vga_offset, 1'b0});
			
			if(s_vga_endline) vga_repln_count <= 0;
			else vga_repln_count <= vga_repln_count + 1;
			if(s_vga_endframe) begin
				vga400[0] <= vga400req;
				vgatext[0] <= vgatextreq;
				v240[0] <= v240req;
				planar[0] <= planarreq;
				half[0] <= halfreq;
				vga_ddr_row_count <= 0;
			end else vga_ddr_row_count <= vga_ddr_row_count + 1; 
		end else s_vga_endscanline <= (vga_lnbytecount[7:3] == vga_lnend);
	end
	
	always @ (posedge clk_cpu) begin
		s_RS232_DCE_RXD <= RS232_DCE_RXD;
		s_RS232_HOST_RXD <= RS232_HOST_RXD;
		if(IORQ & CPU_CE) begin
			if(WR & RS232_OE) begin
				{RS232_HOST_RST, RS232_HOST_TXD, RS232_DCE_TXD} <= CPU_DOUT[2:0];
				if(WORD) auto_flush[2] <= CPU_DOUT[0];
			end
			if(VGA_FONT_OE) vga_font_counter <= WR && WORD ? {CPU_DOUT[7:0], 4'b0000} : vga_font_counter + 1; 
			if(WR & SPEAKER_PORT) speaker_on <= &CPU_DOUT[1:0];
//			if(WR & LED_PORT) LED <= CPU_DOUT[7:0];
		end
// SD
		if(CPU_CE) begin
			SD_CK <= IORQ & INPUT_STATUS_OE & WR & ~WORD;
			if(IORQ & INPUT_STATUS_OE & WR) begin
				if(WORD) SD_n_CS <= ~CPU_DOUT[8]; // SD chip select
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
		
		auto_flush[1:0] <= {auto_flush[0], vblnk};		
		
/*		rWAITIO_ADDR <= WAITIO_ADDR;

		slowportdata <= ({8{VGA_DAC_OE}} & VGA_DAC_DATA) |
							 ({8{VGA_FONT_OE}}& VGA_FONT_DATA) |
							 ({8{KB_OE}} & KB_DOUT) |
							 ({8{VGA_CRT_OE}} & VGA_CRT_DATA) | 
							 ({8{MEMORY_MAP}} & {memmap[7:0]}) |
							 ({8{TIMER_OE}} & TIMER_DOUT) |
							 ({8{PIC_OE}} & PIC_DOUT) |
							 ({8{VGA_SC}} & VGA_SC_DATA) |
							 ({8{VGA_GC}} & VGA_GC_DATA) |
							 ({8{JOYSTICK}})|
							 ({8{PARALLEL_PORT_CTL}} & {1'bx, dss_full, 6'bxxxxxx});
*/
	end
	
	always @ (posedge clk_25) begin
		s_displ_on <= {s_displ_on[17:0], displ_on};
		vga_attr <= fifo_dout[15:8];		
		flash_on <= (vgaflash & fifo_dout[15] & flashcount[5]) | (~oncursor && flashcount[4] && (charcount == cursorpos) && ((vcount[3:0] == 13) || vcount[3:0] == 14));		
		
		if(!vblnk) begin
			flashbit <= 1;
			vga400[2] <= vga400[1];
			vgatext[2] <= vgatext[1];
			v240[2] <= v240[1];
			planar[2] <= planar[1];
			half[2] <= half[1];
		end else if(flashbit) begin
			flashcount <= flashcount + 1;
			flashbit <= 0;
			vga400[1] <= vga400[0];
			vgatext[1] <= vgatext[0];
			v240[1] <= v240[0];
			planar[1] <= planar[0];
			half[1] <= half[0];
		end
		
		if(RTCDIVEND) RTCDIV25 <= 0;	// real time clock
		else RTCDIV25 <= RTCDIV25 + 1;
		
		if(!BTN_NMI) rNMI <= 0;		// NMI
		else if(!rNMI[9] && RTCDIVEND) rNMI <= rNMI + 1;	// 1Mhz increment

		{VGA_B, VGA_G, VGA_R} <= DAC_COLOR & {18{s_displ_on[17+vgatext[1]]}};
		if(VGA_VSYNC) vga_hrzpan <= half[0] ? {vga_hrzpan_req[2:0], 1'b0} : {1'b0, vga_hrzpan_req[2:0]};
	end
	
	reg [4:0]mix;
	always @(posedge CLK44100x256) begin
		mix <= mix + 1'b1;
		AUD_L <= &mix & speaker_on ? timer_spk : AUDIO_L;
		AUD_R <= &mix & speaker_on ? timer_spk : AUDIO_R; 
	end
	
endmodule

