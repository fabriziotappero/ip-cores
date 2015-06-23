//============================================================================
// Test the implementation of the Sinclair ZX Spectrum ULA
//
//  Copyright (C) 2014  Goran Devic
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================
module test_ula
(
    input wire CLOCK_50,        // Input clock 50 MHz
    input wire CLOCK_27,        // Input clock 27 MHz
    input wire KEY0,            // Button 0 is reset

    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B,
    output reg VGA_HS,
    output reg VGA_VS,

    output wire [21:0] FL_ADDR,
    input wire [7:0] FL_DQ,
    output wire FL_CE_N,
    output wire FL_OE_N,
    output wire FL_RST_N,
    output wire FL_WE_N,

    input wire PS2_CLK,
    input wire PS2_DAT,
    output wire UART_TXD,

    output wire [6:0] GPIO_0,   // Scope test points
    input wire SW0,
    input wire SW1,
    input wire SW2
);
`default_nettype none

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Instantiate PLL and clocks block
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire clk_pix;                   // VGA pixel clock (25.175 MHz)
wire clk_ula;                   // ULA master clock (14 MHz)
pll pll_( .inclk0(CLOCK_27), .c0(clk_pix), .c1(clk_ula) );

wire clk_cpu;                   // Clocks generates CPU clocks of 3.5 MHz
clocks clocks_( .* );

// Various scope test points, connect as needed:
//assign GPIO_0[0] = CLOCK_27;
//assign GPIO_0[1] = clk_pix;
//assign GPIO_0[2] = clk_ula;
//assign GPIO_0[3] = clk_cpu;
assign GPIO_0[4] = VGA_VS;
assign GPIO_0[5] = VGA_HS;
assign GPIO_0[6] = VGA_B[0];

assign GPIO_0[0] = PS2_CLK;
assign GPIO_0[1] = PS2_DAT;
assign GPIO_0[2] = UART_TXD;
assign GPIO_0[3] = vs_nintr;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Instantiate RAM that contains a sample screen image
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reg [12:0] vram_address;
reg [7:0] vram_data;
ram8 ram8_( .address(vram_address), .clock(clk_pix), .data(0), .wren(0), .q(vram_data));

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// State register containing the border color index
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reg [7:0] state;

// Testing: assign the border color index based on the board switches
wire [2:0] border;              // Border color index value
assign border = { SW2, SW1, SW0 };

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Instantiate ULA's video subsystem
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire vs_nintr;                  // Vertical retrace interrupt

video video_( .*, .vram_address(vram_address), .vram_data(vram_data) );

// Use flash interface instead of the internal RAM
assign FL_CE_N = 0;
assign FL_OE_N = 0;
assign FL_RST_N = KEY0;
assign FL_WE_N = 1;
assign FL_ADDR[21:13] = 'b10;
//video video_( .*, .vram_address(FL_ADDR[12:0]), .vram_data(FL_DQ) );

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Instantiate keyboard support
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire [7:0] scan_code;
wire scan_code_ready;
wire scan_code_error;

ps2_keyboard ps2_keyboard_( .*, .clk(CLOCK_50), .reset(KEY0) );

reg [15:0] A = 16'hFEFE;
wire [4:0] key_row;
zx_keyboard zx_keyboard_( .*, .clk(CLOCK_50), .reset(KEY0)  );

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Add UART so we can echo keyboard through the serial port out
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire busy_tx;
uart_core uart_core_( .*, .reset(!KEY0), .clk(CLOCK_50), .uart_tx(UART_TXD), .data_in(scan_code), .data_in_wr(scan_code_ready) );

endmodule
