//============================================================================
// Implementation of the Sinclair ZX Spectrum ULA
//
// This module contains video support.
//
// Note: There is no reset signal in this VGA design since all relevant
//       counters will reset themselves within one display frame as the
//       pixel clock keeps ticking.
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
module video
(
    input wire clk_pix,         // Input VGA pixel clock of 25.175 MHz

    output wire [3:0] VGA_R,    // Output VGA R component
    output wire [3:0] VGA_G,    // Output VGA G component
    output wire [3:0] VGA_B,    // Output VGA B component
    output reg VGA_HS,          // Output VGA horizontal sync
    output reg VGA_VS,          // Output VGA vertical sync
    output wire vs_nintr,       // Vertical retrace interrupt

    output wire [12:0] vram_address,// Address request to the video RAM
    input wire [7:0] vram_data, // Data read from the video RAM

    input wire [2:0] border     // Border color index value
);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// VGA 640x480 Sync pulses generator
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reg [9:0] vga_hc;               // Horizontal counter
reg [9:0] vga_vc;               // Vertical counter
reg [4:0] frame;                // Frame counter, used for the flash attribute

always @(posedge clk_pix)
begin
    vga_hc <= vga_hc + 10'b1;   // With each pixel clock, advance the horizontal counter
    //---------------------------------------------------------------
    // Horizontal sync and line end timings
    //---------------------------------------------------------------
    case (vga_hc)
        96:     VGA_HS <= 1;
        800: begin
                VGA_HS <= 0;
                vga_hc <= 0;
                vga_vc <= vga_vc + 10'b1;
             end
    endcase
    //---------------------------------------------------------------
    // Vertical sync and display end timings
    //---------------------------------------------------------------
    case (vga_vc)
        2:      VGA_VS <= 1;
        525: begin
                VGA_VS <= 0;
                vga_vc <= 0;
                frame  <= frame + 5'b1;
             end
    endcase
end

// Generate interrupt at around the time of the vertical retrace start
assign vs_nintr = (vga_vc=='0 && vga_hc[9:7]=='0)? '0 : '1;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// VGA active display area 640x480
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire disp_enable;
assign disp_enable = vga_hc>=144 && vga_hc<784 && vga_vc>=35 && vga_vc<515;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Fetch screen data from RAM based on the current video counters
// Spectrum resolution of 256x192 is line-doubled to 512x384 sub-frame
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire screen_en;
assign screen_en = vga_hc>=208 && vga_hc<720 && vga_vc>=83 && vga_vc<467;

reg [7:0] bits_prefetch;        // Line bitmap data prefetch register
reg [7:0] attr_prefetch;        // Attribute data prefetch register

// At the first clock of each new character, prefetch values are latched into these:
reg [7:0] bits;                 // Current line bitmap data register
reg [7:0] attr;                 // Current attribute data register

wire [4:0] pix_x;               // Column 0-31
wire [7:0] pix_y;               // Active display pixel Y coordinate
// We use 16 clocks for 1 byte of display; also prefetch 1 byte (+16)
wire [9:0] xd = vga_hc-10'd192; // =vga_hc-208+16
assign pix_x = xd[8:4];         // Effectively divide by 16
wire [9:0] yd = vga_vc-10'd83;  // Lines are (also) doubled vertically
assign pix_y = yd[8:1];         // Effectively divide by 2

always @(posedge clk_pix)
begin
    case (vga_hc[3:0])
                // Format the address into the bitmap which is a swizzle of coordinate parts
        10:     vram_address <= {pix_y[7:6], pix_y[2:0], pix_y[5:3], pix_x};
        12:     begin
                    bits_prefetch <= vram_data;
                    // Format the address into the attribute map
                    vram_address <= {3'b110, pix_y[7:3], pix_x};
                end
        14:     attr_prefetch <= vram_data;
        // Last tick before a new character: load working bitmap and attribute registers
        15:     begin
                    attr <= attr_prefetch;
                    bits <= bits_prefetch;
                end
    endcase
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Pixel data generator
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire [2:0] ink;                 // INK color (index into the palette)
wire [2:0] paper;               // PAPER color
wire bright;                    // BRIGHT attribute bit
wire flash;                     // FLASH attribute bit
wire pixbit;                    // Current pixel to render
wire inverted;                  // Are the pixel's attributes inverted?

// Output a pixel bit based on the VGA horizontal counter. This could have been
// a shift register but a mux works as well since we are writing out each pixel
// twice (required by this VGA clock rate)
always_comb
begin
    case (vga_hc[3:1])
        0:      pixbit = bits[7];
        1:      pixbit = bits[6];
        2:      pixbit = bits[5];
        3:      pixbit = bits[4];
        4:      pixbit = bits[3];
        5:      pixbit = bits[2];
        6:      pixbit = bits[1];
        7:      pixbit = bits[0];
    endcase
end

assign flash  = attr[7];
assign bright = attr[6];
assign inverted = flash & frame[4];
assign ink    = inverted? attr[5:3] : attr[2:0];
assign paper  = inverted? attr[2:0] : attr[5:3];

// The final color index depends on where we are (active display area, border) and
// whether we are rendering INK or PAPER color, including the brightness bit
assign cindex = screen_en? pixbit? {bright,ink} : {bright,paper} : {1'b0,border[2:0]};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Color lookup table
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire [3:0] cindex;
wire [11:0] pix_rgb;

always_comb
begin
    case (cindex[3:0])
        // Normal color
        0:   pix_rgb = 12'h000; // BLACK
        1:   pix_rgb = 12'h00D; // BLUE
        2:   pix_rgb = 12'hD00; // RED
        3:   pix_rgb = 12'hD0D; // MAGENTA
        4:   pix_rgb = 12'h0D0; // GREEN
        5:   pix_rgb = 12'h0DD; // CYAN
        6:   pix_rgb = 12'hDD0; // YELLOW
        7:   pix_rgb = 12'hDDD; // WHITE
        // "Bright" bit is set
        8:   pix_rgb = 12'h000; // BLACK remains black
        9:   pix_rgb = 12'h00F;
        10:  pix_rgb = 12'hF00;
        11:  pix_rgb = 12'hF0F;
        12:  pix_rgb = 12'h0F0;
        13:  pix_rgb = 12'h0FF;
        14:  pix_rgb = 12'hFF0;
        15:  pix_rgb = 12'hFFF;
    endcase
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// VGA RGB output drivers
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
assign VGA_R[3:0] = disp_enable? pix_rgb[11:8] : '0;
assign VGA_G[3:0] = disp_enable? pix_rgb[7:4]  : '0;
assign VGA_B[3:0] = disp_enable? pix_rgb[3:0]  : '0;

endmodule
