// LPM Mux Testbench
//

module lpm_mux8_tb;

reg [7:0] 	in0;
reg [7:0] 	in1;
reg [7:0] 	in2;
reg [7:0] 	in3;
reg [7:0] 	in4;
reg [7:0] 	in5;
reg [7:0] 	in6;
reg [7:0] 	in7;
reg [2:0]	s;
wire [7:0]	out;

lpm_mux8 #(
	.WIDTH(8)
) dut (
	.in0(in0),
	.in1(in1),
	.in2(in2),
	.in3(in3),
	.in4(in4),
	.in5(in5),
	.in6(in6),
	.in7(in7),
	.s(s),
	.out(out)
);

initial
begin
	in0 = 10;
	in1 = 20;
	in2 = 30;
	in3 = 40;
	in4 = 50;
	in5 = 60;
	in6 = 70;
	in7 = 80;
	s = 0;
	#10 s = 1;
	#10 s = 2;
	#10 s = 3;
	#10 s = 4;
	#10 s = 5;
	#10 s = 6;
	#10 s = 7;
end

endmodule
