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
 * \brief aoOCS top-level module for the Terasic DE2-70 board.
 */

/*! \brief \copybrief aoOCS.v
*/
module aoOCS(
	//% \name Clock and reset
    //% @{
	input           clk_50,
	input           reset_ext_n,
	//% @}
	
	//% \name IS61LPS51236A pipelined SSRAM hardware interface
    //% @{
	output [18:0]   ssram_address,
	output          ssram_oe_n,
	output          ssram_writeen_n,
	output [3:0]    ssram_byteen_n,
	inout [35:0]    ssram_data,
	output          ssram_clk,
	output          ssram_globalw_n,
	output          ssram_advance_n,
	output          ssram_adsp_n,
	output          ssram_adsc_n,
	output          ssram_ce1_n,
	output          ssram_ce2,
	output          ssram_ce3_n,
	//% @}
	
	//% \name SD bus 1-bit hardware interface
    //% @{
	output          sd_clk_o,
	inout           sd_cmd_io,
	inout           sd_dat_io,
	//% @}
	
	//% \name ADV7123 Video DAC hardware interface
    //% @{
	output [9:0]    vga_r,
	output [9:0]    vga_g,
	output [9:0]    vga_b,
	output          vga_blank_n,
	output          vga_sync_n,
	output          vga_clock,
	output          vga_hsync,
	output          vga_vsync,
	//% @}
	
	//% \name PS/2 keyboard hardware interface
    //% @{
	inout           ps2_kbclk,
    inout           ps2_kbdat,
	//% @}
	
	//% \name PS/2 mouse hardware interface
    //% @{
    inout           ps2_mouseclk,
    inout           ps2_mousedat,
    //% @}
    
    //% \name WM8731 audio codec hardware interface
    //% @{
    output          ac_sclk,
    inout           ac_sdat,
    output          ac_xclk,
    output          ac_bclk,
    output          ac_dat,
    output          ac_lr,
    //% @}
    
    //% \name DM9000A Ethernet hardware interface
    //% @{
    output          enet_clk_25,
    output          enet_reset_n,
    output          enet_cs_n,
    input           enet_irq,
    output          enet_ior_n,
    output          enet_iow_n,
    output          enet_cmd,
    inout [15:0]    enet_data,
    //% @}
    
    //% \name Switches and hex leds hardware interface from drv_debug
    //% @{
    // hex output
	output [7:0]    hex0,
	output [7:0]    hex1,
	output [7:0]    hex2,
	output [7:0]    hex3,
	output [7:0]    hex4,
	output [7:0]    hex5,
	output [7:0]    hex6,
	output [7:0]    hex7,
	 // switches input
    input           debug_sw1_pc,
    input           debug_sw2_adr,
    input           debug_sw3_halt,
    //% @}
    
    //% \name Leds hardware interface for debug purposes
    //% @{
	output [7:0]    debug_sd,
	output [7:0]    debug_68k_state,
	output [7:0]    debug_floppy
	//% @}
);

/*
Amiga:
    00 0000 - 0F FFFF       1MB Chip RAM
    BF D000 - BF DF00       8520-B  (access at even-byte addresses only)
        -         -
    BF E001 - BF EF01       8520-A  (access at odd-byte addresses only)

    DF F000 - DF FFFF       Chip registers.
    C0 0000 - D7 FFFF       Internal expansion (slow) memory (on some systems).
    C0 0000 - DB FFFF       Slow memory check in ROM
    
    FC 0000 - FF FFFF       256K System ROM.
    
    0000 0000 0000 xxxx xxxx xxxx xxxx xxxx - chip ram
    0000 0000 1011 1111 11** **** **** **** - 8520-A/B
    0000 0000 1101 1111 1111 000x xxxx xxxx - chip registes
    0000 0000 1100 xxxx xxxx xxxx xxxx xxxx - slow memory
    0000 0000 1101 0xxx xxxx xxxx xxxx xxxx - slow memory
    0000 0000 1101 10xx xxxx xxxx xxxx xxxx - slow memory
    0000 0000 1111 11xx xxxx xxxx xxxx xxxx - system rom
    
    0000 0000 110* **** **** **** **** **** - chip registers and copy of chip registers
    
    0x00F00000 - no ROM at this address

bus_ssram
    SLAVE 2: ssram memory
        0x00000000 - 0x001FFFFF - 1MB Chip RAM and copies
            0x00000000 - 0x000FFFFF - 1MB Chip RAM          -> 0x00000000 - 0x000FFFFF in SSRAM
            0x00100000 - 0x001FFFFF - copy of Chip RAM
            
            AND mask:           0000 0000 0000 1111 1111 1111 1111 1111
            overlay OR mask:    0000 0000 0001 1100 0000 0000 0000 0000
            
        0x10100000 - 0x101BFFFF - 768Kb firmware RAM        -> 0x00100000 - 0x001BFFFF in SSRAM
            0x10180000 - 0x101B5FFF - video buffer          -> 0x00180000 - 0x001B5FFF in SSRAM, 216*4*256
            0x101B6000 - 0x101BFFFF - free                  -> 0x001B6000 - 0x001BFFFF in SSRAM
            
            AND mask:           0000 0000 0001 1111 1111 1111 1111 1111
            
        0x00FC0000 - 0x00FFFFFF - 256Kb ROM                 -> 0x001C0000 - 0x001FFFFF in SSRAM
        
            AND mask:           0000 0000 0001 1111 1111 1111 1111 1111

bus_sd
    SLAVE 1: control
        0x10001000 - 0x1000100F - 4 long words
    MASTER R1
    
control_osd
    SLAVE 3: on screen display
        0x10000000 - 0x10000FFF - 512x8
    MASTER R2

bus_terminator
    SLAVE 0:
        all unused addresses

ao68000
    MASTER R3

ocs_video
    SLAVE 4:
        chip registers
        08C-09B, 100-10B, 0E0-0F7, 120-1BF, 110-11B
    MASTER P1

ocs_control
    SLAVE 5:
        chip registers
        000-007 R, 09C-09F, 010-013 R, 01C-01F R, 028-02B

ocs_blitter
    SLAVE 6:
        chip registers
        040-059, 060-067, 070-075
    MASTER P2

ocs_copper
    SLAVE 7:
        chip registers
        02C-02F, 080-08B
    MASTER R4
    
cia_a
    SLAVE 8:
    0000_0000_101*_****_**10_****_****_****

cia_b
    SLAVE 9:
    0000_0000_101*_****_**01_****_****_****

ocs_serial
    SLAVE 10:
        chip registers
        018-01B R, 030-033

ocs_floppy
    SLAVE 11:
        chip registers
        020-027, 07C-07F
    SLAVE 12: floppy buffer
        0x10004000 - 0x100055FF, 11x512
    MASTER R5

ocs_input
    SLAVE 13:
        chip registers
        008-00F R, 014-017 R, 034-037

ocs_audio
    SLAVE 14:
        chip registers
        0A0-0AB, 0B0-0BB, 0C0-0CB, 0D0-0DB
    MASTER R6
*/

/***********************************************************************************************************************
 * System PLL
 **********************************************************************************************************************/

wire [5:0]  pll_clocks;
wire        clk_30 = pll_clocks[0];
wire        clk_12 = pll_clocks[1];
wire        clk_25 = pll_clocks[2];
wire        pll_locked;

altpll pll_inst(
	.inclk  ( {1'b0, clk_50} ),
	.clk    (pll_clocks),
	.locked (pll_locked)
);
defparam
    pll_inst.clk0_divide_by             = 5,
    pll_inst.clk0_duty_cycle            = 50,
    pll_inst.clk0_multiply_by           = 3,
    pll_inst.clk0_phase_shift           = "0",
    pll_inst.clk1_divide_by             = 25,
    pll_inst.clk1_duty_cycle            = 50,
    pll_inst.clk1_multiply_by           = 6,
    pll_inst.clk1_phase_shift           = "0",
    pll_inst.clk2_divide_by             = 2,
    pll_inst.clk2_duty_cycle            = 50,
    pll_inst.clk2_multiply_by           = 1,
    pll_inst.clk2_phase_shift           = "0",
    pll_inst.compensate_clock           = "CLK0",
    pll_inst.gate_lock_counter          = 1048575,
    pll_inst.gate_lock_signal           = "YES",
    pll_inst.inclk0_input_frequency     = 20000,
    pll_inst.intended_device_family     = "Cyclone II",
    pll_inst.invalid_lock_multiplier    = 5,
    pll_inst.lpm_hint                   = "CBX_MODULE_PREFIX=pll30",
    pll_inst.lpm_type                   = "altpll",
    pll_inst.operation_mode             = "NORMAL",
    pll_inst.valid_lock_multiplier      = 1;

wire reset_n            = pll_locked & reset_ext_n & ~reset_request;
wire management_reset_n = reset_n & ~management_mode;

/***********************************************************************************************************************
 * drv_audio
 **********************************************************************************************************************/
drv_audio drv_audio_inst(
    .clk_12 (clk_12),
    .reset_n(management_reset_n),
    
    // drv_audio interface
    .volume0(volume0), /*[6:0]*/
    .volume1(volume1), /*[6:0]*/
    .volume2(volume2), /*[6:0]*/
    .volume3(volume3), /*[6:0]*/
    
    .sample0(sample0), /*[7:0]*/
    .sample1(sample1), /*[7:0]*/
    .sample2(sample2), /*[7:0]*/
    .sample3(sample3), /*[7:0]*/
    
    // WM8731 audio codec hardware interface
    .ac_sclk(ac_sclk),
    .ac_sdat(ac_sdat),
    .ac_xclk(ac_xclk),
    .ac_bclk(ac_bclk),
    .ac_dat (ac_dat),
    .ac_lr  (ac_lr)
);

/***********************************************************************************************************************
 * drv_keyboard
 **********************************************************************************************************************/
wire        joystick_1_up;
wire        joystick_1_down;
wire        joystick_1_left;
wire        joystick_1_right;
wire        joystick_1_fire;

wire        request_osd;
wire        keyboard_event;
wire [7:0]  keyboard_scancode;

drv_keyboard drv_keyboard_inst (
    .clk_30             (clk_30),
    .reset_n            (reset_n),
    
    // On-Screen-Display management interface
    .request_osd        (request_osd),
    .enable_joystick_1  (on_screen_display | joystick_enable),
    
    // drv_keyboard interface
    .keyboard_ready     (keyboard_ready),
    .keyboard_event     (keyboard_event),
    .keyboard_scancode  (keyboard_scancode), /*[7:0]*/
    
    // joystick on port 1
    .joystick_1_up      (joystick_1_up),
    .joystick_1_down    (joystick_1_down),
    .joystick_1_left    (joystick_1_left),
    .joystick_1_right   (joystick_1_right),
    .joystick_1_fire    (joystick_1_fire),
    
    // PS/2 keyboard hardware interface
    .ps2_kbclk          (ps2_kbclk),
    .ps2_kbdat          (ps2_kbdat)
);



/***********************************************************************************************************************
 * drv_mouse
 **********************************************************************************************************************/
wire        mouse_moved;
wire [8:0]  mouse_y_move;
wire [8:0]  mouse_x_move;
wire        mouse_left_button;
wire        mouse_right_button;
wire        mouse_middle_button;

drv_mouse drv_mouse_inst(
    .clk_30                 (clk_30),
    .reset_n                (management_reset_n),
    
    // drv_keyboard interface
    .mouse_moved            (mouse_moved),
    .mouse_y_move           (mouse_y_move), /*[8:0]*/
    .mouse_x_move           (mouse_x_move), /*[8:0]*/
    .mouse_left_button      (mouse_left_button),
    .mouse_right_button     (mouse_right_button),
    .mouse_middle_button    (mouse_middle_button),
    
    // PS/2 mouse hardware interface
    .ps2_mouseclk           (ps2_mouseclk),
    .ps2_mousedat           (ps2_mousedat)
);

/***********************************************************************************************************************
 * bus_sd
 **********************************************************************************************************************/

bus_sd bus_sd_inst(
    .clk_30         (clk_30),
    .reset_n        (reset_n),
    
    // WISHBONE master
    .CYC_O          (masterR1_cyc_o),
    .DAT_O          (masterR1_dat_o),
    .STB_O          (masterR1_stb_o),
    .WE_O           (masterR1_we_o),
    .ADR_O          (masterR1_adr_o),
    .SEL_O          (masterR1_sel_o),
    .DAT_I          (slave_dat_o),
    .ACK_I          (masterR1_ack_i),
    .ERR_I          (masterR1_err_i),
    .RTY_I          (masterR1_rty_i),
    // TAG_TYPE: TGC_O
    .SGL_O          (),
    .BLK_O          (),
    .RMW_O          (),
    // TAG_TYPE: TGA_O
    .CTI_O          (),
    .BTE_O          (),
    
    // WISHBONE slave
    .slave_DAT_O    (slave1_dat_o),
    .slave_DAT_I    (master_dat_o),
    .ACK_O          (slave1_ack_o),
    .ERR_O          (slave1_err_o),
    .RTY_O          (slave1_rty_o),
    .CYC_I          (slave1_cyc_i),
    .ADR_I          (master_adr_o[3:2]), /*[3:2]*/
    .STB_I          (slave1_stb_i),
    .WE_I           (master_we_o),
    .SEL_I          (master_sel_o),
    
    // SD bus 1-bit hardware interface
    .sd_clk_o       (sd_clk_o),
    .sd_cmd_io      (sd_cmd_io),
    .sd_dat_io      (sd_dat_io),
    
    // Debug signals
    .debug_sd       (debug_sd)
);

/***********************************************************************************************************************
 * bus_ssram
 **********************************************************************************************************************/

wire [35:0] burst_read_data;

bus_ssram bus_ssram_inst(
    .clk_30                     (clk_30),
    .reset_n                    (reset_n),
    
    // WISHBONE slave
    .ADR_I                      (master_adr_o[20:2]), /*[20:2]*/
    .CYC_I                      (slave2_cyc_i),
    .WE_I                       (master_we_o),
    .SEL_I                      (master_sel_o),
    .STB_I                      (slave2_stb_i),
    .DAT_I                      (master_dat_o),
    .DAT_O                      (slave2_dat_o),
    .ACK_O                      (slave2_ack_o),
    
    // Direct drv_ssram read/write burst DMA for ocs_video and drv_vga 
    // drv_vga read burst
    .burst_read_vga_request     (burst_read_vga_request),
    .burst_read_vga_address     (burst_read_vga_address),
    .burst_read_vga_ready       (burst_read_vga_ready),
    // ocs_video bitplain read burst
    .burst_read_video_request   (burst_read_video_request),
    .burst_read_video_address   (burst_read_video_address),
    .burst_read_video_ready     (burst_read_video_ready),
    // common read burst data signal
    .burst_read_data            (burst_read_data),
    
    // ocs_video video output write burst
    .burst_write_request        (burst_write_request),
    .burst_write_address        (burst_write_address),
    .burst_write_ready          (burst_write_ready),
    .burst_write_data           (burst_write_data),
    
    // IS61LPS51236A pipelined SSRAM hardware interface
    .ssram_address              (ssram_address),
    .ssram_oe_n                 (ssram_oe_n),
    .ssram_writeen_n            (ssram_writeen_n),
    .ssram_byteen_n             (ssram_byteen_n),
    .ssram_adsp_n               (ssram_adsp_n),
    .ssram_clk                  (ssram_clk),
    .ssram_globalw_n            (ssram_globalw_n),
    .ssram_advance_n            (ssram_advance_n),
    .ssram_adsc_n               (ssram_adsc_n),
    .ssram_ce1_n                (ssram_ce1_n),
    .ssram_ce2                  (ssram_ce2),
    .ssram_ce3_n                (ssram_ce3_n),
    .ssram_data                 (ssram_data)
);

/***********************************************************************************************************************
 * drv_vga
 **********************************************************************************************************************/

wire        burst_read_vga_request;
wire [31:2] burst_read_vga_address;
wire        burst_read_vga_ready;

wire [4:0]  osd_line;
wire [4:0]  osd_column;

wire        display_valid;

drv_vga drv_vga_inst(
    .clk_30             (clk_30),
    .reset_n            (reset_n),
    
    // On-Screen-Display management interface
    .management_mode    (management_mode),
    .on_screen_display  (on_screen_display),
    .osd_line           (osd_line),
    .osd_column         (osd_column),
    .character          (character),
    
    // Control signal for VGA capture
    .display_valid(display_valid),
    
    // Direct drv_ssram burst read DMA video interface
    .burst_read_request (burst_read_vga_request),
    .burst_read_address (burst_read_vga_address),   /*[18:0]*/
    .burst_read_ready   (burst_read_vga_ready),
    .burst_read_data    (burst_read_data),          /*[35:0]*/
    
    // ADV7123 Video DAC hardware interface
    .vga_r              (vga_r),        /*[9:0]*/
    .vga_g              (vga_g),        /*[9:0]*/
    .vga_b              (vga_b),        /*[9:0]*/
    .vga_blank_n        (vga_blank_n),
    .vga_sync_n         (vga_sync_n),
    .vga_clock          (vga_clock),
    .vga_hsync          (vga_hsync),
    .vga_vsync          (vga_vsync)
);

/***********************************************************************************************************************
 * drv_eth_vga_capture
 **********************************************************************************************************************/
drv_eth_vga_capture drv_eth_vga_capture_inst(
    .clk_30         (clk_30),
    .clk_25         (clk_25),
    .reset_n        (reset_n),
    
    // Captured VGA output signals
    .display_valid  (display_valid),
    .vga_r          (vga_r),
    .vga_g          (vga_g),
    .vga_b          (vga_b),
    
    // DM9000A Ethernet hardware interface
    .enet_clk_25(enet_clk_25),
    .enet_reset_n(enet_reset_n),
    .enet_cs_n(enet_cs_n),
    .enet_irq(enet_irq),
    
    .enet_ior_n(enet_ior_n),
    .enet_iow_n(enet_iow_n),
    .enet_cmd(enet_cmd),
    .enet_data(enet_data) /*[15:0]*/
);

/***********************************************************************************************************************
 * drv_debug
 **********************************************************************************************************************/

drv_debug drv_debug_inst(
    .CLK_I          (clk_30),
    .reset_n        (reset_n),
    
    // Internal debug signals
    .master_adr_o   (master_adr_o),
    .debug_pc       (debug_pc),
    .debug_syscon   (debug_syscon),
    .debug_track    (debug_track),
    
    // Switches and hex leds hardware interface
    // hex output
    .hex0           (hex0),
    .hex1           (hex1),
    .hex2           (hex2),
    .hex3           (hex3),
    .hex4           (hex4),
    .hex5           (hex5),
    .hex6           (hex6),
    .hex7           (hex7),
    // switches input
    .debug_sw_pc    (debug_sw1_pc),
    .debug_sw_adr   (debug_sw2_adr)
);


/***********************************************************************************************************************
 * control_osd
 **********************************************************************************************************************/
wire        management_mode;
wire        on_screen_display;
wire [7:0]  character;

wire        floppy_inserted;
wire [31:0] floppy_sector;
wire        floppy_write_enabled;
wire        joystick_enable;
wire        reset_request;

control_osd control_osd_inst(
    .CLK_I                  (clk_30),
    .reset_n                (reset_n),
    .reset_request          (reset_request),
    .management_mode        (management_mode),
    
    // WISHBONE master
    .CYC_O                  (masterR2_cyc_o),
    .STB_O                  (masterR2_stb_o),
    .WE_O                   (masterR2_we_o),
    .ADR_O                  (masterR2_adr_o), /*[31:2]*/
    .SEL_O                  (masterR2_sel_o),
    .master_DAT_O           (masterR2_dat_o),
    .master_DAT_I           (slave_dat_o),
    .ACK_I                  (masterR2_ack_i),
    
    // WISHBONE slave
    .ADR_I                  (master_adr_o),
    .CYC_I                  (slave3_cyc_i),
    .WE_I                   (master_we_o),
    .STB_I                  (slave3_stb_i),
    .SEL_I                  (master_sel_o),
    .slave_DAT_I            (master_dat_o),
    .slave_DAT_O            (slave3_dat_o),
    .ACK_O                  (slave3_ack_o),
    .RTY_O                  (slave3_rty_o),
    .ERR_O                  (slave3_err_o),
    
    // On-Screen-Display management interface
    .request_osd            (request_osd),
    .on_screen_display      (on_screen_display),
    
    .osd_line               (osd_line),
    .osd_column             (osd_column),
    .character              (character),
    
    .joystick_enable        (joystick_enable),
    .keyboard_select        (joystick_1_fire),
    .keyboard_up            (joystick_1_up),
    .keyboard_down          (joystick_1_down),
    
    // On-Screen-Display floppy management interface
    .floppy_inserted        (floppy_inserted),
    .floppy_sector          (floppy_sector),
    .floppy_write_enabled   (floppy_write_enabled),
    .floppy_error           (floppy_error)
);


/***********************************************************************************************************************
 * bus_terminator
 **********************************************************************************************************************/

bus_terminator bus_terminator_inst(
    .CLK_I(clk_30),
    .reset_n(reset_n),
    
    // WISHBONE slave
    .ADR_I                  (master_adr_o),
    .CYC_I                  (slave0_cyc_i),
    .WE_I                   (master_we_o),
    .STB_I                  (slave0_stb_i),
    .SEL_I                  (master_sel_o),
    .slave_DAT_I            (master_dat_o),
    .slave_DAT_O            (slave0_dat_o),
    .ACK_O                  (slave0_ack_o),
    .RTY_O                  (slave0_rty_o),
    .ERR_O                  (slave0_err_o),
    
    // ao68000 interrupt cycle indicator
    .cpu_space_cycle( masterR3_cyc_o == 1'b1 && masterR3_stb_o == 1'b1 && masterR3_we_o == 1'b0 && fc == 3'd7 )
);


/***********************************************************************************************************************
 * ao68000
 **********************************************************************************************************************/
wire [31:0] debug_pc;
wire [2:0]  fc;

ao68000 ao68000_inst(
	.CLK_I              (clk_30),
	.reset_n            (management_reset_n),
    
    // WISHBONE master
	.CYC_O              (masterR3_cyc_o),
	.ADR_O              (masterR3_adr_o),
	.DAT_O              (masterR3_dat_o),
	.DAT_I              (slave_dat_o),
	.SEL_O              (masterR3_sel_o),
	.STB_O              (masterR3_stb_o),
	.WE_O               (masterR3_we_o),

	.ACK_I              (masterR3_ack_i),
	.ERR_I              (masterR3_err_i),
	.RTY_I              (masterR3_rty_i),

	// TAG_TYPE: TGC_O
	.SGL_O              (),
	.BLK_O              (),
	.RMW_O              (),

	// TAG_TYPE: TGA_O
	.CTI_O              (),
	.BTE_O              (),

	// TAG_TYPE: TGC_O
	.fc_o               (fc),

	//****************** OTHER
	/* interrupt acknowlege:
	 * ACK_I: interrupt vector on DAT_I[7:0]
	 * ERR_I: spurious interrupt
	 * RTY_I: autovector
	 */
	.ipl_i              (interrupt),
	.reset_o            (),
	.blocked_o          (),
	
	.debug_pc           (debug_pc),
	.debug_68k_state    (debug_68k_state)
);

/***********************************************************************************************************************
 * ocs_video
 **********************************************************************************************************************/

wire        burst_read_video_request;
wire [31:2] burst_read_video_address;
wire        burst_read_video_ready;

wire        burst_write_request;
wire [31:2] burst_write_address;
wire [35:0] burst_write_data;
wire        burst_write_ready;

wire        na_int_ena_write;
wire [15:0] na_int_ena;
wire [1:0]  na_int_ena_sel;
    
wire        na_dma_con_write;
wire [15:0] na_dma_con;
wire [1:0]  na_dma_con_sel;

wire [15:0] na_clx_dat;

ocs_video ocs_video_inst(
    .CLK_I              (clk_30),
    .reset_n            (management_reset_n),
    
    // WISHBONE master
    .CYC_O              (masterP_cyc_o),
    .STB_O              (masterP_stb_o),
    .WE_O               (masterP_we_o),
    .ADR_O              (masterP_adr_o), /*[31:2]*/
    .SEL_O              (masterP_sel_o),
    .master_DAT_I       (slave_dat_o),
    .ACK_I              (masterP_ack_i),
    
    // WISHBONE slave
    .CYC_I              (slave4_cyc_i),
    .STB_I              (slave4_stb_i),
    .WE_I               (master_we_o),
    .ADR_I              (master_adr_o[8:2]), /*[8:2]*/
    .SEL_I              (master_sel_o),
    .slave_DAT_I        (master_dat_o),
    .ACK_O              (slave4_ack_o),
    
    // Not aligned register access on a 32-bit WISHBONE bus
        // CLXDAT read not implemented here
    .na_clx_dat_read    (na_clx_dat_read),
    .na_clx_dat         (na_clx_dat),
        // INTENA write implemented here
    .na_int_ena_write   (na_int_ena_write),
    .na_int_ena         (na_int_ena),       /*[15:0]*/
    .na_int_ena_sel     (na_int_ena_sel),   /*[1:0]*/
        // DMACON write implemented here
    .na_dma_con_write   (na_dma_con_write),
    .na_dma_con         (na_dma_con),       /*[15:0]*/
    .na_dma_con_sel     (na_dma_con_sel),   /*[1:0]*/
    
    // Direct drv_ssram read/write DMA burst video interface
    // bitplain burst read
	.burst_read_request (burst_read_video_request),
	.burst_read_address (burst_read_video_address), /*[18:0]*/
	.burst_read_ready   (burst_read_video_ready),
	.burst_read_data    (burst_read_data[31:0]),    /*[31:0]*/
	
    // video output burst write
    .burst_write_request(burst_write_request),
    .burst_write_address(burst_write_address),
    .burst_write_data   (burst_write_data),
    .burst_write_ready  (burst_write_ready),
    
    // Internal OCS ports
    .line_start         (line_start),
    .line_pre_start     (line_pre_start),
    .line_number        (line_number),
    .column_number      (column_number),
    
    .dma_con            (dma_con) /*[10:0]*/
);

/***********************************************************************************************************************
 * ocs_control
 **********************************************************************************************************************/

wire        line_start;
wire        line_pre_start;
wire [8:0]  line_number;
wire [8:0]  column_number;

wire        pulse_709379_hz;
wire        pulse_color;

wire [2:0]  interrupt;

wire [10:0] dma_con;
wire [14:0] adk_con;

wire        na_pot0dat_read;

ocs_control ocs_control_inst(
    .clk_30             (clk_30),
    .reset_n            (management_reset_n),
    
    // WISHBONE slave
    .CYC_I              (slave5_cyc_i),
    .STB_I              (slave5_stb_i),
    .WE_I               (master_we_o),
    .ADR_I              (master_adr_o[8:2]),
    .SEL_I              (master_sel_o),
    .slave_DAT_I        (master_dat_o),
    .slave_DAT_O        (slave5_dat_o),
    .ACK_O              (slave5_ack_o),
    
    // Not aligned register access on a 32-bit WISHBONE bus
        // INTENA write not implemented here
    .na_int_ena_write   (na_int_ena_write),
    .na_int_ena         (na_int_ena), /*[15:0]*/
    .na_int_ena_sel     (na_int_ena_sel), /*[1:0]*/
        // DMACON write not implemented here
    .na_dma_con_write   (na_dma_con_write),
    .na_dma_con         (na_dma_con), /*[15:0]*/
    .na_dma_con_sel     (na_dma_con_sel), /*[1:0]*/
        // POT0DAT read implemented here
    .na_pot0dat_read    (na_pot0dat_read),
    .na_pot0dat         (na_pot0dat),
    
    // Internal OCS ports: beam counters
    .line_start         (line_start),
    .line_pre_start     (line_pre_start),
    .line_number        (line_number),
    .column_number      (column_number),
    
    // Internal OCS ports: clock pulses for CIA and audio
    .pulse_709379_hz    (pulse_709379_hz),
    .pulse_color        (pulse_color),
    
    // Internal OCS ports: global registers and blitter signals
    .dma_con            (dma_con), /*[10:0]*/
    .adk_con            (adk_con), /*[14:0]*/
    
    .blitter_busy       (blitter_busy),
    .blitter_zero       (blitter_zero),
    
    // Internal OCS ports: interrupts
    .blitter_irq        (blitter_irq),
    .cia_a_irq          (~cia_a_irq_n),
    .cia_b_irq          (~cia_b_irq_n),
    .floppy_syn_irq     (floppy_syn_irq),
    .floppy_blk_irq     (floppy_blk_irq),
    .serial_rbf_irq     (1'b0),
    .serial_tbe_irq     (1'b0),
    .audio_irq          (audio_irq),
    
    .interrupt          (interrupt)
);

/***********************************************************************************************************************
 * ocs_blitter
 **********************************************************************************************************************/

wire blitter_zero;
wire blitter_busy;
wire blitter_irq;

ocs_blitter ocs_blitter_inst(
    .CLK_I          (clk_30),
    .reset_n        (management_reset_n),
    
    // WISHBONE master
    .CYC_O          (masterR7_cyc_o),
    .STB_O          (masterR7_stb_o),
    .WE_O           (masterR7_we_o),
    .ADR_O          (masterR7_adr_o),
    .SEL_O          (masterR7_sel_o),
    .master_DAT_O   (masterR7_dat_o),
    .master_DAT_I   (slave_dat_o),
    .ACK_I          (masterR7_ack_i),

    // WISHBONE slave
    .CYC_I          (slave6_cyc_i),
    .STB_I          (slave6_stb_i),
    .WE_I           (master_we_o),
    .ADR_I          (master_adr_o[8:2]),
    .SEL_I          (master_sel_o),
    .slave_DAT_I    (master_dat_o),
    .ACK_O          (slave6_ack_o),
    
    // Internal OCS ports
    .dma_con        (dma_con), /*[10:0]*/
    
    .blitter_irq    (blitter_irq),
    .blitter_zero   (blitter_zero),
    .blitter_busy   (blitter_busy)
);

/***********************************************************************************************************************
 * ocs_copper
 **********************************************************************************************************************/

ocs_copper ocs_copper_inst(
    .CLK_I          (clk_30),
    .reset_n        (management_reset_n),
    
    // WISHBONE master
    .CYC_O          (masterR4_cyc_o),
    .STB_O          (masterR4_stb_o),
    .WE_O           (masterR4_we_o),
    .ADR_O          (masterR4_adr_o),
    .SEL_O          (masterR4_sel_o),
    .master_DAT_O   (masterR4_dat_o),
    .master_DAT_I   (slave_dat_o),
    .ACK_I          (masterR4_ack_i),
    
    // WISHBONE slave
    .CYC_I          (slave7_cyc_i),
    .STB_I          (slave7_stb_i),
    .WE_I           (master_we_o),
    .ADR_I          (master_adr_o[8:2]),
    .SEL_I          (master_sel_o),
    .slave_DAT_I    (master_dat_o),
    .ACK_O          (slave7_ack_o),
    
    // Internal OCS ports
    .line_start     (line_start),
    .line_number    (line_number),  /*[8:0]*/
    .column_number  (column_number),/*[8:0]*/
    
    .dma_con        (dma_con), /*[10:0]*/
    .blitter_busy   (blitter_busy)
);

/***********************************************************************************************************************
 * CIA-A
 **********************************************************************************************************************/
wire [7:0]  cia_a_pa;
wire [7:0]  cia_a_pa_i;
wire        cia_a_irq_n;
wire        cia_a_sp_o;

wire [7:0]  cia_a_output;
assign slave8_dat_o = {8'd0, cia_a_output, 8'd0, cia_a_output};

cia8520 cia8520_a_inst(
    .CLK_I              (clk_30),
    .reset_n            (management_reset_n),
    
    // WISHBONE slave
    .CYC_I              (slave8_cyc_i),
    .STB_I              (slave8_stb_i),
    .WE_I               (master_we_o),
    .ADR_I              (master_adr_o[11:8]),
    .DAT_I              (master_dat_o[23:16]),
    .ACK_O              (slave8_ack_o),
    .DAT_O              (cia_a_output),
    
    // Internal OCS ports
    .pulse_709379_hz    (pulse_709379_hz),
    
    // 8520 synchronous interface
    .pa_o               (cia_a_pa),
    .pb_o               (),
    .pa_i               ( {cia_a_pa_i[7:2], 2'b11} ),
    .pb_i               (8'hFF),
    
    .flag_n             (1'b1),
    .pc_n               (),
    .tod                (line_start == 1'b1 && line_number == 9'd0),
    .irq_n              (cia_a_irq_n),
    
    .sp_i               (sp_to_cia_a),
    .sp_o               (cia_a_sp_o),
    .cnt_i              (cnt_to_cia_a),
    .cnt_o              ()
);

/***********************************************************************************************************************
 * CIA-B
 **********************************************************************************************************************/
wire [7:0]  cia_b_pb;
wire        cia_b_irq_n;
wire        cia_b_flag_n;

wire [7:0]  cia_b_output;
assign slave9_dat_o = {cia_b_output, 8'd0, cia_a_output, 8'd0};

cia8520 cia8520_b_inst(
    .CLK_I              (clk_30),
    .reset_n            (management_reset_n),
    
    // WISHBONE slave
    .CYC_I              (slave9_cyc_i),
    .STB_I              (slave9_stb_i),
    .WE_I               (master_we_o),
    .ADR_I              (master_adr_o[11:8]),
    .DAT_I              (master_dat_o[31:24]),
    .ACK_O              (slave9_ack_o),
    .DAT_O              (cia_b_output),
    
    // Internal OCS ports
    .pulse_709379_hz    (pulse_709379_hz),
    
    // 8520 synchronous interface
    .pa_o               (),
    .pb_o               (cia_b_pb),
    .pa_i               (8'hFF),
    .pb_i               (8'hFF),
    
    .flag_n             (cia_b_flag_n),
    .pc_n               (),
    .tod                (line_start == 1'b1),
    .irq_n              (cia_b_irq_n),
    
    .sp_i               (1'b0),
    .sp_o               (),
    .cnt_i              (1'b0),
    .cnt_o              ()
);

/***********************************************************************************************************************
 * ocs_serial
 **********************************************************************************************************************/
wire na_dskbytr_read;

ocs_serial ocs_serial_inst(
    .CLK_I          (clk_30),
    .reset_n        (management_reset_n),

    // WISHBONE slave
    .CYC_I          (slave10_cyc_i),
    .STB_I          (slave10_stb_i),
    .WE_I           (master_we_o),
    .ADR_I          (master_adr_o[8:2]),
    .SEL_I          (master_sel_o),
    .DAT_I          (master_dat_o),
    .DAT_O          (slave10_dat_o),
    .ACK_O          (slave10_ack_o),

    // Not aligned register access on a 32-bit WISHBONE bus
        // DSKBYTR implemented here
    .na_dskbytr_read(na_dskbytr_read),
    .na_dskbytr     (na_dskbytr)
);

/***********************************************************************************************************************
 * ocs_floppy
 **********************************************************************************************************************/
wire [15:0] na_dskbytr;
wire        floppy_error;

wire        floppy_syn_irq;
wire        floppy_blk_irq;

wire [7:0]  debug_track;

ocs_floppy ocs_floppy_inst(
    .CLK_I                  (clk_30),
    .reset_n                (management_reset_n),
    
    // On-Screen-Display management interface
    .floppy_inserted        (floppy_inserted),
    .floppy_sector          (floppy_sector),
    .floppy_write_enabled   (floppy_write_enabled),
    .floppy_error           (floppy_error),
    
    // WISHBONE master
    .CYC_O                  (masterR5_cyc_o),
    .STB_O                  (masterR5_stb_o),
    .WE_O                   (masterR5_we_o),
    .ADR_O                  (masterR5_adr_o),
    .SEL_O                  (masterR5_sel_o),
    .master_DAT_O           (masterR5_dat_o),
    .master_DAT_I           (slave_dat_o),
    .ACK_I                  (masterR5_ack_i),

    // WISHBONE slave for OCS registers
    .CYC_I                  (slave11_cyc_i),
    .STB_I                  (slave11_stb_i),
    .WE_I                   (master_we_o),
    .ADR_I                  (master_adr_o[8:2]),
    .SEL_I                  (master_sel_o),
    .slave_DAT_I            (master_dat_o),
    .ACK_O                  (slave11_ack_o),
    
    // WISHBONE slave for floppy buffer
    .buffer_CYC_I           (slave12_cyc_i),
    .buffer_STB_I           (slave12_stb_i),
    .buffer_WE_I            (master_we_o),
    .buffer_ADR_I           (master_adr_o[13:2]),
    .buffer_SEL_I           (master_sel_o),
    .buffer_DAT_I           (master_dat_o),
    .buffer_DAT_O           (slave12_dat_o),
    .buffer_ACK_O           (slave12_ack_o),
    
    // Not aligned register access on a 32-bit WISHBONE bus
        // DSKBYTR read not implemented here
    .na_dskbytr_read        (na_dskbytr_read),
    .na_dskbytr             (na_dskbytr),
    
    // Internal OCS ports
    .line_start             (line_start),
    
    .dma_con                (dma_con), /*[10:0]*/
    .adk_con                (adk_con), /*[14:0]*/

    .floppy_syn_irq         (floppy_syn_irq),
    .floppy_blk_irq         (floppy_blk_irq),

    // Floppy CIA interface
    .fl_rdy_n               (cia_a_pa_i[5]),
    .fl_tk0_n               (cia_a_pa_i[4]),
    .fl_wpro_n              (cia_a_pa_i[3]),
    .fl_chng_n              (cia_a_pa_i[2]),
    .fl_index_n             (cia_b_flag_n),

    .fl_mtr_n               (cia_b_pb[7]),
    .fl_sel_n               (cia_b_pb[6:3]),
    .fl_side_n              (cia_b_pb[2]),
    .fl_dir                 (cia_b_pb[1]),
    .fl_step_n              (cia_b_pb[0]),
    
    // Debug signals
    .debug_floppy           (debug_floppy),
    .debug_track            (debug_track)
);

/***********************************************************************************************************************
 * ocs_input
 **********************************************************************************************************************/
wire        sp_to_cia_a;
wire        cnt_to_cia_a;

wire [15:0] na_pot0dat;
wire        na_clx_dat_read;

wire        keyboard_ready;

ocs_input ocs_input_inst(
    .CLK_I              (clk_30),
    .reset_n            (management_reset_n),
    
    // On-Screen-Display management interface
    .on_screen_display  (on_screen_display),
    .enable_joystick_1  (joystick_enable),
    
    // WISHBONE slave
    .CYC_I              (slave13_cyc_i),
    .STB_I              (slave13_stb_i),
    .WE_I               (master_we_o),
    .ADR_I              (master_adr_o[8:2]),
    .SEL_I              (master_sel_o),
    .DAT_I              (master_dat_o),
    .DAT_O              (slave13_dat_o),
    .ACK_O              (slave13_ack_o),
    
    // Not aligned register access on a 32-bit WISHBONE bus
        // CLXDAT read implemented here
    .na_clx_dat_read    (na_clx_dat_read),
    .na_clx_dat         (na_clx_dat),
        // POT0DAT read not implemented here
    .na_pot0dat_read    (na_pot0dat_read),
    .na_pot0dat         (na_pot0dat),
    
    // User input CIA interface
    // keyboard output
    .sp_from_cia        (cia_a_sp_o),
    .sp_to_cia          (sp_to_cia_a),
    .cnt_to_cia         (cnt_to_cia_a),
    
    // CIA-A fire buttons
    .ciaa_fire_0_n      (cia_a_pa_i[6]),
    .ciaa_fire_1_n      (cia_a_pa_i[7]),
    
    // drv_keyboard interface
    .keyboard_ready     (keyboard_ready),
    .keyboard_event     (keyboard_event),
    .keyboard_scancode  (keyboard_scancode), /*[8:0]*/
    
    // joystick on port 1
    .joystick_1_up      (joystick_1_up),
    .joystick_1_down    (joystick_1_down),
    .joystick_1_left    (joystick_1_left),
    .joystick_1_right   (joystick_1_right),
    .joystick_1_fire    (joystick_1_fire),
    
    // drv_mouse interface
    .mouse_moved        (mouse_moved),
    .mouse_y_move       (mouse_y_move), /*[8:0]*/
    .mouse_x_move       (mouse_x_move), /*[8:0]*/
    .mouse_left_button  (mouse_left_button),
    .mouse_right_button (mouse_right_button),
    .mouse_middle_button(mouse_middle_button)
);

/***********************************************************************************************************************
 * ocs_audio
 **********************************************************************************************************************/
wire [5:0] volume0;
wire [5:0] volume1;
wire [5:0] volume2;
wire [5:0] volume3;
wire [7:0] sample0;
wire [7:0] sample1;
wire [7:0] sample2;
wire [7:0] sample3;

wire [3:0] audio_irq;

ocs_audio ocs_audio_inst(
    .CLK_I          (clk_30),
    .reset_n        (management_reset_n),
    
    // WISHBONE master
    .CYC_O          (masterR6_cyc_o),
    .STB_O          (masterR6_stb_o),
    .WE_O           (masterR6_we_o),
    .ADR_O          (masterR6_adr_o),
    .SEL_O          (masterR6_sel_o),
    .master_DAT_I   (slave_dat_o),
    .ACK_I          (masterR6_ack_i),
    
    // WISHBONE slave
    .CYC_I          (slave14_cyc_i),
    .STB_I          (slave14_stb_i),
    .WE_I           (master_we_o),
    .ADR_I          (master_adr_o[8:2]),
    .SEL_I          (master_sel_o),
    .slave_DAT_I    (master_dat_o),
    .ACK_O          (slave14_ack_o),
    
    // Internal OCS ports
    .pulse_color    (pulse_color),
    .line_start     (line_start),
    
    .dma_con        (dma_con),
    .adk_con        (adk_con),
    
    .audio_irq      (audio_irq),
    
    // drv_audio interface
    .volume0        (volume0), /*[6:0]*/
    .volume1        (volume1), /*[6:0]*/
    .volume2        (volume2), /*[6:0]*/
    .volume3        (volume3), /*[6:0]*/
    
    .sample0        (sample0), /*[7:0]*/
    .sample1        (sample1), /*[7:0]*/
    .sample2        (sample2), /*[7:0]*/
    .sample3        (sample3)  /*[7:0]*/
);

/***********************************************************************************************************************
 * bus_syscon
 **********************************************************************************************************************/

wire        masterP_cyc_o;
wire        masterP_stb_o;
wire        masterP_we_o;
wire [31:2] masterP_adr_o;
wire [3:0]  masterP_sel_o;
wire [31:0] masterP_dat_o;
wire        masterP_ack_i;
wire        masterP_rty_i;
wire        masterP_err_i;

wire        masterR1_cyc_o;
wire        masterR1_stb_o;
wire        masterR1_we_o;
wire [31:2] masterR1_adr_o;
wire [3:0]  masterR1_sel_o;
wire [31:0] masterR1_dat_o;
wire        masterR1_ack_i;
wire        masterR1_rty_i;
wire        masterR1_err_i;

wire        masterR2_cyc_o;
wire        masterR2_stb_o;
wire        masterR2_we_o;
wire [31:2] masterR2_adr_o;
wire [3:0]  masterR2_sel_o;
wire [31:0] masterR2_dat_o;
wire        masterR2_ack_i;
wire        masterR2_rty_i;
wire        masterR2_err_i;

wire        masterR3_cyc_o;
wire        masterR3_stb_o;
wire        masterR3_we_o;
wire [31:2] masterR3_adr_o;
wire [3:0]  masterR3_sel_o;
wire [31:0] masterR3_dat_o;
wire        masterR3_ack_i;
wire        masterR3_rty_i;
wire        masterR3_err_i;

wire        masterR4_cyc_o;
wire        masterR4_stb_o;
wire        masterR4_we_o;
wire [31:2] masterR4_adr_o;
wire [3:0]  masterR4_sel_o;
wire [31:0] masterR4_dat_o;
wire        masterR4_ack_i;
wire        masterR4_rty_i;
wire        masterR4_err_i;

wire        masterR5_cyc_o;
wire        masterR5_stb_o;
wire        masterR5_we_o;
wire [31:2] masterR5_adr_o;
wire [3:0]  masterR5_sel_o;
wire [31:0] masterR5_dat_o;
wire        masterR5_ack_i;
wire        masterR5_rty_i;
wire        masterR5_err_i;

wire        masterR6_cyc_o;
wire        masterR6_stb_o;
wire        masterR6_we_o;
wire [31:2] masterR6_adr_o;
wire [3:0]  masterR6_sel_o;
wire [31:0] masterR6_dat_o;
wire        masterR6_ack_i;
wire        masterR6_rty_i;
wire        masterR6_err_i;

wire        masterR7_cyc_o;
wire        masterR7_stb_o;
wire        masterR7_we_o;
wire [31:2] masterR7_adr_o;
wire [3:0]  masterR7_sel_o;
wire [31:0] masterR7_dat_o;
wire        masterR7_ack_i;
wire        masterR7_rty_i;
wire        masterR7_err_i;

wire [31:2] master_adr_o;
wire        master_we_o;
wire [3:0]  master_sel_o;
wire [31:0] master_dat_o;
wire [31:0] slave_dat_o;

wire [31:2] master_adr_early_o;

wire        slave0_ack_o;
wire        slave0_rty_o;
wire        slave0_err_o;
wire [31:0] slave0_dat_o;
wire        slave0_cyc_i;
wire        slave0_stb_i;

wire        slave1_ack_o;
wire        slave1_rty_o;
wire        slave1_err_o;
wire [31:0] slave1_dat_o;
wire        slave1_cyc_i;
wire        slave1_stb_i;

wire        slave2_ack_o;
wire        slave2_rty_o    = 1'b0;
wire        slave2_err_o    = 1'b0;
wire [31:0] slave2_dat_o;
wire        slave2_cyc_i;
wire        slave2_stb_i;

wire        slave3_ack_o;
wire        slave3_rty_o;
wire        slave3_err_o;
wire [31:0] slave3_dat_o;
wire        slave3_cyc_i;
wire        slave3_stb_i;

wire        slave4_ack_o;
wire        slave4_rty_o    = 1'b0;
wire        slave4_err_o    = 1'b0;
wire [31:0] slave4_dat_o;
wire        slave4_cyc_i;
wire        slave4_stb_i;

wire        slave5_ack_o;
wire        slave5_rty_o    = 1'b0;
wire        slave5_err_o    = 1'b0;
wire [31:0] slave5_dat_o;
wire        slave5_cyc_i;
wire        slave5_stb_i;

wire        slave6_ack_o;
wire        slave6_rty_o    = 1'b0;
wire        slave6_err_o    = 1'b0;
wire [31:0] slave6_dat_o;
wire        slave6_cyc_i;
wire        slave6_stb_i;

wire        slave7_ack_o;
wire        slave7_rty_o    = 1'b0;
wire        slave7_err_o    = 1'b0;
wire [31:0] slave7_dat_o;
wire        slave7_cyc_i;
wire        slave7_stb_i;

wire        slave8_ack_o;
wire        slave8_rty_o    = 1'b0;
wire        slave8_err_o    = 1'b0;
wire [31:0] slave8_dat_o;
wire        slave8_cyc_i;
wire        slave8_stb_i;

wire        slave9_ack_o;
wire        slave9_rty_o    = 1'b0;
wire        slave9_err_o    = 1'b0;
wire [31:0] slave9_dat_o;
wire        slave9_cyc_i;
wire        slave9_stb_i;

wire        slave10_ack_o;
wire        slave10_rty_o   = 1'b0;
wire        slave10_err_o   = 1'b0;
wire [31:0] slave10_dat_o;
wire        slave10_cyc_i;
wire        slave10_stb_i;

wire        slave11_ack_o;
wire        slave11_rty_o   = 1'b0;
wire        slave11_err_o   = 1'b0;
wire [31:0] slave11_dat_o;
wire        slave11_cyc_i;
wire        slave11_stb_i;

wire        slave12_ack_o;
wire        slave12_rty_o   = 1'b0;
wire        slave12_err_o   = 1'b0;
wire [31:0] slave12_dat_o;
wire        slave12_cyc_i;
wire        slave12_stb_i;

wire        slave13_ack_o;
wire        slave13_rty_o   = 1'b0;
wire        slave13_err_o   = 1'b0;
wire [31:0] slave13_dat_o;
wire        slave13_cyc_i;
wire        slave13_stb_i;

wire        slave14_ack_o;
wire        slave14_rty_o   = 1'b0;
wire        slave14_err_o   = 1'b0;
wire [31:0] slave14_dat_o;
wire        slave14_cyc_i;
wire        slave14_stb_i;

wire        slave15_ack_o   = 1'b0;
wire        slave15_rty_o   = 1'b0;
wire        slave15_err_o   = 1'b0;
wire [31:0] slave15_dat_o;
wire        slave15_cyc_i;
wire        slave15_stb_i;

wire [7:0]  debug_syscon;

bus_syscon syscon_inst(
    .CLK_I              (clk_30),
    .reset_n            (reset_n),
    .halt_switch        (debug_sw3_halt),
    
    // Priority WISHBONE master interfaces
    .masterP_cyc_o      (masterP_cyc_o),
    .masterP_stb_o      (masterP_stb_o),
    .masterP_we_o       (masterP_we_o),
    .masterP_adr_o      (masterP_adr_o), /*[31:2]*/
    .masterP_sel_o      (masterP_sel_o), /*[3:0]*/
    .masterP_dat_o      (masterP_dat_o), /*[31:0]*/
    .masterP_ack_i      (masterP_ack_i),
    .masterP_rty_i      (masterP_rty_i),
    .masterP_err_i      (masterP_err_i),
    
    // Round-robin WISHBONE master interfaces
    .masterR1_cyc_o     (masterR1_cyc_o),
    .masterR1_stb_o     (masterR1_stb_o),
    .masterR1_we_o      (masterR1_we_o),
    .masterR1_adr_o     (masterR1_adr_o), /*[31:2]*/
    .masterR1_sel_o     (masterR1_sel_o), /*[3:0]*/
    .masterR1_dat_o     (masterR1_dat_o), /*[31:0]*/
    .masterR1_ack_i     (masterR1_ack_i),
    .masterR1_rty_i     (masterR1_rty_i),
    .masterR1_err_i     (masterR1_err_i),
    
    .masterR2_cyc_o     (masterR2_cyc_o),
    .masterR2_stb_o     (masterR2_stb_o),
    .masterR2_we_o      (masterR2_we_o),
    .masterR2_adr_o     (masterR2_adr_o), /*[31:2]*/
    .masterR2_sel_o     (masterR2_sel_o), /*[3:0]*/
    .masterR2_dat_o     (masterR2_dat_o), /*[31:0]*/
    .masterR2_ack_i     (masterR2_ack_i),
    .masterR2_rty_i     (masterR2_rty_i),
    .masterR2_err_i     (masterR2_err_i),
    
    .masterR3_cyc_o     (masterR3_cyc_o),
    .masterR3_stb_o     (masterR3_stb_o),
    .masterR3_we_o      (masterR3_we_o),
    .masterR3_adr_o     (masterR3_adr_o), /*[31:2]*/
    .masterR3_sel_o     (masterR3_sel_o), /*[3:0]*/
    .masterR3_dat_o     (masterR3_dat_o), /*[31:0]*/
    .masterR3_ack_i     (masterR3_ack_i),
    .masterR3_rty_i     (masterR3_rty_i),
    .masterR3_err_i     (masterR3_err_i),
    
    .masterR4_cyc_o     (masterR4_cyc_o),
    .masterR4_stb_o     (masterR4_stb_o),
    .masterR4_we_o      (masterR4_we_o),
    .masterR4_adr_o     (masterR4_adr_o), /*[31:2]*/
    .masterR4_sel_o     (masterR4_sel_o), /*[3:0]*/
    .masterR4_dat_o     (masterR4_dat_o), /*[31:0]*/
    .masterR4_ack_i     (masterR4_ack_i),
    .masterR4_rty_i     (masterR4_rty_i),
    .masterR4_err_i     (masterR4_err_i),
    
    .masterR5_cyc_o     (masterR5_cyc_o),
    .masterR5_stb_o     (masterR5_stb_o),
    .masterR5_we_o      (masterR5_we_o),
    .masterR5_adr_o     (masterR5_adr_o), /*[31:2]*/
    .masterR5_sel_o     (masterR5_sel_o), /*[3:0]*/
    .masterR5_dat_o     (masterR5_dat_o), /*[31:0]*/
    .masterR5_ack_i     (masterR5_ack_i),
    .masterR5_rty_i     (masterR5_rty_i),
    .masterR5_err_i     (masterR5_err_i),
    
    .masterR6_cyc_o     (masterR6_cyc_o),
    .masterR6_stb_o     (masterR6_stb_o),
    .masterR6_we_o      (masterR6_we_o),
    .masterR6_adr_o     (masterR6_adr_o), /*[31:2]*/
    .masterR6_sel_o     (masterR6_sel_o), /*[3:0]*/
    .masterR6_dat_o     (masterR6_dat_o), /*[31:0]*/
    .masterR6_ack_i     (masterR6_ack_i),
    .masterR6_rty_i     (masterR6_rty_i),
    .masterR6_err_i     (masterR6_err_i),
    
    .masterR7_cyc_o     (masterR7_cyc_o),
    .masterR7_stb_o     (masterR7_stb_o),
    .masterR7_we_o      (masterR7_we_o),
    .masterR7_adr_o     (masterR7_adr_o), /*[31:2]*/
    .masterR7_sel_o     (masterR7_sel_o), /*[3:0]*/
    .masterR7_dat_o     (masterR7_dat_o), /*[31:0]*/
    .masterR7_ack_i     (masterR7_ack_i),
    .masterR7_rty_i     (masterR7_rty_i),
    .masterR7_err_i     (masterR7_err_i),
    
    // Common WISHBONE master signals
    .master_adr_o       (master_adr_o),       /*[31:2]*/
    .master_we_o        (master_we_o),
    .master_sel_o       (master_sel_o),       /*[3:0]*/
    .master_dat_o       (master_dat_o),       /*[31:0]*/
    .slave_dat_o        (slave_dat_o),        /*[31:0]*/
    
    // AND/OR master address mask signals
    .master_adr_early_o (master_adr_early_o), /*[31:2]*/
    .master_adr_and_mask(
        ({master_adr_early_o, 2'b00} >= 32'h00000000 && {master_adr_early_o, 2'b00} <= 32'h001FFFFC && management_mode == 1'b0) ?
                        30'b0000_0000_0000_1111_1111_1111_1111_11 :
        (({master_adr_early_o, 2'b00} >= 32'h10100000 && {master_adr_early_o, 2'b00} <= 32'h101BFFFC) ||
         ({master_adr_early_o, 2'b00} >= 32'h00FC0000 && {master_adr_early_o, 2'b00} <= 32'h00FFFFFC) ) ?
                        30'b0000_0000_0001_1111_1111_1111_1111_11 :
                        30'b1111_1111_1111_1111_1111_1111_1111_11
    ),
    .master_adr_or_mask(
        ({master_adr_early_o, 2'b00} >= 32'h00000000 && {master_adr_early_o, 2'b00} <= 32'h001FFFFC && management_mode == 1'b0 && cia_a_pa[0] == 1'b1) ?
                        30'b0000_0000_0001_1100_0000_0000_0000_00 :
                        30'b0000_0000_0000_0000_0000_0000_0000_00
    ),
    
    // WISHBONE slave interfaces
    // bus_terminator
    .slave0_cyc_i(slave0_cyc_i),
    .slave0_stb_i(slave0_stb_i),
    .slave0_ack_o(slave0_ack_o),
    .slave0_rty_o(slave0_rty_o),
    .slave0_err_o(slave0_err_o),
    .slave0_dat_o(slave0_dat_o), /*[31:0]*/
    
    // bus_sd
    .slave1_selected    (
        {master_adr_early_o, 2'b00} >= 32'h10001000 && {master_adr_early_o, 2'b00} <= 32'h1000100F
    ),
    .slave1_cyc_i       (slave1_cyc_i),
    .slave1_stb_i       (slave1_stb_i),
    .slave1_ack_o       (slave1_ack_o),
    .slave1_rty_o       (slave1_rty_o),
    .slave1_err_o       (slave1_err_o),
    .slave1_dat_o       (slave1_dat_o), /*[31:0]*/
    
    // bus_ssram
    .slave2_selected    (
        ({master_adr_early_o, 2'b00} >= 32'h00000000 && {master_adr_early_o, 2'b00} <= 32'h001FFFFC) ||
        ({master_adr_early_o, 2'b00} >= 32'h10100000 && {master_adr_early_o, 2'b00} <= 32'h101BFFFC) ||
        ({master_adr_early_o, 2'b00} >= 32'h00FC0000 && {master_adr_early_o, 2'b00} <= 32'h00FFFFFC)
    ),
    .slave2_cyc_i       (slave2_cyc_i),
    .slave2_stb_i       (slave2_stb_i),
    .slave2_ack_o       (slave2_ack_o),
    .slave2_rty_o       (slave2_rty_o),
    .slave2_err_o       (slave2_err_o),
    .slave2_dat_o       (slave2_dat_o), /*[31:0]*/
    
    // control_osd
    .slave3_selected    (
        {master_adr_early_o, 2'b00} >= 32'h10000000 && {master_adr_early_o, 2'b00} <= 32'h10000FFF
    ),
    .slave3_cyc_i       (slave3_cyc_i),
    .slave3_stb_i       (slave3_stb_i),
    .slave3_ack_o       (slave3_ack_o),
    .slave3_rty_o       (slave3_rty_o),
    .slave3_err_o       (slave3_err_o),
    .slave3_dat_o       (slave3_dat_o), /*[31:0]*/
    
    // ocs_video: 08C-09B, 100-10B, 0E0-0F7, 120-1BF, 110-11B
    .slave4_selected    ( master_adr_early_o[31:21] == 11'b0000_0000_110 && (
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h08C && {master_adr_early_o[8:2], 2'b00} <= 9'h098 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h100 && {master_adr_early_o[8:2], 2'b00} <= 9'h108 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h0E0 && {master_adr_early_o[8:2], 2'b00} <= 9'h0F4 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h110 && {master_adr_early_o[8:2], 2'b00} <= 9'h118 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h120 && {master_adr_early_o[8:2], 2'b00} <= 9'h1BC ) )
    ),
    .slave4_cyc_i       (slave4_cyc_i),
    .slave4_stb_i       (slave4_stb_i),
    .slave4_ack_o       (slave4_ack_o),
    .slave4_rty_o       (slave4_rty_o),
    .slave4_err_o       (slave4_err_o),
    .slave4_dat_o       (slave4_dat_o), /*[31:0]*/
    
    // ocs_control: 000-007 R, 09C-09F, 010-013 R, 01C-01F R, 028-02B
    .slave5_selected    ( master_adr_early_o[31:21] == 11'b0000_0000_110 && (
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h000 && {master_adr_early_o[8:2], 2'b00} <= 9'h004 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h09C && {master_adr_early_o[8:2], 2'b00} <= 9'h09C ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h010 && {master_adr_early_o[8:2], 2'b00} <= 9'h010 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h01C && {master_adr_early_o[8:2], 2'b00} <= 9'h01C ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h028 && {master_adr_early_o[8:2], 2'b00} <= 9'h028 ) )
    ),
    .slave5_cyc_i       (slave5_cyc_i),
    .slave5_stb_i       (slave5_stb_i),
    .slave5_ack_o       (slave5_ack_o),
    .slave5_rty_o       (slave5_rty_o),
    .slave5_err_o       (slave5_err_o),
    .slave5_dat_o       (slave5_dat_o), /*[31:0]*/
    
    // ocs_blitter: 040-059, 060-067, 070-075 
    .slave6_selected    ( master_adr_early_o[31:21] == 11'b0000_0000_110 && (
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h040 && {master_adr_early_o[8:2], 2'b00} <= 9'h058 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h060 && {master_adr_early_o[8:2], 2'b00} <= 9'h064 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h070 && {master_adr_early_o[8:2], 2'b00} <= 9'h074 ) )
    ),
    .slave6_cyc_i       (slave6_cyc_i),
    .slave6_stb_i       (slave6_stb_i),
    .slave6_ack_o       (slave6_ack_o),
    .slave6_rty_o       (slave6_rty_o),
    .slave6_err_o       (slave6_err_o),
    .slave6_dat_o       (slave6_dat_o), /*[31:0]*/
    
    // ocs_copper: 02C-02F, 080-08B
    .slave7_selected    ( master_adr_early_o[31:21] == 11'b0000_0000_110 && (
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h02C && {master_adr_early_o[8:2], 2'b00} <= 9'h02C ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h080 && {master_adr_early_o[8:2], 2'b00} <= 9'h088 ) )
    ),
    .slave7_cyc_i       (slave7_cyc_i),
    .slave7_stb_i       (slave7_stb_i),
    .slave7_ack_o       (slave7_ack_o),
    .slave7_rty_o       (slave7_rty_o),
    .slave7_err_o       (slave7_err_o),
    .slave7_dat_o       (slave7_dat_o), /*[31:0]*/
    
    // cia-a: 0000_0000_101*_****_**10_****_****_****
    .slave8_selected    (
        master_adr_early_o[31:21] == 11'b0000_0000_101 && master_adr_early_o[13:12] == 2'b10
    ),
    .slave8_cyc_i       (slave8_cyc_i),
    .slave8_stb_i       (slave8_stb_i),
    .slave8_ack_o       (slave8_ack_o),
    .slave8_rty_o       (slave8_rty_o),
    .slave8_err_o       (slave8_err_o),
    .slave8_dat_o       (slave8_dat_o), /*[31:0]*/
    
    // cia-b: 0000_0000_101*_****_**01_****_****_****
    .slave9_selected    (
        master_adr_early_o[31:21] == 11'b0000_0000_101 && master_adr_early_o[13:12] == 2'b01
    ),
    .slave9_cyc_i       (slave9_cyc_i),
    .slave9_stb_i       (slave9_stb_i),
    .slave9_ack_o       (slave9_ack_o),
    .slave9_rty_o       (slave9_rty_o),
    .slave9_err_o       (slave9_err_o),
    .slave9_dat_o       (slave9_dat_o), /*[31:0]*/
    
    // ocs_serial: 018-01B R, 030-033
    .slave10_selected   ( master_adr_early_o[31:21] == 11'b0000_0000_110 && (
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h018 && {master_adr_early_o[8:2], 2'b00} <= 9'h018 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h030 && {master_adr_early_o[8:2], 2'b00} <= 9'h030 ) )
    ),
    .slave10_cyc_i      (slave10_cyc_i),
    .slave10_stb_i      (slave10_stb_i),
    .slave10_ack_o      (slave10_ack_o),
    .slave10_rty_o      (slave10_rty_o),
    .slave10_err_o      (slave10_err_o),
    .slave10_dat_o      (slave10_dat_o), /*[31:0]*/

    // ocs_floppy: 020-027, 07C-07F
    .slave11_selected   ( master_adr_early_o[31:21] == 11'b0000_0000_110 && (
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h020 && {master_adr_early_o[8:2], 2'b00} <= 9'h027 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h07C && {master_adr_early_o[8:2], 2'b00} <= 9'h07F ) )
    ),
    .slave11_cyc_i      (slave11_cyc_i),
    .slave11_stb_i      (slave11_stb_i),
    .slave11_ack_o      (slave11_ack_o),
    .slave11_rty_o      (slave11_rty_o),
    .slave11_err_o      (slave11_err_o),
    .slave11_dat_o      (slave11_dat_o), /*[31:0]*/
    
    // ocs_floppy memory buffer: 0x10004000 - 0x100055FF
    .slave12_selected   (
        {master_adr_early_o[31:2], 2'b00} >= 32'h10004000 && {master_adr_early_o[31:2], 2'b00} <= 32'h100055FF
    ),
    .slave12_cyc_i      (slave12_cyc_i),
    .slave12_stb_i      (slave12_stb_i),
    .slave12_ack_o      (slave12_ack_o),
    .slave12_rty_o      (slave12_rty_o),
    .slave12_err_o      (slave12_err_o),
    .slave12_dat_o      (slave12_dat_o), /*[31:0]*/
    
    // ocs_input: 008-00F R, 014-017 R, 034-037
    .slave13_selected   ( master_adr_early_o[31:21] == 11'b0000_0000_110 && (
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h008 && {master_adr_early_o[8:2], 2'b00} <= 9'h00F ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h014 && {master_adr_early_o[8:2], 2'b00} <= 9'h017 ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h034 && {master_adr_early_o[8:2], 2'b00} <= 9'h037 ) )
    ),
    .slave13_cyc_i      (slave13_cyc_i),
    .slave13_stb_i      (slave13_stb_i),
    .slave13_ack_o      (slave13_ack_o),
    .slave13_rty_o      (slave13_rty_o),
    .slave13_err_o      (slave13_err_o),
    .slave13_dat_o      (slave13_dat_o), /*[31:0]*/
    
    // ocs_audio: 0A0-0AB, 0B0-0BB, 0C0-0CB, 0D0-0DB
    .slave14_selected   ( master_adr_early_o[31:21] == 11'b0000_0000_110 && (
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h0A0 && {master_adr_early_o[8:2], 2'b00} <= 9'h0AB ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h0B0 && {master_adr_early_o[8:2], 2'b00} <= 9'h0BB ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h0C0 && {master_adr_early_o[8:2], 2'b00} <= 9'h0CB ) ||
        ( {master_adr_early_o[8:2], 2'b00} >= 9'h0D0 && {master_adr_early_o[8:2], 2'b00} <= 9'h0DB ) )
    ),
    .slave14_cyc_i      (slave14_cyc_i),
    .slave14_stb_i      (slave14_stb_i),
    .slave14_ack_o      (slave14_ack_o),
    .slave14_rty_o      (slave14_rty_o),
    .slave14_err_o      (slave14_err_o),
    .slave14_dat_o      (slave14_dat_o), /*[31:0]*/
    
    // not used
    .slave15_selected   (
        1'b0
    ),
    .slave15_cyc_i      (slave15_cyc_i),
    .slave15_stb_i      (slave15_stb_i),
    .slave15_ack_o      (slave15_ack_o),
    .slave15_rty_o      (slave15_rty_o),
    .slave15_err_o      (slave15_err_o),
    .slave15_dat_o      (slave15_dat_o), /*[31:0]*/
    
    // Debug signals
    .debug_syscon       (debug_syscon)
);

endmodule

