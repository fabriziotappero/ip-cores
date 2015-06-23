// ALU for PATLPP

module alunit
(
	input				[15:0]	op0,
	input				[15:0]	op1,
	input				[1:0]		op,
	output	reg	[15:0]	res
);

always @(op0 or op1 or op)
begin
	case (op)
		0: res <= op0 + op1;
		1: res <= op0 - op1;
		2: res <= op0 & op1;
		3: res <= op0 | op1;
	endcase
end

endmodule
