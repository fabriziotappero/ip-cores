//============================================================================
// Implementation of the PS/2 keyboard scan-code reader
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
module ps2_keyboard
(
    input wire clk,
    input wire reset,           // Reset (negative logic)
    input wire PS2_CLK,         // PS/2 keyboard clock line
    input wire PS2_DAT,         // PS/2 keyboard data line

    output wire [7:0] scan_code,// Completed keyboard scan code
    output reg scan_code_ready, // Active for 1 clock: scan code is ready
    output reg scan_code_error  // Error receiving keyboard data
);

reg [7:0] clk_filter;
reg ps2_clk_in;

reg clk_edge;
reg [3:0] bit_count;

// Shift register contains all the bits that are read so far; scan_code simply
// mirrors it and becomes valid only when "scan_code_ready" is set
reg [8:0] shiftreg;
assign scan_code = shiftreg[7:0];

// Compute parity on the fly; we only need it after the last bit is stored
wire parity;
assign parity = ^shiftreg[8:0];

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Filter the PS/2 clock signal since it might have a noise (false '1')
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
always @(posedge clk or negedge reset)
begin
    if (!reset) begin
        ps2_clk_in <= 1;
        clk_filter <= 8'b1;
        clk_edge <= 0;
        end
    else begin
        // Filter in a new keyboard clock sample
        clk_filter <= { PS2_CLK, clk_filter[7:1] };
        clk_edge <= 0;

        if (clk_filter==8'b1)
            ps2_clk_in <= 1;
        else if (clk_filter==8'b0) begin
            // Filter clock is low, check for edge
            if (ps2_clk_in==1)
                clk_edge <= 1;
            ps2_clk_in <= 0;
        end
    end
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// State machine to process bits of PS/2 data
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
always @(posedge clk or negedge reset)
begin
    if (!reset) begin
        bit_count <= '0;
        shiftreg <= '0;
        scan_code_ready <= 0;
        scan_code_error <= 0;
        end
    else begin
        scan_code_ready <= 0;
        scan_code_error <= 0;
        // We have a new valid clocked bit from the keyboard
        if (clk_edge==1) begin
            // Start condition, the bit count is 0
            if (bit_count==0 && PS2_DAT==0)
                    bit_count <= bit_count + 4'h1;
            else begin
                // Collecting up to 8 data bits and a parity bit
                if (bit_count < 10) begin
                    bit_count <= bit_count + 4'h1;
                    shiftreg <= { PS2_DAT, shiftreg[8:1] };
                    end
                else
                // Finalize: both the calculated parity and the stop bits should be '1'
                begin
                    bit_count <= '0;
                    scan_code_ready <= { PS2_DAT, parity} == 2'b11;
                    scan_code_error <= { PS2_DAT, parity} != 2'b11;
                end
            end
        end
    end
end

endmodule
