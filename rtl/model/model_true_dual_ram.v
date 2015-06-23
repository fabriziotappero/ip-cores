/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module model_true_dual_ram(
    input                       clk,
    
    input       [widthad-1:0]   address_a,
    input                       wren_a,
    input       [width-1:0]     data_a,
    output reg  [width-1:0]     q_a,
    
    input       [widthad-1:0]   address_b,
    input                       wren_b,
    input       [width-1:0]     data_b,
    output reg  [width-1:0]     q_b
); /* verilator public_module */

parameter width     = 1;
parameter widthad   = 1;

reg [width-1:0] mem [(2**widthad)-1:0];

always @(posedge clk) begin
    if(wren_a) mem[address_a] <= data_a;
    
    q_a <= mem[address_a];
end

always @(posedge clk) begin
    if(wren_b) mem[address_b] <= data_b;
    
    q_b <= mem[address_b];
end

endmodule
