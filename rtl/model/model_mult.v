/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

module model_mult(
    input                           clk,
    input signed    [widtha-1:0]    a,
    input signed    [widthb-1:0]    b,
    output          [widthp-1:0]    out
);

//------------------------------------------------------------------------------

parameter widtha = 1;
parameter widthb = 1;
parameter widthp = 2;

//------------------------------------------------------------------------------

reg signed [widtha-1:0] a_reg;
reg signed [widthb-1:0] b_reg;
reg signed [widthp-1:0] out_1;

assign out = out_1;

wire signed [widthp-1:0] mult_out;
assign mult_out = a_reg * b_reg;

always @ (posedge clk)
begin
    a_reg   <= a;
    b_reg   <= b;
    out_1   <= mult_out;
end

//------------------------------------------------------------------------------

endmodule
