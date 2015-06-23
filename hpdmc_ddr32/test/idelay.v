/*
 * Simplified IDELAY model.
 * Only fixed delay type is implemented and assumed.
 */

`timescale 1ns / 1ps

module IDELAY #(
	parameter IOBDELAY_TYPE = "DEFAULT",
	parameter IOBDELAY_VALUE = 0
) (
	input C,
	input CE,
	input I,
	input INC,
	input RST,
	output reg O
);

always @(I)
	# (IOBDELAY_VALUE*0.078) O = I;

endmodule
