`timescale 1ns / 1ps
/*
 * File         : SRAM.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   4-Apr-2010   GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A simple memory of varying width and depth. Reads are asynchronous,
 *   writes are synchronous. Defaults to 8-bit width and 8-bit depth for
 *   a total of 8-bit * 256 entry or 256 bytes of storage.
 */
module SRAM(clock, wEn, rAddr, wAddr, dIn, dOut);
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 8;
    parameter RAM_DEPTH = 1 << ADDR_WIDTH;
    input clock;
    input wEn;
    input [(ADDR_WIDTH-1):0] rAddr;
    input [(ADDR_WIDTH-1):0] wAddr;
    input [(DATA_WIDTH-1):0] dIn;
    output [(DATA_WIDTH-1):0] dOut;   

    reg [(DATA_WIDTH-1):0] mem [0:(RAM_DEPTH-1)];
    assign dOut = mem[rAddr];
   
    always @(posedge clock) begin
        if (wEn) mem[wAddr] <= dIn;
    end

endmodule

