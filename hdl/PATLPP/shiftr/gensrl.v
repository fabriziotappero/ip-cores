// Generic SRL 16 for use with V4/V5/?V6

module gensrl (
	input CLK,
	input D,
	input CE,
	input [3:0] A,
	output Q
);

reg [15:0] data;
assign Q = data[A];

always @(posedge CLK)
begin
	if (CE == 1'b1)
		data <= {data[14:0], D};
end

endmodule
