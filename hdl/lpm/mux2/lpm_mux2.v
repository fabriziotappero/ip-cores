// LPM Mux
// Author: Peter Lieber
//

module lpm_mux2
(
	in0,
	in1,
	s,
	out
);

parameter WIDTH = 8;

input		wire		[WIDTH-1:0]		in0;
input		wire		[WIDTH-1:0]		in1;
input		wire							s;
output	reg 		[WIDTH-1:0] 	out;

always @(in0 or in1 or s)
begin
	case (s)
		0: out = in0;
		default: out = in1;
	endcase
end

endmodule
