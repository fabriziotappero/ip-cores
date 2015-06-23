// LPM Mux
// Author: Peter Lieber
//

module lpm_mux8
(
	in0,
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	in7,
	s,
	out
);

parameter WIDTH = 8;

input		wire		[WIDTH-1:0]		in0;
input		wire		[WIDTH-1:0]		in1;
input		wire		[WIDTH-1:0]		in2;
input		wire		[WIDTH-1:0]		in3;
input		wire		[WIDTH-1:0]		in4;
input		wire		[WIDTH-1:0]		in5;
input		wire		[WIDTH-1:0]		in6;
input		wire		[WIDTH-1:0]		in7;
input		wire		[2:0]				s;
output	reg 		[WIDTH-1:0] 	out;

always @(in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7 or s)
begin
	case (s)
		0: out = in0;
		1: out = in1;
		2: out = in2;
		3: out = in3;
		4: out = in4;
		5: out = in5;
		6: out = in6;
		default: out = in7;
	endcase
end

endmodule
