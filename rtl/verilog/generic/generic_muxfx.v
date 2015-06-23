// Technology independent version of MUXF7 and MUXF8.
//
// This file should not be included while targeting Xilinx so that
// the MUXF7/MUXF8 primitives in the Xilinx simulation/synthesis
// will be used instead.
module MUXF7 (output O, input I0, input I1, input S);
	assign O = (S)? I1 : I0;
endmodule

module MUXF8 (output O, input I0, input I1, input S);
	assign O = (S)? I1 : I0;
endmodule