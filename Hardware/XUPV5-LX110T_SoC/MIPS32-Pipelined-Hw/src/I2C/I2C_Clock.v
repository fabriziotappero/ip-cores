`timescale 1ns / 1ps
/*
 * File         : I2C_Clock.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   21-Jun-2012  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   Generates a 100 kHz clock signal and an indicator which pulses
 *   in the middle of the high and low periods of the clock.
 */
module I2C_Clock(
    input  clock,           // 100 (66) MHz
    input  reset,
    inout  scl,             // A 100 (66) kHz clock
    output scl_tick_90      // A pulse indicating the middle of the +/- scl levels
    );

    reg [7:0] count_4x;
    
    
    always @(posedge clock) begin
        //count_4x <= (reset) ? 8'h00 : (scl) ? count_4x + 1 : count_4x;
        count_4x <= (reset) ? 8'h00 : count_4x + 1; // XXX SIMULATION ONLY
    end

    // A single pulse once every 250 cycles
    wire tick_4x = (count_4x == 8'hFA);
    
    reg [1:0] state;
    always @(posedge clock) begin
        if (reset) begin
            state <= 2'b00;
        end
        else begin
            case (state)
                2'd0 : state <= (tick_4x) ? 2'd1 : 2'd0;
                2'd1 : state <= (tick_4x) ? 2'd2 : 2'd1;
                2'd2 : state <= (tick_4x) ? 2'd3 : 2'd2;
                2'd3 : state <= (tick_4x) ? 2'd0 : 2'd3;
            endcase
        end
    end

    assign scl = ((state == 2'd0) || (state == 2'd1));
    assign scl_tick_90 = tick_4x & ((state == 2'd0) || (state == 2'd2));

endmodule

