`timescale 1ns / 1ps
/*
 * File         : uart_clock.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   24-May-2010  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   Takes a 100 MHz clock and generates synchronous pulses for 115200 baud
 *   and 16x 115200 baud (synchronized).
 *
 *   This timing can be adjusted to allow for other baud rates.
 */
module uart_clock(
    input clock,
    output uart_tick,
    output uart_tick_16x
    );

    // 100MHz / (2^13 / 151) == 16 * 115203.857 Hz
    // 100MHz / (2^17 / 151) == 115203.857 Hz
    //  66MHz / (2^14 / 453) == 16 * 115203.857 Hz
    //  66MHz / (2^18 / 453) == 115203.857 Hz
    

    // 66 MHz version
    reg [14:0] accumulator = 15'h0000;
    always @(posedge clock) begin
        accumulator <= accumulator[13:0] + 453;
    end
    assign uart_tick_16x = accumulator[14];

/*
    // 100 MHz version
    reg [13:0] accumulator = 14'h0000;
    always @(posedge clock) begin
        accumulator <= accumulator[12:0] + 151;
    end
    assign uart_tick_16x = accumulator[13];
*/

    //------------------------------
    reg [3:0] uart_16x_count = 4'h0;
    always @(posedge clock) begin
        uart_16x_count <= (uart_tick_16x) ? uart_16x_count + 1 : uart_16x_count;
    end
    assign uart_tick = (uart_tick_16x==1'b1 && (uart_16x_count == 4'b1111));
    
endmodule

