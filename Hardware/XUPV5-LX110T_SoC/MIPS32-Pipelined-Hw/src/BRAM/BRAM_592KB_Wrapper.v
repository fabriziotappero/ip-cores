`timescale 1ns / 1ps
/*
 * File         : BRAM_592KB_Wrapper.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   6-Jun-2012   GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   Provides access to Block Memory through a 4-way handshaking protocol,
 *   which allows for multi-cycle and variably-timed operations on the
 *   data bus.
 */
module BRAM_592KB_Wrapper(
    input  clock,
    input  reset,
    input         rea,
    input  [3:0]  wea,
    input  [17:0] addra,
    input  [31:0] dina,
    output [31:0] douta,
    output reg       dreadya,
    input         reb,
    input  [3:0]  web,
    input  [17:0] addrb,
    input  [31:0] dinb,
    output [31:0] doutb,
    output reg       dreadyb
    );

    /* Four-Way Memory Handshake Protocol:
          1. Read/Write request goes high.
          2. Ack goes high when data is available.
          3. Read/Write request goes low.
          4. Ack signal goes low.
                  ____
          R/W: __|    |____
                     ____
          Ack: _____|    |____
          
    */


    // Writes require one clock cycle, and reads require 2 or 3 clock cycles (registered output).
    // The following logic controls the Ready signal based on these latencies.
    reg [1:0] delay_A, delay_B;
    
    always @(posedge clock) begin
        delay_A <= (reset | ~rea) ? 2'b00 : ((delay_A == 2'b10) ? delay_A : delay_A + 1);
        delay_B <= (reset | ~reb) ? 2'b00 : ((delay_B == 2'b10) ? delay_B : delay_B + 1);
    end
    
    always @(posedge clock) begin
        dreadya <= (reset) ? 0 : ((wea != 4'b0000) || ((delay_A == 2'b10) && rea)) ? 1 : 0;
        dreadyb <= (reset) ? 0 : ((web != 4'b0000) || ((delay_B == 2'b10) && reb)) ? 1 : 0;
    end

    BRAM_592KB_2R RAM (
        .clka   (clock),    // input clka
        .rsta   (reset),    // input rsta
        .wea    (wea),      // input [3 : 0] wea
        .addra  (addra),    // input [17 : 0] addra
        .dina   (dina),     // input [31 : 0] dina
        .douta  (douta),    // output [31 : 0] douta
        .clkb   (clock),    // input clkb
        .rstb   (reset),    // input rstb
        .web    (web),      // input [3 : 0] web
        .addrb  (addrb),    // input [17 : 0] addrb
        .dinb   (dinb),     // input [31 : 0] dinb
        .doutb  (doutb)     // output [31 : 0] doutb
    );

endmodule

