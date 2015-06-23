// LPM Mux Testbench
//

module lpm_mux2_tb;

reg [7:0] 	in0;
reg [7:0] 	in1;
reg			s;
wire [7:0]	out;

lpm_mux2 #(
	.WIDTH(8)
) dut (
	.in0(in0),
	.in1(in1),
	.s(s),
	.out(out)
);

initial
begin
	in0 = 10;
	in1 = 20;
	s = 0;
	#10 s = 1;
	#10 s = 0;
end

endmodule
