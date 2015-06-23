/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

/* Generated an interrupt every 500000 cycles.
 * If the clock is 50 MHz, the interrupt will be at a frequency of 100 Hz.
 * Any write acknowledges the interrupt.
 */

module simple_clock(
        input           clk,
        input           rst_n,
        
        output reg      irq,
        
        input           avs_write,
        input [31:0]    avs_writedata
);

reg [18:0] counter;
always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)               counter <= 19'd0;
        else if(counter == 19'd499999)  counter <= 19'd0;
        else                            counter <= counter + 13'd1;
end

always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)               irq <= 1'd0;
        else if(counter == 19'd499999)  irq <= 1'd1;
        else if(avs_write)              irq <= 1'd0;
end

endmodule
