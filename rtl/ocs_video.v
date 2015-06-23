/*
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*! \file
 * \brief OCS video implementation with WISHBONE master and slave interface.
 */

/*! \brief \copybrief ocs_video.v

List of video registers:
\verbatim
Implemented:
    DIWSTRT      08E  W   A       Display window start (upper left vert-horiz position)
    DIWSTOP      090  W   A       Display window stop (lower right vert.-horiz. position)
    DDFSTRT      092  W   A       Display bitplane data fetch start (horiz. position)
    DDFSTOP      094  W   A       Display bitplane data fetch stop              write implemented here
     [DMACON     096  W   ADP     DMA control write (clear or set)              write implemented here]
    
     [JOY1DAT   *00C  R   D       Joystick-mouse 1 data (vert,horiz)            read not implemented here]
    CLXDAT      *00E  R   D       Collision data register (read and clear)      read not implemented here
    CLXCON       098  W   D       Collision control                             write implemented here
     [INTENA     09A  W   P       Interrupt enable bits (clear or set bits)     write implemented here]
    
    BPLCON0      100  W   AD( E ) Bitplane control register (misc. control bits)
    BPLCON1      102  W   D       Bitplane control reg. (scroll value PF1, PF2)
    BPLCON2      104  W   D( E )  Bitplane control reg. (priority control)
    
    BPL1MOD      108  W   A       Bitplane modulo (odd planes)
    BPL2MOD      10A  W   A       Bitplane modulo (even planes)
    
    BPL1PTH   +  0E0  W   A       Bitplane 1 pointer (high 3 bits)
    BPL1PTL   +  0E2  W   A       Bitplane 1 pointer (low 15 bits)
    BPL2PTH   +  0E4  W   A       Bitplane 2 pointer (high 3 bits)
    BPL2PTL   +  0E6  W   A       Bitplane 2 pointer (low 15 bits)
    BPL3PTH   +  0E8  W   A       Bitplane 3 pointer (high 3 bits)
    BPL3PTL   +  0EA  W   A       Bitplane 3 pointer (low 15 bits)
    BPL4PTH   +  0EC  W   A       Bitplane 4 pointer (high 3 bits)
    BPL4PTL   +  0EE  W   A       Bitplane 4 pointer (low 15 bits)
    BPL5PTH   +  0F0  W   A       Bitplane 5 pointer (high 3 bits)
    BPL5PTL   +  0F2  W   A       Bitplane 5 pointer (low 15 bits)
    BPL6PTH   +  0F4  W   A       Bitplane 6 pointer (high 3 bits)
    BPL6PTL   +  0F6  W   A       Bitplane 6 pointer (low 15 bits)
    
    BPL1DAT   &  110  W   D       Bitplane 1 data (parallel-to-serial convert)
    BPL2DAT   &  112  W   D       Bitplane 2 data (parallel-to-serial convert)
    BPL3DAT   &  114  W   D       Bitplane 3 data (parallel-to-serial convert)
    BPL4DAT   &  116  W   D       Bitplane 4 data (parallel-to-serial convert)
    BPL5DAT   &  118  W   D       Bitplane 5 data (parallel-to-serial convert)
    BPL6DAT   &  11A  W   D       Bitplane 6 data (parallel-to-serial convert)
    
    SPR0PTH   +  120  W   A       Sprite 0 pointer (high 3 bits)
    SPR0PTL   +  122  W   A       Sprite 0 pointer (low 15 bits)
    SPR0POS   %  140  W   AD      Sprite 0 vert-horiz start position data
    SPR0CTL   %  142  W   AD( E ) Sprite 0 vert stop position and control data
    SPR0DATA  %  144  W   D       Sprite 0 image data register A
    SPR0DATB  %  146  W   D       Sprite 0 image data register B
    SPR1PTH   +  124  W   A       Sprite 1 pointer (high 3 bits)
    SPR1PTL   +  126  W   A       Sprite 1 pointer (low 15 bits)
    SPR1POS   %  148  W   AD      Sprite 1 vert-horiz start position  data
    SPR1CTL   %  14A  W   AD      Sprite 1 vert stop position and control data
    SPR1DATA  %  14C  W   D       Sprite 1 image data register A
    SPR1DATB  %  14E  W   D       Sprite 1 image data register B
    SPR2PTH   +  128  W   A       Sprite 2 pointer (high 3 bits)
    SPR2PTL   +  12A  W   A       Sprite 2 pointer (low 15 bits)
    SPR2POS   %  150  W   AD      Sprite 2 vert-horiz start position data
    SPR2CTL   %  152  W   AD      Sprite 2 vert stop position and control data
    SPR2DATA  %  154  W   D       Sprite 2 image data register A
    SPR2DATB  %  156  W   D       Sprite 2 image data register B
    SPR3PTH   +  12C  W   A       Sprite 3 pointer (high 3 bits)
    SPR3PTL   +  12E  W   A       Sprite 3 pointer (low 15 bits)
    SPR3POS   %  158  W   AD      Sprite 3 vert-horiz start position data
    SPR3CTL   %  15A  W   AD      Sprite 3 vert stop position and control data
    SPR3DATA  %  15C  W   D       Sprite 3 image data register A
    SPR3DATB  %  15E  W   D       Sprite 3 image data register B
    SPR4PTH   +  130  W   A       Sprite 4 pointer (high 3 bits)
    SPR4PTL   +  132  W   A       Sprite 4 pointer (low 15 bits)
    SPR4POS   %  160  W   AD      Sprite 4 vert-horiz start position data
    SPR4CTL   %  162  W   AD      Sprite 4 vert stop position and control data
    SPR4DATA  %  164  W   D       Sprite 4 image data register A
    SPR4DATB  %  166  W   D       Sprite 4 image data register B
    SPR5PTH   +  134  W   A       Sprite 5 pointer (high 3 bits)
    SPR5PTL   +  136  W   A       Sprite 5 pointer (low 15 bits)
    SPR5POS   %  168  W   AD      Sprite 5 vert-horiz start position data
    SPR5CTL   %  16A  W   AD      Sprite 5 vert stop position and control data
    SPR5DATA  %  16C  W   D       Sprite 5 image data register A
    SPR5DATB  %  16E  W   D       Sprite 5 image data register B
    SPR6PTH   +  138  W   A       Sprite 6 pointer (high 3 bits)
    SPR6PTL   +  13A  W   A       Sprite 6 pointer (low 15 bits)
    SPR6POS   %  170  W   AD      Sprite 6 vert-horiz start position data
    SPR6CTL   %  172  W   AD      Sprite 6 vert stop position and control data
    SPR6DATA  %  174  W   D       Sprite 6 image data register A
    SPR6DATB  %  176  W   D       Sprite 6 image data register B
    SPR7PTH   +  13C  W   A       Sprite 7 pointer (high 3 bits)
    SPR7PTL   +  13E  W   A       Sprite 7 pointer (low 15 bits)
    SPR7POS   %  178  W   AD      Sprite 7 vert-horiz start position data
    SPR7CTL   %  17A  W   AD      Sprite 7 vert stop position and control data
    SPR7DATA  %  17C  W   D       Sprite 7 image data register A
    SPR7DATB  %  17E  W   D       Sprite 7 image data register B
    
    COLOR00      180  W   D       Color table 00
    COLOR01      182  W   D       Color table 01
    COLOR02      184  W   D       Color table 02
    COLOR03      186  W   D       Color table 03
    COLOR04      188  W   D       Color table 04
    COLOR05      18A  W   D       Color table 05
    COLOR06      18C  W   D       Color table 06
    COLOR07      18E  W   D       Color table 07
    COLOR08      190  W   D       Color table 08
    COLOR09      192  W   D       Color table 09
    COLOR10      194  W   D       Color table 10
    COLOR11      196  W   D       Color table 11
    COLOR12      198  W   D       Color table 12
    COLOR13      19A  W   D       Color table 13
    COLOR14      19C  W   D       Color table 14
    COLOR15      19E  W   D       Color table 15
    COLOR16      1A0  W   D       Color table 16
    COLOR17      1A2  W   D       Color table 17
    COLOR18      1A4  W   D       Color table 18
    COLOR19      1A6  W   D       Color table 19
    COLOR20      1A8  W   D       Color table 20
    COLOR21      1AA  W   D       Color table 21
    COLOR22      1AC  W   D       Color table 22
    COLOR23      1AE  W   D       Color table 23
    COLOR24      1B0  W   D       Color table 24
    COLOR25      1B2  W   D       Color table 25
    COLOR26      1B4  W   D       Color table 26
    COLOR27      1B6  W   D       Color table 27
    COLOR28      1B8  W   D       Color table 28
    COLOR29      1BA  W   D       Color table 29
    COLOR30      1BC  W   D       Color table 30
    COLOR31      1BE  W   D       Color table 31
\endverbatim
*/
module ocs_video(
    //% \name Clock and reset
    //% @{
    input               CLK_I,
    input               reset_n,
    //% @}
    
    //% \name WISHBONE master
    //% @{
    output reg          CYC_O,
    output reg          STB_O,
    output              WE_O,
    output reg [31:2]   ADR_O,
    output [3:0]        SEL_O,
    input [31:0]        master_DAT_I,
    input               ACK_I,
    //% @}
    
    //% \name WISHBONE slave
    //% @{
    input               CYC_I,
    input               STB_I,
    input               WE_I,
    input [8:2]         ADR_I,
    input [3:0]         SEL_I,
    input [31:0]        slave_DAT_I,
    output reg          ACK_O,
    //% @}
    
    //% \name Not aligned register access on a 32-bit WISHBONE bus
    //% @{
        // CLXDAT read not implemented here
    input               na_clx_dat_read,
    output [15:0]       na_clx_dat,
        // INTENA write implemented here
    output              na_int_ena_write,
    output [15:0]       na_int_ena,
    output [1:0]        na_int_ena_sel,
        // DMACON write implemented here
    output              na_dma_con_write,
    output [15:0]       na_dma_con,
    output [1:0]        na_dma_con_sel,
    //% @}
    
    //% \name Direct drv_ssram read/write DMA burst video interface
    //% @{
	// bitplain burst read
	output              burst_read_request,
	output [31:2]       burst_read_address,
	input               burst_read_ready,
	input [31:0]        burst_read_data,
	
    // video output burst write
    output              burst_write_request,
    output [31:2]       burst_write_address,
    output [35:0]       burst_write_data,
    input               burst_write_ready,
    //% @}
    
    //% \name Internal OCS ports
    //% @{
    input               line_start,
    input               line_pre_start,
    input [8:0]         line_number,
    input [8:0]         column_number,
    
    input [10:0]        dma_con
    //% @}
);

`define VIDEO_BUFFER            32'h10180000
`define VIDEO_BUFFER_DIV_4      30'h04060000

// No: BPLCON0: External synchronize, Lace mode, lightpen, genlock audio enable, color composite
// No: data fetch word after word - all fetched at once

/*                              16-bit      32-bit
- get sprite data:              2x8         2x8     
- get bitplain data:            40x6        21x6
- save line to video memory:    214         214
16-bit: 16+240+214 = 470 = 7.834 us
32-bit: 16+126+640+214 = 996 = 16599.993 us

PAL: 52.000 us / 64.000 us
display out: 3.567 us / 26.667 us
*/
assign na_int_ena_write = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && { ADR_I, 2'b0 } == 9'h098 && ACK_O == 1'b0);
assign na_int_ena = slave_DAT_I[15:0];
assign na_int_ena_sel = SEL_I[1:0];

assign na_dma_con_write = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && { ADR_I, 2'b0 } == 9'h094 && ACK_O == 1'b0);
assign na_dma_con = slave_DAT_I[15:0];
assign na_dma_con_sel = SEL_I[1:0];

assign SEL_O = 4'b1111;
assign WE_O = 1'b0;

wire [3:0] dma_select;
assign dma_select = 
    (sprite0_dma_req == 1'b1) ? 4'd1 :
    (sprite1_dma_req == 1'b1) ? 4'd2 :
    (sprite2_dma_req == 1'b1) ? 4'd3 :
    (sprite3_dma_req == 1'b1) ? 4'd4 :
    (sprite4_dma_req == 1'b1) ? 4'd5 :
    (sprite5_dma_req == 1'b1) ? 4'd6 :
    (sprite6_dma_req == 1'b1) ? 4'd7 :
    (sprite7_dma_req == 1'b1) ? 4'd8 :
    4'd0;

wire [31:2] dma_address_select;
assign dma_address_select =
    (dma_select == 4'd1) ? sprite0_dma_address :
    (dma_select == 4'd2) ? sprite1_dma_address :
    (dma_select == 4'd3) ? sprite2_dma_address :
    (dma_select == 4'd4) ? sprite3_dma_address :
    (dma_select == 4'd5) ? sprite4_dma_address :
    (dma_select == 4'd6) ? sprite5_dma_address :
    (dma_select == 4'd7) ? sprite6_dma_address :
    sprite7_dma_address;

wire [5:0] bpl_color;
wire [1:0] sprite0_color;
wire [1:0] sprite1_color;
wire sprite01_attached;
wire [1:0] sprite2_color;
wire [1:0] sprite3_color;
wire sprite23_attached;
wire [1:0] sprite4_color;
wire [1:0] sprite5_color;
wire sprite45_attached;
wire [1:0] sprite6_color;
wire [1:0] sprite7_color;
wire sprite67_attached;
wire [10:0] bpl_con0;
wire window_line_enable;

wire priority_write_ena;
assign priority_write_ena = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0 &&
    (   ({ ADR_I, 2'b0 } >= 9'h180 && { ADR_I, 2'b0 } <= 9'h1BC) || 
        { ADR_I, 2'b0 } == 9'h08C || { ADR_I, 2'b0 } == 9'h090 || { ADR_I, 2'b0 } == 9'h098 || { ADR_I, 2'b0 } == 9'h104
    ));

video_priority video_priority_inst (
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .line_pre_start(line_pre_start),
    .line_number(line_number),
    .column_number(column_number),
    .window_line_enable(window_line_enable),
    
    .write_ena(priority_write_ena),
    // 0:   COLOR00,    COLOR01,
    // 1:   COLOR02,    COLOR03,
    // 2:   COLOR04,    COLOR05,
    // 3:   COLOR06,    COLOR07,
    // 4:   COLOR08,    COLOR09,
    // 5:   COLOR10,    COLOR11,
    // 6:   COLOR12,    COLOR13,
    // 7:   COLOR14,    COLOR15,
    // 8:   COLOR16,    COLOR17,
    // 9:   COLOR18,    COLOR19,
    // 10:  COLOR20,    COLOR21,
    // 11:  COLOR22,    COLOR23,
    // 12:  COLOR24,    COLOR25,
    // 13:  COLOR26,    COLOR27,
    // 14:  COLOR28,    COLOR29,
    // 15:  COLOR30,    COLOR31,
    // 16:      DIWSTRT [15:0],     COPINS      [31:16], * COPINS not implemented  
    // 17:      DIWSTOP [31:16],    DDFSTART    [15:0], *
    // 18:      CLXCON  [31:16],    INTENA      [15:0], *
    // 19:      BPLCON2 [31:16],    NOT USED    [15:0],
    // read:    CLXDAT  [15:0],     JOY1DAT     [31:16] *
    .write_address(
        ({ ADR_I, 2'b0 } == 9'h180) ? 5'd0 :
        ({ ADR_I, 2'b0 } == 9'h184) ? 5'd1 :
        ({ ADR_I, 2'b0 } == 9'h188) ? 5'd2 :
        ({ ADR_I, 2'b0 } == 9'h18C) ? 5'd3 :
        ({ ADR_I, 2'b0 } == 9'h190) ? 5'd4 :
        ({ ADR_I, 2'b0 } == 9'h194) ? 5'd5 :
        ({ ADR_I, 2'b0 } == 9'h198) ? 5'd6 :
        ({ ADR_I, 2'b0 } == 9'h19C) ? 5'd7 :
        ({ ADR_I, 2'b0 } == 9'h1A0) ? 5'd8 :
        ({ ADR_I, 2'b0 } == 9'h1A4) ? 5'd9 :
        ({ ADR_I, 2'b0 } == 9'h1A8) ? 5'd10 :
        ({ ADR_I, 2'b0 } == 9'h1AC) ? 5'd11 :
        ({ ADR_I, 2'b0 } == 9'h1B0) ? 5'd12 :
        ({ ADR_I, 2'b0 } == 9'h1B4) ? 5'd13 :
        ({ ADR_I, 2'b0 } == 9'h1B8) ? 5'd14 :
        ({ ADR_I, 2'b0 } == 9'h1BC) ? 5'd15 :
        ({ ADR_I, 2'b0 } == 9'h08C) ? 5'd16 :
        ({ ADR_I, 2'b0 } == 9'h090) ? 5'd17 :
        ({ ADR_I, 2'b0 } == 9'h098) ? 5'd18 :
        5'd19
    ),
    .write_data(slave_DAT_I),
    .write_sel(SEL_I),
    
    .bpl_color(bpl_color),
    .sprite0_color(sprite0_color),
    .sprite1_color(sprite1_color),
    .sprite01_attached(sprite01_attached),
    .sprite2_color(sprite2_color),
    .sprite3_color(sprite3_color),
    .sprite23_attached(sprite23_attached),
    .sprite4_color(sprite4_color),
    .sprite5_color(sprite5_color),
    .sprite45_attached(sprite45_attached),
    .sprite6_color(sprite6_color),
    .sprite7_color(sprite7_color),
    .sprite67_attached(sprite67_attached),
    
    .clx_dat_read(na_clx_dat_read),
    .clx_dat(na_clx_dat),
    
    .bpl_con0(bpl_con0),
    
    // video interface
    .burst_write_request(burst_write_request),
    .burst_write_address(burst_write_address),
    .burst_write_data(burst_write_data),
    .burst_write_ready(burst_write_ready)
);

wire bitplains_write_ena;
assign bitplains_write_ena = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0 &&
    (   ({ ADR_I, 2'b0 } >= 9'h0E0 && { ADR_I, 2'b0 } <= 9'h0F4) || 
        { ADR_I, 2'b0 } == 9'h090 ||
        { ADR_I, 2'b0 } == 9'h094 ||
        { ADR_I, 2'b0 } == 9'h100 ||
        { ADR_I, 2'b0 } == 9'h108 ||
        ({ ADR_I, 2'b0 } >= 9'h110 && { ADR_I, 2'b0 } <= 9'h118)
    ));

wire [7:0] disabled_sprites;

bitplains bitplains_inst(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .column_number(column_number),
    
    // video interface - read
    .burst_read_enabled(dma_con[9] == 1'b1 && dma_con[8] == 1'b1 && window_line_enable == 1'b1),
	.burst_read_request(burst_read_request),
	.burst_read_address(burst_read_address),
	.burst_read_ready(burst_read_ready),
	.burst_read_data(burst_read_data),
    
    .write_ena(bitplains_write_ena),
    // 0:   BPL1PTH,    BPL1PTL,
    // 1:   BPL2PTH,    BPL2PTL,
    // 2:   BPL3PTH,    BPL3PTL,
    // 3:   BPL4PTH,    BPL4PTL,
    // 4:   BPL5PTH,    BPL5PTL,
    // 5:   BPL6PTH,    BPL6PTL,
    // 6:       DDFSTRT [15:0],     DIWSTOP [31:16], *
    // 7:       DDFSTOP [31:16],    DMACON  [15:0], *
    // 8:   BPLCON0,    BPLCON1,
    // 9:   BPL1MOD,    BPL2MOD,
    // 10:  BPL1DAT,    BPL2DAT,
    // 11:  BPL3DAT,    BPL4DAT,
    // 12:  BPL5DAT,    BPL6DAT
    .write_address(
        ({ ADR_I, 2'b0 } == 9'h0E0) ? 4'd0 :
        ({ ADR_I, 2'b0 } == 9'h0E4) ? 4'd1 :
        ({ ADR_I, 2'b0 } == 9'h0E8) ? 4'd2 :
        ({ ADR_I, 2'b0 } == 9'h0EC) ? 4'd3 :
        ({ ADR_I, 2'b0 } == 9'h0F0) ? 4'd4 :
        ({ ADR_I, 2'b0 } == 9'h0F4) ? 4'd5 :
        ({ ADR_I, 2'b0 } == 9'h090) ? 4'd6 :
        ({ ADR_I, 2'b0 } == 9'h094) ? 4'd7 :
        ({ ADR_I, 2'b0 } == 9'h100) ? 4'd8 :
        ({ ADR_I, 2'b0 } == 9'h108) ? 4'd9 :
        ({ ADR_I, 2'b0 } == 9'h110) ? 4'd10 :
        ({ ADR_I, 2'b0 } == 9'h114) ? 4'd11 :
        4'd12
    ),
    .write_data(slave_DAT_I),
    .write_sel(SEL_I),
    
    .disable_sprites(disabled_sprites),
    .bpl_con0(bpl_con0),
    .color(bpl_color),
    
    .line_number(line_number)
);

wire sprite0_write_ena;
wire sprite0_dma_req;
wire [31:2] sprite0_dma_address;

assign sprite0_write_ena = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0 &&
    ({ ADR_I, 2'b0 } == 9'h120 || { ADR_I, 2'b0 } == 9'h140 || { ADR_I, 2'b0 } == 9'h144) );

sprite sprite0_inst(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .line_number(line_number),
    .column_number(column_number),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[5] == 1'b1 && disabled_sprites[0] == 1'b0),
    .dma_req(sprite0_dma_req),
    .dma_address(sprite0_dma_address),
    .dma_done(dma_select == 4'd1 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(sprite0_write_ena),
    // 0:   SPR0PTH,    SPR0PTL,
    // 1:   SPR0POS,    SPR0CTL,
    // 2:   SPR0DATA,   SPR0DATB,
    .write_address(
        ({ ADR_I, 2'b0 } == 9'h120) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h140) ? 2'd1 :
        2'd2
    ),
    .write_data(slave_DAT_I),
    .write_sel(SEL_I),
    
    .attached(),
    .color(sprite0_color)
);

wire sprite1_write_ena;
wire sprite1_dma_req;
wire [31:2] sprite1_dma_address;

assign sprite1_write_ena = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0 &&
    ({ ADR_I, 2'b0 } == 9'h124 || { ADR_I, 2'b0 } == 9'h148 || { ADR_I, 2'b0 } == 9'h14C) );

sprite sprite1_inst(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .line_number(line_number),
    .column_number(column_number),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[5] == 1'b1 && disabled_sprites[1] == 1'b0),
    .dma_req(sprite1_dma_req),
    .dma_address(sprite1_dma_address),
    .dma_done(dma_select == 4'd2 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(sprite1_write_ena),
    // 0:   SPR0PTH,    SPR0PTL,
    // 1:   SPR0POS,    SPR0CTL,
    // 2:   SPR0DATA,   SPR0DATB,
    .write_address(
        ({ ADR_I, 2'b0 } == 9'h124) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h148) ? 2'd1 :
        2'd2
    ),
    .write_data(slave_DAT_I),
    .write_sel(SEL_I),
    
    .attached(sprite01_attached),
    .color(sprite1_color)
);

wire sprite2_write_ena;
wire sprite2_dma_req;
wire [31:2] sprite2_dma_address;

assign sprite2_write_ena = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0 &&
    ({ ADR_I, 2'b0 } == 9'h128 || { ADR_I, 2'b0 } == 9'h150 || { ADR_I, 2'b0 } == 9'h154) );

sprite sprite2_inst(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .line_number(line_number),
    .column_number(column_number),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[5] == 1'b1 && disabled_sprites[2] == 1'b0),
    .dma_req(sprite2_dma_req),
    .dma_address(sprite2_dma_address),
    .dma_done(dma_select == 4'd3 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(sprite2_write_ena),
    // 0:   SPR0PTH,    SPR0PTL,
    // 1:   SPR0POS,    SPR0CTL,
    // 2:   SPR0DATA,   SPR0DATB,
    .write_address(
        ({ ADR_I, 2'b0 } == 9'h128) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h150) ? 2'd1 :
        2'd2
    ),
    .write_data(slave_DAT_I),
    .write_sel(SEL_I),
    
    .attached(),
    .color(sprite2_color)
);

wire sprite3_write_ena;
wire sprite3_dma_req;
wire [31:2] sprite3_dma_address;

assign sprite3_write_ena = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0 &&
    ({ ADR_I, 2'b0 } == 9'h12C || { ADR_I, 2'b0 } == 9'h158 || { ADR_I, 2'b0 } == 9'h15C) );

sprite sprite3_inst(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .line_number(line_number),
    .column_number(column_number),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[5] == 1'b1 && disabled_sprites[3] == 1'b0),
    .dma_req(sprite3_dma_req),
    .dma_address(sprite3_dma_address),
    .dma_done(dma_select == 4'd4 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(sprite3_write_ena),
    // 0:   SPR0PTH,    SPR0PTL,
    // 1:   SPR0POS,    SPR0CTL,
    // 2:   SPR0DATA,   SPR0DATB,
    .write_address(
        ({ ADR_I, 2'b0 } == 9'h12C) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h158) ? 2'd1 :
        2'd2
    ),
    .write_data(slave_DAT_I),
    .write_sel(SEL_I),
    
    .attached(sprite23_attached),
    .color(sprite3_color)
);

wire sprite4_write_ena;
wire sprite4_dma_req;
wire [31:2] sprite4_dma_address;

assign sprite4_write_ena = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0 &&
    ({ ADR_I, 2'b0 } == 9'h130 || { ADR_I, 2'b0 } == 9'h160 || { ADR_I, 2'b0 } == 9'h164) );

sprite sprite4_inst(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .line_number(line_number),
    .column_number(column_number),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[5] == 1'b1 && disabled_sprites[4] == 1'b0),
    .dma_req(sprite4_dma_req),
    .dma_address(sprite4_dma_address),
    .dma_done(dma_select == 4'd5 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(sprite4_write_ena),
    // 0:   SPR0PTH,    SPR0PTL,
    // 1:   SPR0POS,    SPR0CTL,
    // 2:   SPR0DATA,   SPR0DATB,
    .write_address(
        ({ ADR_I, 2'b0 } == 9'h130) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h160) ? 2'd1 :
        2'd2
    ),
    .write_data(slave_DAT_I),
    .write_sel(SEL_I),
    
    .attached(),
    .color(sprite4_color)
);

wire sprite5_write_ena;
wire sprite5_dma_req;
wire [31:2] sprite5_dma_address;

assign sprite5_write_ena = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0 &&
    ({ ADR_I, 2'b0 } == 9'h134 || { ADR_I, 2'b0 } == 9'h168 || { ADR_I, 2'b0 } == 9'h16C) );

sprite sprite5_inst(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .line_number(line_number),
    .column_number(column_number),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[5] == 1'b1 && disabled_sprites[5] == 1'b0),
    .dma_req(sprite5_dma_req),
    .dma_address(sprite5_dma_address),
    .dma_done(dma_select == 4'd6 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(sprite5_write_ena),
    // 0:   SPR0PTH,    SPR0PTL,
    // 1:   SPR0POS,    SPR0CTL,
    // 2:   SPR0DATA,   SPR0DATB,
    .write_address(
        ({ ADR_I, 2'b0 } == 9'h134) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h168) ? 2'd1 :
        2'd2
    ),
    .write_data(slave_DAT_I),
    .write_sel(SEL_I),
    
    .attached(sprite45_attached),
    .color(sprite5_color)
);

wire sprite6_write_ena;
wire sprite6_dma_req;
wire [31:2] sprite6_dma_address;

assign sprite6_write_ena = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0 &&
    ({ ADR_I, 2'b0 } == 9'h138 || { ADR_I, 2'b0 } == 9'h170 || { ADR_I, 2'b0 } == 9'h174) );

sprite sprite6_inst(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .line_number(line_number),
    .column_number(column_number),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[5] == 1'b1 && disabled_sprites[6] == 1'b0),
    .dma_req(sprite6_dma_req),
    .dma_address(sprite6_dma_address),
    .dma_done(dma_select == 4'd7 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(sprite6_write_ena),
    // 0:   SPR0PTH,    SPR0PTL,
    // 1:   SPR0POS,    SPR0CTL,
    // 2:   SPR0DATA,   SPR0DATB,
    .write_address(
        ({ ADR_I, 2'b0 } == 9'h138) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h170) ? 2'd1 :
        2'd2
    ),
    .write_data(slave_DAT_I),
    .write_sel(SEL_I),
    
    .attached(),
    .color(sprite6_color)
);

wire sprite7_write_ena;
wire sprite7_dma_req;
wire [31:2] sprite7_dma_address;

assign sprite7_write_ena = (CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0 &&
    ({ ADR_I, 2'b0 } == 9'h13C || { ADR_I, 2'b0 } == 9'h178 || { ADR_I, 2'b0 } == 9'h17C) );

sprite sprite7_inst(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .line_number(line_number),
    .column_number(column_number),
    
    .dma_ena(dma_con[9] == 1'b1 && dma_con[5] == 1'b1 && disabled_sprites[7] == 1'b0),
    .dma_req(sprite7_dma_req),
    .dma_address(sprite7_dma_address),
    .dma_done(dma_select == 4'd8 && ACK_I == 1'b1),
    .dma_data(master_DAT_I),
    
    .write_ena(sprite7_write_ena),
    // 0:   SPR0PTH,    SPR0PTL,
    // 1:   SPR0POS,    SPR0CTL,
    // 2:   SPR0DATA,   SPR0DATB,
    .write_address(
        ({ ADR_I, 2'b0 } == 9'h13C) ? 2'd0 :
        ({ ADR_I, 2'b0 } == 9'h178) ? 2'd1 :
        2'd2
    ),
    .write_data(slave_DAT_I),
    .write_sel(SEL_I),
    
    .attached(sprite67_attached),
    .color(sprite7_color)
);

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        CYC_O <= 1'b0;
        STB_O <= 1'b0;
        ADR_O <= 19'd0;
        ACK_O <= 1'b0;
    end
    else begin
        // write/read registers as slave
        
        // if start of new line:
        //      get sprite data as master
        //      get bitmap data as master
        
        // concurrent save line to video memory
        
        if(ACK_O == 1'b1) begin
            ACK_O <= 1'b0;
        end
        else if((CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0) || priority_write_ena == 1'b1 || bitplains_write_ena == 1'b1 ||
            sprite0_write_ena == 1'b1 || sprite1_write_ena == 1'b1 || sprite2_write_ena == 1'b1 || sprite3_write_ena == 1'b1 || 
            sprite4_write_ena == 1'b1 || sprite5_write_ena == 1'b1 || sprite6_write_ena == 1'b1 || sprite7_write_ena == 1'b1 ||
            na_int_ena_write == 1'b1 || na_dma_con_write == 1'b1)
        begin
            ACK_O <= 1'b1;
        end
        
        if(CYC_O == 1'b0 && STB_O == 1'b0 && dma_select != 4'd0) begin
            ADR_O <= dma_address_select;
            CYC_O <= 1'b1;
            STB_O <= 1'b1;
        end
        else if(CYC_O == 1'b1 && STB_O == 1'b1 && ACK_I == 1'b1) begin
            CYC_O <= 1'b0;
            STB_O <= 1'b0;
        end
        
        // WARNING: disable sprites if ddf_start early
        // WARNING: line_start, line_number and line_ena change at once
    end
end

endmodule

/*! \brief Video output generator from bitplain and sprite video data input.
 */
module video_priority(
    input CLK_I,
    input reset_n,
    
    input line_start,
    input line_pre_start,
    input [8:0] line_number,
    input [8:0] column_number,
    output window_line_enable,
    
    input write_ena,
    // 0:   COLOR00,    COLOR01,
    // 1:   COLOR02,    COLOR03,
    // 2:   COLOR04,    COLOR05,
    // 3:   COLOR06,    COLOR07,
    // 4:   COLOR08,    COLOR09,
    // 5:   COLOR10,    COLOR11,
    // 6:   COLOR12,    COLOR13,
    // 7:   COLOR14,    COLOR15,
    // 8:   COLOR16,    COLOR17,
    // 9:   COLOR18,    COLOR19,
    // 10:  COLOR20,    COLOR21,
    // 11:  COLOR22,    COLOR23,
    // 12:  COLOR24,    COLOR25,
    // 13:  COLOR26,    COLOR27,
    // 14:  COLOR28,    COLOR29,
    // 15:  COLOR30,    COLOR31,
    // 16:      DIWSTRT [15:0],     COPINS      [31:16], * COPINS not implemented  
    // 17:      DIWSTOP [31:16],    DDFSTART    [15:0], *
    // 18:      CLXCON  [31:16],    INTENA      [15:0], *
    // 19:      BPLCON2 [31:16],    NOT USED    [15:0],
    // read:    CLXDAT  [15:0],     JOY1DAT     [31:16] *
    input [4:0] write_address,
    input [31:0] write_data,
    input [3:0] write_sel,
    
    input [5:0] bpl_color,
    input [1:0] sprite0_color,
    input [1:0] sprite1_color,
    input sprite01_attached,
    input [1:0] sprite2_color,
    input [1:0] sprite3_color,
    input sprite23_attached,
    input [1:0] sprite4_color,
    input [1:0] sprite5_color,
    input sprite45_attached,
    input [1:0] sprite6_color,
    input [1:0] sprite7_color,
    input sprite67_attached,
    
    input clx_dat_read,
    output reg [15:0] clx_dat,
    
    input [10:0] bpl_con0,
    
    // video interface
    output reg burst_write_request,
    output reg [31:2] burst_write_address,
    output [35:0] burst_write_data,
    input burst_write_ready
);

// lowres, noninterlaced
reg [15:0] diw_start;
wire [8:0] hstart;
wire [8:0] vstart;
assign hstart = { 1'b0, diw_start[7:0] };
assign vstart = { 1'b0, diw_start[15:8]};

// lowres, noninterlaced
reg [15:0] diw_stop;
wire [8:0] hstop;
wire [8:0] vstop;
assign hstop = { 1'b1, diw_stop[7:0] };
assign vstop = { ~diw_stop[15], diw_stop[15:8] };

assign window_line_enable = (line_number >= vstart && line_number < vstop);
wire screen_line_enable;
assign screen_line_enable = (line_number >= 9'h2C && line_number < 9'h12C);

// output reg [15:0] clx_dat;
reg [15:0] clx_con;

reg [6:0] bpl_con2;

reg [11:0] color00;
reg [11:0] color01;
reg [11:0] color02;
reg [11:0] color03;
reg [11:0] color04;
reg [11:0] color05;
reg [11:0] color06;
reg [11:0] color07;
reg [11:0] color08;
reg [11:0] color09;
reg [11:0] color10;
reg [11:0] color11;
reg [11:0] color12;
reg [11:0] color13;
reg [11:0] color14;
reg [11:0] color15;
reg [11:0] color16;
reg [11:0] color17;
reg [11:0] color18;
reg [11:0] color19;
reg [11:0] color20;
reg [11:0] color21;
reg [11:0] color22;
reg [11:0] color23;
reg [11:0] color24;
reg [11:0] color25;
reg [11:0] color26;
reg [11:0] color27;
reg [11:0] color28;
reg [11:0] color29;
reg [11:0] color30;
reg [11:0] color31;

reg [7:0] line_ram_addr;
reg [35:0] line_ram_data;
altsyncram line_ram_inst(
	.clock0(CLK_I),

	.address_a(line_ram_addr),
	.wren_a(screen_line_enable == 1'b1 && column_number >= 9'h81 &&
	    ((column_number == 9'h1C1 && line_ram_counter == 3'd1) || (column_number < 9'h1C1 && line_ram_counter == 3'd3))),
	.data_a(
        (column_number == 9'h1C1 && line_ram_counter == 3'd1)? { final_color_value, 24'd0 } : { line_ram_data[23:0], final_color_value }
    ),
	.q_a(burst_write_data)
);
defparam 
    line_ram_inst.operation_mode = "SINGLE_PORT",
    line_ram_inst.width_a = 36,
    line_ram_inst.widthad_a = 8;

// Collision detection
// - sprite group - sprite group(1); sprite group - any playfield(2); playfield - playfield(3)
// - clxdat: does not depend on dual-playfield mode
// - clxcon: all disabled bitplains = collision always detected
wire clx_sprite_group_01;
assign clx_sprite_group_01 = (sprite0_color != 2'b00 || (clx_con[12] == 1'b1 && sprite1_color != 2'b00));
wire clx_sprite_group_23;
assign clx_sprite_group_23 = (sprite2_color != 2'b00 || (clx_con[13] == 1'b1 && sprite3_color != 2'b00));
wire clx_sprite_group_45;
assign clx_sprite_group_45 = (sprite4_color != 2'b00 || (clx_con[14] == 1'b1 && sprite5_color != 2'b00));
wire clx_sprite_group_67;
assign clx_sprite_group_67 = (sprite6_color != 2'b00 || (clx_con[15] == 1'b1 && sprite7_color != 2'b00));

wire clx_even_bpls;
assign clx_even_bpls =  (clx_con[7] == 1'b1 && clx_con[1] == bpl_color[1]) ||  (clx_con[9] == 1'b1 && clx_con[3] == bpl_color[3]) ||
                        (clx_con[11] == 1'b1 && clx_con[5] == bpl_color[5]);
wire clx_odd_bpls;
assign clx_odd_bpls =   (clx_con[6] == 1'b1 && clx_con[0] == bpl_color[0]) || (clx_con[8] == 1'b1 && clx_con[2] == bpl_color[2]) ||
                        (clx_con[10] == 1'b1 && clx_con[4] == bpl_color[4]);

wire [14:0] clx_detected;
assign clx_detected = {
    clx_sprite_group_45 && clx_sprite_group_67,
    clx_sprite_group_23 && clx_sprite_group_67,
    clx_sprite_group_23  && clx_sprite_group_45,
    clx_sprite_group_01 && clx_sprite_group_67,
    clx_sprite_group_01  && clx_sprite_group_45,
    clx_sprite_group_01  && clx_sprite_group_23,
    (clx_con[11:6] == 6'd0) || (clx_even_bpls == 1'b1 && clx_sprite_group_67),
    (clx_con[11:6] == 6'd0) || (clx_even_bpls == 1'b1 && clx_sprite_group_45),
    (clx_con[11:6] == 6'd0) || (clx_even_bpls == 1'b1 && clx_sprite_group_23),
    (clx_con[11:6] == 6'd0) || (clx_even_bpls == 1'b1 && clx_sprite_group_01),
    (clx_con[11:6] == 6'd0) || (clx_odd_bpls == 1'b1 && clx_sprite_group_67),
    (clx_con[11:6] == 6'd0) || (clx_odd_bpls == 1'b1 && clx_sprite_group_45),
    (clx_con[11:6] == 6'd0) || (clx_odd_bpls == 1'b1 && clx_sprite_group_23),
    (clx_con[11:6] == 6'd0) || (clx_odd_bpls == 1'b1 && clx_sprite_group_01),
    (clx_con[11:6] == 6'd0) || (clx_odd_bpls == 1'b1 && clx_even_bpls == 1'b1)
};

// Video priority
// - sprite 0 more important than 1,2,3,4,5,6,7
// - for priority and collision, sprite groups: 0-1, 2-3, 4-5, 6-7
// - PF2PRI = 0, PF1 more important than PF2; PF2PRI = 1, PL2 more important than PL1
// - PF2P2 - PF2P0 for non-dual playfield or PF2
// - PF1P2 - PF1P0 for PF1
//      - PF(0) SP01 PF(1) SP23 PF(2) SP45 PF(3) SP67 PF(4)
//
// Dual-playfield: bpl_con0[5] == 1'b1; PF1 color lookup 0(transparent)-7; PF2 color lookup 8(transparent)-15
// Attached sprites: 0-1, 2-3, 4-5, 6-7; color 16(transparent)-31; { sprite1_color[1:0], sprite0_color[1:0] }
wire [4:0] spr0_color;
assign spr0_color = { 1'b1, (sprite01_attached == 1'b1)? sprite1_color[1:0] : 2'b00, sprite0_color[1:0] };
wire [4:0] spr1_color;
assign spr1_color = (sprite01_attached == 1'b1)? spr0_color : { 3'b100, sprite1_color[1:0] };

wire [4:0] spr2_color;
assign spr2_color = { 1'b1, (sprite23_attached == 1'b1)? sprite3_color[1:0] : 2'b01, sprite2_color[1:0] };
wire [4:0] spr3_color;
assign spr3_color = (sprite23_attached == 1'b1)? spr2_color : { 3'b101, sprite3_color[1:0] };

wire [4:0] spr4_color;
assign spr4_color = { 1'b1, (sprite45_attached == 1'b1)? sprite5_color[1:0] : 2'b10, sprite4_color[1:0] };
wire [4:0] spr5_color;
assign spr5_color = (sprite45_attached == 1'b1)? spr4_color : { 3'b110, sprite5_color[1:0] };

wire [4:0] spr6_color;
assign spr6_color = { 1'b1, (sprite67_attached == 1'b1)? sprite7_color[1:0] : 2'b11, sprite6_color[1:0] };
wire [4:0] spr7_color;
assign spr7_color = (sprite67_attached == 1'b1)? spr6_color : { 3'b111, sprite7_color[1:0] };

wire sprite01_exists;
assign sprite01_exists = (sprite0_color[1:0] != 2'b00 || sprite1_color[1:0] != 2'b00);
wire sprite23_exists;
assign sprite23_exists = (sprite2_color[1:0] != 2'b00 || sprite3_color[1:0] != 2'b00);
wire sprite45_exists;
assign sprite45_exists = (sprite4_color[1:0] != 2'b00 || sprite5_color[1:0] != 2'b00);
wire sprite67_exists;
assign sprite67_exists = (sprite6_color[1:0] != 2'b00 || sprite7_color[1:0] != 2'b00);

wire [4:0] pf1_color;
assign pf1_color = { 2'b0, bpl_color[4], bpl_color[2], bpl_color[0] };

// Dual playfield: bpl_con0[5] == 1'b1
wire [4:0] pf2_color;
assign pf2_color = (bpl_con0[5] == 1'b1) ? { 2'b1, bpl_color[5], bpl_color[3], bpl_color[1] } : bpl_color[4:0];

// bpl_con2[6] PF2PRI
wire pf1_exists;
assign pf1_exists = (bpl_con0[5] == 1'b1) ?
    ((bpl_con2[6] == 1'b0) ? (pf1_color[2:0] != 3'd0) : ((pf2_color[2:0] != 3'd0) ? 1'b0 : (pf1_color[2:0] != 3'd0))) :
    1'b0;

wire pf2_exists;
assign pf2_exists = (bpl_con0[5] == 1'b1) ?
    ((bpl_con2[6] == 1'b1) ? (pf2_color[2:0] != 3'd0) : ((pf1_color[2:0] != 3'd0) ? 1'b0 : (pf2_color[2:0] != 3'd0))) :
    (pf2_color[4:0] != 5'd0);

wire [4:0] final_color;
assign final_color =
    (pf1_exists == 1'b1 && bpl_con2[2:0] == 3'd0) ? pf1_color :
    (pf2_exists == 1'b1 && bpl_con2[5:3] == 3'd0) ? pf2_color :
    (sprite01_exists) ? ((sprite0_color[1:0] != 2'b00) ? spr0_color : spr1_color) :
    (pf1_exists == 1'b1 && bpl_con2[2:0] == 3'd1) ? pf1_color :
    (pf2_exists == 1'b1 && bpl_con2[5:3] == 3'd1) ? pf2_color :
    (sprite23_exists) ? ((sprite2_color[1:0] != 2'b00) ? spr2_color : spr3_color) :
    (pf1_exists == 1'b1 && bpl_con2[2:0] == 3'd2) ? pf1_color :
    (pf2_exists == 1'b1 && bpl_con2[5:3] == 3'd2) ? pf2_color :
    (sprite45_exists) ? ((sprite4_color[1:0] != 2'b00) ? spr4_color : spr5_color) : 
    (pf1_exists == 1'b1 && bpl_con2[2:0] == 3'd3) ? pf1_color :
    (pf2_exists == 1'b1 && bpl_con2[5:3] == 3'd3) ? pf2_color :
    (sprite67_exists) ? ((sprite6_color[1:0] != 2'b00) ? spr6_color : spr7_color) :
    (pf1_exists == 1'b1 && bpl_con2[2:0] == 3'd4) ? pf1_color :
    (pf2_exists == 1'b1 && bpl_con2[5:3] == 3'd4) ? pf2_color :
    4'd0;

// HAM mode
// - Hold and Modify mode, 4096 colors on screen at once, 6-bit pixel: 2-bit control + 4-bit data:
//            - set[6'b00DDDD bpl654321](data - regular color lookup 0-15)
//            - modify-red 6'b01DDDDDD, modify-green 6'b10DDDDDD, modify-blue 6'b11DDDDDD (data - modify that component, leave rest unchanged)
// EHB mode 
wire ham_enabled;
assign ham_enabled = (bpl_con0[6] == 1'b1 && bpl_con0[5] == 1'b0 && bpl_con0[10] == 1'b0 && (bpl_con0[9:7] == 3'd6 || bpl_con0[9:7] == 3'd5));
wire ehb_enabled;
assign ehb_enabled = (bpl_con0[6] == 1'b0 && bpl_con0[5] == 1'b0 && bpl_con0[10] == 1'b0 && bpl_con0[9:7] == 3'd6);

wire [11:0] color_value_before_ehb;
assign color_value_before_ehb =
    (ham_enabled == 1'b1 && bpl_color[5:4] == 2'b01) ? { bpl_color[3:0], last_color_value[7:0] } :
    (ham_enabled == 1'b1 && bpl_color[5:4] == 2'b10) ? { last_color_value[11:8], bpl_color[3:0], last_color_value[3:0] } :
    (ham_enabled == 1'b1 && bpl_color[5:4] == 2'b11) ? { last_color_value[11:4], bpl_color[3:0] } :
    (final_color == 5'd0) ? color00 :
    (final_color == 5'd1) ? color01 :
    (final_color == 5'd2) ? color02 :
    (final_color == 5'd3) ? color03 :
    (final_color == 5'd4) ? color04 :
    (final_color == 5'd5) ? color05 :
    (final_color == 5'd6) ? color06 :
    (final_color == 5'd7) ? color07 :
    (final_color == 5'd8) ? color08 :
    (final_color == 5'd9) ? color09 :
    (final_color == 5'd10) ? color10 :
    (final_color == 5'd11) ? color11 :
    (final_color == 5'd12) ? color12 :
    (final_color == 5'd13) ? color13 :
    (final_color == 5'd14) ? color14 :
    (final_color == 5'd15) ? color15 :
    (final_color == 5'd16) ? color16 :
    (final_color == 5'd17) ? color17 :
    (final_color == 5'd18) ? color18 :
    (final_color == 5'd19) ? color19 :
    (final_color == 5'd20) ? color20 :
    (final_color == 5'd21) ? color21 :
    (final_color == 5'd22) ? color22 :
    (final_color == 5'd23) ? color23 :
    (final_color == 5'd24) ? color24 :
    (final_color == 5'd25) ? color25 :
    (final_color == 5'd26) ? color26 :
    (final_color == 5'd27) ? color27 :
    (final_color == 5'd28) ? color28 :
    (final_color == 5'd29) ? color29 :
    (final_color == 5'd30) ? color30 :
    color31;

wire [11:0] final_color_value;
assign final_color_value =
    (column_number < hstart || column_number > hstop) ? color00 :
    (ehb_enabled == 1'b1) ? { 1'b0,color_value_before_ehb[11:9], 1'b0,color_value_before_ehb[7:5], 1'b0,color_value_before_ehb[3:1] } :
    color_value_before_ehb;
    
reg [11:0] last_color_value;
reg [2:0] line_ram_counter;
always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        clx_dat <= 16'd0;
        burst_write_request <= 1'b0;
        burst_write_address <= 30'd0;
        diw_start <= 16'h2C81;
        diw_stop <= 16'h2CC1;
        clx_con <= 16'd0;
        bpl_con2 <= 7'd0;
        color00 <= 12'd0;
        color01 <= 12'd0;
        color02 <= 12'd0;
        color03 <= 12'd0;
        color04 <= 12'd0;
        color05 <= 12'd0;
        color06 <= 12'd0;
        color07 <= 12'd0;
        color08 <= 12'd0;
        color09 <= 12'd0;
        color10 <= 12'd0;
        color11 <= 12'd0;
        color12 <= 12'd0;
        color13 <= 12'd0;
        color14 <= 12'd0;
        color15 <= 12'd0;
        color16 <= 12'd0;
        color17 <= 12'd0;
        color18 <= 12'd0;
        color19 <= 12'd0;
        color20 <= 12'd0;
        color21 <= 12'd0;
        color22 <= 12'd0;
        color23 <= 12'd0;
        color24 <= 12'd0;
        color25 <= 12'd0;
        color26 <= 12'd0;
        color27 <= 12'd0;
        color28 <= 12'd0;
        color29 <= 12'd0;
        color30 <= 12'd0;
        color31 <= 12'd0;
        line_ram_addr <= 8'd0;
        line_ram_data <= 36'd0;
        last_color_value <= 12'd0;
        line_ram_counter <= 3'd0;
    end
    else begin

        if(screen_line_enable == 1'b1 && column_number >= 9'h81 && column_number == 9'h1C1 && line_ram_counter == 3'd1) begin
            line_ram_addr <= 8'd0;
            line_ram_counter <= 3'd4;
            last_color_value <= final_color_value;
        end
        else if(screen_line_enable == 1'b1 && column_number >= 9'h81 && column_number < 9'h1C1 && line_ram_counter == 3'd3) begin
            line_ram_addr <= line_ram_addr + 8'd1;
            line_ram_counter <= 3'd1;
            last_color_value <= final_color_value;
        end
        else if(screen_line_enable == 1'b1 && column_number >= 9'h81 && column_number < 9'h1C1 && line_ram_counter == 3'd0) begin
            line_ram_counter <= line_ram_counter + 3'd1;
        end
        else if(screen_line_enable == 1'b1 && column_number >= 9'h81 && column_number < 9'h1C1 && line_ram_counter < 3'd4) begin
            line_ram_counter <= line_ram_counter + 3'd1;
            line_ram_data <= { line_ram_data[23:0], final_color_value };
            last_color_value <= final_color_value;
        end
        else if(line_ram_counter == 3'd4) begin
            if(burst_write_ready == 1'b1 && line_ram_addr <= 8'd213) begin
                line_ram_addr <= line_ram_addr + 8'd1;
            end
            else if(burst_write_ready == 1'b1 && line_ram_addr == 8'd214) begin
                line_ram_counter <= 3'd0;
            end
        end
        else begin
            line_ram_addr <= 8'd0;
            last_color_value <= color00;
            line_ram_counter <= 3'd0;
        end

        if(screen_line_enable == 1'b1 && column_number >= 9'h81 && column_number == 9'h1C1 && line_ram_counter == 3'd1) begin
            burst_write_request <= 1'b1;
        end
        else if(line_ram_counter == 3'd4 && line_ram_addr == 8'd214) begin
            burst_write_request <= 1'b0;
            burst_write_address <= burst_write_address + 30'd216; // 640/3 = 213.(3) = 214 + 2 for %4 =0
        end
        else if(screen_line_enable == 1'b0) begin
            burst_write_address <= `VIDEO_BUFFER_DIV_4; // start of video buffer
        end
        
        if(clx_dat_read == 1'b1) clx_dat <= 16'd0;
        else clx_dat <= clx_dat | { 1'b0, clx_detected };
        
        if(write_ena == 1'b1) begin
            if(write_address == 5'd0 && write_sel[0] == 1'b1) color01[7:0] <= write_data[7:0];
            if(write_address == 5'd0 && write_sel[1] == 1'b1) color01[11:8] <= write_data[11:8];
            if(write_address == 5'd0 && write_sel[2] == 1'b1) color00[7:0] <= write_data[23:16];
            if(write_address == 5'd0 && write_sel[3] == 1'b1) color00[11:8] <= write_data[27:24];
            if(write_address == 5'd1 && write_sel[0] == 1'b1) color03[7:0] <= write_data[7:0];
            if(write_address == 5'd1 && write_sel[1] == 1'b1) color03[11:8] <= write_data[11:8];
            if(write_address == 5'd1 && write_sel[2] == 1'b1) color02[7:0] <= write_data[23:16];
            if(write_address == 5'd1 && write_sel[3] == 1'b1) color02[11:8] <= write_data[27:24];
            if(write_address == 5'd2 && write_sel[0] == 1'b1) color05[7:0] <= write_data[7:0];
            if(write_address == 5'd2 && write_sel[1] == 1'b1) color05[11:8] <= write_data[11:8];
            if(write_address == 5'd2 && write_sel[2] == 1'b1) color04[7:0] <= write_data[23:16];
            if(write_address == 5'd2 && write_sel[3] == 1'b1) color04[11:8] <= write_data[27:24];
            if(write_address == 5'd3 && write_sel[0] == 1'b1) color07[7:0] <= write_data[7:0];
            if(write_address == 5'd3 && write_sel[1] == 1'b1) color07[11:8] <= write_data[11:8];
            if(write_address == 5'd3 && write_sel[2] == 1'b1) color06[7:0] <= write_data[23:16];
            if(write_address == 5'd3 && write_sel[3] == 1'b1) color06[11:8] <= write_data[27:24];
            if(write_address == 5'd4 && write_sel[0] == 1'b1) color09[7:0] <= write_data[7:0];
            if(write_address == 5'd4 && write_sel[1] == 1'b1) color09[11:8] <= write_data[11:8];
            if(write_address == 5'd4 && write_sel[2] == 1'b1) color08[7:0] <= write_data[23:16];
            if(write_address == 5'd4 && write_sel[3] == 1'b1) color08[11:8] <= write_data[27:24];
            if(write_address == 5'd5 && write_sel[0] == 1'b1) color11[7:0] <= write_data[7:0];
            if(write_address == 5'd5 && write_sel[1] == 1'b1) color11[11:8] <= write_data[11:8];
            if(write_address == 5'd5 && write_sel[2] == 1'b1) color10[7:0] <= write_data[23:16];
            if(write_address == 5'd5 && write_sel[3] == 1'b1) color10[11:8] <= write_data[27:24];
            if(write_address == 5'd6 && write_sel[0] == 1'b1) color13[7:0] <= write_data[7:0];
            if(write_address == 5'd6 && write_sel[1] == 1'b1) color13[11:8] <= write_data[11:8];
            if(write_address == 5'd6 && write_sel[2] == 1'b1) color12[7:0] <= write_data[23:16];
            if(write_address == 5'd6 && write_sel[3] == 1'b1) color12[11:8] <= write_data[27:24];
            if(write_address == 5'd7 && write_sel[0] == 1'b1) color15[7:0] <= write_data[7:0];
            if(write_address == 5'd7 && write_sel[1] == 1'b1) color15[11:8] <= write_data[11:8];
            if(write_address == 5'd7 && write_sel[2] == 1'b1) color14[7:0] <= write_data[23:16];
            if(write_address == 5'd7 && write_sel[3] == 1'b1) color14[11:8] <= write_data[27:24];
            if(write_address == 5'd8 && write_sel[0] == 1'b1) color17[7:0] <= write_data[7:0];
            if(write_address == 5'd8 && write_sel[1] == 1'b1) color17[11:8] <= write_data[11:8];
            if(write_address == 5'd8 && write_sel[2] == 1'b1) color16[7:0] <= write_data[23:16];
            if(write_address == 5'd8 && write_sel[3] == 1'b1) color16[11:8] <= write_data[27:24];
            if(write_address == 5'd9 && write_sel[0] == 1'b1) color19[7:0] <= write_data[7:0];
            if(write_address == 5'd9 && write_sel[1] == 1'b1) color19[11:8] <= write_data[11:8];
            if(write_address == 5'd9 && write_sel[2] == 1'b1) color18[7:0] <= write_data[23:16];
            if(write_address == 5'd9 && write_sel[3] == 1'b1) color18[11:8] <= write_data[27:24];
            if(write_address == 5'd10 && write_sel[0] == 1'b1) color21[7:0] <= write_data[7:0];
            if(write_address == 5'd10 && write_sel[1] == 1'b1) color21[11:8] <= write_data[11:8];
            if(write_address == 5'd10 && write_sel[2] == 1'b1) color20[7:0] <= write_data[23:16];
            if(write_address == 5'd10 && write_sel[3] == 1'b1) color20[11:8] <= write_data[27:24];
            if(write_address == 5'd11 && write_sel[0] == 1'b1) color23[7:0] <= write_data[7:0];
            if(write_address == 5'd11 && write_sel[1] == 1'b1) color23[11:8] <= write_data[11:8];
            if(write_address == 5'd11 && write_sel[2] == 1'b1) color22[7:0] <= write_data[23:16];
            if(write_address == 5'd11 && write_sel[3] == 1'b1) color22[11:8] <= write_data[27:24];
            if(write_address == 5'd12 && write_sel[0] == 1'b1) color25[7:0] <= write_data[7:0];
            if(write_address == 5'd12 && write_sel[1] == 1'b1) color25[11:8] <= write_data[11:8];
            if(write_address == 5'd12 && write_sel[2] == 1'b1) color24[7:0] <= write_data[23:16];
            if(write_address == 5'd12 && write_sel[3] == 1'b1) color24[11:8] <= write_data[27:24];
            if(write_address == 5'd13 && write_sel[0] == 1'b1) color27[7:0] <= write_data[7:0];
            if(write_address == 5'd13 && write_sel[1] == 1'b1) color27[11:8] <= write_data[11:8];
            if(write_address == 5'd13 && write_sel[2] == 1'b1) color26[7:0] <= write_data[23:16];
            if(write_address == 5'd13 && write_sel[3] == 1'b1) color26[11:8] <= write_data[27:24];
            if(write_address == 5'd14 && write_sel[0] == 1'b1) color29[7:0] <= write_data[7:0];
            if(write_address == 5'd14 && write_sel[1] == 1'b1) color29[11:8] <= write_data[11:8];
            if(write_address == 5'd14 && write_sel[2] == 1'b1) color28[7:0] <= write_data[23:16];
            if(write_address == 5'd14 && write_sel[3] == 1'b1) color28[11:8] <= write_data[27:24];
            if(write_address == 5'd15 && write_sel[0] == 1'b1) color31[7:0] <= write_data[7:0];
            if(write_address == 5'd15 && write_sel[1] == 1'b1) color31[11:8] <= write_data[11:8];
            if(write_address == 5'd15 && write_sel[2] == 1'b1) color30[7:0] <= write_data[23:16];
            if(write_address == 5'd15 && write_sel[3] == 1'b1) color30[11:8] <= write_data[27:24];
            // 16:      DIWSTRT [15:0],     COPINS      [31:16], * COPINS not implemented  
            // 17:      DIWSTOP [31:16],    DDFSTART    [15:0], *
            // 18:      CLXCON  [31:16],    INTENA      [15:0], *
            // 19:      BPLCON2 [31:16],    NOT USED    [15:0],
            if(write_address == 5'd16 && write_sel[0] == 1'b1) diw_start[7:0] <= write_data[7:0];
            if(write_address == 5'd16 && write_sel[1] == 1'b1) diw_start[15:8] <= write_data[15:8];
            if(write_address == 5'd16 && write_sel[2] == 1'b1) ;
            if(write_address == 5'd16 && write_sel[3] == 1'b1) ;
            if(write_address == 5'd17 && write_sel[0] == 1'b1) ;
            if(write_address == 5'd17 && write_sel[1] == 1'b1) ;
            if(write_address == 5'd17 && write_sel[2] == 1'b1) diw_stop[7:0] <= write_data[23:16];
            if(write_address == 5'd17 && write_sel[3] == 1'b1) diw_stop[15:8] <= write_data[31:24];
            if(write_address == 5'd18 && write_sel[0] == 1'b1) ;
            if(write_address == 5'd18 && write_sel[1] == 1'b1) ;
            if(write_address == 5'd18 && write_sel[2] == 1'b1) clx_con[7:0] <= write_data[23:16];
            if(write_address == 5'd18 && write_sel[3] == 1'b1) clx_con[15:8] <= write_data[31:24];
            if(write_address == 5'd19 && write_sel[0] == 1'b1) ;
            if(write_address == 5'd19 && write_sel[1] == 1'b1) ;
            if(write_address == 5'd19 && write_sel[2] == 1'b1) bpl_con2 <= write_data[22:16];
            if(write_address == 5'd19 && write_sel[3] == 1'b1) ;
        end
    end
end

endmodule

/*! \brief Bitplain top level module with multiplexers to internal bitplain module instances.
 */
module bitplains(
    input CLK_I,
    input reset_n,
    
    input line_start,
    input [8:0] column_number,
    
    // video interface - read
    input burst_read_enabled,
	output burst_read_request,
	output [31:2] burst_read_address,
	input burst_read_ready,
	input [31:0] burst_read_data,  
    
    input write_ena,
    // 0:   BPL1PTH,    BPL1PTL,
    // 1:   BPL2PTH,    BPL2PTL,
    // 2:   BPL3PTH,    BPL3PTL,
    // 3:   BPL4PTH,    BPL4PTL,
    // 4:   BPL5PTH,    BPL5PTL,
    // 5:   BPL6PTH,    BPL6PTL,
    // 6:       DDFSTRT [15:0],     DIWSTOP [31:16], *
    // 7:       DDFSTOP [31:16],    DMACON  [15:0], *
    // 8:   BPLCON0,    BPLCON1,
    // 9:   BPL1MOD,    BPL2MOD,
    // 10:  BPL1DAT,    BPL2DAT,
    // 11:  BPL3DAT,    BPL4DAT,
    // 12:  BPL5DAT,    BPL6DAT
    input [3:0] write_address,
    input [31:0] write_data,
    input [3:0] write_sel,
    
    output [7:0] disable_sprites,
    output reg [10:0] bpl_con0,
    output [5:0] color,
    
    input [8:0] line_number
);

assign disable_sprites = {
    (ddf_start[8:3] < 6'd14),
    (ddf_start[8:3] < 6'd13),
    (ddf_start[8:3] < 6'd12),
    (ddf_start[8:3] < 6'd11),
    (ddf_start[8:3] < 6'd10),
    (ddf_start[8:3] < 6'd9),
    (ddf_start[8:3] < 6'd8),
    (ddf_start[8:3] < 6'd7)
};

reg [8:3] ddf_start;
reg [8:3] ddf_stop;

reg [31:0] bpl_modulo;

// output reg [10:0] bpl_con0
reg [7:0] bpl_con1;

reg [5:0] dma_reqs_reg;
wire [5:0] dma_reqs;
wire [2:0] selected_bpl;
assign selected_bpl = 
    (dma_reqs_reg[0] == 1'b1) ? 3'd1 :
    (dma_reqs_reg[1] == 1'b1) ? 3'd2 :
    (dma_reqs_reg[2] == 1'b1) ? 3'd3 :
    (dma_reqs_reg[3] == 1'b1) ? 3'd4 :
    (dma_reqs_reg[4] == 1'b1) ? 3'd5 :
    (dma_reqs_reg[5] == 1'b1) ? 3'd6 :
    3'd0;

assign burst_read_address =
    (selected_bpl == 3'd1) ? dma_address_1 :
    (selected_bpl == 3'd2) ? dma_address_2 :
    (selected_bpl == 3'd3) ? dma_address_3 :
    (selected_bpl == 3'd4) ? dma_address_4 :
    (selected_bpl == 3'd5) ? dma_address_5 :
    (selected_bpl == 3'd6) ? dma_address_6 :
    30'd0;

assign burst_read_request =
    (selected_bpl == 3'd1) ? dma_reqs[0] :
    (selected_bpl == 3'd2) ? dma_reqs[1] :
    (selected_bpl == 3'd3) ? dma_reqs[2] :
    (selected_bpl == 3'd4) ? dma_reqs[3] :
    (selected_bpl == 3'd5) ? dma_reqs[4] :
    (selected_bpl == 3'd6) ? dma_reqs[5] :
    1'b0;

wire [31:2] dma_address_1;
bitplain bitplain_1(
    .CLK_I(CLK_I),
    .reset_n(reset_n),

    .line_start(line_start),
    .column_number(column_number),
    
    .burst_read_enabled(burst_read_enabled == 1'b1 && bpl_con0[9:7] >= 3'd1), 
    .burst_read_request(dma_reqs[0]),
    .burst_read_address(dma_address_1),
    .burst_read_ready(burst_read_ready == 1'b1 && selected_bpl == 3'd1),
    .burst_read_data(burst_read_data),
    
    .write_ena(write_ena == 1'b1 && (write_address == 4'd0 || write_address == 4'd10)),
    // 0:   BPLxPTH,    BPLxPTL,
    // 1:   BPLxDAT,    16'd0
    .write_address( (write_address == 4'd0)? 1'b0       : 1'b1),
    .write_data(    (write_address == 4'd0)? write_data : {write_data[31:16], 16'd0}),
    .write_sel(     (write_address == 4'd0)? write_sel  : {write_sel[3:2], 2'b0}),
    
    .bpl_con0(bpl_con0),
    .bpl_delay(bpl_con1[3:0]),
    .bpl_modulo(bpl_modulo[31:16]),
    .ddf_start(ddf_start),
    .ddf_stop(ddf_stop),
    
    .color(color[0]),
    
    .line_number(line_number)
);
wire [31:2] dma_address_2;
bitplain bitplain_2(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .column_number(column_number),
    
    .burst_read_enabled(burst_read_enabled == 1'b1 && bpl_con0[9:7] >= 3'd2), 
    .burst_read_request(dma_reqs[1]),
    .burst_read_address(dma_address_2),
    .burst_read_ready(burst_read_ready == 1'b1 && selected_bpl == 3'd2),
    .burst_read_data(burst_read_data),
    
    .write_ena(write_ena == 1'b1 && (write_address == 4'd1 || write_address == 4'd10)),
    // 0:   BPLxPTH,    BPLxPTL,
    // 1:   BPLxDAT,    16'd0
    .write_address( (write_address == 4'd1)? 1'b0       : 1'b1),
    .write_data(    (write_address == 4'd1)? write_data : {write_data[15:0], 16'd0}),
    .write_sel(     (write_address == 4'd1)? write_sel  : {write_sel[1:0], 2'b0}),
    
    .bpl_con0(bpl_con0),
    .bpl_delay(bpl_con1[7:4]),
    .bpl_modulo(bpl_modulo[15:0]),
    .ddf_start(ddf_start),
    .ddf_stop(ddf_stop),
    
    .color(color[1]),
    
    .line_number(line_number)
);
wire [31:2] dma_address_3;
bitplain bitplain_3(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .column_number(column_number),
    
    .burst_read_enabled(burst_read_enabled == 1'b1 && bpl_con0[9:7] >= 3'd3), 
    .burst_read_request(dma_reqs[2]),
    .burst_read_address(dma_address_3),
    .burst_read_ready(burst_read_ready == 1'b1 && selected_bpl == 3'd3),
    .burst_read_data(burst_read_data),
    
    .write_ena(write_ena == 1'b1 && (write_address == 4'd2 || write_address == 4'd11)),
    // 0:   BPLxPTH,    BPLxPTL,
    // 1:   BPLxDAT,    16'd0
    .write_address( (write_address == 4'd2)? 1'b0       : 1'b1),
    .write_data(    (write_address == 4'd2)? write_data : {write_data[31:16], 16'd0}),
    .write_sel(     (write_address == 4'd2)? write_sel  : {write_sel[3:2], 2'b0}),
    
    .bpl_con0(bpl_con0),
    .bpl_delay(bpl_con1[3:0]),
    .bpl_modulo(bpl_modulo[31:16]),
    .ddf_start(ddf_start),
    .ddf_stop(ddf_stop),
    
    .color(color[2]),
    
    .line_number(line_number)
);
wire [31:2] dma_address_4;
bitplain bitplain_4(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .column_number(column_number),
    
    .burst_read_enabled(burst_read_enabled == 1'b1 && bpl_con0[9:7] >= 3'd4), 
    .burst_read_request(dma_reqs[3]),
    .burst_read_address(dma_address_4),
    .burst_read_ready(burst_read_ready == 1'b1 && selected_bpl == 3'd4),
    .burst_read_data(burst_read_data),
    
    .write_ena(write_ena == 1'b1 && (write_address == 4'd3 || write_address == 4'd11)),
    // 0:   BPLxPTH,    BPLxPTL,
    // 1:   BPLxDAT,    16'd0
    .write_address( (write_address == 4'd3)? 1'b0       : 1'b1),
    .write_data(    (write_address == 4'd3)? write_data : {write_data[15:0], 16'd0}),
    .write_sel(     (write_address == 4'd3)? write_sel  : {write_sel[1:0], 2'b0}),
    
    .bpl_con0(bpl_con0),
    .bpl_delay(bpl_con1[7:4]),
    .bpl_modulo(bpl_modulo[15:0]),
    .ddf_start(ddf_start),
    .ddf_stop(ddf_stop),
    
    .color(color[3]),
    
    .line_number(line_number)
);
wire [31:2] dma_address_5;
bitplain bitplain_5(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .column_number(column_number),
    
    .burst_read_enabled(burst_read_enabled == 1'b1 && bpl_con0[9:7] >= 3'd5), 
    .burst_read_request(dma_reqs[4]),
    .burst_read_address(dma_address_5),
    .burst_read_ready(burst_read_ready == 1'b1 && selected_bpl == 3'd5),
    .burst_read_data(burst_read_data),
    
    .write_ena(write_ena == 1'b1 && (write_address == 4'd4 || write_address == 4'd12)),
    // 0:   BPLxPTH,    BPLxPTL,
    // 1:   BPLxDAT,    16'd0
    .write_address( (write_address == 4'd4)? 1'b0       : 1'b1),
    .write_data(    (write_address == 4'd4)? write_data : {write_data[31:16], 16'd0}),
    .write_sel(     (write_address == 4'd4)? write_sel  : {write_sel[3:2], 2'b0}),
    
    .bpl_con0(bpl_con0),
    .bpl_delay(bpl_con1[3:0]),
    .bpl_modulo(bpl_modulo[31:16]),
    .ddf_start(ddf_start),
    .ddf_stop(ddf_stop),
    
    .color(color[4]),
    
    .line_number(line_number)
);
wire [31:2] dma_address_6;
bitplain bitplain_6(
    .CLK_I(CLK_I),
    .reset_n(reset_n),
    
    .line_start(line_start),
    .column_number(column_number),
    
    .burst_read_enabled(burst_read_enabled == 1'b1 && bpl_con0[9:7] >= 3'd6), 
    .burst_read_request(dma_reqs[5]),
    .burst_read_address(dma_address_6),
    .burst_read_ready(burst_read_ready == 1'b1 && selected_bpl == 3'd6),
    .burst_read_data(burst_read_data),
    
    .write_ena(write_ena == 1'b1 && (write_address == 4'd5 || write_address == 4'd12)),
    // 0:   BPLxPTH,    BPLxPTL,
    // 1:   BPLxDAT,    16'd0
    .write_address( (write_address == 4'd5)? 1'b0       : 1'b1),
    .write_data(    (write_address == 4'd5)? write_data : {write_data[15:0], 16'd0}),
    .write_sel(     (write_address == 4'd5)? write_sel  : {write_sel[1:0], 2'b0}),
    
    .bpl_con0(bpl_con0),
    .bpl_delay(bpl_con1[7:4]),
    .bpl_modulo(bpl_modulo[15:0]),
    .ddf_start(ddf_start),
    .ddf_stop(ddf_stop),
    
    .color(color[5]),
    
    .line_number(line_number)
);

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        bpl_con0 <= 11'd0;
        ddf_start <= 6'd0;
        ddf_stop <= 6'd0;
        bpl_modulo <= 32'd0;
        bpl_con1 <= 8'd0;
        
        dma_reqs_reg <= 6'd0;
    end
    else begin
        dma_reqs_reg <= dma_reqs;
        
        // 6:   DDFSTRT [15:0],     DIWSTOP [31:16], *
        // 7:   DDFSTOP [31:16],    DMACON  [15:0], *
        // 8:   BPLCON0,            BPLCON1,
        // 9:   BPL1MOD,            BPL2MOD,
        if(write_ena == 1'b1) begin
            if(write_address == 4'd6 && write_sel[0] == 1'b1) ddf_start <= write_data[7:2];
            if(write_address == 4'd6 && write_sel[1] == 1'b1) ;
            if(write_address == 4'd6 && write_sel[2] == 1'b1) ;
            if(write_address == 4'd6 && write_sel[3] == 1'b1) ;
            if(write_address == 4'd7 && write_sel[0] == 1'b1) ;
            if(write_address == 4'd7 && write_sel[1] == 1'b1) ;
            if(write_address == 4'd7 && write_sel[2] == 1'b1) ddf_stop <= write_data[23:18];
            if(write_address == 4'd7 && write_sel[3] == 1'b1) ;
            if(write_address == 4'd8 && write_sel[0] == 1'b1) bpl_con1 <= write_data[7:0];
            if(write_address == 4'd8 && write_sel[1] == 1'b1) ;
            if(write_address == 4'd8 && write_sel[2] == 1'b1) bpl_con0[2:0] <= write_data[19:17];
            if(write_address == 4'd8 && write_sel[3] == 1'b1) bpl_con0[10:3] <= write_data[31:24];
            if(write_address == 4'd9 && write_sel[0] == 1'b1) bpl_modulo[7:0] <= write_data[7:0];
            if(write_address == 4'd9 && write_sel[1] == 1'b1) bpl_modulo[15:8] <= write_data[15:8];
            if(write_address == 4'd9 && write_sel[2] == 1'b1) bpl_modulo[23:16] <= write_data[23:16];
            if(write_address == 4'd9 && write_sel[3] == 1'b1) bpl_modulo[31:24] <= write_data[31:24];
        end
    end
end

endmodule

/*! \brief Single bitplain module.
 */
module bitplain(
    input CLK_I,
    input reset_n,
    
    input line_start,
    input [8:0] column_number,
    
    // video interface - read
    input burst_read_enabled,
	output reg burst_read_request,
	output [31:2] burst_read_address,
	input burst_read_ready,
	input [31:0] burst_read_data,
    
    input write_ena,
    // 0:   BPLxPTH,    BPLxPTL,
    // 1:   BPLxDAT,    16'd0
    input write_address,
    input [31:0] write_data,
    input [3:0] write_sel,
    
    input [10:0] bpl_con0,
    input [3:0] bpl_delay,
    input [15:0] bpl_modulo,
    input [8:3] ddf_start,
    input [8:3] ddf_stop,
    
    output color,
    
    input [8:0] line_number
);

assign burst_read_address = dma_address_full[31:2];
reg [31:0] dma_address_full;
reg new_address;
reg dma_started;

reg shift_delay;
reg [5:0] shift_counter;
reg [31:0] shift;
assign color = shift[31];

reg [15:0] even_data;

reg [4:0] bitplain_ram_addr;
wire [31:0] bitplain_ram_q;
altsyncram bitplain_ram_inst(
	.clock0(CLK_I),

	.address_a(bitplain_ram_addr),
	.wren_a(burst_read_ready == 1'b1 && burst_read_request == 1'b1),
	.data_a((dma_address_full[1] == 1'b0) ? burst_read_data : {even_data, burst_read_data[31:16]}),
	.q_a(bitplain_ram_q)
);
defparam 
    bitplain_ram_inst.operation_mode = "SINGLE_PORT",
    bitplain_ram_inst.width_a = 32,
    bitplain_ram_inst.widthad_a = 5;

reg [1:0] dma_state;
parameter [1:0]
    DMA_DISABLED    = 2'd0,
    DMA_ACTIVE      = 2'd1,
    DMA_INACTIVE    = 2'd2;

// in multiples of 8, usually 38
wire [8:3] ddf_diff;
assign ddf_diff = ddf_stop[8:3] - ddf_start[8:3];

wire [8:3] ddf_stop_final;
assign ddf_stop_final = (ddf_diff[3] == 1'b1)? ddf_stop + 6'd1 : ddf_stop;

wire [8:3] ddf_diff_final;
assign ddf_diff_final = ddf_stop_final[8:3] - ddf_start[8:3];

// difference,  diff,   ram_addr
// lowres
// 0-7,         0,      0+1 >= 0 --> 1
// 8-15,        2,      1+1 >= 0,2 --> 2
// 16-23,       4,      2+1 >= 0,2 --> 2
// 24-31,       6,      3+1 >= 0,2,4 --> 3
// .....
// 144-151,     36,     18+1 >= 0,2,4,6,8,10,12,14,16,18 --> 10
// 152-159,     38,     19+1 >= 0,2,4,6,8,10,12,14,16,18,20 --> 11
// hires
// 0-3,         0,      0+2 >= 0,2 --> 2
// 4-7,         1,      1+2 >= 0,2 --> 2
// 8-11,        2,      2+2 >= 0,2,4 --> 3
// 12-15,       3,      3+2 >= 0,2,4 --> 3
// .....
// 148-151,     37,     37+2 >= 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38 --> 20
// 152-155,     38,     38+2 >= 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40 --> 21
wire ddf_continue;
assign ddf_continue = 
    (bpl_con0[10] == 1'b0 && { 1'b0, ddf_diff_final[8:4] } + 6'd1 >= { bitplain_ram_addr + 5'd1, 1'b0 } ) ||
    (bpl_con0[10] == 1'b1 && ddf_diff_final[8:3] + 6'd2           >= { bitplain_ram_addr + 5'd1, 1'b0 } );

// lowres: 1C1 / 2 - 8.5 - 8 = D8 - 8 = D0,     x - 17 - 16 = {ddf_stop[8:3], 3'b0}
// hires:  1C1 / 2 - 4.5 - 8 = DC - 8 = D4,     x - 9  - 16 = {ddf_stop[8:3], 3'b0}
wire ddf_finished;
assign ddf_finished =
    (column_number > { ddf_stop_final[8:3], 3'b0 } + 9'd32) ||
    (column_number == 9'd451);

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        burst_read_request <= 1'b0;
        dma_address_full <= 32'd0;
        new_address <= 1'b0;
        dma_started <= 1'b0;
        shift_delay <= 1'b0;
        shift_counter <= 6'd0;
        shift <= 32'd0;
        even_data <= 16'd0;
        bitplain_ram_addr <= 5'd0;
        dma_state <= DMA_DISABLED;
    end
    else begin
        if(write_ena == 1'b1 && write_address == 1'b1 && write_sel[3:2] != 2'b00) begin
            if(write_sel[3] == 1'b1) shift[31:24] <= write_data[31:24];
            if(write_sel[2] == 1'b1) shift[23:16] <= write_data[23:16];
        end
        else if(dma_state == DMA_ACTIVE || dma_state == DMA_DISABLED) begin
            shift <= 32'd0;
            shift_delay <= 1'b0;
            shift_counter <= 6'd32 + {1'b0, bpl_delay, 1'b0};
            // delay in lowres pixels == 2 hires pixels == 0.5 color clock
        end
        else if(ddf_finished == 1'b1) begin
            // ddf_stop in 2 lowres pixels == 4 hires pixels == 1.0 color clock
            shift <= 32'd0;
            shift_delay <= 1'b0;
            shift_counter <= 6'd32;
        end
        else if(shift_delay == 1'b1) begin
            shift_delay <= 1'b0;
        end
        else if((bpl_con0[10] == 1'b0 && column_number >= { ddf_start[8:3], 3'b0 } + 9'd17) ||
                (bpl_con0[10] == 1'b1 && column_number >= { ddf_start[8:3], 3'b0 } + 9'd9))
        begin
            if(shift_counter > 6'd32) begin
                shift_counter <= shift_counter - 6'd1;
            end
            else if(shift_counter == 6'd32) begin
                if(bpl_con0[10] == 1'b0) shift_delay <= 1'b1; // HIRES==0
                shift <= bitplain_ram_q;
                shift_counter <= shift_counter - 6'd1;
            end
            else begin
                if(bpl_con0[10] == 1'b0) shift_delay <= 1'b1; // HIRES==0
                shift <= { shift[30:0], 1'b0 };
                
                if(shift_counter == 6'd1) shift_counter <= 6'd32;
                else shift_counter <= shift_counter - 6'd1;
            end
        end
        
        if(burst_read_enabled == 1'b0) begin
            bitplain_ram_addr <= 5'd0;
            dma_state <= DMA_DISABLED;
        end
        else if(dma_state == DMA_DISABLED && line_start == 1'b1) begin
            bitplain_ram_addr <= 5'd0;
            dma_state <= DMA_ACTIVE;
            burst_read_request <= 1'b1;
            dma_started <= 1'b0;
            new_address <= 1'b0;
        end
        else if(dma_state == DMA_ACTIVE && burst_read_ready == 1'b1) begin
            if(ddf_continue == 1'b1) begin
                if(dma_address_full[1] == 1'b0 || dma_started == 1'b1) bitplain_ram_addr <= bitplain_ram_addr + 5'd1;
            end
            else begin
                bitplain_ram_addr <= 5'd0;
                dma_state <= DMA_INACTIVE;
                burst_read_request <= 1'b0;
            end
        end
        else if(dma_state == DMA_INACTIVE && ddf_finished == 1'b1) begin
            bitplain_ram_addr <= 5'd0;
            dma_state <= DMA_DISABLED;
        end
        else if(dma_state == DMA_INACTIVE && shift_counter == 6'd2 && shift_delay == 1'b0) begin
            bitplain_ram_addr <= bitplain_ram_addr + 5'd1;
        end
        
        if(write_ena == 1'b1) begin
            if(write_address == 1'b0 && write_sel[0] == 1'b1) dma_address_full[7:0] <= write_data[7:0];
            if(write_address == 1'b0 && write_sel[1] == 1'b1) dma_address_full[15:8] <= write_data[15:8];
            if(write_address == 1'b0 && write_sel[2] == 1'b1) dma_address_full[23:16] <= write_data[23:16];
            if(write_address == 1'b0 && write_sel[3] == 1'b1) dma_address_full[31:24] <= write_data[31:24];
            new_address <= 1'b1;
        end
        else if(dma_state == DMA_ACTIVE && burst_read_ready == 1'b1) begin
            if(ddf_continue == 1'b0) begin
                if(new_address == 1'b1)         dma_address_full <= dma_address_full;
                else if(bpl_con0[10] == 1'b0)   dma_address_full <= dma_address_full + { {16{bpl_modulo[15]}}, bpl_modulo } + { { 1'b0, ddf_diff_final[8:4] } + 6'd1, 1'b0 };
                else if(bpl_con0[10] == 1'b1)   dma_address_full <= dma_address_full + { {16{bpl_modulo[15]}}, bpl_modulo } + { ddf_diff_final[8:3] + 6'd2, 1'b0 };
                
                new_address <= 1'b0;
            end
            
            dma_started <= 1'b1;
            even_data <= burst_read_data[15:0];
        end
    end
end

endmodule

/*! \brief Single sprite module.
 */
module sprite(
    input CLK_I,
    input reset_n,
    
    input line_start,
    input [8:0] line_number,
    input [8:0] column_number,
    
    input dma_ena,
    output reg dma_req,
    output [31:2] dma_address,
    input dma_done,
    input [31:0] dma_data,
    
    input write_ena,
    // 0:   SPRxPTH,    SPRxPTL,
    // 1:   SPRxPOS,    SPRxCTL,
    // 2:   SPRxDATA,   SPRxDATB,
    input [1:0] write_address,
    input [31:0] write_data,
    input [3:0] write_sel,
    
    output reg attached,
    output [1:0] color
);

// { SPRxPTH high 3 bits, SPRxPTL low 15 bits, lowest bit }
reg [31:0] dma_address_full;
assign dma_address = dma_address_full[31:2];
reg dma_address_bit1;

// { SPRxDATB, SPRxDATA }
reg [31:0] data;
// { SPRxCTL[2], SPRxPOS[15:8] }
reg [8:0] vert_start;
// { SPRxCTL[1], SPRxCTL[15:8] }
reg [8:0] vert_end;
// { SPRxPOS[7:0], SPRxCTL[0] }
reg [8:0] horiz_start;
// SPRxCTL[7]
// output reg attached

// disabled by write to SPRxCTL, enabled by write to SPRxDATA
reg ena_horiz_comp;

reg shift_delay;
reg [15:0] shiftA;
reg [15:0] shiftB;
assign color = { shiftA[15], shiftB[15] };

reg [1:0] dma_state;
parameter [1:0]
    DMA_DISABLED = 2'd0,
    DMA_POS_CTL = 2'd1,
    DMA_DAT = 2'd2;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        dma_req <= 1'b0;
        dma_address_full <= 32'd0;
        dma_address_bit1 <= 1'b0;
        attached <= 1'b0;
        data <= 32'd0;
        vert_start <= 9'd0;
        vert_end <= 9'd0;
        horiz_start <= 9'd0;
        ena_horiz_comp <= 1'b0;
        shift_delay <= 1'b0;
        shiftA <= 16'd0;
        shiftB <= 16'd0;
        dma_state <= DMA_DISABLED;
    end
    else begin
        if(ena_horiz_comp == 1'b1 && horiz_start == column_number) begin
            shift_delay <= 1'b0;
            shiftA <= data[15:0];
            shiftB <= data[31:16];
        end
        else if(shift_delay == 1'b1) begin
            shift_delay <= 1'b0;
        end
        else begin
            shift_delay <= 1'b1;
            shiftA <= { shiftA[14:0], 1'b0 };
            shiftB <= { shiftB[14:0], 1'b0 };
        end
        
        if(         (write_ena == 1'b1 && write_address == 2'd1 && (write_sel[0] == 1'b1 || write_sel[1] == 1'b1)) ||
                    (dma_done == 1'b1 && dma_state == DMA_POS_CTL) )    ena_horiz_comp <= 1'b0;
        else if(    (write_ena == 1'b1 && write_address == 2'd2 && (write_sel[2] == 1'b1 || write_sel[3] == 1'b1)) ||
                    (dma_done == 1'b1 && dma_state == DMA_DAT) )        ena_horiz_comp <= 1'b1;
        
        if(dma_ena == 1'b0 || (write_ena == 1'b1 && write_address == 2'd0 && write_sel[3:0] != 4'b0000)) begin
            dma_state <= DMA_DISABLED;
            dma_req <= 1'b0;
            dma_address_bit1 <= 1'b0;
        end
        else if(dma_state != DMA_DISABLED && dma_done == 1'b1 && dma_address_full[1] == 1'b1 && dma_address_bit1 == 1'b0) begin
            dma_req <= 1'b1;
            dma_address_bit1 <= 1'b1;
            dma_address_full <= dma_address_full + 19'd4;
        end
        else if(line_start == 1'b1 && (dma_state == DMA_DISABLED ||
            (dma_state == DMA_DAT && line_number == vert_end && vert_start != vert_end)) )
        begin
            dma_state <= DMA_POS_CTL;
            dma_req <= 1'b1;
        end
        else if(dma_done == 1'b1 && dma_state == DMA_POS_CTL) begin
            dma_state <= DMA_DAT;
            dma_req <= 1'b0;
            if(dma_address_bit1 == 1'b0) dma_address_full <= dma_address_full + 19'd4;
            dma_address_bit1 <= 1'b0;
        end
        else if(line_start == 1'b1 && dma_state == DMA_DAT && line_number >= vert_start && line_number < vert_end) begin
            dma_req <= 1'b1;
        end
        else if(dma_done == 1'b1 && dma_state == DMA_DAT) begin
            dma_req <= 1'b0;
            if(dma_address_bit1 == 1'b0) dma_address_full <= dma_address_full + 19'd4;
            dma_address_bit1 <= 1'b0;
        end
        
        if(write_ena == 1'b1) begin
            if(write_address == 2'd0 && write_sel[0] == 1'b1) dma_address_full[7:0] <= write_data[7:0];
            if(write_address == 2'd0 && write_sel[1] == 1'b1) dma_address_full[15:8] <= write_data[15:8];
            if(write_address == 2'd0 && write_sel[2] == 1'b1) dma_address_full[23:16] <= write_data[23:16];
            if(write_address == 2'd0 && write_sel[3] == 1'b1) dma_address_full[31:24] <= write_data[31:24];
            if(write_address == 2'd1 && write_sel[0] == 1'b1) 
                { attached, vert_start[8], vert_end[8], horiz_start[0]} <= { write_data[7], write_data[2:0] };
            if(write_address == 2'd1 && write_sel[1] == 1'b1) vert_end[7:0] <= write_data[15:8];
            if(write_address == 2'd1 && write_sel[2] == 1'b1) horiz_start[8:1] <= write_data[23:16];
            if(write_address == 2'd1 && write_sel[3] == 1'b1) vert_start[7:0] <= write_data[31:24];
            if(write_address == 2'd2 && write_sel[0] == 1'b1) data[7:0] <= write_data[7:0];
            if(write_address == 2'd2 && write_sel[1] == 1'b1) data[15:8] <= write_data[15:8];
            if(write_address == 2'd2 && write_sel[2] == 1'b1) data[23:16] <= write_data[23:16];
            if(write_address == 2'd2 && write_sel[3] == 1'b1) data[31:24] <= write_data[31:24];
        end
        else if(dma_done == 1'b1) begin 
            if(dma_state == DMA_POS_CTL) begin
                if(dma_address_full[1] == 1'b1 && dma_address_bit1 == 1'b0) begin
                    horiz_start[8:1] <= dma_data[7:0];
                    vert_start[7:0] <= dma_data[15:8];
                end
                else if(dma_address_full[1] == 1'b1 && dma_address_bit1 == 1'b1) begin
                    { attached, vert_start[8], vert_end[8], horiz_start[0]} <= { dma_data[23], dma_data[18:16] };
                    vert_end[7:0] <= dma_data[31:24];
                end
                else begin
                    { attached, vert_start[8], vert_end[8], horiz_start[0]} <= { dma_data[7], dma_data[2:0] };
                    vert_end[7:0]       <= dma_data[15:8];
                    horiz_start[8:1]    <= dma_data[23:16];
                    vert_start[7:0]     <= dma_data[31:24]; // vert_end*256 + horiz_start*2*655536 + vert_start*16777216
                end
            end
            else if(dma_state == DMA_DAT) begin
                if(dma_address_full[1] == 1'b1 && dma_address_bit1 == 1'b0) begin
                    data[31:16] <= dma_data[15:0];
                end
                else if(dma_address_full[1] == 1'b1 && dma_address_bit1 == 1'b1) begin
                    data[15:0] <= dma_data[31:16];
                end
                else begin
                    data <= dma_data;
                end
            end
        end
    end
end

endmodule

