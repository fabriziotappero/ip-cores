/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module soc(
    input               CLOCK_50,
    
    //SDRAM
    output      [12:0]  DRAM_ADDR,
    output      [1:0]   DRAM_BA,
    output              DRAM_CAS_N,
    output              DRAM_CKE,
    output              DRAM_CLK,
    output              DRAM_CS_N,
    inout       [31:0]  DRAM_DQ,
    output      [3:0]   DRAM_DQM,
    output              DRAM_RAS_N,
    output              DRAM_WE_N,
    
    //PS2 KEYBOARD
    inout               PS2_CLK,
    inout               PS2_DAT,
    //PS2 MOUSE
    inout               PS2_CLK2,
    inout               PS2_DAT2,
    
    //KEYS
    input       [3:0]   KEY,

    //SD
    output              SD_CLK,
    inout               SD_CMD,
    inout       [3:0]   SD_DAT,
    input               SD_WP_N,
    
    //VGA
    output              VGA_CLK,
    output              VGA_SYNC_N,
    output              VGA_BLANK_N,
    output              VGA_HS,
    output              VGA_VS,
    
    output      [7:0]   VGA_R,
    output      [7:0]   VGA_G,
    output      [7:0]   VGA_B,
    
    //SOUND
    output              I2C_SCLK,
    inout               I2C_SDAT,
    output              AUD_XCK,
    output              AUD_BCLK,
    output              AUD_DACDAT,
    output              AUD_DACLRCK    
);

//------------------------------------------------------------------------------

assign DRAM_CLK = clk_sys;

//------------------------------------------------------------------------------

wire clk_sys;
wire clk_vga;
wire clk_sound;

wire rst_n;

pll pll_inst(
    .inclk0     (CLOCK_50),
    .c0         (clk_sys),
    .c1         (clk_vga),
    .c2         (clk_sound),
    .locked     (rst_n)
);

//------------------------------------------------------------------------------

wire [7:0] pio_output;

wire ps2_a20_enable;
wire ps2_reset_n;

//------------------------------------------------------------------------------

system u0(
    .clk_sys_clk                       (clk_sys),
    .reset_sys_reset_n                 (rst_n),
    
    .clk_vga_clk                       (clk_vga),
    .reset_vga_reset_n                 (rst_n),
          
    .clk_sound_clk                     (clk_sound),
    .reset_sound_reset_n               (rst_n),
    
    .export_vga_clock                  (VGA_CLK),
    .export_vga_sync_n                 (VGA_SYNC_N),
    .export_vga_blank_n                (VGA_BLANK_N),
    .export_vga_horiz_sync             (VGA_HS),
    .export_vga_vert_sync              (VGA_VS),
    .export_vga_r                      (VGA_R),
    .export_vga_g                      (VGA_G),
    .export_vga_b                      (VGA_B),
    
    .sdram_conduit_end_addr            (DRAM_ADDR),
    .sdram_conduit_end_ba              (DRAM_BA),
    .sdram_conduit_end_cas_n           (DRAM_CAS_N),
    .sdram_conduit_end_cke             (DRAM_CKE),
    .sdram_conduit_end_cs_n            (DRAM_CS_N),
    .sdram_conduit_end_dq              (DRAM_DQ),
    .sdram_conduit_end_dqm             (DRAM_DQM),
    .sdram_conduit_end_ras_n           (DRAM_RAS_N),
    .sdram_conduit_end_we_n            (DRAM_WE_N),
    
    .export_sound_sclk                 (I2C_SCLK),
    .export_sound_sdat                 (I2C_SDAT),
    .export_sound_xclk                 (AUD_XCK),
    .export_sound_bclk                 (AUD_BCLK),
    .export_sound_dat                  (AUD_DACDAT),
    .export_sound_lr                   (AUD_DACLRCK),
    
    .sd_clk_export                     (SD_CLK),
    .sd_dat_export                     (SD_DAT),
    .sd_cmd_export                     (SD_CMD),
    
    .export_ps2_out_port_a20_enable    (ps2_a20_enable),
    .export_ps2_out_port_reset_n       (ps2_reset_n),
    
    .export_ps2_kbclk                  (PS2_CLK),
    .export_ps2_kbdat                  (PS2_DAT),
    .export_ps2_mouseclk               (PS2_CLK2),
    .export_ps2_mousedat               (PS2_DAT2),
    
    .pio_input_export                  ({ 2'd0, ps2_reset_n, ps2_a20_enable, KEY }),
    .reset_only_ao486_reset            (pio_output[0] || ~(ps2_reset_n)),
    .pio_output_export                 (pio_output)
);

endmodule
