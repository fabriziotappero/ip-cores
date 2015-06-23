// LPM Mux
// Author: Peter Lieber
//

module lpm_mux4
(
	in0,
	in1,
	in2,
	in3,
	s,
	out
);

parameter WIDTH = 8;

input		wire		[WIDTH-1:0]		in0;
input		wire		[WIDTH-1:0]		in1;
input		wire		[WIDTH-1:0]		in2;
input		wire		[WIDTH-1:0]		in3;
input		wire		[1:0]				s;
output	reg 		[WIDTH-1:0] 	out;

always @(in0 or in1 or in2 or in3 or s)
begin
	case (s)
		0: out = in0;
		1: out = in1;
		2: out = in2;
		default: out = in3;
	endcase
end

endmodule
